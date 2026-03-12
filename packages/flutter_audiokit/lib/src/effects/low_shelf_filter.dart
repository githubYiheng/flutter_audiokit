import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Low-shelf filter effect node.
///
/// Mirrors AudioKit's `LowShelfFilter` class.
///
/// ```dart
/// final lsf = await LowShelfFilter.create(player, gain: 6);
/// ```
class LowShelfFilter extends Node {
  LowShelfFilter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  // Write-through cache
  double _cutoffFrequency = 80.0;
  double _gain = 0.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'LowShelfFilter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  /// The input node.
  Node get input => _input;

  /// Creates a LowShelfFilter effect node.
  ///
  /// Mirrors `LowShelfFilter(input, cutoffFrequency:gain:)`.
  static Future<LowShelfFilter> create(
    Node input, {
    double cutoffFrequency = 80.0,
    double gain = 0.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'LowShelfFilter',
      {
        'cutoffFrequency': cutoffFrequency,
        'gain': gain,
      },
    );
    return LowShelfFilter._(nodeId, input)
      .._cutoffFrequency = cutoffFrequency
      .._gain = gain;
  }

  /// Cutoff frequency in Hz. 10...200, default 80.
  double get cutoffFrequency => _cutoffFrequency;
  set cutoffFrequency(double value) {
    _cutoffFrequency = value.clamp(10.0, 200.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'cutoffFrequency', _cutoffFrequency);
  }

  /// Gain in dB. -40...40, default 0.
  double get gain => _gain;
  set gain(double value) {
    _gain = value.clamp(-40.0, 40.0);
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
