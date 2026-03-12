import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Vibrato effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `Vibrato` class.
class Vibrato extends Node {
  Vibrato._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _speed = 1.0;
  double _depth = 1.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'Vibrato';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<Vibrato> create(
    Node input, {
    double speed = 1.0,
    double depth = 1.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'Vibrato',
      {
        'speed': speed,
        'depth': depth,
      },
    );
    return Vibrato._(nodeId, input)
      .._speed = speed
      .._depth = depth;
  }

  /// Speed in Hz. 0...100, default 1.
  double get speed => _speed;
  set speed(double value) {
    _speed = value.clamp(0.0, 100.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'speed', _speed);
  }

  /// Depth in semitones. 0...24, default 1.
  double get depth => _depth;
  set depth(double value) {
    _depth = value.clamp(0.0, 24.0);
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
