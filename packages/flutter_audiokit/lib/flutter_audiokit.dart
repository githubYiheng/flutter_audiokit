/// Flutter plugin for AudioKit — audio synthesis, processing, and analysis on iOS.
///
/// This package mirrors AudioKit's native Swift API, providing familiar
/// class names and method signatures for Flutter developers.
library flutter_audiokit;

export 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart'
    show
        AudioFileInfo,
        AudioLevelData,
        AnalysisMode,
        BufferLength,
        NodeParameterInfo,
        PitchData,
        PlaybackState,
        PlaybackStatus,
        ReverbPreset,
        StereoMode;

export 'src/logger.dart';

export 'src/audio_engine.dart';
export 'src/audio_player.dart';
export 'src/mixer.dart';
export 'src/node.dart';
export 'src/oscillator.dart';
export 'src/node_parameter.dart';
export 'src/time_pitch.dart';
export 'src/vari_speed.dart';

// Effects — AudioKit Core
export 'src/effects/band_pass_filter.dart';
export 'src/effects/compressor.dart';
export 'src/effects/delay.dart';
export 'src/effects/distortion.dart';
export 'src/effects/dynamics_processor.dart';
export 'src/effects/high_pass_filter.dart';
export 'src/effects/high_shelf_filter.dart';
export 'src/effects/low_pass_filter.dart';
export 'src/effects/low_shelf_filter.dart';
export 'src/effects/parametric_eq.dart';
export 'src/effects/peak_limiter.dart';
export 'src/effects/reverb.dart';

// Effects — SoundpipeAudioKit: Reverbs
export 'src/effects/chowning_reverb.dart';
export 'src/effects/comb_filter_reverb.dart';
export 'src/effects/convolution.dart';
export 'src/effects/costello_reverb.dart';
export 'src/effects/flat_frequency_response_reverb.dart';
export 'src/effects/zita_reverb.dart';

// Effects — SoundpipeAudioKit: Delay
export 'src/effects/variable_delay.dart';

// Effects — SoundpipeAudioKit: Filters
export 'src/effects/band_pass_butterworth_filter.dart';
export 'src/effects/band_reject_butterworth_filter.dart';
export 'src/effects/diode_ladder_filter.dart';
export 'src/effects/equalizer_filter.dart';
export 'src/effects/formant_filter.dart';
export 'src/effects/high_pass_butterworth_filter.dart';
export 'src/effects/high_shelf_parametric_equalizer_filter.dart';
export 'src/effects/korg_low_pass_filter.dart';
export 'src/effects/low_pass_butterworth_filter.dart';
export 'src/effects/low_shelf_parametric_equalizer_filter.dart';
export 'src/effects/modal_resonance_filter.dart';
export 'src/effects/moog_ladder.dart';
export 'src/effects/peaking_parametric_equalizer_filter.dart';
export 'src/effects/resonant_filter.dart';
export 'src/effects/roland_tb303_filter.dart';
export 'src/effects/three_pole_lowpass_filter.dart';
export 'src/effects/tone_complement_filter.dart';
export 'src/effects/tone_filter.dart';

// Effects — SoundpipeAudioKit: Dynamics
export 'src/effects/clipper.dart';
export 'src/effects/dynamic_range_compressor.dart';

// Effects — SoundpipeAudioKit: Distortion
export 'src/effects/bit_crusher.dart';
export 'src/effects/tanh_distortion.dart';

// Effects — SoundpipeAudioKit: Modulation
export 'src/effects/auto_panner.dart';
export 'src/effects/auto_wah.dart';
export 'src/effects/phaser.dart';
export 'src/effects/tremolo.dart';
export 'src/effects/vibrato.dart';

// Effects — SoundpipeAudioKit: Spatial
export 'src/effects/string_resonator.dart';

// Effects — SoundpipeAudioKit: Utility
export 'src/effects/amplitude_envelope.dart';
export 'src/effects/dc_block.dart';
export 'src/effects/panner.dart';
export 'src/effects/pitch_shifter.dart';
