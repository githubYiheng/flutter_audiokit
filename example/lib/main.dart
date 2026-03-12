import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audiokit/flutter_audiokit.dart';

void main() {
  runApp(const AudioKitExampleApp());
}

class AudioKitExampleApp extends StatelessWidget {
  const AudioKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AudioKit Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AudioKitDemoPage(),
    );
  }
}

class AudioKitDemoPage extends StatefulWidget {
  const AudioKitDemoPage({super.key});

  @override
  State<AudioKitDemoPage> createState() => _AudioKitDemoPageState();
}

class _AudioKitDemoPageState extends State<AudioKitDemoPage> {
  AudioEngine? _engine;
  AudioPlayer? _player;
  Mixer? _mixer;
  Reverb? _reverb;

  bool _engineRunning = false;
  bool _isPlaying = false;
  double _currentTime = 0;
  double _duration = 0;
  double _volume = 1.0;
  double _reverbMix = 0.5;
  double _leftAmplitude = 0;
  double _rightAmplitude = 0;

  String _status = 'Not initialized';
  final List<String> _log = [];

  StreamSubscription<PlaybackState>? _stateSub;
  StreamSubscription<AudioLevelData>? _ampSub;
  StreamSubscription<AudioKitError>? _errorSub;

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  Future<void> _cleanup() async {
    await _stateSub?.cancel();
    await _ampSub?.cancel();
    await _errorSub?.cancel();
    await _player?.dispose();
    await _reverb?.dispose();
    await _mixer?.dispose();
    await _engine?.dispose();
  }

  void _addLog(String msg) {
    setState(() {
      _log.insert(0, '${DateTime.now().toString().substring(11, 19)} $msg');
      if (_log.length > 50) _log.removeLast();
    });
  }

  // ---- Engine Setup ----

  Future<void> _initEngine() async {
    try {
      _addLog('Creating engine...');
      final engine = await AudioEngine.create();
      _addLog('Engine created: ${engine.engineId}');

      final player = await AudioPlayer.create();
      _addLog('Player created: ${player.nodeId}');

      final reverb = await Reverb.create(player, dryWetMix: _reverbMix);
      _addLog('Reverb created: ${reverb.nodeId}');

      final mixer = await Mixer.withInputs([reverb]);
      _addLog('Mixer created: ${mixer.nodeId}');

      await engine.setOutput(mixer);
      _addLog('Engine output set to mixer');

      await engine.start();
      _addLog('Engine started');

      // Listen to streams
      _stateSub = player.onStateChanged.listen((state) {
        setState(() {
          _isPlaying = state.status == PlaybackStatus.playing;
          _currentTime = state.currentTime;
          _duration = state.duration;
        });
      });

      _ampSub = player.onAmplitude.listen((data) {
        setState(() {
          _leftAmplitude = data.leftAmplitude;
          _rightAmplitude = data.rightAmplitude;
        });
      });

      _errorSub = FlutterAudioKitPlatform.instance.onError.listen((err) {
        _addLog('ERROR [${err.code}]: ${err.message}');
      });

      setState(() {
        _engine = engine;
        _player = player;
        _mixer = mixer;
        _reverb = reverb;
        _engineRunning = true;
        _status = 'Engine running';
      });
    } catch (e) {
      _addLog('Init failed: $e');
      setState(() => _status = 'Init failed');
    }
  }

  // ---- Audio File ----

  Future<void> _loadFile() async {
    final player = _player;
    if (player == null) return;

    try {
      // Copy bundled asset to a temp path that AudioKit can read
      final data = await rootBundle.load('assets/demo.mp3');
      final tempDir = Directory.systemTemp.path;
      final tempFile = '$tempDir/flutter_audiokit_demo.mp3';
      await File(tempFile).writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      _addLog('Loading: $tempFile');

      final info = await player.load(url: tempFile);
      _addLog('Loaded: ${info.duration.toStringAsFixed(1)}s, '
          '${info.sampleRate.toInt()}Hz, ${info.channels}ch');
      setState(() {
        _duration = info.duration;
        _status = 'File loaded (${info.duration.toStringAsFixed(1)}s)';
      });

      await player.startAmplitudeTap();
      _addLog('Amplitude tap started');
    } catch (e) {
      _addLog('Load failed: $e');
    }
  }

  // ---- Playback Controls ----

  Future<void> _play() async {
    try {
      await _player?.play();
      _addLog('Play');
    } catch (e) {
      _addLog('Play failed: $e');
    }
  }

  Future<void> _pause() async {
    try {
      await _player?.pause();
      _addLog('Pause');
    } catch (e) {
      _addLog('Pause failed: $e');
    }
  }

  Future<void> _stop() async {
    try {
      await _player?.stop();
      _addLog('Stop');
    } catch (e) {
      _addLog('Stop failed: $e');
    }
  }

  Future<void> _seek(double time) async {
    try {
      await _player?.seek(time);
    } catch (e) {
      _addLog('Seek failed: $e');
    }
  }

  // ---- Reverb Preset ----

  Future<void> _loadPreset(ReverbPreset preset) async {
    try {
      await _reverb?.loadFactoryPreset(preset);
      _addLog('Reverb preset: ${preset.name}');
    } catch (e) {
      _addLog('Preset failed: $e');
    }
  }

  // ---- UI ----

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AudioKit Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: _engineRunning ? Colors.green.shade50 : Colors.grey.shade100,
              child: Text(_status,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Engine
                  _sectionTitle('Engine'),
                  ElevatedButton(
                    onPressed: _engineRunning ? null : _initEngine,
                    child: Text(
                        _engineRunning ? 'Engine Running' : 'Initialize Engine'),
                  ),
                  const SizedBox(height: 16),

                  // File
                  _sectionTitle('Audio File'),
                  ElevatedButton(
                    onPressed: _engineRunning ? _loadFile : null,
                    child: const Text('Load demo.mp3 (from assets)'),
                  ),
                  const SizedBox(height: 16),

                  // Playback
                  _sectionTitle('Playback${_isPlaying ? " (Playing)" : ""}'),
                  Row(
                    children: [
                      _iconBtn(Icons.play_arrow, _engineRunning ? _play : null),
                      _iconBtn(Icons.pause, _engineRunning ? _pause : null),
                      _iconBtn(Icons.stop, _engineRunning ? _stop : null),
                    ],
                  ),
                  if (_duration > 0) ...[
                    Slider(
                      value: _currentTime.clamp(0, _duration),
                      max: _duration,
                      onChanged: _seek,
                    ),
                    Text(
                      '${_currentTime.toStringAsFixed(1)} / ${_duration.toStringAsFixed(1)}s',
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Volume
                  _sectionTitle('Volume'),
                  Slider(
                    value: _volume,
                    onChanged: (v) {
                      setState(() => _volume = v);
                      _player?.volume = v;
                    },
                  ),
                  Text('${(_volume * 100).toStringAsFixed(0)}%',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),

                  // Reverb
                  _sectionTitle('Reverb'),
                  Row(
                    children: [
                      const Text('Dry/Wet: '),
                      Expanded(
                        child: Slider(
                          value: _reverbMix,
                          onChanged: (v) {
                            setState(() => _reverbMix = v);
                            _reverb?.dryWetMix = v;
                          },
                        ),
                      ),
                      Text('${(_reverbMix * 100).toStringAsFixed(0)}%'),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final preset in ReverbPreset.values)
                        ActionChip(
                          label: Text(preset.name,
                              style: const TextStyle(fontSize: 11)),
                          onPressed: () => _loadPreset(preset),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Amplitude meters
                  _sectionTitle('Amplitude'),
                  Row(
                    children: [
                      const Text('L: '),
                      Expanded(
                          child: LinearProgressIndicator(
                              value: _leftAmplitude.clamp(0.0, 1.0))),
                      const SizedBox(width: 12),
                      const Text('R: '),
                      Expanded(
                          child: LinearProgressIndicator(
                              value: _rightAmplitude.clamp(0.0, 1.0))),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Log
                  _sectionTitle('Log'),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      itemCount: _log.length,
                      itemBuilder: (_, i) => Text(
                        _log[i],
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      );

  Widget _iconBtn(IconData icon, VoidCallback? onPressed) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: IconButton.filled(onPressed: onPressed, icon: Icon(icon)),
      );
}
