import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Pitch shifter effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `PitchShifter` class.
///
/// ```dart
/// final shifter = await PitchShifter.create(player, shift: 7);
/// ```
class PitchShifter extends Node {
  PitchShifter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  // Write-through cache
  double _shift = 0.0;
  double _windowSize = 1024.0;
  double _crossfade = 512.0;
  double _dryWetMix = 1.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'PitchShifter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  /// The input node.
  Node get input => _input;

  /// Creates a PitchShifter effect node.
  ///
  /// Mirrors `PitchShifter(input, shift:windowSize:crossfade:dryWetMix:)`.
  static Future<PitchShifter> create(
    Node input, {
    double shift = 0.0,
    double windowSize = 1024.0,
    double crossfade = 512.0,
    double dryWetMix = 1.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'PitchShifter',
      {
        'shift': shift,
        'windowSize': windowSize,
        'crossfade': crossfade,
        'dryWetMix': dryWetMix,
      },
    );
    return PitchShifter._(nodeId, input)
      .._shift = shift
      .._windowSize = windowSize
      .._crossfade = crossfade
      .._dryWetMix = dryWetMix;
  }

  /// Pitch shift in semitones. -24...24, default 0.
  double get shift => _shift;
  set shift(double value) {
    _shift = value.clamp(-24.0, 24.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'shift', _shift);
  }

  /// Window size in samples. 0...10000, default 1024.
  double get windowSize => _windowSize;
  set windowSize(double value) {
    _windowSize = value.clamp(0.0, 10000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'windowSize', _windowSize);
  }

  /// Crossfade in samples. 0...10000, default 512.
  double get crossfade => _crossfade;
  set crossfade(double value) {
    _crossfade = value.clamp(0.0, 10000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'crossfade', _crossfade);
  }

  /// Dry/wet mix. 0...1, default 1.
  double get dryWetMix => _dryWetMix;
  set dryWetMix(double value) {
    _dryWetMix = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'dryWetMix', _dryWetMix);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
