@safe
public struct CoreVideoDescriptor: ~Copyable {
	public let width: UInt16
	public let height: UInt16
	public let pixelFormat: Self.PixelFormat
	public let frameBuffer: Self.FrameBufferMode

	public init(width: UInt16, height: UInt16, pixelFormat: Self.PixelFormat, frameBuffer: Self.FrameBufferMode) {
		self.width = width
		self.height = height
		self.pixelFormat = pixelFormat
		self.frameBuffer = frameBuffer
	}

	@safe public enum FrameBufferMode {
		case none
		case assignable
		@unsafe
		case existing(UnsafeMutableBufferPointer<UInt8>)
	}

	public enum PixelFormat: UInt8 {
		case bgra8Unorm
		case rgba8Unorm
		case bgr565Unorm
	}
}

#if canImport(Metal)
import Metal

public extension CoreVideoDescriptor.PixelFormat {
	var metalFormat: MTLPixelFormat {
		switch self {
		case .bgra8Unorm: .bgra8Unorm
		case .rgba8Unorm: .rgba8Unorm
		case .bgr565Unorm: .b5g6r5Unorm
		}
	}
}
#endif

public extension CoreVideoDescriptor.PixelFormat {
	var bytesPerPixel: UInt8 {
		switch self {
		case .rgba8Unorm, .bgra8Unorm: 4
		case .bgr565Unorm: 2
		}
	}
}
