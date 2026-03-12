# flutter_audiokit_platform_interface

The platform interface for the [`flutter_audiokit`](../flutter_audiokit/) plugin.

This package provides the abstract `FlutterAudioKitPlatform` class that all platform implementations must extend, plus the shared data types used across the plugin.

## Usage

**App developers:** You do not need to depend on this package directly. Use [`flutter_audiokit`](../flutter_audiokit/) instead.

**Platform implementors:** Extend `FlutterAudioKitPlatform` and implement all abstract methods.

```dart
import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';

class FlutterAudioKitMyPlatform extends FlutterAudioKitPlatform {
  @override
  Future<String> createEngine() async {
    // Platform-specific implementation
  }
  // ... implement all methods
}
```

## Shared Types

| Type | Description |
|------|-------------|
| `AudioFileInfo` | Metadata returned after loading an audio file |
| `PlaybackState` | Current playback status, time position, and duration |
| `PlaybackStatus` | Enum: `stopped`, `playing`, `paused` |
| `AudioLevelData` | Stereo amplitude data from AmplitudeTap |
| `PitchData` | Pitch and amplitude data from PitchTap |
| `AudioKitError` | Structured error with code, message, and optional nodeId |
| `NodeParameterInfo` | Parameter metadata (name, min, max, value, unit) |
| `ReverbPreset` | Apple AU reverb presets |
| `AnalysisMode` | Amplitude analysis mode |
| `StereoMode` | Stereo/mono configuration |
| `ConnectStrategy` | How nodes connect in the audio graph |
| `DisconnectStrategy` | How nodes disconnect from the graph |
| `BufferLength` | Audio buffer size options |

## Requirements

- Dart SDK >= 3.5.0
- Flutter >= 3.19.0
