import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Variable delay effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `VariableDelay` class.
class VariableDelay extends Node {
  VariableDelay._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _time = 0.0;
  double _feedback = 0.0;
  double _dryWetMix = 1.0;
  double _maximumTime = 10.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'VariableDelay';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  /// Creates a VariableDelay effect node.
  ///
  /// [maximumTime] is init-only and cannot be changed after creation.
  static Future<VariableDelay> create(
    Node input, {
    double time = 0.0,
    double feedback = 0.0,
    double dryWetMix = 1.0,
    double maximumTime = 10.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'VariableDelay',
      {
        'time': time,
        'feedback': feedback,
        'dryWetMix': dryWetMix,
        'maximumTime': maximumTime,
      },
    );
    return VariableDelay._(nodeId, input)
      .._time = time
      .._feedback = feedback
      .._dryWetMix = dryWetMix
      .._maximumTime = maximumTime;
  }

  /// The maximum delay time set at creation (read-only).
  double get maximumTime => _maximumTime;

  /// Delay time in seconds. 0...[maximumTime], default 0.
  double get time => _time;
  set time(double value) {
    _time = value.clamp(0.0, _maximumTime);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'time', _time);
  }

  /// Feedback. 0...1, default 0.
  double get feedback => _feedback;
  set feedback(double value) {
    _feedback = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'feedback', _feedback);
  }

  /// Dry/wet mix. 0...1, default 1.
  double get dryWetMix => _dryWetMix;
  set dryWetMix(double value) {
    _dryWetMix = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'dryWetMix', _dryWetMix);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
