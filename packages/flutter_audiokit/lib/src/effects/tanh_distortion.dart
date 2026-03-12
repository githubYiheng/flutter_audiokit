import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Tanh distortion effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `TanhDistortion` class.
class TanhDistortion extends Node {
  TanhDistortion._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _pregain = 2.0;
  double _postgain = 0.5;
  double _positiveShapeParameter = 0.0;
  double _negativeShapeParameter = 0.0;
  double _dryWetMix = 1.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'TanhDistortion';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  /// Creates a TanhDistortion effect node.
  static Future<TanhDistortion> create(
    Node input, {
    double pregain = 2.0,
    double postgain = 0.5,
    double positiveShapeParameter = 0.0,
    double negativeShapeParameter = 0.0,
    double dryWetMix = 1.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'TanhDistortion',
      {
        'pregain': pregain,
        'postgain': postgain,
        'positiveShapeParameter': positiveShapeParameter,
        'negativeShapeParameter': negativeShapeParameter,
        'dryWetMix': dryWetMix,
      },
    );
    return TanhDistortion._(nodeId, input)
      .._pregain = pregain
      .._postgain = postgain
      .._positiveShapeParameter = positiveShapeParameter
      .._negativeShapeParameter = negativeShapeParameter
      .._dryWetMix = dryWetMix;
  }

  /// Pre-gain. 0...10, default 2.
  double get pregain => _pregain;
  set pregain(double value) {
    _pregain = value.clamp(0.0, 10.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'pregain', _pregain);
  }

  /// Post-gain. 0...10, default 0.5.
  double get postgain => _postgain;
  set postgain(double value) {
    _postgain = value.clamp(0.0, 10.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'postgain', _postgain);
  }

  /// Positive shape parameter. -10...10, default 0.
  double get positiveShapeParameter => _positiveShapeParameter;
  set positiveShapeParameter(double value) {
    _positiveShapeParameter = value.clamp(-10.0, 10.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'positiveShapeParameter', _positiveShapeParameter);
  }

  /// Negative shape parameter. -10...10, default 0.
  double get negativeShapeParameter => _negativeShapeParameter;
  set negativeShapeParameter(double value) {
    _negativeShapeParameter = value.clamp(-10.0, 10.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'negativeShapeParameter', _negativeShapeParameter);
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
