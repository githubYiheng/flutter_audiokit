# flutter_audiokit

Flutter plugin bridging [AudioKit](https://github.com/AudioKit/AudioKit) and [SoundpipeAudioKit](https://github.com/AudioKit/SoundpipeAudioKit) to Flutter/Dart for iOS.

Provides a complete, 1:1 mirror of AudioKit's native Swift API — including audio engine, player, mixer, oscillator, 51 audio effects, amplitude/pitch analysis, and more.

> **Platform support:** iOS only (15.0+).

## Features

- **AudioEngine** — Start/stop/pause the audio engine
- **AudioPlayer** — Load, play, pause, stop, seek audio files with playback state & progress streams
- **Mixer** — Multi-track mixing with volume and pan control
- **Oscillator** — Pure waveform synthesis (sine, square, triangle, sawtooth)
- **51 Audio Effects** — Reverbs, delays, filters, distortion, modulation, dynamics, and more
- **Convolution** — Impulse response reverb from audio files
- **AmplitudeTap** — Real-time stereo amplitude monitoring
- **PitchTap** — Real-time pitch detection
- **NodeParameter** — Runtime parameter inspection and ramping

## Getting Started

### Prerequisites

- Flutter >= 3.19.0 / Dart >= 3.5.0
- iOS deployment target >= 15.0
- AudioKit 5.6+ and SoundpipeAudioKit 5.6+ (pulled automatically via SPM)

### Installation

Add `flutter_audiokit` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_audiokit: ^0.1.0
```

### iOS Setup

In your iOS project's `Podfile` or Xcode project, ensure the minimum deployment target is **iOS 15.0**.

## Usage

### Basic Audio Playback

```dart
import 'package:flutter_audiokit/flutter_audiokit.dart';

// Create the audio graph
final engine = await AudioEngine.create();
final player = await AudioPlayer.create();
final mixer  = await Mixer.withInputs([player]);

await engine.setOutput(mixer);
await engine.start();

// Load and play an audio file
final info = await player.load(url: '/path/to/audio.mp3');
await player.play();

// Listen to playback state changes
player.onStateChanged.listen((state) {
  print('Status: ${state.status}, Time: ${state.currentTime}');
});
```

### Applying Effects

```dart
// Insert a reverb between the player and mixer
final reverb = await Reverb.create(player, dryWetMix: 0.6);
final mixer  = await Mixer.withInputs([reverb]);

// Change reverb preset at runtime
await reverb.loadFactoryPreset(ReverbPreset.largeChamber);

// Use a SoundpipeAudioKit filter
final filter = await KorgLowPassFilter.create(player,
  cutoffFrequency: 1000,
  resonance: 0.8,
);
```

### Tone Generation with Oscillator

```dart
final engine = await AudioEngine.create();
final osc = await Oscillator.create(frequency: 440, amplitude: 0.5);
final mixer = await Mixer.withInputs([osc]);

await engine.setOutput(mixer);
await engine.start();
await osc.start();

// Change frequency in real-time
osc.frequency = 880;
```

### Amplitude Monitoring

```dart
await player.startAmplitudeTap();

player.onAmplitude.listen((data) {
  print('L: ${data.leftAmplitude}, R: ${data.rightAmplitude}');
});
```

### Pitch Detection

```dart
await player.startPitchTap();

FlutterAudioKitPlatform.instance.onPitchData.listen((data) {
  print('Pitch: ${data.pitch} Hz, Amplitude: ${data.amplitude}');
});
```

### Debug Logging

```dart
// Enable verbose logging (Dart + native Swift logs)
AudioKitLogger.level = AudioKitLogLevel.verbose;

// Info-level: lifecycle events only (create, dispose, play, stop)
AudioKitLogger.level = AudioKitLogLevel.info;

// Disable logging (default)
AudioKitLogger.level = AudioKitLogLevel.none;
```

Logs appear in the VS Code Debug Console, terminal, Flutter DevTools, and Xcode console. Setting the level in Dart automatically syncs to the native (Swift) layer.

## Architecture

This plugin uses the [Federated Plugin](https://docs.flutter.dev/packages-and-plugins/developing-packages#federated-plugins) pattern:

```
packages/
├── flutter_audiokit/                      ← App-facing package (import this)
├── flutter_audiokit_platform_interface/   ← Abstract interface + shared types
└── flutter_audiokit_ios/                  ← iOS implementation (Pigeon + AudioKit)
```

### Design Principles

1. **Mirror AudioKit's API** — Class names, method names, and parameters match AudioKit's Swift API
2. **Handle-based** — Each native AudioKit node is referenced by a UUID (`nodeId`); Dart controls nodes via handles
3. **Write-through cache** — Property setters update the local cache immediately and fire-and-forget to native
4. **Native audio processing** — All DSP runs on the native side; Dart only sends control commands and receives state

## Available Effects (51)

| Category | Effects |
|----------|---------|
| **Reverb** | Reverb, CostelloReverb, ChowningReverb, ZitaReverb, FlatFrequencyResponseReverb, CombFilterReverb, Convolution |
| **Delay** | Delay, VariableDelay |
| **Filter** | LowPassFilter, HighPassFilter, BandPassFilter, LowShelfFilter, HighShelfFilter, ParametricEQ, MoogLadder, KorgLowPassFilter, RolandTB303Filter, DiodeLadderFilter, LowPassButterworthFilter, HighPassButterworthFilter, BandPassButterworthFilter, BandRejectButterworthFilter, ThreePoleLowpassFilter, ResonantFilter, EqualizerFilter, FormantFilter, ToneFilter, ToneComplementFilter, ModalResonanceFilter, PeakingParametricEqualizerFilter, LowShelfParametricEqualizerFilter, HighShelfParametricEqualizerFilter |
| **Distortion** | Distortion, TanhDistortion, BitCrusher, Clipper |
| **Dynamics** | Compressor, DynamicsProcessor, PeakLimiter, DynamicRangeCompressor |
| **Modulation** | Phaser, Tremolo, AutoWah, AutoPanner, Vibrato |
| **Spatial** | Panner, StringResonator |
| **Utility** | AmplitudeEnvelope, DCBlock, PitchShifter, TimePitch, VariSpeed |

## Development

This project uses [Melos](https://melos.invertase.dev/) for monorepo management.

```bash
# Install dependencies
melos bootstrap

# Generate Pigeon bridge code
melos run pigeon

# Run static analysis
melos run analyze

# Run tests
melos run test
```

## License

See individual packages for license information.
