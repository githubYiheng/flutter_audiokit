import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import 'logger.dart';
import 'node.dart';

/// Variable-speed playback node.
///
/// Mirrors AudioKit's `VariSpeed` class. Changes playback speed
/// without independent pitch control (pitch changes proportionally).
///
/// ```dart
/// final variSpeed = await VariSpeed.create(player, rate: 1.5);
/// ```
class VariSpeed extends Node {
  VariSpeed._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  // Write-through cache
  double _rate = 1.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'VariSpeed';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  /// The input node.
  Node get input => _input;

  /// Creates a VariSpeed node.
  ///
  /// Mirrors `VariSpeed(input, rate:)`.
  ///
  /// - [rate]: Playback rate. 0.25...4.0, default 1.0.
  static Future<VariSpeed> create(Node input, {double rate = 1.0}) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createVariSpeed(
      input.nodeId,
      rate: rate,
    );
    AudioKitLogger.info('VariSpeed created: $nodeId (rate=$rate)');
    return VariSpeed._(nodeId, input).._rate = rate;
  }

  /// Playback rate. 0.25...4.0, default 1.0.
  ///
  /// Mirrors `variSpeed.rate`.
  double get rate => _rate;
  set rate(double value) {
    _rate = value.clamp(0.25, 4.0);
    AudioKitLogger.verbose('VariSpeed($_nodeId) rate = $_rate');
    FlutterAudioKitPlatform.instance.setVariSpeedRate(_nodeId, _rate);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
