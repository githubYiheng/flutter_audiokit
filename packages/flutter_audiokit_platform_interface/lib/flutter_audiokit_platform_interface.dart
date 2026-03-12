/// The platform interface for the flutter_audiokit plugin.
///
/// This package provides the abstract platform interface and shared types
/// used by both the app-facing `flutter_audiokit` package and platform-specific
/// implementations (e.g., `flutter_audiokit_ios`).
///
/// Platform implementations should extend [FlutterAudioKitPlatform] rather
/// than implementing it, to ensure forward compatibility.
library flutter_audiokit_platform_interface;

export 'src/platform_interface.dart';
export 'src/types.dart';
