import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// String resonator effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `StringResonator` class.
class StringResonator extends Node {
  StringResonator._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _fundamentalFrequency = 100.0;
  double _feedback = 0.95;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'StringResonator';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<StringResonator> create(
    Node input, {
    double fundamentalFrequency = 100.0,
    double feedback = 0.95,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'StringResonator',
      {
        'fundamentalFrequency': fundamentalFrequency,
        'feedback': feedback,
      },
    );
    return StringResonator._(nodeId, input)
      .._fundamentalFrequency = fundamentalFrequency
      .._feedback = feedback;
  }

  /// Fundamental frequency in Hz. 12...10000, default 100.
  double get fundamentalFrequency => _fundamentalFrequency;
  set fundamentalFrequency(double value) {
    _fundamentalFrequency = value.clamp(12.0, 10000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'fundamentalFrequency', _fundamentalFrequency);
  }

  /// Feedback. 0...1, default 0.95.
  double get feedback => _feedback;
  set feedback(double value) {
    _feedback = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'feedback', _feedback);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
