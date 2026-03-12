import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import 'node.dart';

/// Time-stretch and pitch-shift effect node.
///
/// Mirrors AudioKit's `TimePitch` class. Allows independent control
/// of playback rate and pitch.
///
/// ```dart
/// final timePitch = await TimePitch.create(player, rate: 1.0, pitch: 200);
/// ```
class TimePitch extends Node {
  TimePitch._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  // Write-through cache
  double _rate = 1.0;
  double _pitch = 0.0;
  double _overlap = 8.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'TimePitch';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  /// The input node.
  Node get input => _input;

  /// Creates a TimePitch effect node.
  ///
  /// Mirrors `TimePitch(input, rate:pitch:overlap:)`.
  ///
  /// - [rate]: Playback rate. 0.03125...32.0, default 1.0.
  /// - [pitch]: Pitch shift in cents. -2400...2400, default 0.0.
  /// - [overlap]: Overlap factor. 3.0...32.0, default 8.0.
  static Future<TimePitch> create(
    Node input, {
    double rate = 1.0,
    double pitch = 0.0,
    double overlap = 8.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createTimePitch(
      input.nodeId,
      rate: rate,
      pitch: pitch,
      overlap: overlap,
    );
    return TimePitch._(nodeId, input)
      .._rate = rate
      .._pitch = pitch
      .._overlap = overlap;
  }

  /// Playback rate. 0.03125...32.0, default 1.0.
  ///
  /// Mirrors `timePitch.rate`.
  double get rate => _rate;
  set rate(double value) {
    _rate = value.clamp(0.03125, 32.0);
    FlutterAudioKitPlatform.instance.setTimePitchRate(_nodeId, _rate);
  }

  /// Pitch shift in cents. -2400...2400, default 0.0.
  ///
  /// Mirrors `timePitch.pitch`.
  double get pitch => _pitch;
  set pitch(double value) {
    _pitch = value.clamp(-2400.0, 2400.0);
    FlutterAudioKitPlatform.instance.setTimePitchPitch(_nodeId, _pitch);
  }

  /// Overlap factor. 3.0...32.0, default 8.0.
  ///
  /// Mirrors `timePitch.overlap`.
  double get overlap => _overlap;
  set overlap(double value) {
    _overlap = value.clamp(3.0, 32.0);
    FlutterAudioKitPlatform.instance.setTimePitchOverlap(_nodeId, _overlap);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
