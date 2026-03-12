import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Clipper effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `Clipper` class.
class Clipper extends Node {
  Clipper._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _limit = 1.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'Clipper';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  /// Creates a Clipper effect node.
  static Future<Clipper> create(
    Node input, {
    double limit = 1.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'Clipper',
      {'limit': limit},
    );
    return Clipper._(nodeId, input).._limit = limit;
  }

  /// Clipping limit. 0...1, default 1.
  double get limit => _limit;
  set limit(double value) {
    _limit = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'limit', _limit);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
