# flutter_audiokit_ios

The iOS implementation of [`flutter_audiokit`](../flutter_audiokit/).

Bridges [AudioKit](https://github.com/AudioKit/AudioKit) (v5.6+) and [SoundpipeAudioKit](https://github.com/AudioKit/SoundpipeAudioKit) (v5.6+) to Flutter via [Pigeon](https://pub.dev/packages/pigeon) type-safe platform channels.

## How It Works

```
Dart (FlutterAudioKitIOS)
  ↕  Pigeon (type-safe method channels)
Swift (AudioKitBridge)
  ↕  Native calls
AudioKit / SoundpipeAudioKit frameworks
```

- **`FlutterAudioKitPlugin.swift`** — Plugin registration entry point
- **`AudioKitBridge.swift`** — Core bridge implementation: manages AudioKit nodes, handles all Pigeon API calls, routes parameters and callbacks
- **`Messages.g.swift`** — Pigeon-generated Swift code (do not edit)

### Pigeon Code Generation

The Pigeon interface is defined in `pigeons/messages.dart`. After modifying it, regenerate:

```bash
cd packages/flutter_audiokit_ios
dart run pigeon --input pigeons/messages.dart
```

This produces:
- `lib/src/messages.g.dart` — Dart side
- `ios/.../Messages.g.swift` — Swift side

> Do not manually edit `*.g.dart` or `*.g.swift` files.

## Native Dependencies

AudioKit and SoundpipeAudioKit are pulled via Swift Package Manager (not CocoaPods):

```swift
// ios/flutter_audiokit_ios/Package.swift
dependencies: [
    .package(url: "https://github.com/AudioKit/AudioKit.git", from: "5.6.0"),
    .package(url: "https://github.com/AudioKit/SoundpipeAudioKit.git", from: "5.6.0"),
]
```

## Requirements

- iOS >= 15.0
- Dart SDK >= 3.5.0
- Flutter >= 3.19.0

## Notes

- Swift files will show `No such module 'Flutter'` errors until the Flutter project is built — this is expected
- The bridge supports 51 effect types via a generic `createEffect` factory, plus specialized methods for `Convolution` and `PitchTap`
