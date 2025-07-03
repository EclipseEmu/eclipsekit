public struct CoreAudioDescriptor {
	public let sampleRate: Double
	public let sampleFormat: SampleFormat
	public let channelCount: UInt8
	public let interlaced: Bool

	public init(sampleRate: Double, sampleFormat: SampleFormat, channelCount: UInt8, interlaced: Bool = true) {
		self.sampleRate = sampleRate
		self.sampleFormat = sampleFormat
		self.channelCount = channelCount
		self.interlaced = interlaced
	}

	public enum SampleFormat: UInt8 {
		case int16 = 0
		case int32 = 1
		case float32 = 2
		case float64 = 3
	}
}

public extension CoreAudioDescriptor.SampleFormat {
	var bytesPerSample: UInt8 {
		switch self {
		case .int16: 2
		case .int32: 4
		case .float32: 4
		case .float64: 8
		}
	}
}
