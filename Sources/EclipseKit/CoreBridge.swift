import Foundation.NSURL

/// The settings object, with all resolved files.
public struct CoreResolvedSettings<Settings: CoreSettings>: ~Copyable {
	public let settings: Settings
	public let resolvedFiles: [CoreSettingsFile : URL]

	public init(settings: Settings, resolvedFiles: [CoreSettingsFile : URL]) {
		self.settings = settings
		self.resolvedFiles = resolvedFiles
	}
}

/// A bridge between the core and its coordinator.
/// - WARNING: An instance is not available for use until after the ``CoreProtocol.start`` method has been called.
public protocol CoreBridgeProtocol: ~Copyable {
	/// Writes audio samples to the audio renderer.
	/// - NOTE: This is safe as long as the passed in pointer is valid.
	@unsafe
	@discardableResult
	func writeAudioSamples(samples: UnsafeRawBufferPointer) -> Int

	/// The core did save to the given save file path.
	func didSave() -> Void
}
