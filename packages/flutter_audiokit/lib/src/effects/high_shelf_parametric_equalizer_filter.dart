import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// High-shelf parametric equalizer filter effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `HighShelfParametricEqualizerFilter` class.
class HighShelfParametricEqualizerFilter extends Node {
  HighShelfParametricEqualizerFilter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _centerFrequency = 1000.0;
  double _gain = 1.0;
  double _q = 0.707;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'HighShelfParametricEqualizerFilter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<HighShelfParametricEqualizerFilter> create(
    Node input, {
    double centerFrequency = 1000.0,
    double gain = 1.0,
    double q = 0.707,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'HighShelfParametricEqualizerFilter',
      {
        'centerFrequency': centerFrequency,
        'gain': gain,
        'q': q,
      },
    );
    return HighShelfParametricEqualizerFilter._(nodeId, input)
      .._centerFrequency = centerFrequency
      .._gain = gain
      .._q = q;
  }

  /// Center frequency in Hz. 12...20000, default 1000.
  double get centerFrequency => _centerFrequency;
  set centerFrequency(double value) {
    _centerFrequency = value.clamp(12.0, 20000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'centerFrequency', _centerFrequency);
  }

  /// Gain. 0...10, default 1.
  double get gain => _gain;
  set gain(double value) {
    _gain = value.clamp(0.0, 10.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'gain', _gain);
  }

  /// Q factor. 0...2, default 0.707.
  double get q => _q;
  set q(double value) {
    _q = value.clamp(0.0, 2.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'q', _q);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
