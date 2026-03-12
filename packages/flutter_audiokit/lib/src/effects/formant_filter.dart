import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Formant filter effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `FormantFilter` class.
class FormantFilter extends Node {
  FormantFilter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _centerFrequency = 1000.0;
  double _attackDuration = 0.007;
  double _decayDuration = 0.04;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'FormantFilter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<FormantFilter> create(
    Node input, {
    double centerFrequency = 1000.0,
    double attackDuration = 0.007,
    double decayDuration = 0.04,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'FormantFilter',
      {
        'centerFrequency': centerFrequency,
        'attackDuration': attackDuration,
        'decayDuration': decayDuration,
      },
    );
    return FormantFilter._(nodeId, input)
      .._centerFrequency = centerFrequency
      .._attackDuration = attackDuration
      .._decayDuration = decayDuration;
  }

  /// Center frequency in Hz. 12...20000, default 1000.
  double get centerFrequency => _centerFrequency;
  set centerFrequency(double value) {
    _centerFrequency = value.clamp(12.0, 20000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'centerFrequency', _centerFrequency);
  }

  /// Attack duration in seconds. 0...0.1, default 0.007.
  double get attackDuration => _attackDuration;
  set attackDuration(double value) {
    _attackDuration = value.clamp(0.0, 0.1);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'attackDuration', _attackDuration);
  }

  /// Decay duration in seconds. 0...0.1, default 0.04.
  double get decayDuration => _decayDuration;
  set decayDuration(double value) {
    _decayDuration = value.clamp(0.0, 0.1);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'decayDuration', _decayDuration);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
