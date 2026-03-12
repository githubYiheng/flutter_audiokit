import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Delay effect node.
///
/// Mirrors AudioKit's `Delay` class. Wraps Apple's AVAudioUnitDelay.
///
/// ```dart
/// final delay = await Delay.create(player, time: 0.5, feedback: 60);
/// ```
class Delay extends Node {
  Delay._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  // Write-through cache
  double _time = 1.0;
  double _feedback = 50.0;
  double _lowPassCutoff = 15000.0;
  double _dryWetMix = 100.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'Delay';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  /// The input node.
  Node get input => _input;

  /// Creates a Delay effect node.
  ///
  /// Mirrors `Delay(input, time:feedback:lowPassCutoff:dryWetMix:)`.
  static Future<Delay> create(
    Node input, {
    double time = 1.0,
    double feedback = 50.0,
    double lowPassCutoff = 15000.0,
    double dryWetMix = 100.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'Delay',
      {
        'time': time,
        'feedback': feedback,
        'lowPassCutoff': lowPassCutoff,
        'dryWetMix': dryWetMix,
      },
    );
    return Delay._(nodeId, input)
      .._time = time
      .._feedback = feedback
      .._lowPassCutoff = lowPassCutoff
      .._dryWetMix = dryWetMix;
  }

  /// Delay time in seconds. 0...2.0, default 1.0.
  ///
  /// Mirrors `delay.time`.
  double get time => _time;
  set time(double value) {
    _time = value.clamp(0.0, 2.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'time', _time);
  }

  /// Feedback percentage. -100...100, default 50.0.
  ///
  /// Mirrors `delay.feedback`.
  double get feedback => _feedback;
  set feedback(double value) {
    _feedback = value.clamp(-100.0, 100.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'feedback', _feedback);
  }

  /// Low-pass cutoff frequency in Hz. 10...22050, default 15000.
  ///
  /// Mirrors `delay.lowPassCutoff`.
  double get lowPassCutoff => _lowPassCutoff;
  set lowPassCutoff(double value) {
    _lowPassCutoff = value.clamp(10.0, 22050.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'lowPassCutoff', _lowPassCutoff);
  }

  /// Dry/wet mix percentage. 0...100, default 100.
  ///
  /// Mirrors `delay.dryWetMix`.
  double get dryWetMix => _dryWetMix;
  set dryWetMix(double value) {
    _dryWetMix = value.clamp(0.0, 100.0);
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
