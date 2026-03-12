import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Amplitude envelope (ADSR) effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `AmplitudeEnvelope` class.
class AmplitudeEnvelope extends Node {
  AmplitudeEnvelope._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _attackDuration = 0.1;
  double _decayDuration = 0.1;
  double _sustainLevel = 1.0;
  double _releaseDuration = 0.1;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'AmplitudeEnvelope';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<AmplitudeEnvelope> create(
    Node input, {
    double attackDuration = 0.1,
    double decayDuration = 0.1,
    double sustainLevel = 1.0,
    double releaseDuration = 0.1,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'AmplitudeEnvelope',
      {
        'attackDuration': attackDuration,
        'decayDuration': decayDuration,
        'sustainLevel': sustainLevel,
        'releaseDuration': releaseDuration,
      },
    );
    return AmplitudeEnvelope._(nodeId, input)
      .._attackDuration = attackDuration
      .._decayDuration = decayDuration
      .._sustainLevel = sustainLevel
      .._releaseDuration = releaseDuration;
  }

  /// Attack duration in seconds. 0...99, default 0.1.
  double get attackDuration => _attackDuration;
  set attackDuration(double value) {
    _attackDuration = value.clamp(0.0, 99.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'attackDuration', _attackDuration);
  }

  /// Decay duration in seconds. 0...99, default 0.1.
  double get decayDuration => _decayDuration;
  set decayDuration(double value) {
    _decayDuration = value.clamp(0.0, 99.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'decayDuration', _decayDuration);
  }

  /// Sustain level. 0...99, default 1.
  double get sustainLevel => _sustainLevel;
  set sustainLevel(double value) {
    _sustainLevel = value.clamp(0.0, 99.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'sustainLevel', _sustainLevel);
  }

  /// Release duration in seconds. 0...99, default 0.1.
  double get releaseDuration => _releaseDuration;
  set releaseDuration(double value) {
    _releaseDuration = value.clamp(0.0, 99.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'releaseDuration', _releaseDuration);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
