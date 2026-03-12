import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Low-pass Butterworth filter effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `LowPassButterworthFilter` class.
class LowPassButterworthFilter extends Node {
  LowPassButterworthFilter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _cutoffFrequency = 1000.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'LowPassButterworthFilter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<LowPassButterworthFilter> create(
    Node input, {
    double cutoffFrequency = 1000.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'LowPassButterworthFilter',
      {'cutoffFrequency': cutoffFrequency},
    );
    return LowPassButterworthFilter._(nodeId, input)
      .._cutoffFrequency = cutoffFrequency;
  }

  /// Cutoff frequency in Hz. 12...22050, default 1000.
  double get cutoffFrequency => _cutoffFrequency;
  set cutoffFrequency(double value) {
    _cutoffFrequency = value.clamp(12.0, 22050.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'cutoffFrequency', _cutoffFrequency);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
