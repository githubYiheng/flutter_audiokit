import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import 'node_parameter.dart';

/// Base class for all AudioKit nodes.
///
/// Mirrors AudioKit's `Node` protocol. Every node in the audio graph
/// extends this class and holds a [nodeId] handle to its native counterpart.
abstract class Node {
  /// The unique identifier for this node in the native layer.
  String get nodeId;

  /// The AudioKit node type name (e.g., 'AudioPlayer', 'Mixer').
  String get nodeType;

  /// Whether this node has been disposed.
  bool get isDisposed;

  /// Mirrors `node.isStarted`.
  bool get isStarted;

  /// Throws [StateError] if this node has been disposed.
  void _throwIfDisposed() {
    if (isDisposed) {
      throw StateError('$nodeType($nodeId) has been disposed.');
    }
  }

  /// Mirrors `node.start()`.
  Future<void> start() {
    _throwIfDisposed();
    return _platform.startNode(nodeId);
  }

  /// Mirrors `node.stop()`.
  Future<void> stop() {
    _throwIfDisposed();
    return _platform.stopNode(nodeId);
  }

  /// Mirrors `node.bypass()`.
  Future<void> bypass() {
    _throwIfDisposed();
    return _platform.bypassNode(nodeId);
  }

  /// Retrieves all adjustable parameters of this node.
  ///
  /// Mirrors `node.parameters`.
  Future<List<NodeParameter>> getParameters() async {
    _throwIfDisposed();
    final infos = await _platform.getNodeParameters(nodeId);
    return infos
        .map((info) => NodeParameter(nodeId: nodeId, info: info))
        .toList();
  }

  /// Gets a specific parameter by identifier.
  ///
  /// Mirrors accessing `node.$paramName`.
  Future<NodeParameter?> parameter(String identifier) async {
    _throwIfDisposed();
    final params = await getParameters();
    for (final p in params) {
      if (p.identifier == identifier) return p;
    }
    return null;
  }

  /// Releases native resources associated with this node.
  Future<void> dispose() =>
      _platform.disposeNode(nodeId);

  FlutterAudioKitPlatform get _platform =>
      FlutterAudioKitPlatform.instance;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node &&
          runtimeType == other.runtimeType &&
          nodeId == other.nodeId;

  @override
  int get hashCode => nodeId.hashCode;

  @override
  String toString() => '$nodeType($nodeId)';
}
