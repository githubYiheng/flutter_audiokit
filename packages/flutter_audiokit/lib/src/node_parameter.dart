import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import 'logger.dart';

/// Runtime wrapper for an AudioKit node parameter.
///
/// Mirrors AudioKit's `NodeParameter` class. Provides get/set access
/// to parameter values and supports ramping (automation).
class NodeParameter {
  /// Creates a NodeParameter from platform info.
  NodeParameter({
    required this.nodeId,
    required NodeParameterInfo info,
  })  : identifier = info.identifier,
        name = info.name,
        _value = info.value,
        defaultValue = info.defaultValue,
        minValue = info.minValue,
        maxValue = info.maxValue;

  /// The node this parameter belongs to.
  final String nodeId;

  /// Unique parameter identifier.
  final String identifier;

  /// Human-readable parameter name.
  final String name;

  /// Default parameter value.
  final double defaultValue;

  /// Minimum allowed value.
  final double minValue;

  /// Maximum allowed value.
  final double maxValue;

  double _value;

  /// Current parameter value (cached).
  double get value => _value;

  /// Sets the parameter value.
  ///
  /// Updates local cache immediately and sends to native.
  set value(double newValue) {
    _value = newValue.clamp(minValue, maxValue);
    AudioKitLogger.verbose('NodeParameter($nodeId.$identifier) = $_value');
    FlutterAudioKitPlatform.instance
        .setNodeParameter(nodeId, identifier, _value);
  }

  /// The valid range for this parameter.
  ({double min, double max}) get range => (min: minValue, max: maxValue);

  /// Smoothly ramps the parameter to [to] over [duration] seconds.
  ///
  /// Mirrors `$param.ramp(to:duration:delay:)`.
  Future<void> ramp({
    required double to,
    required double duration,
    double delay = 0,
  }) {
    _value = to.clamp(minValue, maxValue);
    AudioKitLogger.verbose('NodeParameter($nodeId.$identifier) ramp -> $_value over ${duration}s');
    return FlutterAudioKitPlatform.instance.rampNodeParameter(
      nodeId,
      identifier,
      value: _value,
      duration: duration,
      delay: delay,
    );
  }

  @override
  String toString() =>
      'NodeParameter($identifier: $_value [$minValue...$maxValue])';
}
