# Findings

## Pigeon 代码生成行为
- Pigeon 22.7.x 生成的 HostApi Dart 代码中，**所有方法都返回 Future**，无论原始定义是否标记 @async
- 这与手写代码假设同步调用不兼容 — flutter_audiokit_ios.dart 有 5 处需要加 await（已修复）
- 生成的 Swift 代码中，@async 标记的方法使用 completion handler，未标记的使用 throws

## Melos 7.x 变更
- 配置从独立 `melos.yaml` 迁移到根 `pubspec.yaml` 的 `melos:` 字段
- 需要根 `pubspec.yaml` 的 `workspace:` 字段列出所有包
- 每个包的 pubspec.yaml 需要 `resolution: workspace`
- 最低 SDK 要求 >=3.5.0
- workspace 中所有包的 dev_dependencies 版本必须兼容（如 flutter_lints 必须统一）

## AudioKit 参数系统
- AudioKit 的 @Parameter 包装器注册标准参数 → getNodeParameters / setNodeParameter 可用
- Apple AU 效果器（Reverb）的 dryWetMix 是直接属性，不走标准参数系统 → 需特殊处理
- ZitaReverb 的 equalizerFrequency2 的 NodeParameterDef identifier 是 "EQ Frequency 2" 而非 "equalizerFrequency2" → 需 fallback
- AVAudioUnitReverbPreset（不是 AVAudioUnitReverbPresetType）是正确的 Swift 类型名

## SoundpipeAudioKit 效果器 init 参数差异
- VariableDelay、TanhDistortion、BitCrusher、Phaser 的 `dryWetMix` 不在 init 参数列表中
  → 创建后需要单独通过属性赋值设置
- Tremolo、AutoPanner 接受 `waveform: Table` 参数（默认 positiveSine）
  → Table 类型暂不桥接，使用默认值
- Vibrato 的 init 参数名是 `vibratoSpeed` / `vibratoDepth`（不是 `speed` / `depth`）
  → Dart 侧用 `speed` / `depth`，Swift 侧映射到 `vibratoSpeed` / `vibratoDepth`
- FlatFrequencyResponseReverb / CombFilterReverb 的 `loopDuration` 是 init-only 参数
  → 通过 params map 传递到 Swift，但不暴露为 Dart setter

## Convolution 特殊处理
- `Convolution(input, impulseResponseFileURL:, partitionLength:)` 需要 URL 参数
- `createEffect` 的 `params: Map<String, double>` 无法传递字符串
- → 新增专用 Pigeon 方法 `createConvolution(inputNodeId, filePath, partitionLength)`

## PitchTap 实现
- PitchTap 回调签名: `(pitches: [Float], amplitudes: [Float]) -> Void`
- pitches/amplitudes 数组长度取决于声道数（mono=1, stereo=2）
- 新增 PlatformPitchData 类型 + onPitchData 回调

## Flutter 环境
- Flutter 3.41.4 stable (via FVM)
- Dart SDK 3.11.1
- 路径: /Users/designer.ai/fvm/versions/stable/bin/
- melos 安装在 ~/.pub-cache/bin/melos，但 shell PATH 不包含此目录

## Example App
- flutter create 生成的 iOS 默认 deployment target 是 13.0，AudioKit 需要 15.0
- 需要修改 project.pbxproj 中 3 处 IPHONEOS_DEPLOYMENT_TARGET
- 音频文件从 Flutter assets 加载时，需先复制到 temp 目录（AudioKit 读取文件路径）

## 效果器统计
- 共 51 个效果器 Dart 类（18 Phase 2 + 33 Phase C）
- AudioKit Core: 12 个（Delay, Reverb, Distortion, Compressor, DynamicsProcessor, PeakLimiter, 6 种 Filter, ParametricEQ）
- SoundpipeAudioKit: 39 个（6 Reverb, 1 Delay, 19 Filter, 3 Distortion, 5 Modulation, 1 Spatial, 3 Utility, 1 Convolution）
