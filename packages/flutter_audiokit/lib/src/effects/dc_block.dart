import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// DC blocking filter effect node (SoundpipeAudioKit).
///
/// Removes DC offset from audio signal. No user-controllable parameters.
/// Mirrors SoundpipeAudioKit's `DCBlock` class.
class DCBlock extends Node {
  DCBlock._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'DCBlock';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<DCBlock> create(Node input) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'DCBlock',
      {},
    );
    return DCBlock._(nodeId, input);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
