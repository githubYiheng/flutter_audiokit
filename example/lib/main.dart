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
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AudioKit Example'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Player'),
              Tab(text: 'Tone'),
              Tab(text: 'Binaural'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PlayerPage(),
            _ToneGeneratorPage(),
            _BinauralBeatsPage(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Tab 1: Audio Player (original demo)
// ============================================================

class _PlayerPage extends StatefulWidget {
  const _PlayerPage();

  @override
  State<_PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<_PlayerPage>
    with AutomaticKeepAliveClientMixin {
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
  bool get wantKeepAlive => true;

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

  Future<void> _initEngine() async {
    try {
      _addLog('Creating engine...');
      final engine = await AudioEngine.create();
      final player = await AudioPlayer.create();
      final reverb = await Reverb.create(player, dryWetMix: _reverbMix);
      final mixer = await Mixer.withInputs([reverb]);

      await engine.setOutput(mixer);
      await engine.start();
      _addLog('Engine started');

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

  Future<void> _loadFile() async {
    final player = _player;
    if (player == null) return;

    try {
      final data = await rootBundle.load('assets/demo.mp3');
      final tempDir = Directory.systemTemp.path;
      final tempFile = '$tempDir/flutter_audiokit_demo.mp3';
      await File(tempFile).writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      _addLog('Loading audio...');

      final info = await player.load(url: tempFile);
      _addLog('Loaded: ${info.duration.toStringAsFixed(1)}s');
      setState(() {
        _duration = info.duration;
        _status = 'File loaded (${info.duration.toStringAsFixed(1)}s)';
      });

      await player.startAmplitudeTap();
    } catch (e) {
      _addLog('Load failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: _engineRunning ? Colors.green.shade50 : Colors.grey.shade100,
          child: Text(_status,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _engineRunning ? null : _initEngine,
          child:
              Text(_engineRunning ? 'Engine Running' : 'Initialize Engine'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _engineRunning ? _loadFile : null,
          child: const Text('Load demo.mp3'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton.filled(
                onPressed: _engineRunning ? () => _player?.play() : null,
                icon: const Icon(Icons.play_arrow)),
            IconButton.filled(
                onPressed: _engineRunning ? () => _player?.pause() : null,
                icon: const Icon(Icons.pause)),
            IconButton.filled(
                onPressed: _engineRunning ? () => _player?.stop() : null,
                icon: const Icon(Icons.stop)),
          ],
        ),
        if (_duration > 0) ...[
          Slider(
            value: _currentTime.clamp(0, _duration),
            max: _duration,
            onChanged: (v) => _player?.seek(v),
          ),
          Text(
            '${_currentTime.toStringAsFixed(1)} / ${_duration.toStringAsFixed(1)}s',
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 12),
        _label('Volume'),
        Slider(
          value: _volume,
          onChanged: (v) {
            setState(() => _volume = v);
            _player?.volume = v;
          },
        ),
        _label('Reverb Dry/Wet'),
        Slider(
          value: _reverbMix,
          onChanged: (v) {
            setState(() => _reverbMix = v);
            _reverb?.dryWetMix = v;
          },
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final preset in ReverbPreset.values)
              ActionChip(
                label:
                    Text(preset.name, style: const TextStyle(fontSize: 11)),
                onPressed: () => _reverb?.loadFactoryPreset(preset),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _label('Amplitude'),
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
        const SizedBox(height: 12),
        _label('Log'),
        Container(
          height: 160,
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
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      );
}

// ============================================================
// Tab 2: Tone Generator (pure sine wave)
// ============================================================

class _ToneGeneratorPage extends StatefulWidget {
  const _ToneGeneratorPage();

  @override
  State<_ToneGeneratorPage> createState() => _ToneGeneratorPageState();
}

class _ToneGeneratorPageState extends State<_ToneGeneratorPage>
    with AutomaticKeepAliveClientMixin {
  AudioEngine? _engine;
  Oscillator? _osc;
  Mixer? _mixer;

  bool _playing = false;
  double _frequency = 440;
  double _amplitude = 0.5;

  final List<_FrequencyPreset> _presets = const [
    _FrequencyPreset('C4', 261.63),
    _FrequencyPreset('D4', 293.66),
    _FrequencyPreset('E4', 329.63),
    _FrequencyPreset('F4', 349.23),
    _FrequencyPreset('G4', 392.00),
    _FrequencyPreset('A4', 440.00),
    _FrequencyPreset('B4', 493.88),
    _FrequencyPreset('C5', 523.25),
  ];

  @override
  bool get wantKeepAlive => true;

  Future<void> _toggle() async {
    if (_playing) {
      await _osc?.stop();
      setState(() => _playing = false);
      return;
    }

    try {
      if (_engine == null) {
        final engine = await AudioEngine.create();
        final osc = await Oscillator.create(
            frequency: _frequency, amplitude: _amplitude);
        final mixer = await Mixer.withInputs([osc]);
        await engine.setOutput(mixer);
        await engine.start();
        _engine = engine;
        _osc = osc;
        _mixer = mixer;
      }
      await _osc!.start();
      setState(() => _playing = true);
    } catch (e) {
      debugPrint('Tone error: $e');
    }
  }

  @override
  void dispose() {
    _osc?.dispose();
    _mixer?.dispose();
    _engine?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Pure Sine Wave',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('Generate a pure sine wave at a specific frequency.'),
        const SizedBox(height: 24),

        // Frequency
        Row(
          children: [
            const Text('Frequency: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${_frequency.toStringAsFixed(1)} Hz'),
          ],
        ),
        Slider(
          value: _frequency,
          min: 20,
          max: 2000,
          onChanged: (v) {
            setState(() => _frequency = v);
            _osc?.frequency = v;
          },
        ),

        // Presets
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final p in _presets)
              ActionChip(
                label: Text('${p.name}\n${p.freq.toStringAsFixed(0)}Hz',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11)),
                onPressed: () {
                  setState(() => _frequency = p.freq);
                  _osc?.frequency = p.freq;
                },
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Amplitude
        Row(
          children: [
            const Text('Volume: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${(_amplitude * 100).toStringAsFixed(0)}%'),
          ],
        ),
        Slider(
          value: _amplitude,
          min: 0,
          max: 1,
          onChanged: (v) {
            setState(() => _amplitude = v);
            _osc?.amplitude = v;
          },
        ),
        const SizedBox(height: 24),

        // Play button
        FilledButton.icon(
          onPressed: _toggle,
          icon: Icon(_playing ? Icons.stop : Icons.play_arrow),
          label: Text(_playing ? 'Stop' : 'Play Tone'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
      ],
    );
  }
}

class _FrequencyPreset {
  const _FrequencyPreset(this.name, this.freq);
  final String name;
  final double freq;
}

// ============================================================
// Tab 3: Binaural Beats
// ============================================================

class _BinauralBeatsPage extends StatefulWidget {
  const _BinauralBeatsPage();

  @override
  State<_BinauralBeatsPage> createState() => _BinauralBeatsPageState();
}

class _BinauralBeatsPageState extends State<_BinauralBeatsPage>
    with AutomaticKeepAliveClientMixin {
  AudioEngine? _engine;
  Oscillator? _oscLeft;
  Oscillator? _oscRight;
  Mixer? _mixerLeft;
  Mixer? _mixerRight;
  Mixer? _masterMixer;

  bool _playing = false;
  double _baseFrequency = 200;
  double _beatFrequency = 10; // difference between L and R
  double _amplitude = 0.5;

  final List<_BeatPreset> _beatPresets = const [
    _BeatPreset('Delta (deep sleep)', 2),
    _BeatPreset('Theta (meditation)', 6),
    _BeatPreset('Alpha (relaxation)', 10),
    _BeatPreset('Beta (focus)', 20),
    _BeatPreset('Gamma (cognition)', 40),
  ];

  @override
  bool get wantKeepAlive => true;

  double get _leftFreq => _baseFrequency;
  double get _rightFreq => _baseFrequency + _beatFrequency;

  Future<void> _toggle() async {
    if (_playing) {
      await _oscLeft?.stop();
      await _oscRight?.stop();
      setState(() => _playing = false);
      return;
    }

    try {
      if (_engine == null) {
        final engine = await AudioEngine.create();

        // Left oscillator → sub-mixer panned left
        final oscL = await Oscillator.create(
            frequency: _leftFreq, amplitude: _amplitude);
        final mixL = await Mixer.withInputs([oscL]);
        mixL.pan = -1.0; // hard left

        // Right oscillator → sub-mixer panned right
        final oscR = await Oscillator.create(
            frequency: _rightFreq, amplitude: _amplitude);
        final mixR = await Mixer.withInputs([oscR]);
        mixR.pan = 1.0; // hard right

        // Master mixer
        final master = await Mixer.withInputs([mixL, mixR]);

        await engine.setOutput(master);
        await engine.start();

        _engine = engine;
        _oscLeft = oscL;
        _oscRight = oscR;
        _mixerLeft = mixL;
        _mixerRight = mixR;
        _masterMixer = master;
      }

      await _oscLeft!.start();
      await _oscRight!.start();
      setState(() => _playing = true);
    } catch (e) {
      debugPrint('Binaural error: $e');
    }
  }

  @override
  void dispose() {
    _oscLeft?.dispose();
    _oscRight?.dispose();
    _mixerLeft?.dispose();
    _mixerRight?.dispose();
    _masterMixer?.dispose();
    _engine?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Binaural Beats', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text(
          'Two slightly different frequencies in each ear create a perceived '
          '"beat" at the difference frequency. Use headphones for best effect.',
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: const Row(
            children: [
              Icon(Icons.headphones, color: Colors.amber),
              SizedBox(width: 8),
              Expanded(child: Text('Please use headphones!')),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Base frequency
        Row(
          children: [
            const Text('Base Freq: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${_baseFrequency.toStringAsFixed(0)} Hz'),
          ],
        ),
        Slider(
          value: _baseFrequency,
          min: 100,
          max: 500,
          onChanged: (v) {
            setState(() => _baseFrequency = v);
            _oscLeft?.frequency = _leftFreq;
            _oscRight?.frequency = _rightFreq;
          },
        ),

        // Beat frequency
        Row(
          children: [
            const Text('Beat Freq: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${_beatFrequency.toStringAsFixed(1)} Hz'),
          ],
        ),
        Slider(
          value: _beatFrequency,
          min: 1,
          max: 50,
          onChanged: (v) {
            setState(() => _beatFrequency = v);
            _oscRight?.frequency = _rightFreq;
          },
        ),

        // Info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('L: ${_leftFreq.toStringAsFixed(1)} Hz   '
                  'R: ${_rightFreq.toStringAsFixed(1)} Hz'),
              Text('Perceived beat: ${_beatFrequency.toStringAsFixed(1)} Hz',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Presets
        const Text('Presets', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final p in _beatPresets)
              ActionChip(
                label: Text('${p.name}\n${p.beatHz.toStringAsFixed(0)} Hz',
                    style: const TextStyle(fontSize: 11)),
                onPressed: () {
                  setState(() => _beatFrequency = p.beatHz);
                  _oscRight?.frequency = _rightFreq;
                },
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Volume
        Row(
          children: [
            const Text('Volume: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${(_amplitude * 100).toStringAsFixed(0)}%'),
          ],
        ),
        Slider(
          value: _amplitude,
          min: 0,
          max: 1,
          onChanged: (v) {
            setState(() => _amplitude = v);
            _oscLeft?.amplitude = v;
            _oscRight?.amplitude = v;
          },
        ),
        const SizedBox(height: 24),

        // Play button
        FilledButton.icon(
          onPressed: _toggle,
          icon: Icon(_playing ? Icons.stop : Icons.play_arrow),
          label: Text(_playing ? 'Stop Binaural' : 'Start Binaural'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
      ],
    );
  }
}

class _BeatPreset {
  const _BeatPreset(this.name, this.beatHz);
  final String name;
  final double beatHz;
}
