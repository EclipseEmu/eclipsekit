import Foundation.NSURL

/// A type determining the behavior of player connections.
public enum CorePlayerConnectionBehavior: UInt8 {
	/// Players will connect to any of the available ports, determined by ``CoreProtocol.maxPlayers``. When a player disconnects, other players will remain in-place.
	case ports = 0
	/// Players will connect in incrementing order. If a player disconnects, other players will be shifted to fill the empty space.
	/// (i.e. player 2 disconnects, players 3 and 4 become players 2 and 3).
	case linear = 1
}

public protocol CoreProtocol: ~Copyable, SendableMetatype {
	associatedtype VideoRenderer: CoreVideoRendererProtocol
	associatedtype Settings: CoreSettings
	associatedtype Failure: Error = any Error

	/// A unique identifier for this core, i.e. a bundle ID.
	static var id: String { get }
	/// The display name for this core.
	static var name: String { get }
	/// A link to the source code.
	static var sourceCodeRepository: URL { get }
	/// The name of the developer(s) for this core.
	static var developer: String { get }
	/// The current version of this core.
	static var version: String { get }

	/// A list of systems the core supports.
	static var systems: Set<System> { get }
	
	/// The features the core supports for the given system.
	static func features(for system: System) -> CoreFeatures

	/// The cheat formats the core uses for the given system.
	static func cheatFormats(for system: System) -> [CoreCheatFormat]

	/// A link to the core's runner, offering the ability to write audio samples and notify when the game has saved.
	var bridge: any CoreBridgeProtocol { get set }

	/// How players connect to the system.
	/// - NOTE: This is only accessed before the game has been started.
	nonisolated var playerConnectionBehavior: CorePlayerConnectionBehavior { get }

	/// The number of players the core supports.
	/// - NOTE: This is only accessed before the game has been started.
	nonisolated var maxPlayers: UInt8 { get }

	/// The desired frame rate of this game (i.e. 30, 60, 120).
	/// - NOTE: This is accessed after the game has been started.
	nonisolated var desiredFrameRate: Double { get }

	/// Gets the video format, including width, height, pixel format, and frame buffer.
	func getVideoDescriptor() -> CoreVideoDescriptor

	/// Gets the audio format, including sample format, sample rate, whether its interleaved, and the
	/// channel count.
	func getAudioDescriptor() -> CoreAudioDescriptor

	/// Called if you have set the frame buffer in your video descriptor
	/// to ``CoreVideoDescriptor.FrameBufferMode.assignable``
	mutating func setFrameBuffer(to pointer: UnsafeMutableBufferPointer<UInt8>)

	/// Sets up things necessary for general core usage. No game is targetted yet.
	/// - Parameters:
	///   - system: The system to setup for.
	///   - settings: The settings this core specifies.
	///   - bridge: A bridge to communicate with the core's runner.
	init(
		system: System,
		settings: consuming CoreResolvedSettings<Self.Settings>,
		bridge: consuming any CoreBridgeProtocol
	) throws(Failure)

	/// Called to load the game, do any game-related setup here.
	/// - Parameters:
	///   - romPath: The path to the ROM file.
	///   - savePath: The path to the game's save file, which may not exist. Cores should write to this path.
	mutating func start(romPath: URL, savePath: URL) throws(Self.Failure)

	/// Called before the game is going to be unloaded, do game-related cleanup work here.
	mutating func stop()

	/// The game will be resumed from a paused state.
	mutating func play()

	/// The game will be temporarily paused.
	mutating func pause()

	/// The game will do a soft reset.
	mutating func reset()

	/// The core should write the save to disk.
	///
	/// - Parameter path: The path to write the save file to.
	///	- Returns: If the save could be properly written.
	func save(to path: URL) async throws(Self.Failure)

	/// Attempts to save a state to the given path.
	/// - Parameter path: The path the save state is written to.
	func saveState(to path: URL) throws(Self.Failure)

	/// Attempts to load a state from the given path.
	/// - Parameter path: The path the save state is loaded from.
	mutating func loadState(from path: URL) throws(Self.Failure)

	/// Perform enough emulation to produce a single video frame.
	/// - Parameters timestamp: The timestamp of when this frame is being emulated.
	/// - Parameters willRender: If this frame will be rendered.
	mutating func step(timestamp: CFAbsoluteTime, willRender: Bool)

	/// Notifies the core that a player has connected.
	/// - Parameter port: The index of the port the player connected to.
	mutating func playerConnected(to port: UInt8)

	/// Notifies the core that a player has disconnected.
	/// - Parameter port: The index of the port the player disconnected from. If the core uses the `linear` ``CorePlayerConnectionKind``, then this will always be the last player.
	mutating func playerDisconnected(from port: UInt8)

	/// Applies the ``CoreInputDelta`` for the given player.
	/// - Parameter delta: A change in inputs.
	/// - Parameter player: The player these changes are for.
	mutating func writeInput(_ delta: CoreInputDelta, for player: UInt8)

	/// Adds the given core and sets its state.
	/// - Parameter cheat: Information about the cheat.
	/// - Parameter enabled: Whether this cheat should be enabled or not.
	mutating func setCheat(cheat: CoreCheat, enabled: Bool) -> Void

	/// Removes all active cheats from the core
	mutating func clearCheats() -> Void
}
