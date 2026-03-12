import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Bit crusher effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `BitCrusher` class.
class BitCrusher extends Node {
  BitCrusher._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  double _bitDepth = 8.0;
  double _sampleRate = 10000.0;
  double _dryWetMix = 1.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'BitCrusher';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  /// Creates a BitCrusher effect node.
  static Future<BitCrusher> create(
    Node input, {
    double bitDepth = 8.0,
    double sampleRate = 10000.0,
    double dryWetMix = 1.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'BitCrusher',
      {
        'bitDepth': bitDepth,
        'sampleRate': sampleRate,
        'dryWetMix': dryWetMix,
      },
    );
    return BitCrusher._(nodeId, input)
      .._bitDepth = bitDepth
      .._sampleRate = sampleRate
      .._dryWetMix = dryWetMix;
  }

  /// Bit depth. 1...24, default 8.
  double get bitDepth => _bitDepth;
  set bitDepth(double value) {
    _bitDepth = value.clamp(1.0, 24.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'bitDepth', _bitDepth);
  }

  /// Sample rate in Hz. 0...20000, default 10000.
  double get sampleRate => _sampleRate;
  set sampleRate(double value) {
    _sampleRate = value.clamp(0.0, 20000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'sampleRate', _sampleRate);
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
