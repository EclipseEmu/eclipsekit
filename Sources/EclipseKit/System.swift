public enum System: UInt16, RawRepresentable, Sendable, CaseIterable {
	case unknown
	case gb
	case gbc
	case gba
	case nes
	case snes
}

public extension System {
	var screenAspectRatio: Float {
		switch self {
		case .gb, .gbc: 160 / 144
		case .gba: 3 / 2
		case .nes: 256 / 240
		case .snes: 8 / 7
		case .unknown: 1 / 1
		}
	}
}
