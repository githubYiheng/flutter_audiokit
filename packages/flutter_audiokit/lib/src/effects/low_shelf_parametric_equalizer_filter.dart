import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Low-shelf parametric equalizer filter effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `LowShelfParametricEqualizerFilter` class.
class LowShelfParametricEqualizerFilter extends Node {
  LowShelfParametricEqualizerFilter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _cornerFrequency = 1000.0;
  double _gain = 1.0;
  double _q = 0.707;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'LowShelfParametricEqualizerFilter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<LowShelfParametricEqualizerFilter> create(
    Node input, {
    double cornerFrequency = 1000.0,
    double gain = 1.0,
    double q = 0.707,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'LowShelfParametricEqualizerFilter',
      {
        'cornerFrequency': cornerFrequency,
        'gain': gain,
        'q': q,
      },
    );
    return LowShelfParametricEqualizerFilter._(nodeId, input)
      .._cornerFrequency = cornerFrequency
      .._gain = gain
      .._q = q;
  }

  /// Corner frequency in Hz. 12...20000, default 1000.
  double get cornerFrequency => _cornerFrequency;
  set cornerFrequency(double value) {
    _cornerFrequency = value.clamp(12.0, 20000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'cornerFrequency', _cornerFrequency);
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
