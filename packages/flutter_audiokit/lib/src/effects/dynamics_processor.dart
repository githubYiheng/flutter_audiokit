import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Dynamics processor effect node with expansion and compression.
///
/// Mirrors AudioKit's `DynamicsProcessor` class.
///
/// ```dart
/// final dp = await DynamicsProcessor.create(player, threshold: -25);
/// ```
class DynamicsProcessor extends Node {
  DynamicsProcessor._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  // Write-through cache
  double _threshold = -20.0;
  double _headRoom = 5.0;
  double _expansionRatio = 2.0;
  double _expansionThreshold = 2.0;
  double _attackTime = 0.001;
  double _releaseTime = 0.05;
  double _masterGain = 0.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'DynamicsProcessor';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  /// The input node.
  Node get input => _input;

  /// Creates a DynamicsProcessor effect node.
  ///
  /// Mirrors `DynamicsProcessor(input, ...)`.
  static Future<DynamicsProcessor> create(
    Node input, {
    double threshold = -20.0,
    double headRoom = 5.0,
    double expansionRatio = 2.0,
    double expansionThreshold = 2.0,
    double attackTime = 0.001,
    double releaseTime = 0.05,
    double masterGain = 0.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'DynamicsProcessor',
      {
        'threshold': threshold,
        'headRoom': headRoom,
        'expansionRatio': expansionRatio,
        'expansionThreshold': expansionThreshold,
        'attackTime': attackTime,
        'releaseTime': releaseTime,
        'masterGain': masterGain,
      },
    );
    return DynamicsProcessor._(nodeId, input)
      .._threshold = threshold
      .._headRoom = headRoom
      .._expansionRatio = expansionRatio
      .._expansionThreshold = expansionThreshold
      .._attackTime = attackTime
      .._releaseTime = releaseTime
      .._masterGain = masterGain;
  }

  /// Threshold in dB. -40...20, default -20.
  double get threshold => _threshold;
  set threshold(double value) {
    _threshold = value.clamp(-40.0, 20.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'threshold', _threshold);
  }

  /// Head room in dB. 0.1...40, default 5.
  double get headRoom => _headRoom;
  set headRoom(double value) {
    _headRoom = value.clamp(0.1, 40.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'headRoom', _headRoom);
  }

  /// Expansion ratio. 1...50, default 2.
  double get expansionRatio => _expansionRatio;
  set expansionRatio(double value) {
    _expansionRatio = value.clamp(1.0, 50.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'expansionRatio', _expansionRatio);
  }

  /// Expansion threshold in dB. 1...50, default 2.
  double get expansionThreshold => _expansionThreshold;
  set expansionThreshold(double value) {
    _expansionThreshold = value.clamp(1.0, 50.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'expansionThreshold', _expansionThreshold);
  }

  /// Attack time in seconds. 0.0001...0.2, default 0.001.
  double get attackTime => _attackTime;
  set attackTime(double value) {
    _attackTime = value.clamp(0.0001, 0.2);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'attackTime', _attackTime);
  }

  /// Release time in seconds. 0.01...3, default 0.05.
  double get releaseTime => _releaseTime;
  set releaseTime(double value) {
    _releaseTime = value.clamp(0.01, 3.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'releaseTime', _releaseTime);
  }

  /// Master gain in dB. -40...40, default 0.
  double get masterGain => _masterGain;
  set masterGain(double value) {
    _masterGain = value.clamp(-40.0, 40.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'masterGain', _masterGain);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
