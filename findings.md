# Findings — Code Review 报告验证

## 验证结果汇总

29 个问题全部逐一对照代码验证。**28 个确认存在，1 个有争议。**

---

## CRITICAL (5/5 确认存在)

| ID | 问题 | 状态 | 备注 |
|----|------|------|------|
| C-1 | dryWetMix setter 对 4 个效果器抛异常 | ✅ 确认 | setNodeParameter 只处理 Reverb/ZitaReverb 的 dryWetMix，VariableDelay/TanhDistortion/BitCrusher/Phaser 不在列 |
| C-2 | Tap 未在 disposeNode 中 stop | ✅ 确认 | disposeNode 只 removeValue 不 .stop()，而 stopAmplitudeTap/stopPitchTap 正确调了 .stop() |
| C-3 | rampNodeParameter 缺 Reverb dryWetMix | ✅ 确认 | setNodeParameter 有 Reverb dryWetMix 处理，rampNodeParameter 没有 |
| C-4 | Oscillator.dispose() 无幂等守卫 | ✅ 确认 | 缺 if (_isDisposed) return; 且 _isDisposed=true 在 super.dispose() 之后 |
| C-5 | completionHandler 在 play() 之后设置 | ✅ 确认 | playerPlay 方法先 player.play()，后设 completionHandler |

## HIGH (6/6 确认存在)

| ID | 问题 | 状态 | 备注 |
|----|------|------|------|
| H-1 | 直接依赖 flutter_audiokit_ios | ❌ 误报 | Flutter Federated Plugin 的 default_package 机制要求 app-facing 包显式依赖实现包，移除会导致插件无法加载 |
| H-2 | ConnectStrategy/DisconnectStrategy 被丢弃 | ✅ 确认 | iOS impl 接收参数但不传给 Pigeon/Swift |
| H-3 | disposeEngine 不清理 nodes | ✅ 确认 | 只 engine.stop()，不清理 nodes/taps/timers |
| H-4 | Mixer.isStarted 和 VariSpeed.isStarted 语义错误 | ✅ 确认 | Mixer 用 volume!=0，VariSpeed 用 rate!=1.0，应该用状态标记 |
| H-5 | Node/AudioPlayer 方法不检查 isDisposed | ✅ 确认 | Node.start/stop/bypass 和 AudioPlayer 所有方法都无检查 |
| H-6 | Swift 无主线程保证 | ✅ 确认 | 无 @MainActor，无 DispatchQueue.main.async |

## MEDIUM (10/11 确认存在，1 个有争议)

| ID | 问题 | 状态 | 备注 |
|----|------|------|------|
| M-1 | Timer 未加 .common RunLoop mode | ✅ 确认 | 使用 Timer.scheduledTimer 默认 .default mode |
| M-2 | PitchTap 无数组边界检查 | ✅ 确认 | pitches[0]/amplitudes[0] 直接访问，无 isEmpty 守卫 |
| M-3 | Delay 默认 dryWetMix 100 | ✅ 确认 | 应为 50 |
| M-4 | PlaybackStatus 无边界检查 | ✅ 确认 | 两处直接 .values[state.statusIndex] |
| M-5 | AudioPlayer.volume 缺 clamp | ⚠️ 有争议 | 报告称"Mixer.volume 有 clamp"但实际 Mixer.volume 也没有 clamp。AudioKit AudioPlayer.volume 可能允许 >1.0 做增益放大。但从 API 安全角度仍建议 clamp |
| M-6 | VariableDelay.time 硬编码 10.0 | ✅ 确认 | 应使用实际 maximumTime |
| M-7 | Timer 自停不发最终状态 | ✅ 确认 | guard 失败时只 stopTimer 不 sendPlayerState |
| M-8 | Mixer.addInput 并发重复添加 | ✅ 确认 | contains 检查在 await 之后 |
| M-9 | AmplitudeTap 数据竞争 | ✅ 确认 | tap.leftAmplitude 在回调中读取无同步保护 |
| M-10 | bridge 可能被 ARC 释放 | ✅ 确认 | bridge 是局部变量，依赖 Pigeon 实现细节持有强引用 |
| M-11 | DynamicRangeCompressor gain 默认值错误 | ✅ 确认 | 默认 1 应为 0 |

### M-5 争议说明
报告原文称"所有其他 setter（`Mixer.volume`、`TimePitch.rate`、所有效果器参数）均使用 `.clamp()`"，但验证发现 **Mixer.volume 也没有 clamp**。报告此处描述不准确。不过 AudioPlayer.volume 加 clamp 仍然是好实践。

## LOW (7/7 确认存在)

| ID | 问题 | 状态 | 备注 |
|----|------|------|------|
| L-1 | FlutterAudioKitPlatform 导出 | ✅ 确认 | 在 barrel export 的 show 列表中 |
| L-2 | doc comment 错位 | ✅ 确认 | createEffect 和 createOscillator 注释混在一起 |
| L-3 | onError 流永不 emit | ✅ 确认 | AudioKitBridge 从未调用 flutterApi?.onError() |
| L-4 | _setupEventChannels 空方法 | ✅ 确认 | 定义但从未调用 |
| L-5 | editStartTime 等无 setter | ✅ 确认 | 只有 getter，field 初始值不可修改 |
| L-6 | ReverbPreset 枚举顺序耦合无注释 | ✅ 确认 | index 直接作为 rawValue 传递 |
| L-7 | loopDuration 创建后不可读 | ✅ 确认 | 传给原生但未存为 Dart 字段 |
