import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// High-shelf filter effect node.
///
/// Mirrors AudioKit's `HighShelfFilter` class.
///
/// ```dart
/// final hsf = await HighShelfFilter.create(player, gain: -6);
/// ```
class HighShelfFilter extends Node {
  HighShelfFilter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  // Write-through cache
  double _cutOffFrequency = 10000.0;
  double _gain = 0.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'HighShelfFilter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  /// The input node.
  Node get input => _input;

  /// Creates a HighShelfFilter effect node.
  ///
  /// Mirrors `HighShelfFilter(input, cutOffFrequency:gain:)`.
  static Future<HighShelfFilter> create(
    Node input, {
    double cutOffFrequency = 10000.0,
    double gain = 0.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'HighShelfFilter',
      {
        'cutOffFrequency': cutOffFrequency,
        'gain': gain,
      },
    );
    return HighShelfFilter._(nodeId, input)
      .._cutOffFrequency = cutOffFrequency
      .._gain = gain;
  }

  /// Cut-off frequency in Hz. 10000...22050, default 10000.
  ///
  /// Note: AudioKit uses `cutOffFrequency` (capital O) for this filter.
  double get cutOffFrequency => _cutOffFrequency;
  set cutOffFrequency(double value) {
    _cutOffFrequency = value.clamp(10000.0, 22050.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'cutOffFrequency', _cutOffFrequency);
  }

  /// Gain in dB. -40...40, default 0.
  double get gain => _gain;
  set gain(double value) {
    _gain = value.clamp(-40.0, 40.0);
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
