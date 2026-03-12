/// Flutter plugin for AudioKit — audio synthesis, processing, and analysis on iOS.
///
/// This package mirrors AudioKit's native Swift API, providing familiar
/// class names and method signatures for Flutter developers.
library flutter_audiokit;

export 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart'
    show
        AudioFileInfo,
        AudioKitError,
        AudioLevelData,
        AnalysisMode,
        BufferLength,
        ConnectStrategy,
        DisconnectStrategy,
        NodeParameterInfo,
        PlaybackState,
        PlaybackStatus,
        StereoMode;

export 'src/audio_engine.dart';
export 'src/audio_player.dart';
export 'src/mixer.dart';
export 'src/node.dart';
export 'src/node_parameter.dart';
export 'src/time_pitch.dart';
export 'src/vari_speed.dart';
