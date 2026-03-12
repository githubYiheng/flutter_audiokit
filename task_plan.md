# Task Plan — flutter_audiokit Phase 1 验证 + Phase 3 推进

## Goal
完成 Phase 1 剩余验证工作（bootstrap、pigeon codegen、example app），然后推进 Phase 3（剩余 SoundpipeAudioKit 效果器 + 高级功能）。

## Current State
- Phase 1 脚手架 ✅，AmplitudeTap 立体声 ✅，进度定时器 ✅
- Phase 2 效果器 ✅ 全部 18 个实现
- Phase A 验证 ✅ 全部通过（bootstrap、pigeon codegen、dart analyze、melos.yaml 清理）
- Phase B Example App ✅ 骨架完成
- Phase C ✅ 全部完成（33 个新效果器 + Convolution + PitchTap）
- Phase D 未开始

---

## Phase A — 验证基础设施 [status: complete]

### A1. melos bootstrap ✅
### A2. Pigeon 代码生成 ✅
### A3. Dart 静态分析 ✅
### A4. melos.yaml 删除 ✅

## Phase B — Example App [status: complete]
### B1. 创建 example app 骨架 ✅
### B2. 实现基础集成测试页面 ✅

## Phase C — Phase 3 效果器 + 高级功能 [status: complete]

### C1. 新增 SoundpipeAudioKit 效果器 (33 个) ✅

**Reverbs (3):**
- [x] ChowningReverb
- [x] FlatFrequencyResponseReverb
- [x] CombFilterReverb

**Delay (1):**
- [x] VariableDelay

**Filters (16):**
- [x] KorgLowPassFilter, RolandTB303Filter, DiodeLadderFilter
- [x] LowPassButterworthFilter, HighPassButterworthFilter
- [x] BandPassButterworthFilter, BandRejectButterworthFilter
- [x] ThreePoleLowpassFilter, ResonantFilter
- [x] EqualizerFilter, FormantFilter
- [x] ToneFilter, ToneComplementFilter
- [x] ModalResonanceFilter
- [x] PeakingParametricEqualizerFilter, LowShelfParametricEqualizerFilter, HighShelfParametricEqualizerFilter

**Distortion (3):**
- [x] TanhDistortion, BitCrusher, Clipper

**Modulation (5):**
- [x] Phaser, Tremolo, AutoWah, AutoPanner, Vibrato

**Spatial (1):**
- [x] StringResonator

**Utility (3):**
- [x] DCBlock, AmplitudeEnvelope

**Special (1):**
- [x] Convolution（脉冲响应混响 — 需要 Pigeon 专用方法 createConvolution）

### C2. 高级功能 ✅
- [x] Convolution（脉冲响应混响）— 新增 Pigeon 方法 + Swift + Dart
- [x] PitchTap（音高检测）— 新增 Pigeon 方法 + Swift + Dart + PitchData 类型

### C3. Pigeon 代码重新生成 ✅
- [x] messages.g.dart 重新生成
- [x] Messages.g.swift 重新生成
- [x] dart analyze 全部 4 包 0 errors

## Phase D — 测试与文档 [status: complete]
- [x] 补充 platform_interface 单元测试（106 tests all pass）
  - platform_interface_test: 80 tests（instance管理 + 42个方法UnimplementedError + mock返回值 + void方法完成）
  - types_test: 26 tests（6个数据类 + 8个枚举全覆盖）
- [x] 确保所有效果器的参数范围与 AudioKit 源码一致（已验证 51 个效果器参数匹配）

## Phase E — 项目文档 [status: complete]
- [x] 根目录 README.md — 项目总览、安装、使用示例、架构、效果器列表、开发命令
- [x] packages/flutter_audiokit/README.md — App-facing 包文档、API 概览、快速上手
- [x] packages/flutter_audiokit_platform_interface/README.md — 平台接口说明、共享类型表
- [x] packages/flutter_audiokit_ios/README.md — iOS 实现说明、Pigeon 代码生成、SPM 依赖
- [x] example/README.md — 三个 Tab 功能介绍、运行方式、音频文件说明
- [x] 3 个包 CHANGELOG.md — 0.1.0 初始版本记录

---

## Decisions Log
| Decision | Reason |
|----------|--------|
| 效果器使用 generic createEffect + setNodeParameter | 避免为每个效果器添加专用 Pigeon 方法，减少桥接层代码量 |
| Reverb 特殊处理 dryWetMix | AudioKit Reverb 不使用标准 @Parameter 包装器 |
| ZitaReverb equalizerFrequency2 fallback | AudioKit 源码 identifier 与属性名不一致 |
| melos.yaml → pubspec.yaml melos: | Melos 7.x 要求配置在 pubspec.yaml 中 |
| SDK >=3.5.0 | pub workspace 特性最低要求 |
| flutter_lints ^6.0.0 统一 | workspace 要求所有包版本一致 |
| FlutterAudioKitPlatform 加入 barrel export | example app 需要访问 onError 全局流 |
| Convolution 单独 Pigeon 方法 | createEffect 的 params Map<String,double> 无法传递文件路径字符串 |
| PitchTap 单独 Pigeon 方法 | 与 AmplitudeTap 一样需要专用 start/stop + 回调 |
| dryWetMix 后设置（VariableDelay/TanhDistortion/BitCrusher/Phaser）| 这些效果器的 Swift init 不接受 dryWetMix 参数 |
| Tremolo/AutoPanner 使用默认 waveform | Table 类型暂不桥接，使用默认 positiveSine |

## Errors Encountered
| Error | Resolution |
|-------|------------|
| AVAudioUnitReverbPresetType 不存在 | 改为 AVAudioUnitReverbPreset |
| _FlutterApiHandler.onError 无限递归 | 字段改名为 onErrorCallback |
| ZitaReverb equalizerFrequency2 不匹配 | 添加 identifier fallback 映射 |
| melos "not within workspace" | 创建根 pubspec.yaml + workspace 字段 + resolution: workspace |
| SDK ^3.3.0 不支持 workspace | 升级到 ^3.5.0 |
| melos run pigeon PATH 问题 | 直接 cd 到 ios 包运行 dart run pigeon |
| Pigeon 生成后同步调用变 async | 5 处加 await（已修复） |
| flutter_lints ^5.0.0 vs ^6.0.0 冲突 | 统一为 ^6.0.0 |
