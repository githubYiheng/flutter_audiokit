import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Band-pass Butterworth filter effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `BandPassButterworthFilter` class.
class BandPassButterworthFilter extends Node {
  BandPassButterworthFilter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _centerFrequency = 2000.0;
  double _bandwidth = 100.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'BandPassButterworthFilter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<BandPassButterworthFilter> create(
    Node input, {
    double centerFrequency = 2000.0,
    double bandwidth = 100.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'BandPassButterworthFilter',
      {
        'centerFrequency': centerFrequency,
        'bandwidth': bandwidth,
      },
    );
    return BandPassButterworthFilter._(nodeId, input)
      .._centerFrequency = centerFrequency
      .._bandwidth = bandwidth;
  }

  /// Center frequency in Hz. 12...20000, default 2000.
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

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
