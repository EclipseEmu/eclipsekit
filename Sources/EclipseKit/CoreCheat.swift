public struct CoreCheat: Sendable, Hashable {
	/// The ID of the cheat format
	public let format: String
	/// The code to use.
	public let code: String

	public init(format: String, code: String) {
		self.format = format
		self.code = code
	}
}

/// A declaration of a cheat format.
public struct CoreCheatFormat: Sendable, Identifiable {
	/// A unique ID for this cheat format
	public let id: String
	/// The user-shown name of this cheat format.
	public let name: String
	/// Which characters are allowed for this set.
	public let charset: Self.CharacterSet
	/// A string of characters, where "x" is used as a placeholder for the cheat code: i.e. "xxxxxx xxxx".
	public let pattern: String

	public enum CharacterSet: UInt8, Sendable {
		case hexadecimal = 0
	}

	public init(id: String, name: String, charset: Self.CharacterSet, pattern: String) {
		self.id = id
		self.name = name
		self.charset = charset
		self.pattern = pattern
	}
}

