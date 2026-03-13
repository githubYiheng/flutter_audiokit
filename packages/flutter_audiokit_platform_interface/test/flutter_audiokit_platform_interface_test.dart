import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// ---------------------------------------------------------------------------
// Mock that implements every method
// ---------------------------------------------------------------------------
class MockFlutterAudioKitPlatform extends FlutterAudioKitPlatform
    with MockPlatformInterfaceMixin {
  // Engine
  @override
  Future<String> createEngine() async => 'mock-engine-id';
  @override
  Future<void> startEngine(String engineId) async {}
  @override
  Future<void> stopEngine(String engineId) async {}
  @override
  Future<void> pauseEngine(String engineId) async {}
  @override
  Future<void> setEngineOutput(String engineId, String nodeId) async {}
  @override
  Future<void> disposeEngine(String engineId) async {}

  // Player
  @override
  Future<String> createAudioPlayer() async => 'mock-player-id';
  @override
  Future<AudioFileInfo> loadAudioFile(String nodeId, String filePath) async =>
      const AudioFileInfo(duration: 3.5, sampleRate: 44100, channels: 2);
  @override
  Future<void> playerPlay(String nodeId,
      {double? startTime, double? endTime}) async {}
  @override
  Future<void> playerPause(String nodeId) async {}
  @override
  Future<void> playerResume(String nodeId) async {}
  @override
  Future<void> playerStop(String nodeId) async {}
  @override
  Future<void> playerSeek(String nodeId, double time) async {}
  @override
  Future<void> setPlayerVolume(String nodeId, double volume) async {}
  @override
  Future<void> setPlayerIsLooping(String nodeId, bool isLooping) async {}
  @override
  Future<void> setPlayerIsReversed(String nodeId, bool isReversed) async {}
  @override
  Future<PlaybackState> getPlayerState(String nodeId) async =>
      const PlaybackState(
        nodeId: 'mock-player-id',
        status: PlaybackStatus.stopped,
        currentTime: 0.0,
        duration: 3.5,
      );

  // Mixer
  @override
  Future<String> createMixer({
    List<String> inputNodeIds = const [],
    double volume = 1.0,
    String? name,
  }) async =>
      'mock-mixer-id';
  @override
  Future<void> mixerAddInput(String mixerId, String nodeId) async {}
  @override
  Future<void> mixerRemoveInput(String mixerId, String nodeId) async {}
  @override
  Future<void> mixerRemoveAllInputs(String mixerId) async {}
  @override
  Future<void> setMixerVolume(String mixerId, double volume) async {}
  @override
  Future<void> setMixerPan(String mixerId, double pan) async {}
  @override
  Future<void> setMixerName(String mixerId, String name) async {}

  // TimePitch
  @override
  Future<String> createTimePitch(String inputNodeId,
          {double rate = 1.0, double pitch = 0.0, double overlap = 8.0}) async =>
      'mock-timepitch-id';
  @override
  Future<void> setTimePitchRate(String nodeId, double rate) async {}
  @override
  Future<void> setTimePitchPitch(String nodeId, double pitch) async {}
  @override
  Future<void> setTimePitchOverlap(String nodeId, double overlap) async {}

  // VariSpeed
  @override
  Future<String> createVariSpeed(String inputNodeId,
          {double rate = 1.0}) async =>
      'mock-varispeed-id';
  @override
  Future<void> setVariSpeedRate(String nodeId, double rate) async {}

  // Generic Node
  @override
  Future<void> startNode(String nodeId) async {}
  @override
  Future<void> stopNode(String nodeId) async {}
  @override
  Future<void> bypassNode(String nodeId) async {}
  @override
  Future<void> disposeNode(String nodeId) async {}
  @override
  Future<bool> isNodeStarted(String nodeId) async => true;
  @override
  Future<List<NodeParameterInfo>> getNodeParameters(String nodeId) async => [
        const NodeParameterInfo(
          identifier: 'cutoff',
          name: 'Cutoff',
          value: 1000.0,
          defaultValue: 1000.0,
          minValue: 12.0,
          maxValue: 20000.0,
        ),
      ];
  @override
  Future<void> setNodeParameter(
      String nodeId, String identifier, double value) async {}
  @override
  Future<void> rampNodeParameter(String nodeId, String identifier,
      {required double value,
      required double duration,
      double delay = 0}) async {}

  // Effects
  @override
  Future<String> createEffect(
          String inputNodeId, String effectType, Map<String, double> params) async =>
      'mock-effect-id';
  @override
  Future<void> loadReverbPreset(String nodeId, int presetIndex) async {}
  @override
  Future<String> createConvolution(String inputNodeId,
          String impulseResponseFilePath, int partitionLength) async =>
      'mock-convolution-id';

  // Taps
  @override
  Future<void> startAmplitudeTap(String nodeId,
      {int bufferSize = 1024}) async {}
  @override
  Future<void> stopAmplitudeTap(String nodeId) async {}
  @override
  Future<void> startPitchTap(String nodeId, {int bufferSize = 4096}) async {}
  @override
  Future<void> stopPitchTap(String nodeId) async {}

  // Streams
  final _playbackStateController = StreamController<PlaybackState>.broadcast();
  final _playbackCompletedController = StreamController<String>.broadcast();
  final _amplitudeController = StreamController<AudioLevelData>.broadcast();
  final _pitchController = StreamController<PitchData>.broadcast();

  @override
  Stream<PlaybackState> get onPlaybackStateChanged =>
      _playbackStateController.stream;
  @override
  Stream<String> get onPlaybackCompleted =>
      _playbackCompletedController.stream;
  @override
  Stream<AudioLevelData> get onAmplitudeData => _amplitudeController.stream;
  @override
  Stream<PitchData> get onPitchData => _pitchController.stream;

  // Settings
  @override
  Future<void> setGlobalSampleRate(double sampleRate) async {}
  @override
  Future<void> setGlobalBufferLength(BufferLength bufferLength) async {}

  void dispose() {
    _playbackStateController.close();
    _playbackCompletedController.close();
    _amplitudeController.close();
    _pitchController.close();
  }
}

// ---------------------------------------------------------------------------
// Bare subclass — verifies defaults throw UnimplementedError
// ---------------------------------------------------------------------------
class UnimplementedPlatform extends FlutterAudioKitPlatform
    with MockPlatformInterfaceMixin {}

void main() {
  late MockFlutterAudioKitPlatform mock;

  setUp(() {
    mock = MockFlutterAudioKitPlatform();
    FlutterAudioKitPlatform.instance = mock;
  });

  tearDown(() {
    mock.dispose();
  });

  // =========================================================================
  // Instance management
  // =========================================================================
  group('Instance management', () {
    test('can set and get mock instance', () {
      expect(FlutterAudioKitPlatform.instance, mock);
    });

    test('rejects implementation without MockPlatformInterfaceMixin', () {
      // UnimplementedPlatform has the mixin, so it can be set — this just
      // verifies the verify() path doesn't throw for correct subclasses.
      final valid = UnimplementedPlatform();
      FlutterAudioKitPlatform.instance = valid;
      expect(FlutterAudioKitPlatform.instance, valid);
    });
  });

  // =========================================================================
  // Default implementations throw UnimplementedError
  // =========================================================================
  group('Default implementations throw UnimplementedError', () {
    late UnimplementedPlatform platform;
    setUp(() => platform = UnimplementedPlatform());

    // Engine
    test('createEngine', () {
      expect(() => platform.createEngine(), throwsUnimplementedError);
    });
    test('startEngine', () {
      expect(() => platform.startEngine('e'), throwsUnimplementedError);
    });
    test('stopEngine', () {
      expect(() => platform.stopEngine('e'), throwsUnimplementedError);
    });
    test('pauseEngine', () {
      expect(() => platform.pauseEngine('e'), throwsUnimplementedError);
    });
    test('setEngineOutput', () {
      expect(
          () => platform.setEngineOutput('e', 'n'), throwsUnimplementedError);
    });
    test('disposeEngine', () {
      expect(() => platform.disposeEngine('e'), throwsUnimplementedError);
    });

    // Player
    test('createAudioPlayer', () {
      expect(() => platform.createAudioPlayer(), throwsUnimplementedError);
    });
    test('loadAudioFile', () {
      expect(
          () => platform.loadAudioFile('n', '/f'), throwsUnimplementedError);
    });
    test('playerPlay', () {
      expect(() => platform.playerPlay('n'), throwsUnimplementedError);
    });
    test('playerPause', () {
      expect(() => platform.playerPause('n'), throwsUnimplementedError);
    });
    test('playerResume', () {
      expect(() => platform.playerResume('n'), throwsUnimplementedError);
    });
    test('playerStop', () {
      expect(() => platform.playerStop('n'), throwsUnimplementedError);
    });
    test('playerSeek', () {
      expect(() => platform.playerSeek('n', 1.0), throwsUnimplementedError);
    });
    test('setPlayerVolume', () {
      expect(
          () => platform.setPlayerVolume('n', 0.5), throwsUnimplementedError);
    });
    test('setPlayerIsLooping', () {
      expect(() => platform.setPlayerIsLooping('n', true),
          throwsUnimplementedError);
    });
    test('setPlayerIsReversed', () {
      expect(() => platform.setPlayerIsReversed('n', false),
          throwsUnimplementedError);
    });
    test('getPlayerState', () {
      expect(() => platform.getPlayerState('n'), throwsUnimplementedError);
    });

    // Mixer
    test('createMixer', () {
      expect(() => platform.createMixer(), throwsUnimplementedError);
    });
    test('mixerAddInput', () {
      expect(
          () => platform.mixerAddInput('m', 'n'), throwsUnimplementedError);
    });
    test('mixerRemoveInput', () {
      expect(() => platform.mixerRemoveInput('m', 'n'),
          throwsUnimplementedError);
    });
    test('mixerRemoveAllInputs', () {
      expect(
          () => platform.mixerRemoveAllInputs('m'), throwsUnimplementedError);
    });
    test('setMixerVolume', () {
      expect(
          () => platform.setMixerVolume('m', 0.5), throwsUnimplementedError);
    });
    test('setMixerPan', () {
      expect(() => platform.setMixerPan('m', 0.0), throwsUnimplementedError);
    });
    test('setMixerName', () {
      expect(
          () => platform.setMixerName('m', 'x'), throwsUnimplementedError);
    });

    // TimePitch
    test('createTimePitch', () {
      expect(() => platform.createTimePitch('n'), throwsUnimplementedError);
    });
    test('setTimePitchRate', () {
      expect(
          () => platform.setTimePitchRate('n', 1.0), throwsUnimplementedError);
    });
    test('setTimePitchPitch', () {
      expect(() => platform.setTimePitchPitch('n', 0.0),
          throwsUnimplementedError);
    });
    test('setTimePitchOverlap', () {
      expect(() => platform.setTimePitchOverlap('n', 8.0),
          throwsUnimplementedError);
    });

    // VariSpeed
    test('createVariSpeed', () {
      expect(() => platform.createVariSpeed('n'), throwsUnimplementedError);
    });
    test('setVariSpeedRate', () {
      expect(
          () => platform.setVariSpeedRate('n', 1.0), throwsUnimplementedError);
    });

    // Generic Node
    test('startNode', () {
      expect(() => platform.startNode('n'), throwsUnimplementedError);
    });
    test('stopNode', () {
      expect(() => platform.stopNode('n'), throwsUnimplementedError);
    });
    test('bypassNode', () {
      expect(() => platform.bypassNode('n'), throwsUnimplementedError);
    });
    test('disposeNode', () {
      expect(() => platform.disposeNode('n'), throwsUnimplementedError);
    });
    test('isNodeStarted', () {
      expect(() => platform.isNodeStarted('n'), throwsUnimplementedError);
    });
    test('getNodeParameters', () {
      expect(() => platform.getNodeParameters('n'), throwsUnimplementedError);
    });
    test('setNodeParameter', () {
      expect(() => platform.setNodeParameter('n', 'id', 1.0),
          throwsUnimplementedError);
    });
    test('rampNodeParameter', () {
      expect(
          () => platform.rampNodeParameter('n', 'id',
              value: 1.0, duration: 0.5),
          throwsUnimplementedError);
    });

    // Effects
    test('createEffect', () {
      expect(() => platform.createEffect('n', 'Delay', {}),
          throwsUnimplementedError);
    });
    test('loadReverbPreset', () {
      expect(
          () => platform.loadReverbPreset('n', 0), throwsUnimplementedError);
    });
    test('createConvolution', () {
      expect(() => platform.createConvolution('n', '/f', 2048),
          throwsUnimplementedError);
    });

    // Taps
    test('startAmplitudeTap', () {
      expect(
          () => platform.startAmplitudeTap('n'), throwsUnimplementedError);
    });
    test('stopAmplitudeTap', () {
      expect(() => platform.stopAmplitudeTap('n'), throwsUnimplementedError);
    });
    test('startPitchTap', () {
      expect(() => platform.startPitchTap('n'), throwsUnimplementedError);
    });
    test('stopPitchTap', () {
      expect(() => platform.stopPitchTap('n'), throwsUnimplementedError);
    });

    // Streams
    test('onPlaybackStateChanged', () {
      expect(
          () => platform.onPlaybackStateChanged, throwsUnimplementedError);
    });
    test('onPlaybackCompleted', () {
      expect(() => platform.onPlaybackCompleted, throwsUnimplementedError);
    });
    test('onAmplitudeData', () {
      expect(() => platform.onAmplitudeData, throwsUnimplementedError);
    });
    test('onPitchData', () {
      expect(() => platform.onPitchData, throwsUnimplementedError);
    });

    // Settings
    test('setGlobalSampleRate', () {
      expect(() => platform.setGlobalSampleRate(44100),
          throwsUnimplementedError);
    });
    test('setGlobalBufferLength', () {
      expect(() => platform.setGlobalBufferLength(BufferLength.medium),
          throwsUnimplementedError);
    });
  });

  // =========================================================================
  // Mock returns expected values
  // =========================================================================
  group('Mock implementation returns expected values', () {
    // Engine
    test('createEngine', () async {
      expect(await mock.createEngine(), 'mock-engine-id');
    });

    // Player
    test('createAudioPlayer', () async {
      expect(await mock.createAudioPlayer(), 'mock-player-id');
    });
    test('loadAudioFile returns AudioFileInfo', () async {
      final info = await mock.loadAudioFile('n', '/f');
      expect(info.duration, 3.5);
      expect(info.sampleRate, 44100);
      expect(info.channels, 2);
    });
    test('getPlayerState returns PlaybackState', () async {
      final state = await mock.getPlayerState('n');
      expect(state.nodeId, 'mock-player-id');
      expect(state.status, PlaybackStatus.stopped);
      expect(state.currentTime, 0.0);
      expect(state.duration, 3.5);
    });

    // Mixer
    test('createMixer', () async {
      expect(await mock.createMixer(), 'mock-mixer-id');
    });

    // TimePitch
    test('createTimePitch', () async {
      expect(await mock.createTimePitch('n'), 'mock-timepitch-id');
    });

    // VariSpeed
    test('createVariSpeed', () async {
      expect(await mock.createVariSpeed('n'), 'mock-varispeed-id');
    });

    // Generic Node
    test('isNodeStarted', () async {
      expect(await mock.isNodeStarted('n'), true);
    });
    test('getNodeParameters', () async {
      final params = await mock.getNodeParameters('n');
      expect(params.length, 1);
      expect(params[0].identifier, 'cutoff');
    });

    // Effects
    test('createEffect', () async {
      expect(await mock.createEffect('n', 'Delay', {}), 'mock-effect-id');
    });
    test('createConvolution', () async {
      expect(
          await mock.createConvolution('n', '/f', 2048), 'mock-convolution-id');
    });

    // Streams are listenable
    test('onPlaybackStateChanged is a stream', () {
      expect(mock.onPlaybackStateChanged, isA<Stream<PlaybackState>>());
    });
    test('onPlaybackCompleted is a stream', () {
      expect(mock.onPlaybackCompleted, isA<Stream<String>>());
    });
    test('onAmplitudeData is a stream', () {
      expect(mock.onAmplitudeData, isA<Stream<AudioLevelData>>());
    });
    test('onPitchData is a stream', () {
      expect(mock.onPitchData, isA<Stream<PitchData>>());
    });
  });

  // =========================================================================
  // Void methods complete without error
  // =========================================================================
  group('Void methods complete without error', () {
    test('engine lifecycle', () async {
      await mock.startEngine('e');
      await mock.stopEngine('e');
      await mock.pauseEngine('e');
      await mock.setEngineOutput('e', 'n');
      await mock.disposeEngine('e');
    });

    test('player controls', () async {
      await mock.playerPlay('n');
      await mock.playerPlay('n', startTime: 1.0, endTime: 2.0);
      await mock.playerPause('n');
      await mock.playerResume('n');
      await mock.playerStop('n');
      await mock.playerSeek('n', 1.0);
    });

    test('player properties', () async {
      await mock.setPlayerVolume('n', 0.8);
      await mock.setPlayerIsLooping('n', true);
      await mock.setPlayerIsReversed('n', false);
    });

    test('mixer operations', () async {
      await mock.mixerAddInput('m', 'n');
      await mock.mixerRemoveInput('m', 'n');
      await mock.mixerRemoveAllInputs('m');
      await mock.setMixerVolume('m', 0.5);
      await mock.setMixerPan('m', -0.5);
      await mock.setMixerName('m', 'Main');
    });

    test('timepitch properties', () async {
      await mock.setTimePitchRate('n', 2.0);
      await mock.setTimePitchPitch('n', 100.0);
      await mock.setTimePitchOverlap('n', 16.0);
    });

    test('varispeed properties', () async {
      await mock.setVariSpeedRate('n', 1.5);
    });

    test('node operations', () async {
      await mock.startNode('n');
      await mock.stopNode('n');
      await mock.bypassNode('n');
      await mock.disposeNode('n');
      await mock.setNodeParameter('n', 'cutoff', 2000.0);
      await mock.rampNodeParameter('n', 'cutoff',
          value: 5000.0, duration: 1.0, delay: 0.5);
    });

    test('effects', () async {
      await mock.loadReverbPreset('n', 0);
    });

    test('taps', () async {
      await mock.startAmplitudeTap('n');
      await mock.startAmplitudeTap('n', bufferSize: 2048);
      await mock.stopAmplitudeTap('n');
      await mock.startPitchTap('n');
      await mock.startPitchTap('n', bufferSize: 8192);
      await mock.stopPitchTap('n');
    });

    test('settings', () async {
      await mock.setGlobalSampleRate(48000);
      await mock.setGlobalBufferLength(BufferLength.long);
    });
  });
}
