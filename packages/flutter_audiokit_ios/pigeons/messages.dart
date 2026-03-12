import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  swiftOut:
      'ios/flutter_audiokit_ios/Sources/flutter_audiokit_ios/Messages.g.swift',
  dartPackageName: 'flutter_audiokit_ios',
))

// ============================================================
// Data classes for Pigeon serialization
// ============================================================

/// Handle referencing a native AudioKit node.
class PlatformNodeHandle {
  PlatformNodeHandle({required this.nodeId, required this.nodeType});
  final String nodeId;
  final String nodeType;
}

/// Audio file metadata.
class PlatformAudioFileInfo {
  PlatformAudioFileInfo({
    required this.duration,
    required this.sampleRate,
    required this.channels,
  });
  final double duration;
  final double sampleRate;
  final int channels;
}

/// Playback state snapshot.
class PlatformPlaybackState {
  PlatformPlaybackState({
    required this.nodeId,
    required this.statusIndex,
    required this.currentTime,
    required this.duration,
  });
  final String nodeId;

  /// Index into PlaybackStatus enum: 0=stopped, 1=playing, 2=paused, 3=scheduling.
  final int statusIndex;
  final double currentTime;
  final double duration;
}

/// Audio level data from AmplitudeTap.
class PlatformAudioLevelData {
  PlatformAudioLevelData({
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

/// Pitch detection data from PitchTap.
class PlatformPitchData {
  PlatformPitchData({
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

/// Node parameter info.
class PlatformNodeParameterInfo {
  PlatformNodeParameterInfo({
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

// ============================================================
// Host API: Dart -> Swift
// ============================================================

@HostApi()
abstract class AudioKitHostApi {
  // ---- AudioEngine ----
  @async
  String createEngine();

  @async
  void startEngine(String engineId);

  void stopEngine(String engineId);

  void pauseEngine(String engineId);

  void setEngineOutput(String engineId, String nodeId);

  void disposeEngine(String engineId);

  // ---- AudioPlayer ----
  @async
  PlatformNodeHandle createAudioPlayer();

  @async
  PlatformAudioFileInfo loadAudioFile(String nodeId, String filePath);

  void playerPlay(String nodeId, double? startTime, double? endTime);

  void playerPause(String nodeId);

  void playerResume(String nodeId);

  void playerStop(String nodeId);

  void playerSeek(String nodeId, double time);

  void setPlayerVolume(String nodeId, double volume);

  void setPlayerIsLooping(String nodeId, bool isLooping);

  void setPlayerIsReversed(String nodeId, bool isReversed);

  @async
  PlatformPlaybackState getPlayerState(String nodeId);

  // ---- Mixer ----
  PlatformNodeHandle createMixer(
    List<String> inputNodeIds,
    double volume,
    String? name,
  );

  void mixerAddInput(String mixerId, String nodeId);

  void mixerRemoveInput(String mixerId, String nodeId);

  void mixerRemoveAllInputs(String mixerId);

  void setMixerVolume(String mixerId, double volume);

  void setMixerPan(String mixerId, double pan);

  void setMixerName(String mixerId, String name);

  // ---- TimePitch ----
  PlatformNodeHandle createTimePitch(
    String inputNodeId,
    double rate,
    double pitch,
    double overlap,
  );

  void setTimePitchRate(String nodeId, double rate);

  void setTimePitchPitch(String nodeId, double pitch);

  void setTimePitchOverlap(String nodeId, double overlap);

  // ---- VariSpeed ----
  PlatformNodeHandle createVariSpeed(String inputNodeId, double rate);

  void setVariSpeedRate(String nodeId, double rate);

  // ---- Generic Node Operations ----
  void startNode(String nodeId);

  void stopNode(String nodeId);

  void bypassNode(String nodeId);

  void disposeNode(String nodeId);

  bool isNodeStarted(String nodeId);

  List<PlatformNodeParameterInfo> getNodeParameters(String nodeId);

  void setNodeParameter(String nodeId, String identifier, double value);

  void rampNodeParameter(
    String nodeId,
    String identifier,
    double value,
    double duration,
    double delay,
  );

  // ---- Effects ----
  PlatformNodeHandle createEffect(
    String inputNodeId,
    String effectType,
    Map<String, double> params,
  );

  void loadReverbPreset(String nodeId, int presetIndex);

  /// Creates a Convolution effect node with an impulse response file.
  PlatformNodeHandle createConvolution(
    String inputNodeId,
    String impulseResponseFilePath,
    int partitionLength,
  );

  // ---- Taps ----
  void startAmplitudeTap(String nodeId, int bufferSize);

  void stopAmplitudeTap(String nodeId);

  void startPitchTap(String nodeId, int bufferSize);

  void stopPitchTap(String nodeId);

  // ---- Settings ----
  void setGlobalSampleRate(double sampleRate);

  void setGlobalBufferLength(int bufferLengthPower);
}

// ============================================================
// Flutter API: Swift -> Dart (callbacks)
// ============================================================

@FlutterApi()
abstract class AudioKitFlutterApi {
  void onPlaybackStateChanged(PlatformPlaybackState state);

  void onPlaybackCompleted(String nodeId);

  void onAmplitudeData(PlatformAudioLevelData data);

  void onError(String nodeId, String code, String message);

  void onPitchData(PlatformPitchData data);
}
