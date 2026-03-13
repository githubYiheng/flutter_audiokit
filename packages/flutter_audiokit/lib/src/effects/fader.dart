import 'dart:math' as math;

import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../logger.dart';
import '../node.dart';

/// Stereo fader / gain node (AudioKitEX).
///
/// Mirrors AudioKitEX's `Fader` class. Controls gain with independent
/// left/right channels and supports smooth ramping for fade-in/fade-out.
///
/// ```dart
/// final fader = await Fader.create(player, gain: 0.0);
/// await player.play();
/// // Fade in over 2 seconds
/// await fader.rampGain(to: 1.0, duration: 2.0);
/// ```
class Fader extends Node {
  Fader._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  // Write-through cache
  double _leftGain = 1.0;
  double _rightGain = 1.0;
  bool _flipStereo = false;
  bool _mixToMono = false;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'Fader';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  /// The input node.
  Node get input => _input;

  /// Creates a Fader node.
  ///
  /// Mirrors `Fader(input, gain:)`.
  static Future<Fader> create(
    Node input, {
    double gain = 1.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'Fader',
      {'gain': gain},
    );
    AudioKitLogger.info('Fader created: $nodeId');
    return Fader._(nodeId, input)
      .._leftGain = gain
      .._rightGain = gain;
  }

  // ---- Properties (write-through cache) ----

  /// Overall gain. Sets both left and right channels.
  ///
  /// 0 = silence, 1 = unity. Default 1.
  ///
  /// Mirrors `fader.gain`.
  double get gain => _leftGain;
  set gain(double value) {
    final clamped = value < 0 ? 0.0 : value;
    _leftGain = clamped;
    _rightGain = clamped;
    AudioKitLogger.verbose('Fader($_nodeId) gain = $clamped');
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'leftGain', clamped);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'rightGain', clamped);
  }

  /// Left channel gain. >= 0, default 1.
  ///
  /// Mirrors `fader.leftGain`.
  double get leftGain => _leftGain;
  set leftGain(double value) {
    _leftGain = value < 0 ? 0.0 : value;
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'leftGain', _leftGain);
  }

  /// Right channel gain. >= 0, default 1.
  ///
  /// Mirrors `fader.rightGain`.
  double get rightGain => _rightGain;
  set rightGain(double value) {
    _rightGain = value < 0 ? 0.0 : value;
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'rightGain', _rightGain);
  }

  /// Gain in decibels. 0 dB = unity (gain 1.0).
  ///
  /// Mirrors `fader.dB`.
  double get dB => 20.0 * math.log(gain) / math.ln10;
  set dB(double value) {
    gain = math.pow(10.0, value / 20.0).toDouble();
  }

  /// Whether to flip left and right channels. Default false.
  ///
  /// Mirrors `fader.flipStereo`.
  bool get flipStereo => _flipStereo;
  set flipStereo(bool value) {
    _flipStereo = value;
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'flipStereo', value ? 1.0 : 0.0);
  }

  /// Whether to mix stereo down to mono. Default false.
  ///
  /// Mirrors `fader.mixToMono`.
  bool get mixToMono => _mixToMono;
  set mixToMono(bool value) {
    _mixToMono = value;
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'mixToMono', value ? 1.0 : 0.0);
  }

  // ---- Ramp methods ----

  /// Ramps gain (both channels) to [to] over [duration] seconds.
  ///
  /// If [from] is provided, the gain is instantly set to [from] via the audio
  /// scheduler (duration=0 ramp), then ramped to [to]. All calls are dispatched
  /// in a single batch to preserve ordering on the native audio timeline.
  ///
  /// ```dart
  /// // Fade in from silence over 2 seconds
  /// fader.rampGain(from: 0.0, to: 1.0, duration: 2.0);
  /// // Fade out from current gain
  /// fader.rampGain(to: 0.0, duration: 1.5);
  /// ```
  Future<void> rampGain({
    required double to,
    required double duration,
    double? from,
    double delay = 0,
  }) async {
    final target = to < 0 ? 0.0 : to;
    _leftGain = target;
    _rightGain = target;
    if (from != null) {
      final start = from < 0 ? 0.0 : from;
      AudioKitLogger.info(
          'Fader($_nodeId) rampGain $start -> $target over ${duration}s');
      // Dispatch all 4 calls at once — no intermediate await — so they
      // arrive at the native audio scheduler in a single batch:
      //   1) Instantly set to [start] (duration=0)
      //   2) Ramp to [target] over [duration] (tiny delay to sequence after 1)
      await Future.wait([
        FlutterAudioKitPlatform.instance.rampNodeParameter(
          _nodeId, 'leftGain',
          value: start, duration: 0, delay: delay,
        ),
        FlutterAudioKitPlatform.instance.rampNodeParameter(
          _nodeId, 'rightGain',
          value: start, duration: 0, delay: delay,
        ),
        FlutterAudioKitPlatform.instance.rampNodeParameter(
          _nodeId, 'leftGain',
          value: target, duration: duration, delay: delay + 0.001,
        ),
        FlutterAudioKitPlatform.instance.rampNodeParameter(
          _nodeId, 'rightGain',
          value: target, duration: duration, delay: delay + 0.001,
        ),
      ]);
    } else {
      AudioKitLogger.info(
          'Fader($_nodeId) rampGain -> $target over ${duration}s');
      await Future.wait([
        FlutterAudioKitPlatform.instance.rampNodeParameter(
          _nodeId, 'leftGain',
          value: target, duration: duration, delay: delay,
        ),
        FlutterAudioKitPlatform.instance.rampNodeParameter(
          _nodeId, 'rightGain',
          value: target, duration: duration, delay: delay,
        ),
      ]);
    }
  }

  /// Ramps left channel gain to [to] over [duration] seconds.
  Future<void> rampLeftGain({
    required double to,
    required double duration,
    double delay = 0,
  }) {
    _leftGain = to < 0 ? 0.0 : to;
    return FlutterAudioKitPlatform.instance.rampNodeParameter(
      _nodeId,
      'leftGain',
      value: _leftGain,
      duration: duration,
      delay: delay,
    );
  }

  /// Ramps right channel gain to [to] over [duration] seconds.
  Future<void> rampRightGain({
    required double to,
    required double duration,
    double delay = 0,
  }) {
    _rightGain = to < 0 ? 0.0 : to;
    return FlutterAudioKitPlatform.instance.rampNodeParameter(
      _nodeId,
      'rightGain',
      value: _rightGain,
      duration: duration,
      delay: delay,
    );
  }

  // ---- Lifecycle ----

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
    AudioKitLogger.info('Fader($_nodeId) disposed');
  }
}
