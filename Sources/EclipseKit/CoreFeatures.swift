public struct CoreFeatures: OptionSet, Sendable {
	public let rawValue: UInt8

	public init(rawValue: UInt8) {
		self.rawValue = rawValue
	}

	public static let saving: Self        = .init(rawValue: 1 << 1)
	public static let cheats: Self        = .init(rawValue: 1 << 2)
	public static let saveStates: Self    = .init(rawValue: 1 << 3)
	public static let softResetting: Self = .init(rawValue: 1 << 4)
	public static let hardResetting: Self = .init(rawValue: 1 << 5)
}
