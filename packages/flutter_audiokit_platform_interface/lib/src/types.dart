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

/// Mirrors AudioKit's ConnectStrategy enum.
enum ConnectStrategy { complete, incremental }

/// Mirrors AudioKit's DisconnectStrategy enum.
enum DisconnectStrategy { recursive, detach }

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

/// Error from the AudioKit native layer.
class AudioKitError implements Exception {
  const AudioKitError({
    required this.code,
    required this.message,
    this.nodeId,
  });

  final String code;
  final String message;
  final String? nodeId;

  @override
  String toString() => 'AudioKitError($code): $message';
}
