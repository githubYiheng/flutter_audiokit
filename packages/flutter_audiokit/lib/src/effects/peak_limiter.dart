import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Peak limiter dynamics effect node.
///
/// Mirrors AudioKit's `PeakLimiter` class.
///
/// ```dart
/// final limiter = await PeakLimiter.create(mixer, preGain: 6);
/// ```
class PeakLimiter extends Node {
  PeakLimiter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  // Write-through cache
  double _attackTime = 0.012;
  double _decayTime = 0.024;
  double _preGain = 0.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'PeakLimiter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  /// The input node.
  Node get input => _input;

  /// Creates a PeakLimiter effect node.
  ///
  /// Mirrors `PeakLimiter(input, attackTime:decayTime:preGain:)`.
  static Future<PeakLimiter> create(
    Node input, {
    double attackTime = 0.012,
    double decayTime = 0.024,
    double preGain = 0.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'PeakLimiter',
      {
        'attackTime': attackTime,
        'decayTime': decayTime,
        'preGain': preGain,
      },
    );
    return PeakLimiter._(nodeId, input)
      .._attackTime = attackTime
      .._decayTime = decayTime
      .._preGain = preGain;
  }

  /// Attack time in seconds. 0.001...0.03, default 0.012.
  double get attackTime => _attackTime;
  set attackTime(double value) {
    _attackTime = value.clamp(0.001, 0.03);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'attackTime', _attackTime);
  }

  /// Decay time in seconds. 0.001...0.06, default 0.024.
  double get decayTime => _decayTime;
  set decayTime(double value) {
    _decayTime = value.clamp(0.001, 0.06);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'decayTime', _decayTime);
  }

  /// Pre-gain in dB. -40...40, default 0.
  double get preGain => _preGain;
  set preGain(double value) {
    _preGain = value.clamp(-40.0, 40.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'preGain', _preGain);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
