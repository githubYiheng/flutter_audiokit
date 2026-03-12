import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Korg low-pass filter effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `KorgLowPassFilter` class.
class KorgLowPassFilter extends Node {
  KorgLowPassFilter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _cutoffFrequency = 1000.0;
  double _resonance = 1.0;
  double _saturation = 0.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'KorgLowPassFilter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<KorgLowPassFilter> create(
    Node input, {
    double cutoffFrequency = 1000.0,
    double resonance = 1.0,
    double saturation = 0.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'KorgLowPassFilter',
      {
        'cutoffFrequency': cutoffFrequency,
        'resonance': resonance,
        'saturation': saturation,
      },
    );
    return KorgLowPassFilter._(nodeId, input)
      .._cutoffFrequency = cutoffFrequency
      .._resonance = resonance
      .._saturation = saturation;
  }

  /// Cutoff frequency in Hz. 0...22050, default 1000.
  double get cutoffFrequency => _cutoffFrequency;
  set cutoffFrequency(double value) {
    _cutoffFrequency = value.clamp(0.0, 22050.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'cutoffFrequency', _cutoffFrequency);
  }

  /// Resonance. 0...2, default 1.
  double get resonance => _resonance;
  set resonance(double value) {
    _resonance = value.clamp(0.0, 2.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'resonance', _resonance);
  }

  /// Saturation. 0...10, default 0.
  double get saturation => _saturation;
  set saturation(double value) {
    _saturation = value.clamp(0.0, 10.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'saturation', _saturation);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
