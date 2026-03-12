import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Parametric equalizer effect node.
///
/// Mirrors AudioKit's `ParametricEQ` class.
///
/// ```dart
/// final eq = await ParametricEQ.create(player, centerFreq: 1000, gain: 6);
/// ```
class ParametricEQ extends Node {
  ParametricEQ._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  // Write-through cache
  double _centerFreq = 2000.0;
  double _q = 1.0;
  double _gain = 0.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'ParametricEQ';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  /// The input node.
  Node get input => _input;

  /// Creates a ParametricEQ effect node.
  ///
  /// Mirrors `ParametricEQ(input, centerFreq:q:gain:)`.
  static Future<ParametricEQ> create(
    Node input, {
    double centerFreq = 2000.0,
    double q = 1.0,
    double gain = 0.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'ParametricEQ',
      {
        'centerFreq': centerFreq,
        'q': q,
        'gain': gain,
      },
    );
    return ParametricEQ._(nodeId, input)
      .._centerFreq = centerFreq
      .._q = q
      .._gain = gain;
  }

  /// Center frequency in Hz. 20...22050, default 2000.
  double get centerFreq => _centerFreq;
  set centerFreq(double value) {
    _centerFreq = value.clamp(20.0, 22050.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'centerFreq', _centerFreq);
  }

  /// Q factor. 0.1...20, default 1.0.
  double get q => _q;
  set q(double value) {
    _q = value.clamp(0.1, 20.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'q', _q);
  }

  /// Gain in dB. -20...20, default 0.
  double get gain => _gain;
  set gain(double value) {
    _gain = value.clamp(-20.0, 20.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'gain', _gain);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
