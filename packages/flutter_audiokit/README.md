# flutter_audiokit

The app-facing package of the `flutter_audiokit` plugin. This is the package you add to your `pubspec.yaml`.

It provides a complete Dart API mirroring [AudioKit](https://github.com/AudioKit/AudioKit) and [SoundpipeAudioKit](https://github.com/AudioKit/SoundpipeAudioKit) for Flutter on iOS.

## Installation

```yaml
dependencies:
  flutter_audiokit: ^0.1.0
```

## Requirements

- Dart SDK >= 3.5.0
- Flutter >= 3.19.0
- iOS >= 15.0

## Quick Start

```dart
import 'package:flutter_audiokit/flutter_audiokit.dart';

// 1. Build the audio graph
final engine = await AudioEngine.create();
final player = await AudioPlayer.create();
final reverb = await Reverb.create(player, dryWetMix: 0.5);
final mixer  = await Mixer.withInputs([reverb]);

// 2. Connect and start
await engine.setOutput(mixer);
await engine.start();

// 3. Load and play
await player.load(url: '/path/to/audio.mp3');
await player.play();
```

## API Overview

### Core Classes

| Class | Description |
|-------|-------------|
| `AudioEngine` | Manages the audio processing graph |
| `AudioPlayer` | Loads and plays audio files |
| `Mixer` | Multi-input mixing with volume and pan |
| `Oscillator` | Waveform synthesis (sine, square, triangle, sawtooth) |
| `Node` | Base class for all audio nodes |
| `NodeParameter` | Runtime parameter inspection and ramping |
| `TimePitch` | Time-stretch and pitch-shift |
| `VariSpeed` | Playback speed adjustment |

### Effects (51 classes)

All effects follow the same pattern:

```dart
// Create an effect with an input node
final effect = await EffectClass.create(inputNode, param1: value1);

// Adjust parameters in real-time (write-through cache)
effect.param1 = newValue;

// Dispose when done
await effect.dispose();
```

**Categories:** Reverb (7), Delay (2), Filter (22), Distortion (4), Dynamics (4), Modulation (5), Spatial (2), Utility (5)

### Real-time Analysis

- **AmplitudeTap** — Stereo amplitude monitoring via `player.onAmplitude`
- **PitchTap** — Pitch detection via `FlutterAudioKitPlatform.instance.onPitchData`

### Playback Streams

- `player.onStateChanged` — Playback status, current time, duration
- `player.onCompleted` — Fires when playback reaches end
- `player.onAmplitude` — Real-time amplitude levels

## Design

- All class/method/parameter names mirror AudioKit's Swift API
- Audio nodes are referenced by UUID handles; Dart controls native nodes via platform channels
- Property setters use write-through cache (update local + fire-and-forget to native)
- All DSP runs natively; Dart only sends commands and receives state

## Platform Implementation

This package delegates to platform-specific implementations via the [federated plugin](https://docs.flutter.dev/packages-and-plugins/developing-packages#federated-plugins) pattern:

- [`flutter_audiokit_platform_interface`](../flutter_audiokit_platform_interface/) — Abstract interface
- [`flutter_audiokit_ios`](../flutter_audiokit_ios/) — iOS implementation using AudioKit + Pigeon

For detailed usage, see the [root README](../../README.md) or the [example app](../../example/).
