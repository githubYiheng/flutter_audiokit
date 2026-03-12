import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Chowning reverb effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `ChowningReverb` class.
class ChowningReverb extends Node {
  ChowningReverb._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _balance = 1.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'ChowningReverb';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  /// Creates a ChowningReverb effect node.
  static Future<ChowningReverb> create(
    Node input, {
    double balance = 1.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'ChowningReverb',
      {'balance': balance},
    );
    return ChowningReverb._(nodeId, input).._balance = balance;
  }

  /// Dry/wet balance. 0...1, default 1.
  double get balance => _balance;
  set balance(double value) {
    _balance = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'balance', _balance);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
