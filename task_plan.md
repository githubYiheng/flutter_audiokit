# Task Plan — Code Review 报告验证与修复规划

## Goal
逐一验证 CODE_REVIEW_REPORT.md 中列出的所有问题是否在实际代码中存在，确认后规划修复方案。

---

## Phase 1 — 验证所有 Issue [status: complete]

29 个问题全部验证完毕。结果：28 确认存在，1 个有争议（M-5）。
详见 findings.md。

---

## Phase 2 — 修复计划 [status: complete]

### 修复批次规划

按优先级和文件关联性分批修复，每批对应一个 commit。

---

#### Batch 1: Swift 层 CRITICAL 修复 (C-1, C-2, C-3, C-5)
**文件：** `AudioKitBridge.swift`
**工作量：** 小

| Issue | 修复内容 |
|-------|---------|
| C-1 | `setNodeParameter` 中添加 VariableDelay/TanhDistortion/BitCrusher/Phaser 的 dryWetMix 处理 |
| C-2 | `disposeNode` 中对 tap 调 `.stop()` — `amplitudeTaps.removeValue(forKey:)?.stop()` |
| C-3 | `rampNodeParameter` 中添加 Reverb dryWetMix 处理（直接设值，不支持 ramp） |
| C-5 | `playerPlay` 中将 completionHandler 赋值移到 play() 之前 |

同时修复同文件的 MEDIUM 问题：

| Issue | 修复内容 |
|-------|---------|
| M-1 | Timer 改用 `RunLoop.main.add(timer, forMode: .common)` |
| M-2 | PitchTap 回调添加 `guard !pitches.isEmpty, !amplitudes.isEmpty` |
| M-3 | Delay dryWetMix 默认值改为 50 |
| M-7 | Timer 自停路径添加 sendPlayerState |
| M-11 | DynamicRangeCompressor gain 默认值改为 0 |

---

#### Batch 2: Dart 层 CRITICAL + HIGH 修复
**文件：** `oscillator.dart`, `node.dart`, `audio_player.dart`, `mixer.dart`, `vari_speed.dart`
**工作量：** 中

| Issue | 修复内容 |
|-------|---------|
| C-4 | `oscillator.dart` — 添加幂等守卫，调整 `_isDisposed` 顺序 |
| H-4 | `mixer.dart` / `vari_speed.dart` — `isStarted` 改用 `_isStarted` 状态标记 |
| H-5 | `node.dart` — 添加 `_throwIfDisposed()` 方法，在 start/stop/bypass/getParameters/parameter 中调用；`audio_player.dart` — 所有公开方法添加检查 |
| M-5 | `audio_player.dart` — volume setter 添加 clamp(0.0, 1.0)（同时检查 Mixer.volume 是否也需要） |
| M-6 | `variable_delay.dart` — 存储 maximumTime，clamp 使用该值 |
| M-8 | `mixer.dart` — addInput 的去重检查移到 await 之前 |

---

#### Batch 3: 架构 & 配置修复
**文件：** `pubspec.yaml`, `flutter_audiokit_ios.dart`, `messages.dart`, `AudioKitBridge.swift`
**工作量：** 中

| Issue | 修复内容 |
|-------|---------|
| H-1 | 从 flutter_audiokit/pubspec.yaml 的 dependencies 中移除 flutter_audiokit_ios |
| H-2 | 方案选择：从 platform_interface 中移除 strategy 参数（iOS 不支持），或在 Pigeon 层实现。建议先移除，留 TODO 日后实现 |
| H-3 | Swift `disposeEngine` 遍历 nodes 清理关联节点，或在 Dart AudioEngine.dispose() 中先清理所有 nodes |
| M-10 | `FlutterAudioKitPlugin.swift` — bridge 存为 static 属性 |

---

#### Batch 4: Swift 线程安全
**文件：** `AudioKitBridge.swift`
**工作量：** 中

| Issue | 修复内容 |
|-------|---------|
| H-6 | 为 AudioKitBridge 添加 `@MainActor` 标注或关键方法入口处 dispatch 到主线程 |
| M-9 | AmplitudeTap 回调中使用闭包参数而非 tap 对象属性（如果 AudioKit API 支持） |

---

#### Batch 5: Dart 代码质量修复 (LOW)
**文件：** 多个 Dart 文件
**工作量：** 小

| Issue | 修复内容 |
|-------|---------|
| L-2 | 修复 platform_interface.dart doc comment 错位 |
| L-4 | 删除 _setupEventChannels() 空方法 |
| L-6 | ReverbPreset 枚举添加注释警告 |
| L-7 | comb_filter_reverb / flat_frequency_response_reverb 存储 loopDuration 为 final 字段 |
| M-4 | flutter_audiokit_ios.dart 添加 statusIndex 边界检查 |

---

#### Batch 6: 剩余确认问题 [status: complete]
**文件：** `AudioKitBridge.swift`, `flutter_audiokit.dart`, `audio_player.dart`, `platform_interface.dart`, `flutter_audiokit_ios.dart`, `types.dart`, tests, example
**工作量：** 中

| Issue | 修复内容 |
|-------|---------|
| H-3 | `disposeEngine` 当无 engine 时级联清理所有 nodes/taps/timers |
| L-1 | 移除 `FlutterAudioKitPlatform`、`ConnectStrategy`、`DisconnectStrategy` 的 barrel export |
| L-3 | 移除空壳 `onError` 流 + `AudioKitError` 类（Pigeon handler 保留 no-op） |
| L-5 | 移除 `editStartTime`/`editEndTime`/`isEditTimeEnabled` 死 getter |

---

## Decisions Log
| Decision | Reason |
|----------|--------|
| 按文件关联性分批 | 减少 commit 数量，同文件修改合并 |
| M-5 仍建议修复 | 虽然报告描述不完全准确，但 volume clamp 是好实践 |
| H-2 建议先移除 strategy | iOS 不支持，保留会误导用户 |
| H-3 采用"无 engine 时全清理"策略 | 避免引入 engine→nodes 映射的复杂度，覆盖 99% 单 engine 场景 |
| H-6/M-9 不修 | H-6: platform channels 已在主线程；M-9: 同一音频线程不竞争 |
| L-3 选择移除而非实现 | Swift 层错误已通过 PigeonError 返回，onError 流是多余的 |
| L-5 选择移除而非实现 setter | editTime 功能不在当前 MVP 范围 |

## Errors Encountered
| Error | Resolution |
|-------|------------|
| M-5 报告描述不准确 | 报告称 Mixer.volume 有 clamp，实际也没有。已在 findings.md 记录 |
