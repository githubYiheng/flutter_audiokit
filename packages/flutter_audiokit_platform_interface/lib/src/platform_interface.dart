import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'types.dart';

/// The interface that implementations of flutter_audiokit must implement.
///
/// Platform implementations should extend this class rather than implement it
/// as `flutter_audiokit` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [FlutterAudioKitPlatform] methods.
abstract class FlutterAudioKitPlatform extends PlatformInterface {
  /// Constructs a FlutterAudioKitPlatform.
  FlutterAudioKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterAudioKitPlatform? _instance;

  /// The instance of [FlutterAudioKitPlatform] to use.
  ///
  /// Defaults to throwing [StateError]. Platform-specific
  /// implementations should set this to their implementation.
  static FlutterAudioKitPlatform get instance {
    final instance = _instance;
    if (instance == null) {
      throw StateError(
        'flutter_audiokit has not been initialized. '
        'Ensure the iOS plugin is registered.',
      );
    }
    return instance;
  }

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterAudioKitPlatform] when
  /// they register themselves.
  static set instance(FlutterAudioKitPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  // ===========================================================
  // AudioEngine — mirrors AudioKit's AudioEngine
  // ===========================================================

  /// Creates a new AudioEngine instance. Returns the engine ID.
  Future<String> createEngine() {
    throw UnimplementedError('createEngine() not implemented.');
  }

  /// Mirrors `engine.start()`.
  Future<void> startEngine(String engineId) {
    throw UnimplementedError('startEngine() not implemented.');
  }

  /// Mirrors `engine.stop()`.
  Future<void> stopEngine(String engineId) {
    throw UnimplementedError('stopEngine() not implemented.');
  }

  /// Mirrors `engine.pause()`.
  Future<void> pauseEngine(String engineId) {
    throw UnimplementedError('pauseEngine() not implemented.');
  }

  /// Mirrors `engine.output = node`.
  Future<void> setEngineOutput(String engineId, String nodeId) {
    throw UnimplementedError('setEngineOutput() not implemented.');
  }

  /// Disposes the engine and all its resources.
  Future<void> disposeEngine(String engineId) {
    throw UnimplementedError('disposeEngine() not implemented.');
  }

  // ===========================================================
  // AudioPlayer — mirrors AudioKit's AudioPlayer
  // ===========================================================

  /// Creates a new AudioPlayer. Returns the node ID.
  Future<String> createAudioPlayer() {
    throw UnimplementedError('createAudioPlayer() not implemented.');
  }

  /// Mirrors `player.load(url:)`.
  Future<AudioFileInfo> loadAudioFile(String nodeId, String filePath) {
    throw UnimplementedError('loadAudioFile() not implemented.');
  }

  /// Mirrors `player.play(from:to:)`.
  Future<void> playerPlay(String nodeId,
      {double? startTime, double? endTime}) {
    throw UnimplementedError('playerPlay() not implemented.');
  }

  /// Mirrors `player.pause()`.
  Future<void> playerPause(String nodeId) {
    throw UnimplementedError('playerPause() not implemented.');
  }

  /// Mirrors `player.resume()`.
  Future<void> playerResume(String nodeId) {
    throw UnimplementedError('playerResume() not implemented.');
  }

  /// Mirrors `player.stop()`.
  Future<void> playerStop(String nodeId) {
    throw UnimplementedError('playerStop() not implemented.');
  }

  /// Mirrors `player.seek(time:)`.
  Future<void> playerSeek(String nodeId, double time) {
    throw UnimplementedError('playerSeek() not implemented.');
  }

  /// Mirrors `player.volume = value`.
  Future<void> setPlayerVolume(String nodeId, double volume) {
    throw UnimplementedError('setPlayerVolume() not implemented.');
  }

  /// Mirrors `player.isLooping = value`.
  Future<void> setPlayerIsLooping(String nodeId, bool isLooping) {
    throw UnimplementedError('setPlayerIsLooping() not implemented.');
  }

  /// Mirrors `player.isReversed = value`.
  Future<void> setPlayerIsReversed(String nodeId, bool isReversed) {
    throw UnimplementedError('setPlayerIsReversed() not implemented.');
  }

  /// Gets current playback state snapshot.
  Future<PlaybackState> getPlayerState(String nodeId) {
    throw UnimplementedError('getPlayerState() not implemented.');
  }

  // ===========================================================
  // Mixer — mirrors AudioKit's Mixer
  // ===========================================================

  /// Creates a new Mixer. Returns the node ID.
  Future<String> createMixer({
    List<String> inputNodeIds = const [],
    double volume = 1.0,
    String? name,
  }) {
    throw UnimplementedError('createMixer() not implemented.');
  }

  /// Mirrors `mixer.addInput(node)`.
  Future<void> mixerAddInput(String mixerId, String nodeId) {
    throw UnimplementedError('mixerAddInput() not implemented.');
  }

  /// Mirrors `mixer.removeInput(node)`.
  Future<void> mixerRemoveInput(String mixerId, String nodeId) {
    throw UnimplementedError('mixerRemoveInput() not implemented.');
  }

  /// Mirrors `mixer.removeAllInputs()`.
  Future<void> mixerRemoveAllInputs(String mixerId) {
    throw UnimplementedError('mixerRemoveAllInputs() not implemented.');
  }

  /// Mirrors `mixer.volume = value`.
  Future<void> setMixerVolume(String mixerId, double volume) {
    throw UnimplementedError('setMixerVolume() not implemented.');
  }

  /// Mirrors `mixer.pan = value`.
  Future<void> setMixerPan(String mixerId, double pan) {
    throw UnimplementedError('setMixerPan() not implemented.');
  }

  /// Mirrors `mixer.name = value`.
  Future<void> setMixerName(String mixerId, String name) {
    throw UnimplementedError('setMixerName() not implemented.');
  }

  // ===========================================================
  // TimePitch — mirrors AudioKit's TimePitch
  // ===========================================================

  /// Creates a TimePitch node. Returns the node ID.
  Future<String> createTimePitch(
    String inputNodeId, {
    double rate = 1.0,
    double pitch = 0.0,
    double overlap = 8.0,
  }) {
    throw UnimplementedError('createTimePitch() not implemented.');
  }

  /// Mirrors `timePitch.rate = value`.
  Future<void> setTimePitchRate(String nodeId, double rate) {
    throw UnimplementedError('setTimePitchRate() not implemented.');
  }

  /// Mirrors `timePitch.pitch = value`.
  Future<void> setTimePitchPitch(String nodeId, double pitch) {
    throw UnimplementedError('setTimePitchPitch() not implemented.');
  }

  /// Mirrors `timePitch.overlap = value`.
  Future<void> setTimePitchOverlap(String nodeId, double overlap) {
    throw UnimplementedError('setTimePitchOverlap() not implemented.');
  }

  // ===========================================================
  // VariSpeed — mirrors AudioKit's VariSpeed
  // ===========================================================

  /// Creates a VariSpeed node. Returns the node ID.
  Future<String> createVariSpeed(String inputNodeId, {double rate = 1.0}) {
    throw UnimplementedError('createVariSpeed() not implemented.');
  }

  /// Mirrors `variSpeed.rate = value`.
  Future<void> setVariSpeedRate(String nodeId, double rate) {
    throw UnimplementedError('setVariSpeedRate() not implemented.');
  }

  // ===========================================================
  // Generic Node Operations
  // ===========================================================

  /// Mirrors `node.start()`.
  Future<void> startNode(String nodeId) {
    throw UnimplementedError('startNode() not implemented.');
  }

  /// Mirrors `node.stop()`.
  Future<void> stopNode(String nodeId) {
    throw UnimplementedError('stopNode() not implemented.');
  }

  /// Mirrors `node.bypass()`.
  Future<void> bypassNode(String nodeId) {
    throw UnimplementedError('bypassNode() not implemented.');
  }

  /// Disposes a node and releases native resources.
  Future<void> disposeNode(String nodeId) {
    throw UnimplementedError('disposeNode() not implemented.');
  }

  /// Mirrors `node.isStarted`.
  Future<bool> isNodeStarted(String nodeId) {
    throw UnimplementedError('isNodeStarted() not implemented.');
  }

  /// Gets all adjustable parameters of a node.
  Future<List<NodeParameterInfo>> getNodeParameters(String nodeId) {
    throw UnimplementedError('getNodeParameters() not implemented.');
  }

  /// Sets a parameter value by identifier.
  Future<void> setNodeParameter(
      String nodeId, String identifier, double value) {
    throw UnimplementedError('setNodeParameter() not implemented.');
  }

  /// Mirrors `$param.ramp(to:duration:delay:)`.
  Future<void> rampNodeParameter(
    String nodeId,
    String identifier, {
    required double value,
    required double duration,
    double delay = 0,
  }) {
    throw UnimplementedError('rampNodeParameter() not implemented.');
  }

  // ===========================================================
  // Effects — Generic factory (Phase 2 extensible)
  // ===========================================================

  /// Creates an effect node by type name.
  ///
  /// [effectType] matches the AudioKit class name (e.g., 'ZitaReverb',
  /// 'MoogLadder').
  /// [params] is a map of parameter identifier to value.
  ///
  /// Returns the node ID.
  Future<String> createEffect(
    String inputNodeId,
    String effectType,
    Map<String, double> params,
  ) {
    throw UnimplementedError('createEffect() not implemented.');
  }

  /// Creates an Oscillator (sine wave generator).
  ///
  /// Returns the node ID.
  Future<String> createOscillator({
    double frequency = 440,
    double amplitude = 1.0,
  }) {
    throw UnimplementedError('createOscillator() not implemented.');
  }

  /// Loads a factory preset on a Reverb node.
  ///
  /// Mirrors `reverb.loadFactoryPreset(preset)`.
  Future<void> loadReverbPreset(String nodeId, int presetIndex) {
    throw UnimplementedError('loadReverbPreset() not implemented.');
  }

  /// Creates a Convolution effect node with an impulse response file.
  ///
  /// Mirrors SoundpipeAudioKit's `Convolution(input, impulseResponseFileURL:partitionLength:)`.
  Future<String> createConvolution(
    String inputNodeId,
    String impulseResponseFilePath,
    int partitionLength,
  ) {
    throw UnimplementedError('createConvolution() not implemented.');
  }

  // ===========================================================
  // Taps (Analysis)
  // ===========================================================

  /// Starts an AmplitudeTap on the given node.
  Future<void> startAmplitudeTap(String nodeId, {int bufferSize = 1024}) {
    throw UnimplementedError('startAmplitudeTap() not implemented.');
  }

  /// Stops the AmplitudeTap on the given node.
  Future<void> stopAmplitudeTap(String nodeId) {
    throw UnimplementedError('stopAmplitudeTap() not implemented.');
  }

  /// Starts a PitchTap on the given node.
  Future<void> startPitchTap(String nodeId, {int bufferSize = 4096}) {
    throw UnimplementedError('startPitchTap() not implemented.');
  }

  /// Stops the PitchTap on the given node.
  Future<void> stopPitchTap(String nodeId) {
    throw UnimplementedError('stopPitchTap() not implemented.');
  }

  // ===========================================================
  // Streams (EventChannel data)
  // ===========================================================

  /// Stream of playback state changes.
  Stream<PlaybackState> get onPlaybackStateChanged {
    throw UnimplementedError('onPlaybackStateChanged not implemented.');
  }

  /// Stream of playback completion events.
  Stream<String> get onPlaybackCompleted {
    throw UnimplementedError('onPlaybackCompleted not implemented.');
  }

  /// Stream of amplitude data from active AmplitudeTaps.
  Stream<AudioLevelData> get onAmplitudeData {
    throw UnimplementedError('onAmplitudeData not implemented.');
  }

  /// Stream of pitch data from active PitchTaps.
  Stream<PitchData> get onPitchData {
    throw UnimplementedError('onPitchData not implemented.');
  }

  // ===========================================================
  // Settings — mirrors AudioKit's Settings
  // ===========================================================

  /// Mirrors `Settings.sampleRate = value`.
  Future<void> setGlobalSampleRate(double sampleRate) {
    throw UnimplementedError('setGlobalSampleRate() not implemented.');
  }

  /// Mirrors `Settings.bufferLength = value`.
  Future<void> setGlobalBufferLength(BufferLength bufferLength) {
    throw UnimplementedError('setGlobalBufferLength() not implemented.');
  }
}
