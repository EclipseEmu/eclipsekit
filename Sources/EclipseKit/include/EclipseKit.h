#ifndef EclipseKit_h
#define EclipseKit_h

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifndef EK_EXPORT_AS
#define EK_EXPORT_AS(name) __attribute__((swift_name(name)))
#endif

#ifndef EK_SWIFT_ENUM
#define EK_SWIFT_ENUM __attribute__((enum_extensibility(open)))
#endif

#ifndef EK_SWIFT_OPTIONS
#define EK_SWIFT_OPTIONS __attribute__((flag_enum)) __attribute__((enum_extensibility(open)))
#endif

#pragma mark - Function Pointers

typedef void (*EKCoreSaveCallback)(const void* const callbackContext);
typedef uint64_t (*EKCoreAudioWriteCallback)(const void* const callbackContext,
	const void* buffer,
	uint64_t count);

#pragma mark - Enum

EK_EXPORT_AS("GameCoreCommonAudioFormat")
typedef enum EK_SWIFT_ENUM {
	EKCoreCommonAudioFormatOtherFormat,
	EKCoreCommonAudioFormatPcmInt16,
	EKCoreCommonAudioFormatPcmInt32,
	EKCoreCommonAudioFormatPcmFloat32,
	EKCoreCommonAudioFormatPcmFloat64
} EKCoreCommonAudioFormat;

EK_EXPORT_AS("GameCoreVideoPixelFormat")
typedef enum EK_SWIFT_ENUM {
	EKCoreVideoPixelFormatBgra8Unorm,
	EKCoreVideoPixelFormatRgba8Unorm,
} EKCoreVideoPixelFormat;

EK_EXPORT_AS("GameCoreVideoRenderingType")
typedef enum EK_SWIFT_ENUM {
	EKCoreVideoRenderingTypeFrameBuffer,
} EKCoreVideoRenderingType;

EK_EXPORT_AS("GameCoreSettingKind")
typedef enum EK_SWIFT_ENUM {
	EKCoreSettingKindFile,
	EKCoreSettingKindBoolean,
} EKCoreSettingKind;

EK_EXPORT_AS("GameCoreCheatCharacterSet")
typedef enum EK_SWIFT_ENUM {
    EKCoreCheatCharacterSetHexadecimal,
} EKCoreCheatCharacterSet;

EK_EXPORT_AS("GameInput")
typedef enum EK_SWIFT_OPTIONS {
	EKInputNone				  = 0b00000000000000000000000000000000,
	EKInputFaceButtonUp		  = 0b00000000000000000000000000000001,
	EKInputFaceButtonDown	  = 0b00000000000000000000000000000010,
	EKInputFaceButtonLeft	  = 0b00000000000000000000000000000100,
	EKInputFaceButtonRight	  = 0b00000000000000000000000000001000,
	EKInputStartButton		  = 0b00000000000000000000000000010000,
	EKInputSelectButton		  = 0b00000000000000000000000000100000,
	EKInputShoulderLeft		  = 0b00000000000000000000000001000000,
	EKInputShoulderRight	  = 0b00000000000000000000000010000000,
	EKInputTriggerLeft		  = 0b00000000000000000000000100000000,
	EKInputTriggerRight		  = 0b00000000000000000000001000000000,
	EKInputDpadUp			  = 0b00000000000000000000010000000000,
	EKInputDpadDown			  = 0b00000000000000000000100000000000,
	EKInputDpadLeft			  = 0b00000000000000000001000000000000,
	EKInputDpadRight		  = 0b00000000000000000010000000000000,
	EKInputLeftJoystickUp	  = 0b00000000000000000100000000000000,
	EKInputLeftJoystickDown	  = 0b00000000000000001000000000000000,
	EKInputLeftJoystickLeft	  = 0b00000000000000010000000000000000,
	EKInputLeftJoystickRight  = 0b00000000000000100000000000000000,
	EKInputRightJoystickUp	  = 0b00000000000001000000000000000000,
	EKInputRightJoystickDown  = 0b00000000000010000000000000000000,
	EKInputRightJoystickLeft  = 0b00000000000100000000000000000000,
	EKInputRightJoystickRight = 0b00000000001000000000000000000000,
	EKInputTouchPosX		  = 0b00000000010000000000000000000000,
	EKInputTouchNegX		  = 0b00000000100000000000000000000000,
	EKInputTouchPosY		  = 0b00000001000000000000000000000000,
	EKInputTouchNegY		  = 0b00000010000000000000000000000000,
	EKInputLid				  = 0b00000100000000000000000000000000,
	EKInputMic				  = 0b00001000000000000000000000000000,
	EKInputGyroX			  = 0b00010000000000000000000000000000,
	EKInputGyroY			  = 0b00100000000000000000000000000000,
	EKInputGyroZ			  = 0b01000000000000000000000000000000,
} EKInput;

EK_EXPORT_AS("GameSystem")
typedef enum EK_SWIFT_ENUM {
	EKSystemUnknown = 0,
	EKSystemGb		= 1,
	EKSystemGbc		= 2,
	EKSystemGba		= 3,
	EKSystemNes		= 4,
	EKSystemSnes	= 5,
} EKSystem;

#pragma mark - Structs

EK_EXPORT_AS("GameCoreAudioFormat")
typedef struct {
	/// The common format the core uses.
	const EKCoreCommonAudioFormat commonFormat;
	/// The sample rate the core uses.
	const double sampleRate;
	/// The number of channels.
	const uint32_t channelCount;
} EKCoreAudioFormat;

EK_EXPORT_AS("GameCoreVideoFormat")
typedef struct {
	/// The video rendering type the core uses.
	const EKCoreVideoRenderingType renderingType;
	/// The pixel format the core uses.
	const EKCoreVideoPixelFormat pixelFormat;
	/// The width of the screen.
	const uint32_t width;
	/// The height of the screen.
	const uint32_t height;
} EKCoreVideoFormat;

EK_EXPORT_AS("GameCoreCheatFormat")
typedef struct {
	/// A unique ID for this cheat format.
	const char* id;
	/// The user-shown name of this cheat format.
	const char* displayName;
	/// A string of allowed characters, i.e. "ABXYabxy" to allow both upper and lower case a, b, x, and y.
	const EKCoreCheatCharacterSet characterSet;
	/// The user-shown name of this cheat format.
	const char* format;
} EKCheatFormat;

EK_EXPORT_AS("GameCoreSettingFile")
typedef struct {
	/// The expected MD5 checksum of the file.
	const char* md5;
	/// The user-shown name of the file.
	const char* displayName;
} EKCoreSettingFile;

EK_EXPORT_AS("GameCoreSettingBoolean")
typedef struct {
	/// The default value of this setting
	const bool defaultValue;
} EKCoreSettingBoolean;

EK_EXPORT_AS("GameCoreSetting")
typedef struct {
	/// The core-unique identifier for this setting.
	const char* id;
	/// The system this applies to, use ``EKGameSystemUnknown`` if it applies to
	/// any system.
	const EKSystem system;
	/// The user-shown name of this setting.
	const char* displayName;
	/// Whether or not this setting is required for the core to run.
	const bool required;
	/// What type of setting this will be.
	const EKCoreSettingKind kind;
 
	union {
		const EKCoreSettingFile* const file;
		const EKCoreSettingBoolean* const boolean;
	};
} EKCoreSetting;

EK_EXPORT_AS("GameCoreSettings")
typedef struct {
	/// The version of these settings.
	const uint16_t version;
	/// The number of settings in the ``items`` field.
	const size_t itemsCount;
	/// The list of settings.
	const EKCoreSetting* const items;
} EKCoreSettings;

EK_EXPORT_AS("GameCoreCallbacks")
typedef struct {
	/// The callback context. Pass this to functions that expect it, like ``writeAudio``. This pointer gets freed after deallocate is called, so ensure references are removed in the `deallocate` function of ``EKCore`` to prevent UAFs.
	const void* const callbackContext;
	/// Notifies the core that a save has occurred.
	EKCoreSaveCallback didSave;
	/// Writes an audio buffer to the audio renderer. The buffer is assumed to be interleaved, if multiple channels are used.
	EKCoreAudioWriteCallback writeAudio;
} EKCoreCallbacks;

EK_EXPORT_AS("GameCore")
typedef struct {
	/// Additional data that can be used with your core. It is passed as the first
	/// arg to every method that may need it.
	void* data;

	/// Called when the core will no longer be used, do all clean up code here.
	///
	/// - Parameter data: the data field on the GameCore struct.
	void (*deallocate)(void* data);

#pragma mark - General setup functions

	/// Gets the audio format, including common format (i.e. AVFoundation's
	/// AVAudioCommonFormat), sample rate, whether or not its interleaved, and the
	/// channel count.
	///
	/// - Parameter data: the data field on the GameCore struct.
	EKCoreAudioFormat (*getAudioFormat)(void* data);

	/// Gets the video format, including width, height, pixel format, and
	/// rendering type.
	///
	/// - Parameter data: the data field on the GameCore struct.
	EKCoreVideoFormat (*getVideoFormat)(void* data);

	/// Gets the core's desired frame rate as a double (i.e. `60.0`)
	///
	/// - Parameter data: the data field on the GameCore struct.
	double (*getDesiredFrameRate)(void* data);

	/// Whether or not the `preferredPointer` parameter will be used in ``getVideoPointer``
	///
	/// - Parameter data: the data field on the GameCore struct.
	bool (*canSetVideoPointer)(void* data);

	/// Gets the pointer to the video buffer.
	///
	/// - Parameters:
	///    - data: the data field on the GameCore struct.
	///    - preferredPointer: Ideally set the video pointer to this and use it instead, return false in ``canSetVideoPointer`` if you will not handle this.
	uint8_t* (*getVideoPointer)(void* data, uint8_t* preferredPointer);

#pragma mark - Lifecycle

	/// Start emulation.
	///
	/// Parameters:
	///   - data: The data field on the GameCore struct.
	bool (*start)(void* data, const char* const gamePath,
		const char* const savePath);

	/// Stop emulation.
	///
	/// Parameters:
	///   - data: The data field on the GameCore struct.
	void (*stop)(void* data);

	/// Restart the game, ideally using any quick reset features, if available.
	///
	/// Parameters:
	///   - data: The data field on the GameCore struct.
	void (*restart)(void* data);

	/// Resume the game.
	///
	/// Parameters:
	///   - data: The data field on the GameCore struct.
	void (*play)(void* data);

	/// Pause the game.
	///
	/// Parameters:
	///   - data: The data field on the GameCore struct.
	void (*pause)(void* data);

	/// Execute a single frame.
	///
	/// Parameters:
	///   - data: The data field on the GameCore struct.
	///	  - willRender: The core will render after this frame is executed.
	void (*executeFrame)(void* data, bool willRender);

#pragma mark - Saving

	/// The core should write the save to disk, ideally immediately.
	/// Return true and use the save callback from ``EKCoreCallbacks`` to signal that the save occurred if it cannot be done immediately.
	///
	/// Parameters:
	///   - data: The data field on the GameCore struct.
	///	  - path: The path to write the save file to.
	///	Returns: If the save could be properly written.
	bool (*save)(void* data, const char* path);

	/// Write the current state to the disk.
	///
	/// Parameters:
	///   - data: The data field on the GameCore struct.
	///	  - path: The path to write the save file to.
	///	Returns: If the save could be properly written.
	bool (*saveState)(void* data, const char* path);

	/// Loads the state at the given path.
	///
	/// Parameters:
	///   - data: The data field on the GameCore struct.
	///	  - path: The path to write the save file to.
	///	Returns: If the save could be properly written.
	bool (*loadState)(void* data, const char* path);

#pragma mark - Controls

	/// Get the maximum number of players supported.
	///
	/// Parameters:
	///   - data: The data field on the GameCore struct.
	/// Returns: The maximum number of players.
	uint8_t (*getMaxPlayers)(void* data);

	/// Notifies a core that a new player has connected.
	///
	/// Parameters:
	///   - data: The data field on the GameCore struct.
	///	  - player: The player that got connected, in the range of 0..<``getMaxPlayers``.
	///	Returns: If the player could be connected.
	bool (*playerConnected)(void* data, uint8_t player);

	/// Notifies a core that a player has been disconnected.
	///
	/// Parameters:
	///   - data: The data field on the GameCore struct.
	///	  - player: The player that disconnected.
	void (*playerDisconnected)(void* data, uint8_t player);

	/// Sets the inputs for the given player
	///
	/// Parameters:
	///   - data: the data field on the GameCore struct.
	///	  - player: The player to set the inputs for.
	///	  - inputs: An u32 with each bit using an ``EKInput``.
	// FIXME: associated values for inputs, i.e. touch x/y values
	void (*playerSetInputs)(void* data, uint8_t player, uint32_t inputs);

#pragma mark - Cheats

	/// Adds or updates the given cheat code.
	///
	/// Parameters:
	///   - data: the data field on the GameCore struct.
	///	  - format: The cheat code's format
	///	  - code: The cheat code
    ///   - enabled: Whether or not to enable this cheat
	///	Returns: If the cheat could be set.
	bool (*setCheat)(void* data, const char *format, const char *code, bool enabled);
    
    /// Removes all existing cheats.
    ///
    /// Parameters:
    ///   - data: the data field on the GameCore struct.
    ///   - format: The cheat code's format
    void (*clearCheats)(void *data);
} EKCore;

EK_EXPORT_AS("GameCoreInfo")
typedef struct {
	// A unique identifier for this core.
	const char* const id;
	/// The user-shown name of the core.
	const char* const name;
	/// The developer(s) responsible for the core.
	const char* const developer;
	/// The version of the core.
	const char* const version;
	/// The URL to the core's source code repository.
	const char* const sourceCodeUrl;
    /// The number of systems this core supports.
    const size_t supportedSystemsCount;
    /// The systems this core supports.
    const EKSystem const* supportedSystems;
    /// The settings this core provides.
	const EKCoreSettings settings;

	/// The number of cheat formats.
	const size_t cheatFormatsCount;
	/// A list of supported cheat formats.
	const EKCheatFormat const* cheatFormats;

	/// A function to do any initialization.
	///
	/// - Parameters
	///    - system: The system to use
	///    - callbacks: The core callbacks
	/// - Returns: an instance of an EKCore.
	EKCore* (*const setup)(EKSystem system, const EKCoreCallbacks* const callbacks);
} EKCoreInfo;

#endif /* EclipseKit_h */
