import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import 'node.dart';

/// A sine wave oscillator (tone generator).
///
/// Mirrors SoundpipeAudioKit's `Oscillator`. Use [setNodeParameter] to
/// change `frequency` and `amplitude` at runtime.
///
/// ```dart
/// final osc = await Oscillator.create(frequency: 440, amplitude: 0.5);
/// ```
class Oscillator extends Node {
  Oscillator._(this._nodeId, {required double frequency, required double amplitude})
      : _frequency = frequency,
        _amplitude = amplitude;

  final String _nodeId;
  double _frequency;
  double _amplitude;
  bool _isDisposed = false;
  bool _isStarted = false;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'Oscillator';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => _isStarted;

  /// Current frequency in Hz.
  double get frequency => _frequency;

  /// Current amplitude (0.0 - 1.0).
  double get amplitude => _amplitude;

  /// Creates a new Oscillator with a sine waveform.
  static Future<Oscillator> create({
    double frequency = 440,
    double amplitude = 1.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createOscillator(
      frequency: frequency,
      amplitude: amplitude,
    );
    return Oscillator._(nodeId, frequency: frequency, amplitude: amplitude);
  }

  /// Sets the frequency in Hz (0 - 20000).
  set frequency(double value) {
    _frequency = value;
    FlutterAudioKitPlatform.instance
        .setNodeParameter(nodeId, 'frequency', value);
  }

  /// Sets the amplitude (0.0 - 10.0).
  set amplitude(double value) {
    _amplitude = value;
    FlutterAudioKitPlatform.instance
        .setNodeParameter(nodeId, 'amplitude', value);
  }

  @override
  Future<void> start() async {
    await super.start();
    _isStarted = true;
  }

  @override
  Future<void> stop() async {
    await super.stop();
    _isStarted = false;
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
