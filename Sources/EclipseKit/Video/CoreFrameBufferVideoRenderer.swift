#if canImport(Metal)
import Metal
import CoreImage
import OSLog
import QuartzCore

private extension Logger {
	static let frameBufferRenderer = Logger(
		subsystem: Bundle.module.bundleIdentifier ?? "dev.magnetar.eclipseemu.kit",
		category: "frameBufferRenderer"
	)
}

public enum FrameBufferRendererError: Error {
	case makeTextureBuffer
	case makeShaderLibrary
	case makePipelineState(any Error)
	case makeFullscreenTexture
	case makeSamplerState
}

@safe
public final class CoreFrameBufferVideoRenderer: CoreVideoRendererProtocol {
	let context: CoreSharedRenderingContext

	nonisolated let width: Int
	nonisolated let height: Int
	nonisolated let pixelFormat: MTLPixelFormat
	nonisolated let bytesPerRow: Int
	nonisolated let bufferSize: Int

	@safe
	private nonisolated(unsafe) let buffer: UnsafeMutableBufferPointer<UInt8>
	private let isBufferOwned: Bool

	private let textureBuffer: any MTLBuffer
	private let fullscreenTexture: any MTLTexture
	private let pipelineState: any MTLRenderPipelineState
	private let samplerState: any MTLSamplerState

	public init(
		core: inout some CoreProtocol,
		for format: consuming CoreVideoDescriptor,
		with sharedContext: CoreSharedRenderingContext,
		isolation: isolated (any Actor)? = #isolation
	) async throws(FrameBufferRendererError) {
		let width = Int(format.width)
		let height = Int(format.width)
		let pixelFormat = format.pixelFormat
		let metalPixelFormat = pixelFormat.metalFormat

		let bytesPerRow = Int(pixelFormat.bytesPerPixel) * width
		let bufferSize = bytesPerRow * height

		guard let shaderLibrary = await sharedContext.shaderLibrary() else {
			throw .makeShaderLibrary
		}

		let vertexShader = shaderLibrary.makeFunction(name: "framebuffer_vertex_main")
		let fragmentShader = shaderLibrary.makeFunction(name: "framebuffer_fragment_main")

		let pipelineDescriptor = MTLRenderPipelineDescriptor()
		pipelineDescriptor.vertexFunction = vertexShader
		pipelineDescriptor.fragmentFunction = fragmentShader
		pipelineDescriptor.colorAttachments[0].pixelFormat = metalPixelFormat

		let pipelineState: any MTLRenderPipelineState
		do {
			pipelineState = try await sharedContext.makePipelineState(descriptor: pipelineDescriptor)
		} catch {
			throw .makePipelineState(error)
		}

		let samplerDescriptor = MTLSamplerDescriptor()
		samplerDescriptor.sAddressMode = .repeat
		samplerDescriptor.tAddressMode = .repeat
		samplerDescriptor.minFilter = .nearest
		samplerDescriptor.magFilter = .linear
		samplerDescriptor.mipFilter = .linear

		guard let samplerState = await sharedContext.makeSamplerState(descriptor: samplerDescriptor) else {
			throw .makeSamplerState
		}

		let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
			pixelFormat: metalPixelFormat,
			width: width,
			height: height,
			mipmapped: false
		)
		textureDescriptor.storageMode = .private
		textureDescriptor.usage = [.shaderRead, .shaderWrite]
		guard
			let fullscreenTexture = await sharedContext.makeTexture(descriptor: textureDescriptor)?.inner
		else {
			throw .makeFullscreenTexture
		}

		guard
			let textureBuffer = await sharedContext.allocate(length: bufferSize, options: .storageModeShared)?.inner
		else {
			throw .makeTextureBuffer
		}

		self.context = sharedContext

		self.width = width
		self.height = height
		self.pixelFormat = metalPixelFormat
		self.bufferSize = bufferSize
		self.bytesPerRow = bytesPerRow

		self.textureBuffer = textureBuffer
		self.fullscreenTexture = fullscreenTexture
		self.pipelineState = pipelineState
		self.samplerState = samplerState

		switch format.frameBuffer {
		case .none: preconditionFailure("invalid frame buffer format")
		case .assignable:
			self.isBufferOwned = true
			self.buffer = UnsafeMutableBufferPointer.allocate(capacity: bufferSize)
			unsafe core.setFrameBuffer(to: self.buffer)
		case .existing(let pointer):
			self.isBufferOwned = false
			self.buffer = unsafe pointer
		}
	}

	deinit {
		if isBufferOwned {
			unsafe buffer.deallocate()
		}
	}

	private func prepare(with commandBuffer: any MTLCommandBuffer, texture: any MTLTexture) {
		guard let pointer = buffer.baseAddress else { return }

		_onFastPath()

		switch texture.storageMode {
		case .private:
			unsafe textureBuffer
				.contents()
				.copyMemory(from: UnsafeRawPointer(pointer), byteCount: buffer.count)
			if let encoder = commandBuffer.makeBlitCommandEncoder() {
				encoder.copy(
					from: textureBuffer,
					sourceOffset: 0,
					sourceBytesPerRow: bytesPerRow,
					sourceBytesPerImage: textureBuffer.length,
					sourceSize: MTLSize(width: width, height: height, depth: 1),
					to: texture,
					destinationSlice: 0,
					destinationLevel: 0,
					destinationOrigin: .init()
				)
				encoder.endEncoding()
			}
		default:
			unsafe texture.replace(
				region: MTLRegionMake2D(0, 0, width, height),
				mipmapLevel: 0,
				withBytes: pointer,
				bytesPerRow: bytesPerRow
			)
		}
	}

	public func render(
		targetTime: Double,
		drawable: CoreSharedRenderingContext.Drawable,
		outputTexture: CoreSharedRenderingContext.Texture
	) {
		guard let commandBuffer = context.makeCommandBuffer() else {
			Logger.frameBufferRenderer.warning("framebuffer renderer - failed to make command buffer")
			return
		}

		prepare(with: commandBuffer, texture: fullscreenTexture)

		let renderPassDescriptor = MTLRenderPassDescriptor()
		renderPassDescriptor.colorAttachments[0].texture = outputTexture
		renderPassDescriptor.colorAttachments[0].loadAction = .clear
		renderPassDescriptor.colorAttachments[0].clearColor = .init(red: 0, green: 0, blue: 0, alpha: 1.0)

		guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
			Logger.frameBufferRenderer.warning("framebuffer renderer - failed to create encoder")
			return
		}

		encoder.setRenderPipelineState(pipelineState)

		encoder.setFragmentTexture(fullscreenTexture, index: 0)
		encoder.setFragmentSamplerState(samplerState, index: 0)

		encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
		encoder.endEncoding()

//		commandBuffer.addCompletedHandler { _ in
//			CATransaction.begin()
//			CATransaction.setDisableActions(true)
//			CATransaction.commit()
//		}

		commandBuffer.present(drawable)
		commandBuffer.commit()
	}

	public func screenshot(colorspace: CoreSharedRenderingContext.ColorSpace) -> CoreSharedRenderingContext.Image? {
		guard let image = CIImage(
			mtlTexture: fullscreenTexture,
			options: [.nearestSampling: true, .colorSpace: colorspace]
		) else { return nil }

		return image
			.transformed(by: .identity.scaledBy(x: 1, y: -1)
				.translatedBy(x: 0, y: image.extent.size.height))
	}
}
#else
#error("CoreFrameBufferVideoRenderer has not been implemented.")
#endif
