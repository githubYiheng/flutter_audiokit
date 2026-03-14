/// Shared data types for the flutter_audiokit plugin.
///
/// These types mirror AudioKit's native iOS API types and are shared between
/// the app-facing package and platform implementations.

/// Audio file metadata, returned after loading an audio file.
class AudioFileInfo {
  const AudioFileInfo({
    required this.duration,
    required this.sampleRate,
    required this.channels,
  });

  /// Duration in seconds.
  final double duration;

  /// Sample rate in Hz.
  final double sampleRate;

  /// Number of audio channels.
  final int channels;
}

/// Mirrors AudioKit's NodeStatus.Playback enum.
enum PlaybackStatus {
  stopped,
  playing,
  paused,
  scheduling,
}

/// Playback state snapshot of an AudioPlayer node.
class PlaybackState {
  const PlaybackState({
    required this.nodeId,
    required this.status,
    required this.currentTime,
    required this.duration,
  });

  final String nodeId;
  final PlaybackStatus status;

  /// Current playback position in seconds.
  final double currentTime;

  /// Total duration in seconds.
  final double duration;

  /// Normalized position 0.0 to 1.0.
  double get position =>
      duration > 0 ? (currentTime / duration).clamp(0.0, 1.0) : 0.0;
}

/// Audio level data from AmplitudeTap.
class AudioLevelData {
  const AudioLevelData({
    required this.nodeId,
    required this.amplitude,
    required this.leftAmplitude,
    required this.rightAmplitude,
  });

  final String nodeId;
  final double amplitude;
  final double leftAmplitude;
  final double rightAmplitude;
}

/// Mirrors AudioKit's AnalysisMode enum.
enum AnalysisMode { rms, peak }

/// Mirrors AudioKit's StereoMode enum.
enum StereoMode { left, right, center }

/// Mirrors AudioKit's Settings.BufferLength enum.
enum BufferLength {
  shortest(5),
  veryShort(6),
  short(7),
  medium(8),
  long(9),
  veryLong(10),
  huge(11),
  longest(12);

  const BufferLength(this.powerOfTwo);
  final int powerOfTwo;

  int get samplesCount => 1 << powerOfTwo;
}

/// Mirrors Apple's AVAudioUnitReverbPreset.
///
/// **WARNING:** The enum order must match `AVAudioUnitReverbPreset` rawValues
/// exactly. The Dart enum `.index` is passed directly to Swift as `rawValue`.
/// Do NOT reorder, insert, or remove entries without updating the Swift mapping.
enum ReverbPreset {
  smallRoom,
  mediumRoom,
  largeRoom,
  mediumHall,
  largeHall,
  plate,
  mediumChamber,
  largeChamber,
  cathedral,
  largeRoom2,
  mediumHall2,
  mediumHall3,
  largeHall2,
}

/// Node parameter metadata, mirrors AudioKit's NodeParameterDef.
class NodeParameterInfo {
  const NodeParameterInfo({
    required this.identifier,
    required this.name,
    required this.value,
    required this.defaultValue,
    required this.minValue,
    required this.maxValue,
  });

  final String identifier;
  final String name;
  final double value;
  final double defaultValue;
  final double minValue;
  final double maxValue;
}

/// Remote command from iOS system media controls (lock screen / headphones / CarPlay).
enum RemoteCommand {
  togglePlayPause,
  play,
  pause,
  nextTrack,
  previousTrack,
  skipForward,
  skipBackward,
  changePlaybackPosition,
}

/// Remote command event with optional position data.
class RemoteCommandEvent {
  const RemoteCommandEvent({
    required this.command,
    this.position,
  });

  /// The command type.
  final RemoteCommand command;

  /// Playback position in seconds — used for [RemoteCommand.changePlaybackPosition].
  final double? position;
}

/// Configuration for which remote commands are enabled on the system media controls.
class RemoteCommandConfig {
  const RemoteCommandConfig({
    this.playPauseEnabled = true,
    this.nextTrackEnabled = true,
    this.previousTrackEnabled = true,
    this.skipForwardEnabled = false,
    this.skipForwardInterval = 15.0,
    this.skipBackwardEnabled = false,
    this.skipBackwardInterval = 15.0,
    this.seekEnabled = false,
  });

  final bool playPauseEnabled;
  final bool nextTrackEnabled;
  final bool previousTrackEnabled;
  final bool skipForwardEnabled;
  final double skipForwardInterval;
  final bool skipBackwardEnabled;
  final double skipBackwardInterval;
  final bool seekEnabled;
}

/// Pitch detection data from PitchTap.
class PitchData {
  const PitchData({
    required this.nodeId,
    required this.leftPitch,
    required this.rightPitch,
    required this.leftAmplitude,
    required this.rightAmplitude,
  });

  final String nodeId;
  final double leftPitch;
  final double rightPitch;
  final double leftAmplitude;
  final double rightAmplitude;
}

