import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

/// Controls the verbosity of flutter_audiokit logging.
enum AudioKitLogLevel {
  /// No logging output. Default.
  none,

  /// Lifecycle events: create, dispose, play, stop, engine start/stop.
  info,

  /// All method calls with parameter values.
  verbose,
}

/// Logger for flutter_audiokit.
///
/// Set [level] to enable debug logging. Logs appear in VS Code Debug Console,
/// terminal, Flutter DevTools, and Xcode console.
///
/// Setting the level also syncs to the native (Swift) layer, so both Dart
/// and native logs are controlled by a single call.
///
/// ```dart
/// AudioKitLogger.level = AudioKitLogLevel.verbose;
/// ```
class AudioKitLogger {
  AudioKitLogger._();

  static AudioKitLogLevel _level = AudioKitLogLevel.none;

  /// Current log level.
  static AudioKitLogLevel get level => _level;

  /// Sets the log level for both Dart and native layers.
  static set level(AudioKitLogLevel value) {
    _level = value;
    // Sync to native side (fire-and-forget).
    try {
      FlutterAudioKitPlatform.instance.setLogLevel(value.index);
    } catch (_) {
      // Platform may not be initialized yet; ignore.
    }
  }

  /// Log at info level (lifecycle events).
  static void info(String message) {
    if (_level.index >= AudioKitLogLevel.info.index) {
      debugPrint('[AudioKit] $message');
      developer.log(message, name: 'AudioKit');
    }
  }

  /// Log at verbose level (all calls with parameters).
  static void verbose(String message) {
    if (_level.index >= AudioKitLogLevel.verbose.index) {
      debugPrint('[AudioKit] $message');
      developer.log(message, name: 'AudioKit', level: 500);
    }
  }
}
