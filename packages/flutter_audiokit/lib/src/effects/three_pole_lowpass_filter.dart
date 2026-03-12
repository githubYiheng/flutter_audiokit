import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Three-pole low-pass filter effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `ThreePoleLowpassFilter` class.
class ThreePoleLowpassFilter extends Node {
  ThreePoleLowpassFilter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _distortion = 0.5;
  double _cutoffFrequency = 1500.0;
  double _resonance = 0.5;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'ThreePoleLowpassFilter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<ThreePoleLowpassFilter> create(
    Node input, {
    double distortion = 0.5,
    double cutoffFrequency = 1500.0,
    double resonance = 0.5,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'ThreePoleLowpassFilter',
      {
        'distortion': distortion,
        'cutoffFrequency': cutoffFrequency,
        'resonance': resonance,
      },
    );
    return ThreePoleLowpassFilter._(nodeId, input)
      .._distortion = distortion
      .._cutoffFrequency = cutoffFrequency
      .._resonance = resonance;
  }

  /// Distortion. 0...2, default 0.5.
  double get distortion => _distortion;
  set distortion(double value) {
    _distortion = value.clamp(0.0, 2.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'distortion', _distortion);
  }

  /// Cutoff frequency in Hz. 12...20000, default 1500.
  double get cutoffFrequency => _cutoffFrequency;
  set cutoffFrequency(double value) {
    _cutoffFrequency = value.clamp(12.0, 20000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'cutoffFrequency', _cutoffFrequency);
  }

  /// Resonance. 0...2, default 0.5.
  double get resonance => _resonance;
  set resonance(double value) {
    _resonance = value.clamp(0.0, 2.0);
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
