import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Tremolo effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `Tremolo` class.
/// Note: Waveform (Table) parameter is set to default (positiveSine) on native side.
class Tremolo extends Node {
  Tremolo._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _frequency = 10.0;
  double _depth = 1.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'Tremolo';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<Tremolo> create(
    Node input, {
    double frequency = 10.0,
    double depth = 1.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'Tremolo',
      {
        'frequency': frequency,
        'depth': depth,
      },
    );
    return Tremolo._(nodeId, input)
      .._frequency = frequency
      .._depth = depth;
  }

  /// Frequency in Hz. 0...100, default 10.
  double get frequency => _frequency;
  set frequency(double value) {
    _frequency = value.clamp(0.0, 100.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'frequency', _frequency);
  }

  /// Depth. 0...1, default 1.
  double get depth => _depth;
  set depth(double value) {
    _depth = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'depth', _depth);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
