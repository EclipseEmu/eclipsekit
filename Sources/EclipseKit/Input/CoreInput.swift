public struct CoreInput: RawRepresentable, OptionSet, Sendable, Codable, Hashable {
	public typealias RawValue = UInt32

	public let rawValue: UInt32

	public init(rawValue: UInt32) {
		self.rawValue = rawValue
	}

	public static let faceButtonUp                 = Self(rawValue: 1 << 0)
	public static let faceButtonDown               = Self(rawValue: 1 << 1)
	public static let faceButtonLeft               = Self(rawValue: 1 << 2)
	public static let faceButtonRight              = Self(rawValue: 1 << 3)
	public static let leftShoulder                 = Self(rawValue: 1 << 4)
	public static let leftTrigger                  = Self(rawValue: 1 << 5)
	public static let rightShoulder                = Self(rawValue: 1 << 6)
	public static let rightTrigger                 = Self(rawValue: 1 << 7)
	public static let start                        = Self(rawValue: 1 << 8)
	public static let select                       = Self(rawValue: 1 << 9)
	public static let dpad                         = Self(rawValue: 1 << 10)
	public static let leftJoystick                 = Self(rawValue: 1 << 11)
	public static let leftJoystickPress            = Self(rawValue: 1 << 12)
	public static let rightJoystick                = Self(rawValue: 1 << 13)
	public static let rightJoystickPress           = Self(rawValue: 1 << 14)
	public static let touchSurface                 = Self(rawValue: 1 << 15)
	public static let touchPress                   = Self(rawValue: 1 << 16)
	public static let sleep                        = Self(rawValue: 1 << 17)
}

public struct CoreInputDelta: Sendable {
	public let input: CoreInput
	/// - For buttons: X will be 1.0 or 0.0 to indicate if they are pressed, with the Y being an analog value.
	/// - For axes: X and Y will be the analog values. Partials are allowed, which will use ``CoreInputDelta.IGNORE_VALUE`` for one of the values.
	public let value: SIMD2<Float32>
	/// The time in seconds
	public let timestamp: Double

	public static let IGNORE_VALUE = Float32.nan

	public static let zero: Self = .init(input: [], x: 0, y: 0, timestamp: 0)

	public init(input: CoreInput, x: Float32, y: Float32, timestamp: Double) {
		self.input = input
		self.value = .init(x, y)
		self.timestamp = timestamp
	}

	public init(input: CoreInput, pressed: Bool, value: Float32 = 0.0, timestamp: Double) {
		self.input = input
		self.value = .init(pressed ? 1.0 : 0.0, value)
		self.timestamp = timestamp
	}

	@inlinable
	public var isPressed: Bool {
		value.x != 0.0
	}

	@inlinable
	public var useX: Bool {
		value.x != Self.IGNORE_VALUE
	}

	@inlinable
	public var useY: Bool {
		value.y != Self.IGNORE_VALUE
	}

	@inlinable
	public var isUp: Bool {
		value.y > 0
	}

	@inlinable
	public var isDown: Bool {
		value.y < 0
	}

	@inlinable
	public var isLeft: Bool {
		value.x < 0
	}

	@inlinable
	public var isRight: Bool {
		value.x > 0
	}
}
