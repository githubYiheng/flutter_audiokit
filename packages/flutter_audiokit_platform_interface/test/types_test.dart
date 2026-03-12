import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

void main() {
  // ===========================================================================
  // AudioFileInfo
  // ===========================================================================
  group('AudioFileInfo', () {
    test('stores all fields', () {
      const info = AudioFileInfo(
        duration: 120.5,
        sampleRate: 44100,
        channels: 2,
      );
      expect(info.duration, 120.5);
      expect(info.sampleRate, 44100);
      expect(info.channels, 2);
    });

    test('supports mono', () {
      const info = AudioFileInfo(
        duration: 60.0,
        sampleRate: 48000,
        channels: 1,
      );
      expect(info.channels, 1);
      expect(info.sampleRate, 48000);
    });
  });

  // ===========================================================================
  // PlaybackStatus enum
  // ===========================================================================
  group('PlaybackStatus', () {
    test('has all expected values', () {
      expect(PlaybackStatus.values, hasLength(4));
      expect(PlaybackStatus.values,
          containsAll([
            PlaybackStatus.stopped,
            PlaybackStatus.playing,
            PlaybackStatus.paused,
            PlaybackStatus.scheduling,
          ]));
    });
  });

  // ===========================================================================
  // PlaybackState
  // ===========================================================================
  group('PlaybackState', () {
    test('stores all fields', () {
      const state = PlaybackState(
        nodeId: 'player-1',
        status: PlaybackStatus.playing,
        currentTime: 30.0,
        duration: 120.0,
      );
      expect(state.nodeId, 'player-1');
      expect(state.status, PlaybackStatus.playing);
      expect(state.currentTime, 30.0);
      expect(state.duration, 120.0);
    });

    test('position is normalized 0.0 to 1.0', () {
      const state = PlaybackState(
        nodeId: 'p',
        status: PlaybackStatus.playing,
        currentTime: 60.0,
        duration: 120.0,
      );
      expect(state.position, 0.5);
    });

    test('position at start is 0.0', () {
      const state = PlaybackState(
        nodeId: 'p',
        status: PlaybackStatus.stopped,
        currentTime: 0.0,
        duration: 120.0,
      );
      expect(state.position, 0.0);
    });

    test('position at end is 1.0', () {
      const state = PlaybackState(
        nodeId: 'p',
        status: PlaybackStatus.stopped,
        currentTime: 120.0,
        duration: 120.0,
      );
      expect(state.position, 1.0);
    });

    test('position is clamped above 1.0', () {
      const state = PlaybackState(
        nodeId: 'p',
        status: PlaybackStatus.playing,
        currentTime: 150.0,
        duration: 120.0,
      );
      expect(state.position, 1.0);
    });

    test('position is 0.0 when duration is zero', () {
      const state = PlaybackState(
        nodeId: 'p',
        status: PlaybackStatus.stopped,
        currentTime: 0.0,
        duration: 0.0,
      );
      expect(state.position, 0.0);
    });
  });

  // ===========================================================================
  // AudioLevelData
  // ===========================================================================
  group('AudioLevelData', () {
    test('stores all fields', () {
      const data = AudioLevelData(
        nodeId: 'node-1',
        amplitude: 0.5,
        leftAmplitude: 0.4,
        rightAmplitude: 0.6,
      );
      expect(data.nodeId, 'node-1');
      expect(data.amplitude, 0.5);
      expect(data.leftAmplitude, 0.4);
      expect(data.rightAmplitude, 0.6);
    });
  });

  // ===========================================================================
  // Enums
  // ===========================================================================
  group('AnalysisMode', () {
    test('has rms and peak', () {
      expect(AnalysisMode.values, hasLength(2));
      expect(AnalysisMode.values,
          containsAll([AnalysisMode.rms, AnalysisMode.peak]));
    });
  });

  group('StereoMode', () {
    test('has left, right, center', () {
      expect(StereoMode.values, hasLength(3));
      expect(StereoMode.values,
          containsAll([StereoMode.left, StereoMode.right, StereoMode.center]));
    });
  });

  group('ConnectStrategy', () {
    test('has complete and incremental', () {
      expect(ConnectStrategy.values, hasLength(2));
      expect(
          ConnectStrategy.values,
          containsAll(
              [ConnectStrategy.complete, ConnectStrategy.incremental]));
    });
  });

  group('DisconnectStrategy', () {
    test('has recursive and detach', () {
      expect(DisconnectStrategy.values, hasLength(2));
      expect(
          DisconnectStrategy.values,
          containsAll(
              [DisconnectStrategy.recursive, DisconnectStrategy.detach]));
    });
  });

  // ===========================================================================
  // BufferLength
  // ===========================================================================
  group('BufferLength', () {
    test('has 8 values', () {
      expect(BufferLength.values, hasLength(8));
    });

    test('powerOfTwo values are correct', () {
      expect(BufferLength.shortest.powerOfTwo, 5);
      expect(BufferLength.veryShort.powerOfTwo, 6);
      expect(BufferLength.short.powerOfTwo, 7);
      expect(BufferLength.medium.powerOfTwo, 8);
      expect(BufferLength.long.powerOfTwo, 9);
      expect(BufferLength.veryLong.powerOfTwo, 10);
      expect(BufferLength.huge.powerOfTwo, 11);
      expect(BufferLength.longest.powerOfTwo, 12);
    });

    test('samplesCount is 2^powerOfTwo', () {
      expect(BufferLength.shortest.samplesCount, 32);
      expect(BufferLength.veryShort.samplesCount, 64);
      expect(BufferLength.short.samplesCount, 128);
      expect(BufferLength.medium.samplesCount, 256);
      expect(BufferLength.long.samplesCount, 512);
      expect(BufferLength.veryLong.samplesCount, 1024);
      expect(BufferLength.huge.samplesCount, 2048);
      expect(BufferLength.longest.samplesCount, 4096);
    });
  });

  // ===========================================================================
  // ReverbPreset
  // ===========================================================================
  group('ReverbPreset', () {
    test('has 13 presets', () {
      expect(ReverbPreset.values, hasLength(13));
    });

    test('index matches AVAudioUnitReverbPreset raw value', () {
      expect(ReverbPreset.smallRoom.index, 0);
      expect(ReverbPreset.mediumRoom.index, 1);
      expect(ReverbPreset.largeRoom.index, 2);
      expect(ReverbPreset.mediumHall.index, 3);
      expect(ReverbPreset.largeHall.index, 4);
      expect(ReverbPreset.plate.index, 5);
      expect(ReverbPreset.mediumChamber.index, 6);
      expect(ReverbPreset.largeChamber.index, 7);
      expect(ReverbPreset.cathedral.index, 8);
      expect(ReverbPreset.largeRoom2.index, 9);
      expect(ReverbPreset.mediumHall2.index, 10);
      expect(ReverbPreset.mediumHall3.index, 11);
      expect(ReverbPreset.largeHall2.index, 12);
    });
  });

  // ===========================================================================
  // NodeParameterInfo
  // ===========================================================================
  group('NodeParameterInfo', () {
    test('stores all fields', () {
      const info = NodeParameterInfo(
        identifier: 'cutoffFrequency',
        name: 'Cutoff Frequency',
        value: 1000.0,
        defaultValue: 1000.0,
        minValue: 12.0,
        maxValue: 20000.0,
      );
      expect(info.identifier, 'cutoffFrequency');
      expect(info.name, 'Cutoff Frequency');
      expect(info.value, 1000.0);
      expect(info.defaultValue, 1000.0);
      expect(info.minValue, 12.0);
      expect(info.maxValue, 20000.0);
    });
  });

  // ===========================================================================
  // PitchData
  // ===========================================================================
  group('PitchData', () {
    test('stores all fields', () {
      const data = PitchData(
        nodeId: 'node-1',
        leftPitch: 440.0,
        rightPitch: 440.0,
        leftAmplitude: 0.8,
        rightAmplitude: 0.75,
      );
      expect(data.nodeId, 'node-1');
      expect(data.leftPitch, 440.0);
      expect(data.rightPitch, 440.0);
      expect(data.leftAmplitude, 0.8);
      expect(data.rightAmplitude, 0.75);
    });

    test('supports mono (both channels same)', () {
      const data = PitchData(
        nodeId: 'n',
        leftPitch: 261.63,
        rightPitch: 0.0,
        leftAmplitude: 0.5,
        rightAmplitude: 0.0,
      );
      expect(data.leftPitch, closeTo(261.63, 0.01));
      expect(data.rightPitch, 0.0);
    });
  });

  // ===========================================================================
  // AudioKitError
  // ===========================================================================
  group('AudioKitError', () {
    test('stores all fields', () {
      const error = AudioKitError(
        code: 'ENGINE_START_FAILED',
        message: 'Failed to start engine',
        nodeId: 'engine-1',
      );
      expect(error.code, 'ENGINE_START_FAILED');
      expect(error.message, 'Failed to start engine');
      expect(error.nodeId, 'engine-1');
    });

    test('nodeId is optional', () {
      const error = AudioKitError(
        code: 'UNKNOWN',
        message: 'Something went wrong',
      );
      expect(error.nodeId, isNull);
    });

    test('implements Exception', () {
      const error = AudioKitError(code: 'E', message: 'msg');
      expect(error, isA<Exception>());
    });

    test('toString includes code and message', () {
      const error = AudioKitError(code: 'E001', message: 'test error');
      expect(error.toString(), 'AudioKitError(E001): test error');
    });
  });
}
