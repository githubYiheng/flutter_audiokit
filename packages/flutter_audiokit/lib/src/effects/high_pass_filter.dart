import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// High-pass filter effect node.
///
/// Mirrors AudioKit's `HighPassFilter` class.
///
/// ```dart
/// final hpf = await HighPassFilter.create(player, cutoffFrequency: 500);
/// ```
class HighPassFilter extends Node {
  HighPassFilter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  // Write-through cache
  double _cutoffFrequency = 6900.0;
  double _resonance = 0.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'HighPassFilter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  /// The input node.
  Node get input => _input;

  /// Creates a HighPassFilter effect node.
  ///
  /// Mirrors `HighPassFilter(input, cutoffFrequency:resonance:)`.
  static Future<HighPassFilter> create(
    Node input, {
    double cutoffFrequency = 6900.0,
    double resonance = 0.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'HighPassFilter',
      {
        'cutoffFrequency': cutoffFrequency,
        'resonance': resonance,
      },
    );
    return HighPassFilter._(nodeId, input)
      .._cutoffFrequency = cutoffFrequency
      .._resonance = resonance;
  }

  /// Cutoff frequency in Hz. 10...22050, default 6900.
  double get cutoffFrequency => _cutoffFrequency;
  set cutoffFrequency(double value) {
    _cutoffFrequency = value.clamp(10.0, 22050.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'cutoffFrequency', _cutoffFrequency);
  }

  /// Resonance in dB. -20...40, default 0.
  double get resonance => _resonance;
  set resonance(double value) {
    _resonance = value.clamp(-20.0, 40.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'resonance', _resonance);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
