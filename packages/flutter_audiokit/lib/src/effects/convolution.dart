import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Convolution (impulse response) reverb effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `Convolution` class.
/// Requires an impulse response audio file.
class Convolution extends Node {
  Convolution._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'Convolution';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  Node get input => _input;

  /// Creates a Convolution effect node with the given impulse response file.
  ///
  /// [impulseResponseFilePath] — absolute path to the impulse response audio file.
  /// [partitionLength] — FFT partition length (power of 2), default 2048.
  static Future<Convolution> create(
    Node input, {
    required String impulseResponseFilePath,
    int partitionLength = 2048,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createConvolution(
      input.nodeId,
      impulseResponseFilePath,
      partitionLength,
    );
    return Convolution._(nodeId, input);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
