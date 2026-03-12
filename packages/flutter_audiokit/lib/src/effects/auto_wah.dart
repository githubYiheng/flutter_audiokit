import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Auto-wah effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `AutoWah` class.
class AutoWah extends Node {
  AutoWah._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _wah = 0.0;
  double _mix = 1.0;
  double _amplitude = 0.1;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'AutoWah';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<AutoWah> create(
    Node input, {
    double wah = 0.0,
    double mix = 1.0,
    double amplitude = 0.1,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'AutoWah',
      {
        'wah': wah,
        'mix': mix,
        'amplitude': amplitude,
      },
    );
    return AutoWah._(nodeId, input)
      .._wah = wah
      .._mix = mix
      .._amplitude = amplitude;
  }

  /// Wah amount. 0...1, default 0.
  double get wah => _wah;
  set wah(double value) {
    _wah = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'wah', _wah);
  }

  /// Mix. 0...1, default 1.
  double get mix => _mix;
  set mix(double value) {
    _mix = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'mix', _mix);
  }

  /// Amplitude. 0...1, default 0.1.
  double get amplitude => _amplitude;
  set amplitude(double value) {
    _amplitude = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'amplitude', _amplitude);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
