import 'dart:async';

import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import 'node.dart';

/// The main audio engine that manages the audio graph.
///
/// Mirrors AudioKit's `AudioEngine` class. Create an engine, set its
/// output to the root of your node graph, and call [start].
///
/// ```dart
/// final engine = await AudioEngine.create();
/// await engine.setOutput(mixer);
/// await engine.start();
/// ```
class AudioEngine {
  AudioEngine._(this._engineId);

  final String _engineId;
  bool _isDisposed = false;
  bool _isRunning = false;
  Node? _output;

  /// The engine's unique identifier.
  String get engineId => _engineId;

  /// Whether the engine is currently running.
  bool get isRunning => _isRunning;

  /// Whether this engine has been disposed.
  bool get isDisposed => _isDisposed;

  /// The current output node, if set.
  Node? get output => _output;

  /// Creates a new AudioEngine instance.
  ///
  /// Mirrors `let engine = AudioEngine()`.
  static Future<AudioEngine> create() async {
    final engineId = await FlutterAudioKitPlatform.instance.createEngine();
    return AudioEngine._(engineId);
  }

  /// Sets the output node of the audio graph.
  ///
  /// Mirrors `engine.output = node`. This triggers the native layer
  /// to build the AVAudioEngine connection graph from the node tree.
  Future<void> setOutput(Node node) async {
    _throwIfDisposed();
    await FlutterAudioKitPlatform.instance
        .setEngineOutput(_engineId, node.nodeId);
    _output = node;
  }

  /// Starts the audio engine.
  ///
  /// Mirrors `try engine.start()`. The engine must have an output set.
  Future<void> start() async {
    _throwIfDisposed();
    await FlutterAudioKitPlatform.instance.startEngine(_engineId);
    _isRunning = true;
  }

  /// Stops the audio engine.
  ///
  /// Mirrors `engine.stop()`.
  Future<void> stop() async {
    _throwIfDisposed();
    await FlutterAudioKitPlatform.instance.stopEngine(_engineId);
    _isRunning = false;
  }

  /// Pauses the audio engine.
  ///
  /// Mirrors `engine.pause()`.
  Future<void> pause() async {
    _throwIfDisposed();
    await FlutterAudioKitPlatform.instance.pauseEngine(_engineId);
    _isRunning = false;
  }

  /// Disposes the engine and releases all native resources.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _isRunning = false;
    _output = null;
    await FlutterAudioKitPlatform.instance.disposeEngine(_engineId);
  }

  void _throwIfDisposed() {
    if (_isDisposed) {
      throw StateError('AudioEngine has been disposed.');
    }
  }

  @override
  String toString() => 'AudioEngine($_engineId, running: $_isRunning)';
}
