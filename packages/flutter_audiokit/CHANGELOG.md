## 0.1.0

- Initial release
- Core audio classes: `AudioEngine`, `AudioPlayer`, `Mixer`, `Oscillator`, `Node`, `NodeParameter`, `TimePitch`, `VariSpeed`
- 51 audio effects mirroring AudioKit and SoundpipeAudioKit:
  - Reverbs: Reverb, CostelloReverb, ChowningReverb, ZitaReverb, FlatFrequencyResponseReverb, CombFilterReverb, Convolution
  - Delays: Delay, VariableDelay
  - Filters: 22 filter types (Butterworth, Korg, Roland TB-303, Moog Ladder, and more)
  - Distortion: Distortion, TanhDistortion, BitCrusher, Clipper
  - Dynamics: Compressor, DynamicsProcessor, PeakLimiter, DynamicRangeCompressor
  - Modulation: Phaser, Tremolo, AutoWah, AutoPanner, Vibrato
  - Spatial: Panner, StringResonator
  - Utility: AmplitudeEnvelope, DCBlock, PitchShifter
- Real-time analysis: AmplitudeTap (stereo), PitchTap
- Playback streams: state changes, completion, amplitude levels
