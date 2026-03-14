import 'dart:async';

import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import 'logger.dart';

/// Manages iOS system Now Playing info and remote command handlers.
///
/// Provides a high-level API over MPNowPlayingInfoCenter and
/// MPRemoteCommandCenter, similar to how [AudioEngine] wraps the native
/// audio engine.
///
/// ```dart
/// await NowPlaying.configureCommands(const RemoteCommandConfig());
/// await NowPlaying.update(title: 'Song', artist: 'Artist', isPlaying: true);
/// NowPlaying.onRemoteCommand.listen((event) { ... });
/// ```
class NowPlaying {
  NowPlaying._();

  /// Updates the system Now Playing metadata (lock screen / control center / CarPlay).
  static Future<void> update({
    required String title,
    required String artist,
    String? artworkAssetKey,
    required bool isPlaying,
    double? duration,
    double? currentTime,
    bool isLiveStream = true,
  }) async {
    await FlutterAudioKitPlatform.instance.updateNowPlayingInfo(
      title: title,
      artist: artist,
      artworkAssetKey: artworkAssetKey,
      isPlaying: isPlaying,
      duration: duration,
      currentTime: currentTime,
      isLiveStream: isLiveStream,
    );
    AudioKitLogger.info('NowPlaying updated: $title ($artist)');
  }

  /// Clears all Now Playing metadata.
  static Future<void> clear() async {
    await FlutterAudioKitPlatform.instance.clearNowPlayingInfo();
    AudioKitLogger.info('NowPlaying cleared');
  }

  /// Configures which remote commands are enabled on system media controls.
  static Future<void> configureCommands(RemoteCommandConfig config) async {
    await FlutterAudioKitPlatform.instance.configureRemoteCommands(config);
    AudioKitLogger.info('NowPlaying remote commands configured');
  }

  /// Disables all remote command handlers.
  static Future<void> disableCommands() async {
    await FlutterAudioKitPlatform.instance.disableRemoteCommands();
    AudioKitLogger.info('NowPlaying remote commands disabled');
  }

  /// Stream of remote command events from system media controls.
  static Stream<RemoteCommandEvent> get onRemoteCommand =>
      FlutterAudioKitPlatform.instance.onRemoteCommand;
}
