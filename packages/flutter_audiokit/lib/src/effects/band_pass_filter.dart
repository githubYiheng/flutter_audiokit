import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Band-pass filter effect node.
///
/// Mirrors AudioKit's `BandPassFilter` class.
///
/// ```dart
/// final bpf = await BandPassFilter.create(player, centerFrequency: 1000);
/// ```
class BandPassFilter extends Node {
  BandPassFilter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  // Write-through cache
  double _centerFrequency = 5000.0;
  double _bandwidth = 600.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'BandPassFilter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  /// The input node.
  Node get input => _input;

  /// Creates a BandPassFilter effect node.
  ///
  /// Mirrors `BandPassFilter(input, centerFrequency:bandwidth:)`.
  static Future<BandPassFilter> create(
    Node input, {
    double centerFrequency = 5000.0,
    double bandwidth = 600.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'BandPassFilter',
      {
        'centerFrequency': centerFrequency,
        'bandwidth': bandwidth,
      },
    );
    return BandPassFilter._(nodeId, input)
      .._centerFrequency = centerFrequency
      .._bandwidth = bandwidth;
  }

  /// Center frequency in Hz. 20...22050, default 5000.
  double get centerFrequency => _centerFrequency;
  set centerFrequency(double value) {
    _centerFrequency = value.clamp(20.0, 22050.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'centerFrequency', _centerFrequency);
  }

  /// Bandwidth in cents. 100...12000, default 600.
  double get bandwidth => _bandwidth;
  set bandwidth(double value) {
    _bandwidth = value.clamp(100.0, 12000.0);
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
