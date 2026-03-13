import 'dart:async';

import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

import 'node.dart';

/// Audio file player node.
///
/// Mirrors AudioKit's `AudioPlayer` class. Supports loading audio files,
/// playback control, seeking, looping, and volume adjustment.
///
/// ```dart
/// final player = await AudioPlayer.create();
/// await player.load(url: 'path/to/audio.mp3');
/// await player.play();
/// ```
class AudioPlayer extends Node {
  AudioPlayer._(this._nodeId);

  final String _nodeId;
  bool _isDisposed = false;

  // Write-through cache
  double _volume = 1.0;
  bool _isLooping = false;
  bool _isReversed = false;
  PlaybackStatus _status = PlaybackStatus.stopped;
  double _duration = 0;
  double _currentTime = 0;
  StreamSubscription<PlaybackState>? _stateSubscription;

  @override
  String get nodeId => _nodeId;

  @override
  String get nodeType => 'AudioPlayer';

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool get isStarted => _status == PlaybackStatus.playing;

  /// Creates a new AudioPlayer instance.
  ///
  /// Mirrors `let player = AudioPlayer()`.
  static Future<AudioPlayer> create() async {
    final nodeId =
        await FlutterAudioKitPlatform.instance.createAudioPlayer();
    final player = AudioPlayer._(nodeId);
    player._listenToStateChanges();
    return player;
  }

  void _throwIfDisposed() {
    if (_isDisposed) {
      throw StateError('AudioPlayer($_nodeId) has been disposed.');
    }
  }

  // ---- Properties (write-through cache) ----

  /// Player volume. 0.0...1.0, default 1.0.
  ///
  /// Mirrors `player.volume`.
  double get volume => _volume;
  set volume(double value) {
    _throwIfDisposed();
    _volume = value.clamp(0.0, 1.0);
    FlutterAudioKitPlatform.instance.setPlayerVolume(_nodeId, _volume);
  }

  /// Whether playback loops. Default false.
  ///
  /// Mirrors `player.isLooping`.
  bool get isLooping => _isLooping;
  set isLooping(bool value) {
    _throwIfDisposed();
    _isLooping = value;
    FlutterAudioKitPlatform.instance.setPlayerIsLooping(_nodeId, value);
  }

  /// Whether playback is reversed. Default false.
  ///
  /// Mirrors `player.isReversed`.
  bool get isReversed => _isReversed;
  set isReversed(bool value) {
    _throwIfDisposed();
    _isReversed = value;
    FlutterAudioKitPlatform.instance.setPlayerIsReversed(_nodeId, value);
  }

  /// Whether the player is currently playing.
  ///
  /// Mirrors `player.isPlaying`.
  bool get isPlaying => _status == PlaybackStatus.playing;

  /// Current playback status.
  ///
  /// Mirrors `player.status`.
  PlaybackStatus get status => _status;

  /// Total duration of the loaded audio file in seconds.
  ///
  /// Mirrors `player.duration`.
  double get duration => _duration;

  /// Current playback position in seconds.
  ///
  /// Mirrors `player.currentTime`.
  double get currentTime => _currentTime;

  /// Normalized playback position (0.0 to 1.0).
  ///
  /// Mirrors `player.currentPosition`.
  double get currentPosition =>
      _duration > 0 ? (_currentTime / _duration).clamp(0.0, 1.0) : 0.0;

  // ---- Methods ----

  /// Loads an audio file from a file path or asset path.
  ///
  /// Mirrors `player.load(url:)`. Returns metadata about the loaded file.
  Future<AudioFileInfo> load({required String url}) async {
    _throwIfDisposed();
    final info =
        await FlutterAudioKitPlatform.instance.loadAudioFile(_nodeId, url);
    _duration = info.duration;
    return info;
  }

  /// Starts playback, optionally from a specific time range.
  ///
  /// Mirrors `player.play(from:to:)`.
  Future<void> play({double? from, double? to}) {
    _throwIfDisposed();
    return FlutterAudioKitPlatform.instance.playerPlay(
      _nodeId,
      startTime: from,
      endTime: to,
    );
  }

  /// Pauses playback.
  ///
  /// Mirrors `player.pause()`.
  Future<void> pause() {
    _throwIfDisposed();
    return FlutterAudioKitPlatform.instance.playerPause(_nodeId);
  }

  /// Resumes playback after a pause.
  ///
  /// Mirrors `player.resume()`.
  Future<void> resume() {
    _throwIfDisposed();
    return FlutterAudioKitPlatform.instance.playerResume(_nodeId);
  }

  /// Stops playback and resets the player.
  ///
  /// Mirrors `player.stop()`. This is different from [Node.stop] which
  /// only sets the bypass flag — this actually stops the AVAudioPlayerNode.
  @override
  Future<void> stop() {
    _throwIfDisposed();
    return FlutterAudioKitPlatform.instance.playerStop(_nodeId);
  }

  /// Seeks to a specific time in seconds.
  ///
  /// Mirrors `player.seek(time:)`.
  Future<void> seek(double time) {
    _throwIfDisposed();
    return FlutterAudioKitPlatform.instance.playerSeek(_nodeId, time);
  }

  // ---- Streams ----

  /// Stream of playback state changes for this player.
  ///
  /// Emits whenever the playback state changes (play/pause/stop/seek).
  Stream<PlaybackState> get onStateChanged =>
      FlutterAudioKitPlatform.instance.onPlaybackStateChanged
          .where((state) => state.nodeId == _nodeId);

  /// Stream that emits when playback completes.
  ///
  /// Mirrors setting `player.completionHandler`.
  Stream<void> get onCompleted =>
      FlutterAudioKitPlatform.instance.onPlaybackCompleted
          .where((id) => id == _nodeId)
          .map((_) {});

  /// Stream of amplitude data (requires calling startAmplitudeTap first).
  Stream<AudioLevelData> get onAmplitude =>
      FlutterAudioKitPlatform.instance.onAmplitudeData
          .where((data) => data.nodeId == _nodeId);

  /// Starts an AmplitudeTap on this player node.
  ///
  /// Mirrors creating an `AmplitudeTap(player)`.
  Future<void> startAmplitudeTap({int bufferSize = 1024}) =>
      FlutterAudioKitPlatform.instance
          .startAmplitudeTap(_nodeId, bufferSize: bufferSize);

  /// Stops the AmplitudeTap on this player node.
  Future<void> stopAmplitudeTap() =>
      FlutterAudioKitPlatform.instance.stopAmplitudeTap(_nodeId);

  // ---- Lifecycle ----

  void _listenToStateChanges() {
    _stateSubscription = onStateChanged.listen((state) {
      _status = state.status;
      _currentTime = state.currentTime;
      _duration = state.duration;
    });
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _stateSubscription?.cancel();
    _stateSubscription = null;
    await super.dispose();
  }
}
