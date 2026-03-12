import 'dart:async';

import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import 'src/messages.g.dart';

/// iOS implementation of [FlutterAudioKitPlatform] using AudioKit.
///
/// This class is registered as the iOS platform implementation via
/// the `flutter_audiokit` app-facing package.
class FlutterAudioKitIOS extends FlutterAudioKitPlatform {
  /// Creates a new [FlutterAudioKitIOS] instance.
  FlutterAudioKitIOS();

  AudioKitHostApi? _hostApiInstance;
  bool _flutterApiSetUp = false;

  AudioKitHostApi get _hostApi {
    _ensureInitialized();
    return _hostApiInstance!;
  }

  void _ensureInitialized() {
    if (_hostApiInstance != null) return;
    _hostApiInstance = AudioKitHostApi();
    _setupFlutterApi();
  }

  // Stream controllers for event forwarding
  final _playbackStateController = StreamController<PlaybackState>.broadcast();
  final _playbackCompletedController = StreamController<String>.broadcast();
  final _amplitudeController = StreamController<AudioLevelData>.broadcast();
  final _errorController = StreamController<AudioKitError>.broadcast();
  final _pitchController = StreamController<PitchData>.broadcast();

  /// Registers this class as the platform implementation.
  static void registerWith() {
    FlutterAudioKitPlatform.instance = FlutterAudioKitIOS();
  }

  void _setupFlutterApi() {
    if (_flutterApiSetUp) return;
    _flutterApiSetUp = true;
    final flutterApi = _FlutterApiHandler(
      onPlaybackState: (state) {
        _playbackStateController.add(PlaybackState(
          nodeId: state.nodeId,
          status: PlaybackStatus.values[state.statusIndex],
          currentTime: state.currentTime,
          duration: state.duration,
        ));
      },
      onCompleted: (nodeId) {
        _playbackCompletedController.add(nodeId);
      },
      onAmplitude: (data) {
        _amplitudeController.add(AudioLevelData(
          nodeId: data.nodeId,
          amplitude: data.amplitude,
          leftAmplitude: data.leftAmplitude,
          rightAmplitude: data.rightAmplitude,
        ));
      },
      onErrorCallback: (nodeId, code, message) {
        _errorController.add(AudioKitError(
          nodeId: nodeId,
          code: code,
          message: message,
        ));
      },
      onPitch: (data) {
        _pitchController.add(PitchData(
          nodeId: data.nodeId,
          leftPitch: data.leftPitch,
          rightPitch: data.rightPitch,
          leftAmplitude: data.leftAmplitude,
          rightAmplitude: data.rightAmplitude,
        ));
      },
    );
    AudioKitFlutterApi.setUp(flutterApi);
  }

  void _setupEventChannels() {
    // EventChannels for high-frequency data can be added here as needed.
    // For Phase 1, we use Pigeon's FlutterApi for all callbacks.
  }

  // ==== AudioEngine ====

  @override
  Future<String> createEngine() => _hostApi.createEngine();

  @override
  Future<void> startEngine(String engineId) =>
      _hostApi.startEngine(engineId);

  @override
  Future<void> stopEngine(String engineId) async =>
      _hostApi.stopEngine(engineId);

  @override
  Future<void> pauseEngine(String engineId) async =>
      _hostApi.pauseEngine(engineId);

  @override
  Future<void> setEngineOutput(String engineId, String nodeId) async =>
      _hostApi.setEngineOutput(engineId, nodeId);

  @override
  Future<void> disposeEngine(String engineId) async =>
      _hostApi.disposeEngine(engineId);

  // ==== AudioPlayer ====

  @override
  Future<String> createAudioPlayer() async {
    final handle = await _hostApi.createAudioPlayer();
    return handle.nodeId;
  }

  @override
  Future<AudioFileInfo> loadAudioFile(String nodeId, String filePath) async {
    final info = await _hostApi.loadAudioFile(nodeId, filePath);
    return AudioFileInfo(
      duration: info.duration,
      sampleRate: info.sampleRate,
      channels: info.channels,
    );
  }

  @override
  Future<void> playerPlay(String nodeId,
      {double? startTime, double? endTime}) async =>
      _hostApi.playerPlay(nodeId, startTime, endTime);

  @override
  Future<void> playerPause(String nodeId) async =>
      _hostApi.playerPause(nodeId);

  @override
  Future<void> playerResume(String nodeId) async =>
      _hostApi.playerResume(nodeId);

  @override
  Future<void> playerStop(String nodeId) async =>
      _hostApi.playerStop(nodeId);

  @override
  Future<void> playerSeek(String nodeId, double time) async =>
      _hostApi.playerSeek(nodeId, time);

  @override
  Future<void> setPlayerVolume(String nodeId, double volume) async =>
      _hostApi.setPlayerVolume(nodeId, volume);

  @override
  Future<void> setPlayerIsLooping(String nodeId, bool isLooping) async =>
      _hostApi.setPlayerIsLooping(nodeId, isLooping);

  @override
  Future<void> setPlayerIsReversed(String nodeId, bool isReversed) async =>
      _hostApi.setPlayerIsReversed(nodeId, isReversed);

  @override
  Future<PlaybackState> getPlayerState(String nodeId) async {
    final state = await _hostApi.getPlayerState(nodeId);
    return PlaybackState(
      nodeId: state.nodeId,
      status: PlaybackStatus.values[state.statusIndex],
      currentTime: state.currentTime,
      duration: state.duration,
    );
  }

  // ==== Mixer ====

  @override
  Future<String> createMixer({
    List<String> inputNodeIds = const [],
    double volume = 1.0,
    String? name,
  }) async {
    final handle = await _hostApi.createMixer(inputNodeIds, volume, name);
    return handle.nodeId;
  }

  @override
  Future<void> mixerAddInput(String mixerId, String nodeId,
      {ConnectStrategy strategy = ConnectStrategy.complete}) async =>
      _hostApi.mixerAddInput(mixerId, nodeId);

  @override
  Future<void> mixerRemoveInput(String mixerId, String nodeId,
      {DisconnectStrategy strategy = DisconnectStrategy.recursive}) async =>
      _hostApi.mixerRemoveInput(mixerId, nodeId);

  @override
  Future<void> mixerRemoveAllInputs(String mixerId) async =>
      _hostApi.mixerRemoveAllInputs(mixerId);

  @override
  Future<void> setMixerVolume(String mixerId, double volume) async =>
      _hostApi.setMixerVolume(mixerId, volume);

  @override
  Future<void> setMixerPan(String mixerId, double pan) async =>
      _hostApi.setMixerPan(mixerId, pan);

  @override
  Future<void> setMixerName(String mixerId, String name) async =>
      _hostApi.setMixerName(mixerId, name);

  // ==== TimePitch ====

  @override
  Future<String> createTimePitch(
    String inputNodeId, {
    double rate = 1.0,
    double pitch = 0.0,
    double overlap = 8.0,
  }) async {
    final handle = await _hostApi.createTimePitch(inputNodeId, rate, pitch, overlap);
    return handle.nodeId;
  }

  @override
  Future<void> setTimePitchRate(String nodeId, double rate) async =>
      _hostApi.setTimePitchRate(nodeId, rate);

  @override
  Future<void> setTimePitchPitch(String nodeId, double pitch) async =>
      _hostApi.setTimePitchPitch(nodeId, pitch);

  @override
  Future<void> setTimePitchOverlap(String nodeId, double overlap) async =>
      _hostApi.setTimePitchOverlap(nodeId, overlap);

  // ==== VariSpeed ====

  @override
  Future<String> createVariSpeed(String inputNodeId,
      {double rate = 1.0}) async {
    final handle = await _hostApi.createVariSpeed(inputNodeId, rate);
    return handle.nodeId;
  }

  @override
  Future<void> setVariSpeedRate(String nodeId, double rate) async =>
      _hostApi.setVariSpeedRate(nodeId, rate);

  // ==== Generic Node ====

  @override
  Future<void> startNode(String nodeId) async =>
      _hostApi.startNode(nodeId);

  @override
  Future<void> stopNode(String nodeId) async =>
      _hostApi.stopNode(nodeId);

  @override
  Future<void> bypassNode(String nodeId) async =>
      _hostApi.bypassNode(nodeId);

  @override
  Future<void> disposeNode(String nodeId) async =>
      _hostApi.disposeNode(nodeId);

  @override
  Future<bool> isNodeStarted(String nodeId) async =>
      _hostApi.isNodeStarted(nodeId);

  @override
  Future<List<NodeParameterInfo>> getNodeParameters(String nodeId) async {
    final infos = await _hostApi.getNodeParameters(nodeId);
    return infos
        .map((i) => NodeParameterInfo(
              identifier: i.identifier,
              name: i.name,
              value: i.value,
              defaultValue: i.defaultValue,
              minValue: i.minValue,
              maxValue: i.maxValue,
            ))
        .toList();
  }

  @override
  Future<void> setNodeParameter(
      String nodeId, String identifier, double value) async =>
      _hostApi.setNodeParameter(nodeId, identifier, value);

  @override
  Future<void> rampNodeParameter(
    String nodeId,
    String identifier, {
    required double value,
    required double duration,
    double delay = 0,
  }) async =>
      _hostApi.rampNodeParameter(nodeId, identifier, value, duration, delay);

  // ==== Effects ====

  @override
  Future<String> createOscillator({
    double frequency = 440,
    double amplitude = 1.0,
  }) async {
    final handle = await _hostApi.createOscillator(frequency, amplitude);
    return handle.nodeId;
  }

  @override
  Future<String> createEffect(
    String inputNodeId,
    String effectType,
    Map<String, double> params,
  ) async {
    final handle = await _hostApi.createEffect(inputNodeId, effectType, params);
    return handle.nodeId;
  }

  @override
  Future<void> loadReverbPreset(String nodeId, int presetIndex) async =>
      _hostApi.loadReverbPreset(nodeId, presetIndex);

  @override
  Future<String> createConvolution(
    String inputNodeId,
    String impulseResponseFilePath,
    int partitionLength,
  ) async {
    final handle = await _hostApi.createConvolution(
        inputNodeId, impulseResponseFilePath, partitionLength);
    return handle.nodeId;
  }

  // ==== Taps ====

  @override
  Future<void> startAmplitudeTap(String nodeId,
      {int bufferSize = 1024}) async =>
      _hostApi.startAmplitudeTap(nodeId, bufferSize);

  @override
  Future<void> stopAmplitudeTap(String nodeId) async =>
      _hostApi.stopAmplitudeTap(nodeId);

  @override
  Future<void> startPitchTap(String nodeId, {int bufferSize = 4096}) async =>
      _hostApi.startPitchTap(nodeId, bufferSize);

  @override
  Future<void> stopPitchTap(String nodeId) async =>
      _hostApi.stopPitchTap(nodeId);

  // ==== Streams ====

  @override
  Stream<PlaybackState> get onPlaybackStateChanged =>
      _playbackStateController.stream;

  @override
  Stream<String> get onPlaybackCompleted =>
      _playbackCompletedController.stream;

  @override
  Stream<AudioLevelData> get onAmplitudeData => _amplitudeController.stream;

  @override
  Stream<AudioKitError> get onError => _errorController.stream;

  @override
  Stream<PitchData> get onPitchData => _pitchController.stream;

  // ==== Settings ====

  @override
  Future<void> setGlobalSampleRate(double sampleRate) async =>
      _hostApi.setGlobalSampleRate(sampleRate);

  @override
  Future<void> setGlobalBufferLength(BufferLength bufferLength) async =>
      _hostApi.setGlobalBufferLength(bufferLength.powerOfTwo);
}

/// Internal handler for Swift -> Dart callbacks via Pigeon's FlutterApi.
class _FlutterApiHandler implements AudioKitFlutterApi {
  _FlutterApiHandler({
    required this.onPlaybackState,
    required this.onCompleted,
    required this.onAmplitude,
    required this.onErrorCallback,
    required this.onPitch,
  });

  final void Function(PlatformPlaybackState) onPlaybackState;
  final void Function(String) onCompleted;
  final void Function(PlatformAudioLevelData) onAmplitude;
  final void Function(String nodeId, String code, String message) onErrorCallback;
  final void Function(PlatformPitchData) onPitch;

  @override
  void onPlaybackStateChanged(PlatformPlaybackState state) =>
      onPlaybackState(state);

  @override
  void onPlaybackCompleted(String nodeId) => onCompleted(nodeId);

  @override
  void onAmplitudeData(PlatformAudioLevelData data) => onAmplitude(data);

  @override
  void onError(String nodeId, String code, String message) =>
      onErrorCallback(nodeId, code, message);

  @override
  void onPitchData(PlatformPitchData data) => onPitch(data);
}
