import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Zita reverb effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `ZitaReverb` class. A high-quality
/// stereo reverb with 10 adjustable parameters.
///
/// ```dart
/// final reverb = await ZitaReverb.create(mixer, predelay: 40, midReleaseTime: 3);
/// ```
class ZitaReverb extends Node {
  ZitaReverb._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  // Write-through cache
  double _predelay = 60.0;
  double _crossoverFrequency = 200.0;
  double _lowReleaseTime = 3.0;
  double _midReleaseTime = 2.0;
  double _dampingFrequency = 6000.0;
  double _equalizerFrequency1 = 315.0;
  double _equalizerLevel1 = 0.0;
  double _equalizerFrequency2 = 1000.0;
  double _equalizerLevel2 = 0.0;
  double _dryWetMix = 1.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'ZitaReverb';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  /// The input node.
  Node get input => _input;

  /// Creates a ZitaReverb effect node.
  ///
  /// Mirrors `ZitaReverb(input, predelay:crossoverFrequency:...)`.
  static Future<ZitaReverb> create(
    Node input, {
    double predelay = 60.0,
    double crossoverFrequency = 200.0,
    double lowReleaseTime = 3.0,
    double midReleaseTime = 2.0,
    double dampingFrequency = 6000.0,
    double equalizerFrequency1 = 315.0,
    double equalizerLevel1 = 0.0,
    double equalizerFrequency2 = 1000.0,
    double equalizerLevel2 = 0.0,
    double dryWetMix = 1.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'ZitaReverb',
      {
        'predelay': predelay,
        'crossoverFrequency': crossoverFrequency,
        'lowReleaseTime': lowReleaseTime,
        'midReleaseTime': midReleaseTime,
        'dampingFrequency': dampingFrequency,
        'equalizerFrequency1': equalizerFrequency1,
        'equalizerLevel1': equalizerLevel1,
        'equalizerFrequency2': equalizerFrequency2,
        'equalizerLevel2': equalizerLevel2,
        'dryWetMix': dryWetMix,
      },
    );
    return ZitaReverb._(nodeId, input)
      .._predelay = predelay
      .._crossoverFrequency = crossoverFrequency
      .._lowReleaseTime = lowReleaseTime
      .._midReleaseTime = midReleaseTime
      .._dampingFrequency = dampingFrequency
      .._equalizerFrequency1 = equalizerFrequency1
      .._equalizerLevel1 = equalizerLevel1
      .._equalizerFrequency2 = equalizerFrequency2
      .._equalizerLevel2 = equalizerLevel2
      .._dryWetMix = dryWetMix;
  }

  /// Pre-delay in ms. 10...100, default 60.
  double get predelay => _predelay;
  set predelay(double value) {
    _predelay = value.clamp(10.0, 100.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'predelay', _predelay);
  }

  /// Crossover frequency in Hz. 50...1000, default 200.
  double get crossoverFrequency => _crossoverFrequency;
  set crossoverFrequency(double value) {
    _crossoverFrequency = value.clamp(50.0, 1000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'crossoverFrequency', _crossoverFrequency);
  }

  /// Low-frequency release time in seconds. 1...8, default 3.
  double get lowReleaseTime => _lowReleaseTime;
  set lowReleaseTime(double value) {
    _lowReleaseTime = value.clamp(1.0, 8.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'lowReleaseTime', _lowReleaseTime);
  }

  /// Mid-frequency release time in seconds. 1...8, default 2.
  double get midReleaseTime => _midReleaseTime;
  set midReleaseTime(double value) {
    _midReleaseTime = value.clamp(1.0, 8.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'midReleaseTime', _midReleaseTime);
  }

  /// Damping frequency in Hz. 1500...47040, default 6000.
  double get dampingFrequency => _dampingFrequency;
  set dampingFrequency(double value) {
    _dampingFrequency = value.clamp(1500.0, 47040.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'dampingFrequency', _dampingFrequency);
  }

  /// EQ band 1 frequency in Hz. 40...2500, default 315.
  double get equalizerFrequency1 => _equalizerFrequency1;
  set equalizerFrequency1(double value) {
    _equalizerFrequency1 = value.clamp(40.0, 2500.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'equalizerFrequency1', _equalizerFrequency1);
  }

  /// EQ band 1 level in dB. -15...15, default 0.
  double get equalizerLevel1 => _equalizerLevel1;
  set equalizerLevel1(double value) {
    _equalizerLevel1 = value.clamp(-15.0, 15.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'equalizerLevel1', _equalizerLevel1);
  }

  /// EQ band 2 frequency in Hz. 160...1000, default 1000.
  double get equalizerFrequency2 => _equalizerFrequency2;
  set equalizerFrequency2(double value) {
    _equalizerFrequency2 = value.clamp(160.0, 1000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'equalizerFrequency2', _equalizerFrequency2);
  }

  /// EQ band 2 level in dB. -15...15, default 0.
  double get equalizerLevel2 => _equalizerLevel2;
  set equalizerLevel2(double value) {
    _equalizerLevel2 = value.clamp(-15.0, 15.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'equalizerLevel2', _equalizerLevel2);
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
