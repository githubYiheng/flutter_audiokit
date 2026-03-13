import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import 'node.dart';

/// Audio mixer node that combines multiple inputs.
///
/// Mirrors AudioKit's `Mixer` class. Supports dynamic adding/removing
/// of input nodes, volume control, and stereo panning.
///
/// ```dart
/// final mixer = await Mixer.withInputs([player1, player2]);
/// mixer.volume = 0.8;
/// mixer.pan = -0.5; // pan left
/// ```
class Mixer extends Node {
  Mixer._(this._nodeId, {String? name}) : _name = name ?? '(unset)';

  final String _nodeId;
  bool _isDisposed = false;

  // Write-through cache
  double _volume = 1.0;
  double _pan = 0.0;
  String _name;
  final List<Node> _inputs = [];

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'Mixer';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => true;

  /// Creates an empty Mixer.
  ///
  /// Mirrors `Mixer(volume:name:)`.
  static Future<Mixer> create({double volume = 1.0, String? name}) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createMixer(
      volume: volume,
      name: name,
    );
    return Mixer._(nodeId, name: name).._volume = volume;
  }

  /// Creates a Mixer with initial input nodes.
  ///
  /// Mirrors `Mixer(input1, input2, ...)`.
  static Future<Mixer> withInputs(
    List<Node> inputs, {
    double volume = 1.0,
    String? name,
  }) async {
    final nodeId = await FlutterAudioKitPlatform.instance.createMixer(
      inputNodeIds: inputs.map((n) => n.nodeId).toList(),
      volume: volume,
      name: name,
    );
    return Mixer._(nodeId, name: name)
      .._volume = volume
      .._inputs.addAll(inputs);
  }

  // ---- Properties ----

  /// Mixer volume. Default 1.0. Values above 1.0 amplify the signal.
  ///
  /// Mirrors `mixer.volume`.
  double get volume => _volume;
  set volume(double value) {
    _volume = value;
    FlutterAudioKitPlatform.instance.setMixerVolume(_nodeId, value);
  }

  /// Stereo pan position. -1.0 (left) to 1.0 (right), default 0.0 (center).
  ///
  /// Mirrors `mixer.pan`.
  double get pan => _pan;
  set pan(double value) {
    _pan = value.clamp(-1.0, 1.0);
    FlutterAudioKitPlatform.instance.setMixerPan(_nodeId, _pan);
  }

  /// Mixer name for debugging/identification.
  ///
  /// Mirrors `mixer.name`.
  String get name => _name;
  set name(String value) {
    _name = value;
    FlutterAudioKitPlatform.instance.setMixerName(_nodeId, value);
  }

  /// Current list of input nodes (read-only snapshot).
  List<Node> get inputs => List.unmodifiable(_inputs);

  // ---- Input management ----

  /// Adds a node to this mixer's inputs.
  ///
  /// Mirrors `mixer.addInput(node)`. Can be called while the engine is running.
  Future<void> addInput(Node node) async {
    if (_inputs.contains(node)) return;
    _inputs.add(node);
    await FlutterAudioKitPlatform.instance
        .mixerAddInput(_nodeId, node.nodeId);
  }

  /// Removes a node from this mixer's inputs.
  ///
  /// Mirrors `mixer.removeInput(node)`.
  Future<void> removeInput(Node node) async {
    await FlutterAudioKitPlatform.instance
        .mixerRemoveInput(_nodeId, node.nodeId);
    _inputs.remove(node);
  }

  /// Removes all inputs from this mixer.
  ///
  /// Mirrors `mixer.removeAllInputs()`.
  Future<void> removeAllInputs() async {
    await FlutterAudioKitPlatform.instance.mixerRemoveAllInputs(_nodeId);
    _inputs.clear();
  }

  /// Whether the given node is an input of this mixer.
  ///
  /// Mirrors `mixer.hasInput(node)`.
  bool hasInput(Node node) => _inputs.contains(node);

  // ---- Lifecycle ----

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _inputs.clear();
    await super.dispose();
  }
}
