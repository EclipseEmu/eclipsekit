import Foundation.NSData
import Foundation.NSUUID

public struct CoreSettingsFile: Hashable, Sendable, Codable {
	public let id: UInt
	public let fileExtension: String?

	public init(id: UInt, fileExtension: String?) {
		self.id = id
		self.fileExtension = fileExtension
	}
}

public protocol CoreSettings: Sendable, Codable {
	@MainActor
	static var descriptor: CoreSettingsDescriptor<Self> { get }

	/// Initializes the settings to their default values.
	/// If a field is required, it must be checked at runtime or have a default value.
	init()

	static func migrate(_ data: Data, from oldVersion: UInt) -> Self
}

@MainActor
public struct CoreSettingsDescriptor<Settings: CoreSettings> {
	public let version: UInt
	public let sections: [Self.Section]

	public init(version: UInt, sections: [Self.Section]) {
		self.version = version
		self.sections = sections
	}

	public struct Section: Identifiable {
		public let id: UInt
		public let title: String
		public let settings: [CoreSettingsDescriptor<Settings>.Setting]

		public init(id: UInt, title: String, settings: [CoreSettingsDescriptor<Settings>.Setting]) {
			self.id = id
			self.title = title
			self.settings = settings
		}
	}

	@MainActor
	public enum Setting: @MainActor Identifiable {
		case bool(CoreBoolSettingDescriptor<Settings>)
		case file(CoreFileSettingDescriptor<Settings>)
		case radio(CoreRadioSettingDescriptor<Settings>)

		public var id: UInt {
			switch self {
			case .bool(let inner): inner.id
			case .file(let inner): inner.id
			case .radio(let inner): inner.id
			}
		}
	}
}

@MainActor
public struct CoreBoolSettingDescriptor<Settings: CoreSettings>: Identifiable {
	public let id: UInt
	public let target: WritableKeyPath<Settings, Bool>
	public let displayName: String

	public init(id: UInt, target: WritableKeyPath<Settings, Bool>, displayName: String) {
		self.id = id
		self.target = target
		self.displayName = displayName
	}
}

@MainActor
public struct CoreFileSettingDescriptor<Settings: CoreSettings>: Identifiable {
	public let id: UInt
	public let target: WritableKeyPath<Settings, CoreSettingsFile?>
	public let displayName: String
	public let required: Bool
	public let type: FileType
	public let sha1: Set<String>

	public init(id: UInt, target: WritableKeyPath<Settings, CoreSettingsFile?>, displayName: String, required: Bool, type: FileType, sha1: Set<String> = []) {
		self.id = id
		self.target = target
		self.displayName = displayName
		self.required = required
		self.type = type
		self.sha1 = sha1
	}

	public enum FileType {
		case binary
	}
}

@MainActor
public struct CoreRadioSettingDescriptor<Settings: CoreSettings>: Identifiable {
	public let id: UInt
	public let target: WritableKeyPath<Settings, Int>
	public let displayName: String
	public let options: [Self.Option]

	public init(id: UInt, target: WritableKeyPath<Settings, Int>, displayName: String, options: [Self.Option]) {
		self.id = id
		self.target = target
		self.displayName = displayName
		self.options = options
	}

	@MainActor
	public struct Option: Identifiable {
		public let id: Int
		public let displayName: String

		public init(id: Int, displayName: String) {
			self.id = id
			self.displayName = displayName
		}
	}
}
