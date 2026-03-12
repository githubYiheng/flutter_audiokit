import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Stereo panner effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `Panner` class.
///
/// ```dart
/// final panner = await Panner.create(player, pan: -0.5);
/// ```
class Panner extends Node {
  Panner._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  // Write-through cache
  double _pan = 0.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'Panner';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  /// The input node.
  Node get input => _input;

  /// Creates a Panner effect node.
  ///
  /// Mirrors `Panner(input, pan:)`.
  static Future<Panner> create(
    Node input, {
    double pan = 0.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'Panner',
      {'pan': pan},
    );
    return Panner._(nodeId, input).._pan = pan;
  }

  /// Pan position. -1 (left) to 1 (right), default 0 (center).
  double get pan => _pan;
  set pan(double value) {
    _pan = value.clamp(-1.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'pan', _pan);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
