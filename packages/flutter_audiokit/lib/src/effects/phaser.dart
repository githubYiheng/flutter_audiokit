import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Phaser effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `Phaser` class.
class Phaser extends Node {
  Phaser._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _notchMinimumFrequency = 100.0;
  double _notchMaximumFrequency = 800.0;
  double _notchWidth = 1000.0;
  double _notchFrequency = 1.5;
  double _vibratoMode = 1.0;
  double _depth = 1.0;
  double _feedback = 0.0;
  double _inverted = 0.0;
  double _lfoBPM = 30.0;
  double _dryWetMix = 1.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'Phaser';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  static Future<Phaser> create(
    Node input, {
    double notchMinimumFrequency = 100.0,
    double notchMaximumFrequency = 800.0,
    double notchWidth = 1000.0,
    double notchFrequency = 1.5,
    double vibratoMode = 1.0,
    double depth = 1.0,
    double feedback = 0.0,
    double inverted = 0.0,
    double lfoBPM = 30.0,
    double dryWetMix = 1.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'Phaser',
      {
        'notchMinimumFrequency': notchMinimumFrequency,
        'notchMaximumFrequency': notchMaximumFrequency,
        'notchWidth': notchWidth,
        'notchFrequency': notchFrequency,
        'vibratoMode': vibratoMode,
        'depth': depth,
        'feedback': feedback,
        'inverted': inverted,
        'lfoBPM': lfoBPM,
        'dryWetMix': dryWetMix,
      },
    );
    return Phaser._(nodeId, input)
      .._notchMinimumFrequency = notchMinimumFrequency
      .._notchMaximumFrequency = notchMaximumFrequency
      .._notchWidth = notchWidth
      .._notchFrequency = notchFrequency
      .._vibratoMode = vibratoMode
      .._depth = depth
      .._feedback = feedback
      .._inverted = inverted
      .._lfoBPM = lfoBPM
      .._dryWetMix = dryWetMix;
  }

  /// Notch minimum frequency in Hz. 20...5000, default 100.
  double get notchMinimumFrequency => _notchMinimumFrequency;
  set notchMinimumFrequency(double value) {
    _notchMinimumFrequency = value.clamp(20.0, 5000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'notchMinimumFrequency', _notchMinimumFrequency);
  }

  /// Notch maximum frequency in Hz. 20...10000, default 800.
  double get notchMaximumFrequency => _notchMaximumFrequency;
  set notchMaximumFrequency(double value) {
    _notchMaximumFrequency = value.clamp(20.0, 10000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'notchMaximumFrequency', _notchMaximumFrequency);
  }

  /// Notch width in Hz. 10...5000, default 1000.
  double get notchWidth => _notchWidth;
  set notchWidth(double value) {
    _notchWidth = value.clamp(10.0, 5000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'notchWidth', _notchWidth);
  }

  /// Notch frequency in Hz. 1.1...4, default 1.5.
  double get notchFrequency => _notchFrequency;
  set notchFrequency(double value) {
    _notchFrequency = value.clamp(1.1, 4.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'notchFrequency', _notchFrequency);
  }

  /// Vibrato mode. 0 or 1, default 1.
  double get vibratoMode => _vibratoMode;
  set vibratoMode(double value) {
    _vibratoMode = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'vibratoMode', _vibratoMode);
  }

  /// Depth. 0...1, default 1.
  double get depth => _depth;
  set depth(double value) {
    _depth = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'depth', _depth);
  }

  /// Feedback. 0...1, default 0.
  double get feedback => _feedback;
  set feedback(double value) {
    _feedback = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'feedback', _feedback);
  }

  /// Inverted. 0 or 1, default 0.
  double get inverted => _inverted;
  set inverted(double value) {
    _inverted = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'inverted', _inverted);
  }

  /// LFO BPM. 24...360, default 30.
  double get lfoBPM => _lfoBPM;
  set lfoBPM(double value) {
    _lfoBPM = value.clamp(24.0, 360.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'lfoBPM', _lfoBPM);
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
