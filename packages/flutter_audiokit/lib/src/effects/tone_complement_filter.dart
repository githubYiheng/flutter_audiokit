import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Tone complement filter effect node (SoundpipeAudioKit).
///
/// A first-order recursive high-pass filter (complement of ToneFilter).
/// Mirrors SoundpipeAudioKit's `ToneComplementFilter` class.
class ToneComplementFilter extends Node {
  ToneComplementFilter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _halfPowerPoint = 1000.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'ToneComplementFilter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<ToneComplementFilter> create(
    Node input, {
    double halfPowerPoint = 1000.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'ToneComplementFilter',
      {'halfPowerPoint': halfPowerPoint},
    );
    return ToneComplementFilter._(nodeId, input)
      .._halfPowerPoint = halfPowerPoint;
  }

  /// Half-power point (response frequency) in Hz. 12...20000, default 1000.
  double get halfPowerPoint => _halfPowerPoint;
  set halfPowerPoint(double value) {
    _halfPowerPoint = value.clamp(12.0, 20000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'halfPowerPoint', _halfPowerPoint);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
