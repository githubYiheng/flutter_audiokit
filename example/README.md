# flutter_audiokit Example

A demo app showcasing [`flutter_audiokit`](../packages/flutter_audiokit/) capabilities with three interactive tabs.

## Tabs

### Player
Audio file playback with real-time controls:
- Initialize AudioEngine and load an MP3 file
- Play / Pause / Stop with seek slider
- Volume control
- Reverb effect with dry/wet mix and factory presets
- Real-time stereo amplitude visualization
- Event log

### Tone Generator
Pure sine wave synthesis using `Oscillator`:
- Adjustable frequency (20 Hz - 2000 Hz)
- Note presets (C4 through C5)
- Volume control

### Binaural Beats
Demonstrates stereo panning with two oscillators:
- Left and right oscillators at slightly different frequencies
- Adjustable base frequency and beat frequency
- Brain-wave presets: Delta (2 Hz), Theta (6 Hz), Alpha (10 Hz), Beta (20 Hz), Gamma (40 Hz)
- Requires headphones for the binaural effect

## Running

```bash
# From the project root
cd example
flutter run --device-id <your-ios-device-or-simulator>
```

### Audio File

The Player tab expects an `assets/demo.mp3` file. Place any MP3 file at:

```
example/assets/demo.mp3
```

> The Tone Generator and Binaural Beats tabs work without any audio file.

## Requirements

- iOS device or simulator (iOS 15.0+)
- Flutter >= 3.19.0
