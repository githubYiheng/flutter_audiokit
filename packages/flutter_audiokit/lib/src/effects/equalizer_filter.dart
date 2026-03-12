import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Equalizer filter effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `EqualizerFilter` class.
class EqualizerFilter extends Node {
  EqualizerFilter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _centerFrequency = 1000.0;
  double _bandwidth = 100.0;
  double _gain = 1.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'EqualizerFilter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<EqualizerFilter> create(
    Node input, {
    double centerFrequency = 1000.0,
    double bandwidth = 100.0,
    double gain = 1.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'EqualizerFilter',
      {
        'centerFrequency': centerFrequency,
        'bandwidth': bandwidth,
        'gain': gain,
      },
    );
    return EqualizerFilter._(nodeId, input)
      .._centerFrequency = centerFrequency
      .._bandwidth = bandwidth
      .._gain = gain;
  }

  /// Center frequency in Hz. 12...20000, default 1000.
  double get centerFrequency => _centerFrequency;
  set centerFrequency(double value) {
    _centerFrequency = value.clamp(12.0, 20000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'centerFrequency', _centerFrequency);
  }

  /// Bandwidth in Hz. 0...20000, default 100.
  double get bandwidth => _bandwidth;
  set bandwidth(double value) {
    _bandwidth = value.clamp(0.0, 20000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'bandwidth', _bandwidth);
  }

  /// Gain. 0...20, default 1.
  double get gain => _gain;
  set gain(double value) {
    _gain = value.clamp(0.0, 20.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'gain', _gain);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
