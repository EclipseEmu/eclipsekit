#if canImport(MetalKit)
import MetalKit

public enum CoreMetalContextError: Error {
	case getDevice
	case makeCommandQueue
	case noShaderSource
}

@safe @MainActor
public struct CoreSharedRenderingContext {
	public let device: any MTLDevice
	public nonisolated let commandQueue: any MTLCommandQueue

	public typealias Drawable = any MTLDrawable
	public typealias Texture = any MTLTexture
	public typealias Image = CIImage
	public typealias ColorSpace = CGColorSpace

	public init() throws(CoreMetalContextError) {
		guard let device = MTLCreateSystemDefaultDevice() else {
			throw .getDevice
		}

		guard let commandQueue = device.makeCommandQueue() else {
			throw .makeCommandQueue
		}

		self.device = device
		self.commandQueue = commandQueue
	}

	public func shaderLibrary() -> sending (any MTLLibrary)? {
		guard let shader = try? device.makeDefaultLibrary(bundle: Bundle.module) else {
			return nil
		}
		return shader
	}

	@inlinable
	public func shader(url path: URL) throws -> sending any MTLLibrary {
		return try device.makeLibrary(URL: path)
	}

	@inlinable
	public func shader(source rawSource: String) throws -> sending any MTLLibrary {
		return try device.makeLibrary(source: rawSource, options: nil)
	}

	@inlinable
	public func makePipelineState(descriptor: MTLRenderPipelineDescriptor) throws -> sending any MTLRenderPipelineState {
		try device.makeRenderPipelineState(descriptor: descriptor)
	}

	@inlinable
	public func makeSamplerState(descriptor: MTLSamplerDescriptor) -> sending (any MTLSamplerState)? {
		guard let samplerState = device.makeSamplerState(descriptor: descriptor) else {
			return nil
		}
		return samplerState
	}

	@inlinable
	public func makeTexture(descriptor: MTLTextureDescriptor) -> sending UnsafeSend<any MTLTexture>? {
		guard let texture = device.makeTexture(descriptor: descriptor) else {
			return nil
		}
		return unsafe UnsafeSend(texture)
	}

	@inlinable
	public func allocate(bytes: UnsafeRawPointer, length: Int, options: MTLResourceOptions) -> sending UnsafeSend<any MTLBuffer>? {
		guard let buffer = unsafe device.makeBuffer(bytes: bytes, length: length, options: options) else {
			return nil
		}
		return unsafe UnsafeSend(buffer)
	}

	@inlinable
	public func allocate(length: Int, options: MTLResourceOptions) -> sending UnsafeSend<any MTLBuffer>? {
		guard let buffer = device.makeBuffer(length: length, options: .storageModeShared) else {
			return nil
		}
		return unsafe UnsafeSend(buffer)
	}

	@inlinable
	public nonisolated func makeCommandBuffer() -> (any MTLCommandBuffer)? {
		guard let buffer = self.commandQueue.makeCommandBuffer() else {
			return nil
		}
		return buffer
	}
}
#else
#error("CoreSharedRenderingContext is not available for this platform.")
#endif
