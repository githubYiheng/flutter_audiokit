import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Comb filter reverb effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `CombFilterReverb` class.
class CombFilterReverb extends Node {
  CombFilterReverb._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _reverbDuration = 1.0;
  double _loopDuration = 0.1;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'CombFilterReverb';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  /// Creates a CombFilterReverb effect node.
  ///
  /// [loopDuration] is init-only and cannot be changed after creation.
  static Future<CombFilterReverb> create(
    Node input, {
    double reverbDuration = 1.0,
    double loopDuration = 0.1,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'CombFilterReverb',
      {
        'reverbDuration': reverbDuration,
        'loopDuration': loopDuration,
      },
    );
    return CombFilterReverb._(nodeId, input)
      .._reverbDuration = reverbDuration
      .._loopDuration = loopDuration;
  }

  /// Loop duration set at creation (init-only, read-only).
  double get loopDuration => _loopDuration;

  /// Reverb duration in seconds. 0...10, default 1.0.
  double get reverbDuration => _reverbDuration;
  set reverbDuration(double value) {
    _reverbDuration = value.clamp(0.0, 10.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'reverbDuration', _reverbDuration);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
