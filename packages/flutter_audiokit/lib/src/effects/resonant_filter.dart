import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Resonant filter effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `ResonantFilter` class.
class ResonantFilter extends Node {
  ResonantFilter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _frequency = 4000.0;
  double _bandwidth = 1000.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'ResonantFilter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<ResonantFilter> create(
    Node input, {
    double frequency = 4000.0,
    double bandwidth = 1000.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'ResonantFilter',
      {
        'frequency': frequency,
        'bandwidth': bandwidth,
      },
    );
    return ResonantFilter._(nodeId, input)
      .._frequency = frequency
      .._bandwidth = bandwidth;
  }

  /// Frequency in Hz. 100...20000, default 4000.
  double get frequency => _frequency;
  set frequency(double value) {
    _frequency = value.clamp(100.0, 20000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'frequency', _frequency);
  }

  /// Bandwidth in Hz. 0...10000, default 1000.
  double get bandwidth => _bandwidth;
  set bandwidth(double value) {
    _bandwidth = value.clamp(0.0, 10000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'bandwidth', _bandwidth);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
