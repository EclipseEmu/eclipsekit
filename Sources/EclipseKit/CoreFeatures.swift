/// A set of features this core supports.
public struct CoreFeatures: OptionSet, Sendable {
	public let rawValue: UInt8

	public init(rawValue: UInt8) {
		self.rawValue = rawValue
	}

	/// This core supports saving.
	public static let saving: Self        = .init(rawValue: 1 << 1)
	/// This core supports cheats.
	public static let cheats: Self        = .init(rawValue: 1 << 2)
	/// This core supports save states.
	public static let saveStates: Self    = .init(rawValue: 1 << 3)
	/// This core supports soft resetting.
	public static let softResetting: Self = .init(rawValue: 1 << 4)
	/// This core supports hard resetting.
	public static let hardResetting: Self = .init(rawValue: 1 << 5)
}
