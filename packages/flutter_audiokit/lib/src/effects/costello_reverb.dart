import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import '../node.dart';

/// Costello reverb effect node (SoundpipeAudioKit).
///
/// Mirrors SoundpipeAudioKit's `CostelloReverb` class.
///
/// ```dart
/// final reverb = await CostelloReverb.create(mixer, feedback: 0.8);
/// ```
class CostelloReverb extends Node {
  CostelloReverb._(this._nodeId, this._input);

  final String _nodeId;
  final Node _input;
  bool _isDisposed = false;

  // Write-through cache
  double _feedback = 0.6;
  double _cutoffFrequency = 4000.0;
  double _balance = 1.0;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'CostelloReverb';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  /// The input node.
  Node get input => _input;

  /// Creates a CostelloReverb effect node.
  ///
  /// Mirrors `CostelloReverb(input, balance:feedback:cutoffFrequency:)`.
  static Future<CostelloReverb> create(
    Node input, {
    double feedback = 0.6,
    double cutoffFrequency = 4000.0,
    double balance = 1.0,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createEffect(
      input.nodeId,
      'CostelloReverb',
      {
        'feedback': feedback,
        'cutoffFrequency': cutoffFrequency,
        'balance': balance,
      },
    );
    return CostelloReverb._(nodeId, input)
      .._feedback = feedback
      .._cutoffFrequency = cutoffFrequency
      .._balance = balance;
  }

  /// Feedback. 0...1, default 0.6.
  double get feedback => _feedback;
  set feedback(double value) {
    _feedback = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'feedback', _feedback);
  }

  /// Cutoff frequency in Hz. 12...20000, default 4000.
  double get cutoffFrequency => _cutoffFrequency;
  set cutoffFrequency(double value) {
    _cutoffFrequency = value.clamp(12.0, 20000.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'cutoffFrequency', _cutoffFrequency);
  }

  /// Dry/wet balance. 0...1, default 1.
  double get balance => _balance;
  set balance(double value) {
    _balance = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance
        .setNodeParameter(_nodeId, 'balance', _balance);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await super.dispose();
  }
}
