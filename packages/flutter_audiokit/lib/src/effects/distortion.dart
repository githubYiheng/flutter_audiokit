import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Distortion effect node with 16 parameters.
///
/// Mirrors AudioKit's `Distortion` class. Wraps Apple's AVAudioUnitDistortion.
///
/// ```dart
/// final dist = await Distortion.create(player, finalMix: 30);
/// ```
class Distortion extends Node {
  Distortion._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  // Write-through cache
  double _delay = 0.1;
  double _decay = 1.0;
  double _delayMix = 50.0;
  double _ringModFreq1 = 100.0;
  double _ringModFreq2 = 100.0;
  double _ringModBalance = 50.0;
  double _ringModMix = 0.0;
  double _decimation = 50.0;
  double _rounding = 0.0;
  double _decimationMix = 50.0;
  double _linearTerm = 0.5;
  double _squaredTerm = 10.0;
  double _cubicTerm = 10.0;
  double _polynomialMix = 50.0;
  double _softClipGain = -6.0;
  double _finalMix = 50.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'Distortion';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  /// The input node.
  Node get input => _input;

  /// Creates a Distortion effect node.
  ///
  /// Mirrors `Distortion(input, ...)`.
  static Future<Distortion> create(
    Node input, {
    double delay = 0.1,
    double decay = 1.0,
    double delayMix = 50.0,
    double ringModFreq1 = 100.0,
    double ringModFreq2 = 100.0,
    double ringModBalance = 50.0,
    double ringModMix = 0.0,
    double decimation = 50.0,
    double rounding = 0.0,
    double decimationMix = 50.0,
    double linearTerm = 0.5,
    double squaredTerm = 10.0,
    double cubicTerm = 10.0,
    double polynomialMix = 50.0,
    double softClipGain = -6.0,
    double finalMix = 50.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'Distortion',
      {
        'delay': delay,
        'decay': decay,
        'delayMix': delayMix,
        'ringModFreq1': ringModFreq1,
        'ringModFreq2': ringModFreq2,
        'ringModBalance': ringModBalance,
        'ringModMix': ringModMix,
        'decimation': decimation,
        'rounding': rounding,
        'decimationMix': decimationMix,
        'linearTerm': linearTerm,
        'squaredTerm': squaredTerm,
        'cubicTerm': cubicTerm,
        'polynomialMix': polynomialMix,
        'softClipGain': softClipGain,
        'finalMix': finalMix,
      },
    );
    return Distortion._(nodeId, input)
      .._delay = delay
      .._decay = decay
      .._delayMix = delayMix
      .._ringModFreq1 = ringModFreq1
      .._ringModFreq2 = ringModFreq2
      .._ringModBalance = ringModBalance
      .._ringModMix = ringModMix
      .._decimation = decimation
      .._rounding = rounding
      .._decimationMix = decimationMix
      .._linearTerm = linearTerm
      .._squaredTerm = squaredTerm
      .._cubicTerm = cubicTerm
      .._polynomialMix = polynomialMix
      .._softClipGain = softClipGain
      .._finalMix = finalMix;
  }

  /// Delay in ms. 0.1...500, default 0.1.
  double get delay => _delay;
  set delay(double value) {
    _delay = value.clamp(0.1, 500.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'delay', _delay);
  }

  /// Decay rate. 0.1...50, default 1.0.
  double get decay => _decay;
  set decay(double value) {
    _decay = value.clamp(0.1, 50.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'decay', _decay);
  }

  /// Delay mix %. 0...100, default 50.
  double get delayMix => _delayMix;
  set delayMix(double value) {
    _delayMix = value.clamp(0.0, 100.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'delayMix', _delayMix);
  }

  /// Ring mod frequency 1 in Hz. 0.5...8000, default 100.
  double get ringModFreq1 => _ringModFreq1;
  set ringModFreq1(double value) {
    _ringModFreq1 = value.clamp(0.5, 8000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'ringModFreq1', _ringModFreq1);
  }

  /// Ring mod frequency 2 in Hz. 0.5...8000, default 100.
  double get ringModFreq2 => _ringModFreq2;
  set ringModFreq2(double value) {
    _ringModFreq2 = value.clamp(0.5, 8000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'ringModFreq2', _ringModFreq2);
  }

  /// Ring mod balance %. 0...100, default 50.
  double get ringModBalance => _ringModBalance;
  set ringModBalance(double value) {
    _ringModBalance = value.clamp(0.0, 100.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'ringModBalance', _ringModBalance);
  }

  /// Ring mod mix %. 0...100, default 0.
  double get ringModMix => _ringModMix;
  set ringModMix(double value) {
    _ringModMix = value.clamp(0.0, 100.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'ringModMix', _ringModMix);
  }

  /// Decimation %. 0...100, default 50.
  double get decimation => _decimation;
  set decimation(double value) {
    _decimation = value.clamp(0.0, 100.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'decimation', _decimation);
  }

  /// Rounding %. 0...100, default 0.
  double get rounding => _rounding;
  set rounding(double value) {
    _rounding = value.clamp(0.0, 100.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'rounding', _rounding);
  }

  /// Decimation mix %. 0...100, default 50.
  double get decimationMix => _decimationMix;
  set decimationMix(double value) {
    _decimationMix = value.clamp(0.0, 100.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'decimationMix', _decimationMix);
  }

  /// Linear term. 0...1, default 0.5.
  double get linearTerm => _linearTerm;
  set linearTerm(double value) {
    _linearTerm = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'linearTerm', _linearTerm);
  }

  /// Squared term. 0...20, default 10.
  double get squaredTerm => _squaredTerm;
  set squaredTerm(double value) {
    _squaredTerm = value.clamp(0.0, 20.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'squaredTerm', _squaredTerm);
  }

  /// Cubic term. 0...20, default 10.
  double get cubicTerm => _cubicTerm;
  set cubicTerm(double value) {
    _cubicTerm = value.clamp(0.0, 20.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'cubicTerm', _cubicTerm);
  }

  /// Polynomial mix %. 0...100, default 50.
  double get polynomialMix => _polynomialMix;
  set polynomialMix(double value) {
    _polynomialMix = value.clamp(0.0, 100.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'polynomialMix', _polynomialMix);
  }

  /// Soft clip gain in dB. -80...20, default -6.
  double get softClipGain => _softClipGain;
  set softClipGain(double value) {
    _softClipGain = value.clamp(-80.0, 20.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'softClipGain', _softClipGain);
  }

  /// Final mix %. 0...100, default 50.
  double get finalMix => _finalMix;
  set finalMix(double value) {
    _finalMix = value.clamp(0.0, 100.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'finalMix', _finalMix);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
