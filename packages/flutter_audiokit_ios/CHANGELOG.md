## 0.1.0

- Initial release
- iOS implementation using AudioKit 5.6+ and SoundpipeAudioKit 5.6+ via SPM
- Pigeon-based type-safe platform channels
- `AudioKitBridge.swift`: full bridge supporting 51 effect types, audio engine, player, mixer, oscillator
- Specialized Pigeon methods for Convolution (impulse response) and PitchTap (pitch detection)
- Real-time callbacks: playback state, amplitude, pitch data, errors
- Native-side logging via `setLogLevel` Pigeon method, synced from Dart `AudioKitLogger`
