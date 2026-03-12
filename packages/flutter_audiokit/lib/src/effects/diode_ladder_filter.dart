import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Diode ladder filter effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `DiodeLadderFilter` class.
class DiodeLadderFilter extends Node {
  DiodeLadderFilter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _cutoffFrequency = 1000.0;
  double _resonance = 0.5;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'DiodeLadderFilter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<DiodeLadderFilter> create(
    Node input, {
    double cutoffFrequency = 1000.0,
    double resonance = 0.5,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'DiodeLadderFilter',
      {
        'cutoffFrequency': cutoffFrequency,
        'resonance': resonance,
      },
    );
    return DiodeLadderFilter._(nodeId, input)
      .._cutoffFrequency = cutoffFrequency
      .._resonance = resonance;
  }

  /// Cutoff frequency in Hz. 12...20000, default 1000.
  double get cutoffFrequency => _cutoffFrequency;
  set cutoffFrequency(double value) {
    _cutoffFrequency = value.clamp(12.0, 20000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'cutoffFrequency', _cutoffFrequency);
  }

  /// Resonance. 0...1, default 0.5.
  double get resonance => _resonance;
  set resonance(double value) {
    _resonance = value.clamp(0.0, 1.0);
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
