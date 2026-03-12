import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Roland TB-303 style filter effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `RolandTB303Filter` class.
class RolandTB303Filter extends Node {
  RolandTB303Filter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _cutoffFrequency = 500.0;
  double _resonance = 0.5;
  double _distortion = 2.0;
  double _resonanceAsymmetry = 0.5;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'RolandTB303Filter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<RolandTB303Filter> create(
    Node input, {
    double cutoffFrequency = 500.0,
    double resonance = 0.5,
    double distortion = 2.0,
    double resonanceAsymmetry = 0.5,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'RolandTB303Filter',
      {
        'cutoffFrequency': cutoffFrequency,
        'resonance': resonance,
        'distortion': distortion,
        'resonanceAsymmetry': resonanceAsymmetry,
      },
    );
    return RolandTB303Filter._(nodeId, input)
      .._cutoffFrequency = cutoffFrequency
      .._resonance = resonance
      .._distortion = distortion
      .._resonanceAsymmetry = resonanceAsymmetry;
  }

  /// Cutoff frequency in Hz. 12...20000, default 500.
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

  /// Distortion. 0...4, default 2.
  double get distortion => _distortion;
  set distortion(double value) {
    _distortion = value.clamp(0.0, 4.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'distortion', _distortion);
  }

  /// Resonance asymmetry. 0...1, default 0.5.
  double get resonanceAsymmetry => _resonanceAsymmetry;
  set resonanceAsymmetry(double value) {
    _resonanceAsymmetry = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'resonanceAsymmetry', _resonanceAsymmetry);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
