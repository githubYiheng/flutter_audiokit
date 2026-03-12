import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// High-pass Butterworth filter effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `HighPassButterworthFilter` class.
class HighPassButterworthFilter extends Node {
  HighPassButterworthFilter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _cutoffFrequency = 500.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'HighPassButterworthFilter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<HighPassButterworthFilter> create(
    Node input, {
    double cutoffFrequency = 500.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'HighPassButterworthFilter',
      {'cutoffFrequency': cutoffFrequency},
    );
    return HighPassButterworthFilter._(nodeId, input)
      .._cutoffFrequency = cutoffFrequency;
  }

  /// Cutoff frequency in Hz. 12...20000, default 500.
  double get cutoffFrequency => _cutoffFrequency;
  set cutoffFrequency(double value) {
    _cutoffFrequency = value.clamp(12.0, 20000.0);
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
