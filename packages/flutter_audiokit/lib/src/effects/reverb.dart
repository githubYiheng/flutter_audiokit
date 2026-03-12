import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Apple Reverb effect node with factory presets.
///
/// Mirrors AudioKit's `Reverb` class. Wraps AVAudioUnitReverb.
///
/// ```dart
/// final reverb = await Reverb.create(player, dryWetMix: 0.4);
/// await reverb.loadFactoryPreset(ReverbPreset.largeHall);
/// ```
class Reverb extends Node {
  Reverb._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  // Write-through cache
  double _dryWetMix = 0.5;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'Reverb';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  /// The input node.
  Node get input => _input;

  /// Creates a Reverb effect node.
  ///
  /// Mirrors `Reverb(input, dryWetMix:)`.
  static Future<Reverb> create(
    Node input, {
    double dryWetMix = 0.5,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'Reverb',
      {'dryWetMix': dryWetMix},
    );
    return Reverb._(nodeId, input).._dryWetMix = dryWetMix;
  }

  /// Dry/wet mix. 0...1, default 0.5.
  ///
  /// Mirrors `reverb.dryWetMix`.
  double get dryWetMix => _dryWetMix;
  set dryWetMix(double value) {
    _dryWetMix = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'dryWetMix', _dryWetMix);
  }

  /// Loads a factory reverb preset.
  ///
  /// Mirrors `reverb.loadFactoryPreset(preset)`.
  Future<void> loadFactoryPreset(ReverbPreset preset) =>
      FlutterAudioKitPlatform.instance
          .loadReverbPreset(_nodeId, preset.index);

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
