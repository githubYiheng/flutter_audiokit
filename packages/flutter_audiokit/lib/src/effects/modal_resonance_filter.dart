import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Modal resonance filter effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `ModalResonanceFilter` class.
class ModalResonanceFilter extends Node {
  ModalResonanceFilter._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _frequency = 500.0;
  double _qualityFactor = 50.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'ModalResonanceFilter';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<ModalResonanceFilter> create(
    Node input, {
    double frequency = 500.0,
    double qualityFactor = 50.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'ModalResonanceFilter',
      {
        'frequency': frequency,
        'qualityFactor': qualityFactor,
      },
    );
    return ModalResonanceFilter._(nodeId, input)
      .._frequency = frequency
      .._qualityFactor = qualityFactor;
  }

  /// Frequency in Hz. 12...20000, default 500.
  double get frequency => _frequency;
  set frequency(double value) {
    _frequency = value.clamp(12.0, 20000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'frequency', _frequency);
  }

  /// Quality factor. 0...100, default 50.
  double get qualityFactor => _qualityFactor;
  set qualityFactor(double value) {
    _qualityFactor = value.clamp(0.0, 100.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'qualityFactor', _qualityFactor);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
