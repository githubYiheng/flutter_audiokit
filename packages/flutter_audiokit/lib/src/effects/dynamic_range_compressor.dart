import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Dynamic range compressor effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `DynamicRangeCompressor` class.
///
/// ```dart
/// final comp = await DynamicRangeCompressor.create(mixer, ratio: 4, threshold: -20);
/// ```
class DynamicRangeCompressor extends Node {
  DynamicRangeCompressor._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  // Write-through cache
  double _ratio = 1.0;
  double _threshold = 0.0;
  double _attackDuration = 0.1;
  double _releaseDuration = 0.1;
  double _gain = 0.0;
  double _dryWetMix = 1.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'DynamicRangeCompressor';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  /// The input node.
  Node get input => _input;

  /// Creates a DynamicRangeCompressor effect node.
  ///
  /// Mirrors `DynamicRangeCompressor(input, ratio:threshold:...)`.
  static Future<DynamicRangeCompressor> create(
    Node input, {
    double ratio = 1.0,
    double threshold = 0.0,
    double attackDuration = 0.1,
    double releaseDuration = 0.1,
    double gain = 0.0,
    double dryWetMix = 1.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'DynamicRangeCompressor',
      {
        'ratio': ratio,
        'threshold': threshold,
        'attackDuration': attackDuration,
        'releaseDuration': releaseDuration,
        'gain': gain,
        'dryWetMix': dryWetMix,
      },
    );
    return DynamicRangeCompressor._(nodeId, input)
      .._ratio = ratio
      .._threshold = threshold
      .._attackDuration = attackDuration
      .._releaseDuration = releaseDuration
      .._gain = gain
      .._dryWetMix = dryWetMix;
  }

  /// Compression ratio. 0.01...100, default 1.
  double get ratio => _ratio;
  set ratio(double value) {
    _ratio = value.clamp(0.01, 100.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'ratio', _ratio);
  }

  /// Threshold in dB. -100...0, default 0.
  double get threshold => _threshold;
  set threshold(double value) {
    _threshold = value.clamp(-100.0, 0.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'threshold', _threshold);
  }

  /// Attack duration in seconds. 0...1, default 0.1.
  double get attackDuration => _attackDuration;
  set attackDuration(double value) {
    _attackDuration = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'attackDuration', _attackDuration);
  }

  /// Release duration in seconds. 0...1, default 0.1.
  double get releaseDuration => _releaseDuration;
  set releaseDuration(double value) {
    _releaseDuration = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'releaseDuration', _releaseDuration);
  }

  /// Makeup gain in dB. 0...8, default 0.
  double get gain => _gain;
  set gain(double value) {
    _gain = value.clamp(0.0, 8.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'gain', _gain);
  }

  /// Dry/wet mix. 0...1, default 1.
  double get dryWetMix => _dryWetMix;
  set dryWetMix(double value) {
    _dryWetMix = value.clamp(0.0, 1.0);
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
