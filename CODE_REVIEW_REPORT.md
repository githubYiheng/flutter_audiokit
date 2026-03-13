# flutter_audiokit 全项目 Code Review 报告

**审查日期：** 2026-03-13
**审查范围：** 全部 3 个包 + example app + Swift 原生层
**项目状态：** 新开发，6 commits，未经集成测试
**当前 commit：** c8379af0c26cf310505a332a4080cf4921753c7b

---

## 审查维度

1. **Dart API 层** — app-facing 包的 API 设计、生命周期管理、write-through cache 模式
2. **平台接口层** — platform_interface 抽象定义、类型系统、Pigeon 定义
3. **Swift 原生层** — AudioKitBridge 内存管理、线程安全、资源清理
4. **跨层一致性** — 三层之间的方法签名、参数名、类型对齐
5. **测试与示例** — 测试覆盖率、示例 app 质量、pubspec 配置

---

## CRITICAL — 运行时崩溃或功能完全失败

### C-1. `dryWetMix` setter 对 4 个效果器运行时抛异常

**严重程度：** CRITICAL
**类型：** 跨层参数映射缺失

`VariableDelay`、`TanhDistortion`、`BitCrusher`、`Phaser` 的 Dart 侧 `dryWetMix` setter 调用 `setNodeParameter(nodeId, 'dryWetMix', value)`。但 Swift 侧 `setNodeParameter` 在 `node.parameters` 循环中找不到 `dryWetMix`（因为这 4 个效果器的 `dryWetMix` 是直接属性，不在 AudioKit 标准参数列表中），且只为 `Reverb` 和 `ZitaReverb` 做了 special case 处理。

运行时必然抛出 `PigeonError(code: "PARAM_NOT_FOUND")`。

**涉及文件：**

| 文件 | 行号 | 说明 |
|------|------|------|
| `AudioKitBridge.swift` | 399–424 | `setNodeParameter` 只有 Reverb 和 ZitaReverb 的 special case |
| `variable_delay.dart` | 80 | `setNodeParameter(_nodeId, 'dryWetMix', ...)` |
| `tanh_distortion.dart` | 100 | 同上 |
| `bit_crusher.dart` | 76 | 同上 |
| `phaser.dart` | 159 | 同上 |

**修复方案：**

在 `setNodeParameter` 中添加：

```swift
if let vd = node as? VariableDelay, identifier == "dryWetMix" {
    vd.dryWetMix = AUValue(value); return
}
if let td = node as? TanhDistortion, identifier == "dryWetMix" {
    td.dryWetMix = AUValue(value); return
}
if let bc = node as? BitCrusher, identifier == "dryWetMix" {
    bc.dryWetMix = AUValue(value); return
}
if let ph = node as? Phaser, identifier == "dryWetMix" {
    ph.dryWetMix = AUValue(value); return
}
```

同样需要在 `rampNodeParameter` 中添加对应处理。

---

### C-2. AmplitudeTap / PitchTap 未在 `disposeNode` 中 stop — 可能 EXC_BAD_ACCESS

**严重程度：** CRITICAL
**类型：** 资源泄露 / 野指针

```swift
// AudioKitBridge.swift:373-378
func disposeNode(nodeId: String) throws {
    stopProgressTimer(nodeId: nodeId)
    amplitudeTaps.removeValue(forKey: nodeId)   // ← 没有调 .stop()
    pitchTaps.removeValue(forKey: nodeId)       // ← 没有调 .stop()
    nodes.removeValue(forKey: nodeId)
}
```

Tap 从字典移除但底层 AVAudioTap 仍挂在 AVAudioNode 的输入总线上，tap 闭包继续在音频渲染线程回调。当 node 的 AVAudioUnit 被 ARC 释放后，tap 回调访问已释放的内存，触发 EXC_BAD_ACCESS。

对比 `stopAmplitudeTap`（line 794）和 `stopPitchTap`（line 819）均正确调用了 `tap.stop()`。

**修复方案：**

```swift
func disposeNode(nodeId: String) throws {
    stopProgressTimer(nodeId: nodeId)
    amplitudeTaps.removeValue(forKey: nodeId)?.stop()   // 加 .stop()
    pitchTaps.removeValue(forKey: nodeId)?.stop()       // 加 .stop()
    nodes.removeValue(forKey: nodeId)
}
```

---

### C-3. `rampNodeParameter` 缺少 Reverb `dryWetMix` 的 special case

**严重程度：** CRITICAL
**类型：** 方法间不一致

`setNodeParameter`（line 407–411）有 Reverb `dryWetMix` 的处理：

```swift
if let reverb = node as? Reverb, identifier == "dryWetMix" {
    reverb.dryWetMix = AUValue(value)
    return
}
```

但 `rampNodeParameter`（line 427–447）没有对应处理。Dart 侧调用 `node.parameter('dryWetMix')?.ramp(to: 0.8, duration: 1.0)` 在 Reverb 上会抛 `PARAM_NOT_FOUND`。

**修复方案：** 在 `rampNodeParameter` 的 for 循环之后、ZitaReverb 处理之前，添加与 `setNodeParameter` 一致的 Reverb dryWetMix 处理。注意 Apple 的 `dryWetMix` 不支持 AudioKit 的 `ramp` API，可能需要用 `AVAudioUnitReverb` 的原生 API 或直接设值。

---

### C-4. `Oscillator.dispose()` 缺少幂等守卫，double-dispose 导致双重原生释放

**严重程度：** CRITICAL
**类型：** 生命周期管理缺陷

```dart
// oscillator.dart:81-84
@override
Future<void> dispose() async {
  await super.dispose();   // 先调了 super.dispose() → disposeNode
  _isDisposed = true;      // 后设置标记
}
```

所有其他 Node 子类的 dispose 模式：

```dart
// 正确模式（如 AudioPlayer, Mixer, 所有效果器）
@override
Future<void> dispose() async {
  if (_isDisposed) return;    // ← 幂等守卫
  _isDisposed = true;         // ← 立即标记
  // ... 清理工作 ...
  await super.dispose();
}
```

`Oscillator` 的问题：
1. 没有 `if (_isDisposed) return;` 守卫
2. `_isDisposed = true` 在 `super.dispose()` 之后
3. 如果 `super.dispose()` 抛异常，`_isDisposed` 永远不会被设为 `true`
4. 并发调用 `dispose()` 两次会执行两次 `disposeNode`

**修复方案：**

```dart
@override
Future<void> dispose() async {
  if (_isDisposed) return;
  _isDisposed = true;
  await super.dispose();
}
```

---

### C-5. `completionHandler` 在 `player.play()` 之后才设置 — 竞态 + 事件丢失

**严重程度：** CRITICAL
**类型：** 竞态条件

```swift
// AudioKitBridge.swift:185-196
func playerPlay(nodeId: String, startTime: Double?, endTime: Double?) throws {
    let player = try getPlayer(nodeId)
    player.play(from: ..., to: ...)           // ← 1. 先播放

    player.completionHandler = { [weak self] in   // ← 2. 后设 handler
        self?.stopProgressTimer(nodeId: nodeId)
        self?.flutterApi?.onPlaybackCompleted(nodeId: nodeId) { _ in }
    }
    // ...
}
```

**问题 1 — 竞态：** 极短音频文件可能在 handler 设置前播放完毕，Dart 永远收不到 `onPlaybackCompleted`。

**问题 2 — 覆盖丢失：** 连续调用 `playerPlay` 两次（如快速切歌），第二次 `play()` 会覆盖第一次的 `completionHandler`。第一次播放的完成事件丢失，其 `progressTimer` 会持续运行直到 self-stop guard 触发（检测到 `!player.isPlaying`）。

**修复方案：** 将 `completionHandler` 赋值移到 `player.play()` 之前：

```swift
player.completionHandler = { [weak self] in
    self?.stopProgressTimer(nodeId: nodeId)
    self?.flutterApi?.onPlaybackCompleted(nodeId: nodeId) { _ in }
}
player.play(from: startTime.map { TimeInterval($0) },
            to: endTime.map { TimeInterval($0) })
```

---

## HIGH — 架构问题或显著功能缺陷

### H-1. `flutter_audiokit` 直接依赖 `flutter_audiokit_ios` — 破坏 Federated Plugin 模式

**严重程度：** HIGH
**类型：** 架构违规

```yaml
# packages/flutter_audiokit/pubspec.yaml
dependencies:
  flutter_audiokit_platform_interface: ^0.1.0
  flutter_audiokit_ios: ^0.1.0   # ← 不应该在这里
```

在正确的 Federated Plugin 模式中，app-facing 包不应显式依赖平台实现包。`flutter.plugin.platforms.ios.default_package: flutter_audiokit_ios` 已在同一文件中声明，这是正确且充分的注册机制。

显式依赖会导致：
- 非 iOS 平台（Android, Web, macOS）构建时也会拉入 iOS-only 包
- 可能触发编译错误（iOS-only 的 Swift/ObjC 代码无法在其他平台编译）
- 违反 Flutter 官方的 Federated Plugin 约定

**修复方案：** 从 `dependencies` 中移除 `flutter_audiokit_ios: ^0.1.0`。

---

### H-2. `ConnectStrategy` / `DisconnectStrategy` 参数被静默丢弃

**严重程度：** HIGH
**类型：** API 契约违反

| 层级 | 文件 | 是否有 strategy 参数 |
|------|------|---------------------|
| Platform Interface | `platform_interface.dart:152-167` | 有 |
| iOS Implementation | `flutter_audiokit_ios.dart:189-196` | 接收但丢弃 |
| Pigeon Definition | `messages.dart:151-153` | 无 |
| Swift Bridge | `AudioKitBridge.swift:284-294` | 无 |

调用方传入 `ConnectStrategy.incremental` 或 `DisconnectStrategy.detach` 会被静默忽略，实际行为始终是默认策略。这比抛异常更糟糕——用户以为策略生效了但实际没有。

**修复方案（二选一）：**
1. 在 Pigeon + Swift 层实现 strategy 参数传递和处理
2. 从 platform interface 中移除 strategy 参数，在文档中说明 iOS 不支持

---

### H-3. `disposeEngine` 不清理关联 nodes — 遗留孤儿节点

**严重程度：** HIGH
**类型：** 资源生命周期管理

```swift
// AudioKitBridge.swift:151-155
func disposeEngine(engineId: String) throws {
    if let engine = engines.removeValue(forKey: engineId) {
        engine.stop()
    }
    // nodes, amplitudeTaps, pitchTaps, progressTimers 均未清理
}
```

Engine 被 dispose 后：
- `nodes` 字典中仍保留所有关联节点的引用
- Dart 侧仍可以通过 nodeId 调用这些节点的方法
- 节点底层连接的 AVAudioEngine 已停止/释放
- 后续对这些节点的操作（如 `play()`）可能导致 AVAudioEngine 异常或崩溃

**修复方案（短期）：** 在文档和 Dart API 中明确要求：dispose engine 前必须先 dispose 所有关联节点。在 `AudioEngine.dispose()` 的 Dart 侧实现自动清理。

**修复方案（长期）：** 维护 engineId → Set<nodeId> 的映射关系，`disposeEngine` 时自动清理所有关联节点。

---

### H-4. `Mixer.isStarted` 和 `VariSpeed.isStarted` 语义错误

**严重程度：** HIGH
**类型：** 语义错误

```dart
// mixer.dart:37
@override
bool get isStarted => _volume != 0.0;   // ← 语义错误

// vari_speed.dart:33
@override
bool get isStarted => _rate != 1.0;     // ← 语义错误
```

`Node.isStarted` 应当反映 AudioKit 的 `node.isStarted`——即节点是否在 audio graph 中激活并处理音频。这是一个生命周期状态，与参数值无关。

| 场景 | 预期结果 | 实际结果 |
|------|----------|----------|
| Mixer volume=0（静音但仍在运行） | `true` | `false` |
| Mixer 已 stop() 但 volume=0.5 | `false` | `true` |
| VariSpeed rate=1.0（原速运行中） | `true` | `false` |
| VariSpeed 已 stop() 但 rate=2.0 | `false` | `true` |

对比 `Oscillator` 正确地通过 `_isStarted` 标记跟踪 `start()`/`stop()` 调用。

**修复方案：** 使用与 `Oscillator` 相同的模式——维护 `_isStarted` 状态标记，在 `start()`/`stop()` 时更新。

---

### H-5. `Node` 基类和 `AudioPlayer` 的方法不检查 `isDisposed`

**严重程度：** HIGH
**类型：** 生命周期管理缺失

**Node 基类（node.dart:23-57）：** `start()`、`stop()`、`bypass()`、`getParameters()`、`parameter()` 均无 disposed 检查。

**AudioPlayer（audio_player.dart）：** `play()`、`pause()`、`resume()`、`seek()`、`volume` setter、`isLooping` setter、`isReversed` setter 均无 disposed 检查。

Dispose 后调用任何方法会通过 platform channel 发送指令到已释放的原生节点，可能导致：
- Swift 侧抛出 `NODE_NOT_FOUND` 错误
- 静默失败（fire-and-forget setter）
- 原生层状态损坏

对比 `AudioEngine` 正确地在每个方法前调用 `_throwIfDisposed()`。

**修复方案：**
1. 在 `Node` 基类的 `start()`、`stop()`、`bypass()` 中添加 disposed 检查
2. 在 `AudioPlayer` 的所有公开方法和 setter 中添加 disposed 检查
3. 或在 `Node` 基类中提供统一的 `_throwIfDisposed()` 方法供子类使用

---

### H-6. Swift 层无主线程强制保证

**严重程度：** HIGH
**类型：** 线程安全

`AudioKitBridge` 类注释（line 9）声明 "All AudioKit operations are performed on the main thread"，但代码中没有任何强制措施：

- 无 `DispatchQueue.main.async { ... }` 包装
- 无 `@MainActor` 标注
- `Timer.scheduledTimer` 在当前 RunLoop 上调度，如果不在主线程则 timer 不工作

Pigeon 的 `@async` 方法（`createEngine`、`startEngine`、`createAudioPlayer`、`loadAudioFile`、`getPlayerState`）可能在非主线程调度。AudioKit 底层的 AVAudioEngine 要求在主线程操作。

**修复方案（推荐）：** 为 `AudioKitBridge` 类添加 `@MainActor` 标注（Swift 5.5+），或在关键方法入口处使用 `DispatchQueue.main.async`。

---

## MEDIUM — 边界情况和数据不一致

### M-1. Progress Timer 未添加到 `.common` RunLoop mode

**严重程度：** MEDIUM
**类型：** UX 缺陷

```swift
// AudioKitBridge.swift:100
let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { ... }
```

默认调度在 `.default` RunLoop mode。当用户滚动 `UIScrollView`（`.tracking` mode）时，timer 暂停，播放进度更新冻结。

**修复方案：**

```swift
let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in ... }
RunLoop.main.add(timer, forMode: .common)
```

---

### M-2. `PitchTap` 回调无数组边界检查 — 可能 index out of bounds

**严重程度：** MEDIUM
**类型：** 防御性编程缺失

```swift
// AudioKitBridge.swift:808-811
leftPitch: Double(pitches[0]),        // ← 如果 pitches 为空？
rightPitch: pitches.count > 1 ? Double(pitches[1]) : Double(pitches[0]),
leftAmplitude: Double(amplitudes[0]), // ← 如果 amplitudes 为空？
rightAmplitude: amplitudes.count > 1 ? Double(amplitudes[1]) : Double(amplitudes[0])
```

`pitches[0]` 和 `amplitudes[0]` 直接访问，无空数组守卫。虽然 AudioKit 的 `PitchTap` 正常情况下至少返回 1 个元素，但在异常音频格式或节点断开时可能返回空数组。

**修复方案：**

```swift
guard !pitches.isEmpty, !amplitudes.isEmpty else { return }
```

---

### M-3. `Delay` 默认 `dryWetMix` 为 100 — 原始信号完全消失

**严重程度：** MEDIUM
**类型：** 默认值错误

```swift
// AudioKitBridge.swift:480
dryWetMix: p("dryWetMix", 100)  // 100% 湿信号，干信号完全消失
```

AudioKit 的 `Delay`（基于 `AVAudioUnitDelay`）的 `dryWetMix` 范围是 0–100%。默认值 `100` 意味着只有延迟信号，原始音频完全消失。AudioKit 源码定义的默认值是 `50`（半干半湿）。

**修复方案：** 改为 `dryWetMix: p("dryWetMix", 50)`。

---

### M-4. `PlaybackStatus.values[state.statusIndex]` 无边界检查

**严重程度：** MEDIUM
**类型：** 防御性编程缺失

```dart
// flutter_audiokit_ios.dart:48
status: PlaybackStatus.values[state.statusIndex],
```

如果原生侧发送的 `statusIndex` 超出 `PlaybackStatus.values` 的范围（0–3），会抛出 `RangeError`。虽然当前 Swift 侧的 `@unknown default` 映射为 0，但这是一个脆弱的假设。

**修复方案：**

```dart
status: (state.statusIndex >= 0 && state.statusIndex < PlaybackStatus.values.length)
    ? PlaybackStatus.values[state.statusIndex]
    : PlaybackStatus.stopped,
```

---

### M-5. `AudioPlayer.volume` setter 缺少 clamp

**严重程度：** MEDIUM
**类型：** 一致性缺陷

```dart
// audio_player.dart:64-66
set volume(double value) {
  _volume = value;   // 无 clamp — 可以传负值或 > 1
  FlutterAudioKitPlatform.instance.setPlayerVolume(_nodeId, value);
}
```

所有其他 setter（`Mixer.volume`、`TimePitch.rate`、所有效果器参数）均使用 `.clamp()`。`AudioPlayer.volume` 是唯一未 clamp 的 setter。AudioKit 的 `AudioPlayer.volume` 范围是 0.0–1.0。

**修复方案：** `_volume = value.clamp(0.0, 1.0);`

---

### M-6. `VariableDelay.time` setter clamp 使用硬编码 `10.0` 而非实际 `maximumTime`

**严重程度：** MEDIUM
**类型：** 参数约束不一致

```dart
// variable_delay.dart:62
_time = value.clamp(0.0, 10.0);  // 硬编码上限
```

如果用户创建时传入 `maximumTime: 2.0`，Dart 侧 clamp 到 10.0，但原生侧的缓冲区只有 2 秒。设置 `time = 5.0` 后 Dart 缓存报告 5.0，但原生侧会截断为 2.0。

**修复方案：** 存储 `maximumTime` 为 `final` 字段，clamp 使用该值：`_time = value.clamp(0.0, _maximumTime);`

---

### M-7. Timer 自停路径不发送最终播放状态

**严重程度：** MEDIUM
**类型：** 状态同步缺失

```swift
// AudioKitBridge.swift:100-106
guard let self = self,
      let player = self.nodes[nodeId] as? AudioPlayer,
      player.isPlaying else {
    self?.stopProgressTimer(nodeId: nodeId)   // ← 停了 timer
    return                                     // ← 但没发 sendPlayerState
}
```

当播放器自然停止（非通过 `playerStop` 方法）且 `completionHandler` 因某种原因未触发时，timer 自停但 Dart 侧的状态可能停留在 "playing"。

**修复方案：**

```swift
self?.stopProgressTimer(nodeId: nodeId)
if let self = self, let player = self.nodes[nodeId] as? AudioPlayer {
    self.sendPlayerState(nodeId: nodeId, player: player)
}
return
```

---

### M-8. `Mixer.addInput` 存在并发条件下的重复添加

**严重程度：** MEDIUM
**类型：** 竞态条件

```dart
// mixer.dart:105-113
Future<void> addInput(Node node, ...) async {
  await FlutterAudioKitPlatform.instance
      .mixerAddInput(_nodeId, node.nodeId, strategy: strategy);
  if (!_inputs.contains(node)) {   // ← await 之后才检查
    _inputs.add(node);
  }
}
```

如果对同一个 node 并发调用 `addInput` 两次，两次调用都会通过 `!_inputs.contains(node)` 检查（因为第一次 `await` 返回前第二次已经开始），导致 `_inputs` 中出现重复条目。

**修复方案：** 在 `await` 之前进行去重检查：

```dart
if (_inputs.contains(node)) return;
_inputs.add(node);
await FlutterAudioKitPlatform.instance.mixerAddInput(...);
```

---

### M-9. `AmplitudeTap` 读取 `tap.leftAmplitude` / `tap.rightAmplitude` 存在数据竞争

**严重程度：** MEDIUM
**类型：** 线程安全

```swift
// AudioKitBridge.swift:784-786
let tap = AmplitudeTap(node, bufferSize: ...) { [weak self] amplitude in
    // ...
    leftAmplitude: Double(tap.leftAmplitude),    // ← 从 tap 对象读取
    rightAmplitude: Double(tap.rightAmplitude)   // ← 可能被音频线程同时写入
```

`tap.leftAmplitude` 和 `tap.rightAmplitude` 由 AudioKit 在音频渲染线程更新，闭包中读取时没有同步保护，存在 data race。

---

### M-10. `FlutterAudioKitPlugin` 中 `bridge` 可能被 ARC 立即释放

**严重程度：** MEDIUM
**类型：** 对象生命周期

```swift
// FlutterAudioKitPlugin.swift:8-13
let bridge = AudioKitBridge()   // 局部变量
AudioKitHostApiSetup.setUp(binaryMessenger: messenger, api: bridge)
let flutterApi = AudioKitFlutterApi(binaryMessenger: messenger)
bridge.flutterApi = flutterApi
```

`bridge` 是 `register(with:)` 方法的局部变量。如果 Pigeon 生成的 `AudioKitHostApiSetup.setUp` 以 `weak` 引用持有 `api`，则 `bridge` 会在方法返回后被 ARC 释放，所有 Pigeon 调用会静默失败或崩溃。

**修复方案：** 将 `bridge` 存储为类属性以确保强引用：

```swift
class FlutterAudioKitPlugin: NSObject, FlutterPlugin {
    private static var bridge: AudioKitBridge?

    static func register(with registrar: FlutterPluginRegistrar) {
        let b = AudioKitBridge()
        bridge = b
        // ...
    }
}
```

---

### M-11. `DynamicRangeCompressor` 默认 `gain: 1` 应为 `0`（dB）

**严重程度：** MEDIUM
**类型：** 默认值错误

```swift
// AudioKitBridge.swift:575
gain: p("gain", 1),   // 1 dB，AudioKit 默认是 0 dB
```

SoundpipeAudioKit 的 `DynamicRangeCompressor.gain` 参数单位是 dB，AudioKit 源码定义的默认值是 `0` dB（unity gain）。

---

## LOW — 代码质量、文档、测试

### L-1. `FlutterAudioKitPlatform` 不应从 app-facing 包导出

**严重程度：** LOW
**类型：** API 设计

```dart
// flutter_audiokit.dart
export 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';
```

内部实现细节泄露到公共 API 表面。用户应通过 `AudioEngine`、`AudioPlayer`、`Mixer` 等高层 API 操作，不需要直接访问 `FlutterAudioKitPlatform`。

但目前 `onError` 流只能通过 `FlutterAudioKitPlatform.instance.onError` 访问，这是导出它的原因之一。应在 app-facing 层提供便捷访问器。

---

### L-2. `platform_interface.dart` 的 doc comment 错位

**严重程度：** LOW
**类型：** 文档

```dart
// platform_interface.dart:287-294
/// Creates an effect node by type name.        ← 这是 createEffect 的注释
///
/// [effectType] matches the AudioKit class name...
/// Creates an Oscillator (sine wave generator). ← 混入了 createOscillator 的
///
/// Returns the node ID.
Future<String> createOscillator({...}) {         ← 但附着在 createOscillator 上
```

`createEffect` 和 `createOscillator` 的 doc comment 混在一起。

---

### L-3. `onError` 事件流永远不会发送事件

**严重程度：** LOW
**类型：** 死代码

Pigeon 定义了 `FlutterApi.onError(String nodeId, String code, String message)`，Dart 侧订阅 `FlutterAudioKitPlatform.instance.onError`。但 Swift 的 `AudioKitBridge` 中没有任何地方调用 `flutterApi?.onError(...)`。所有错误都通过 Pigeon 的 async completion 或 throws 返回。

`onError` 流永远不会 emit 事件，给开发者一种"运行时错误可监控"的错觉。

---

### L-4. `_setupEventChannels()` 是空方法，从未被调用

**严重程度：** LOW
**类型：** 死代码

```dart
// flutter_audiokit_ios.dart:84-87
void _setupEventChannels() {
  // For Phase 1, we use Pigeon's FlutterApi for all callbacks.
  // EventChannels may be added in the future for high-frequency streams.
}
```

---

### L-5. `AudioPlayer` 的 `editStartTime`、`editEndTime`、`isEditTimeEnabled` 无对应 setter 和 platform API

**严重程度：** LOW
**类型：** API 不完整

```dart
// audio_player.dart:27-29
bool _isEditTimeEnabled = false;
double _editStartTime = 0;
double _editEndTime = 0;
```

有 getter 但无 setter，无 platform interface 方法，无 Pigeon 定义，无 Swift 实现。这些属性只能读取初始值 0/false，永远无法修改。

---

### L-6. `ReverbPreset` 枚举值顺序与 `AVAudioUnitReverbPreset` rawValue 的耦合无注释保护

**严重程度：** LOW
**类型：** 脆弱耦合

```dart
// types.dart:100-114 — Dart enum 声明顺序必须匹配 AVAudioUnitReverbPreset rawValue
enum ReverbPreset {
  smallRoom,      // 0
  mediumRoom,     // 1
  largeRoom,      // 2
  // ...
}
```

```swift
// AudioKitBridge.swift:757
guard let preset = AVAudioUnitReverbPreset(rawValue: Int(presetIndex)) else { ... }
```

Dart 枚举的 `.index` 直接传给 Swift 作为 `AVAudioUnitReverbPreset` 的 `rawValue`。如果有人重排 Dart 枚举顺序，映射会静默错乱。建议添加注释警告或使用显式的 int→preset 映射表。

---

### L-7. `comb_filter_reverb.dart` 和 `flat_frequency_response_reverb.dart` 的 `loopDuration` 创建后不可读

**严重程度：** LOW
**类型：** API 不完整

`loopDuration` 作为创建参数传入原生，但 Dart 侧未缓存为字段。用户无法在创建后读取这个值。建议存储为 `final double loopDuration;`。

---

## 测试覆盖率

### 当前测试状况

| 包 | 测试文件数 | 测试用例数 | 覆盖范围 |
|----|-----------|-----------|----------|
| `flutter_audiokit` | 0 | 0 | 无测试 |
| `flutter_audiokit_platform_interface` | 2 | 106 | 接口契约 + 类型系统 |
| `flutter_audiokit_ios` | 0 | 0 | 无测试 |

### platform_interface 测试覆盖（已有）

- 所有平台接口方法的 `UnimplementedError` 验证
- Mock 实现的返回值验证
- 所有事件流的类型验证
- 所有数据类型字段验证
- 枚举基数验证
- `PlaybackState.position` 边界条件

### 测试缺口

**`createOscillator` 未包含在 platform_interface 测试中** — 是唯一缺失的方法。

**`flutter_audiokit` 包完全无测试，以下纯 Dart 逻辑可以且应该被测试：**

- `AudioEngine` 的状态机（`isRunning` 在 start/stop/pause 间切换）
- `AudioEngine._throwIfDisposed()` 在 dispose 后抛 `StateError`
- `AudioPlayer` write-through cache（setter 立即更新本地缓存）
- `AudioPlayer._listenToStateChanges()` 从 platform stream 更新内部状态
- `AudioPlayer.onStateChanged` / `onCompleted` 的 nodeId 过滤
- `AudioPlayer.dispose()` 幂等性
- `Mixer` 输入列表管理（`addInput` 去重、`removeInput`、`removeAllInputs`、`hasInput`）
- 所有效果器的参数 clamp 逻辑
- `NodeParameter.value` setter 的 clamp
- `Oscillator` 的 `start()`/`stop()` 状态跟踪

---

## 示例 App 问题

### E-1. `dispose()` 中未 await 异步 dispose 调用

```dart
// main.dart:377-382
@override
void dispose() {
  _osc?.dispose();    // Future<void> 被丢弃
  _mixer?.dispose();  // Future<void> 被丢弃
  _engine?.dispose(); // Future<void> 被丢弃
  super.dispose();
}
```

Widget 的 `dispose()` 是同步方法，无法 await。但应使用 `unawaited()` 标注意图并抑制 lint 警告。

### E-2. 直接使用 `FlutterAudioKitPlatform.instance` 订阅错误流

```dart
// main.dart:146
_errorSub = FlutterAudioKitPlatform.instance.onError.listen((err) { ... });
```

暴露了内部实现。应在 app-facing 层提供便捷 API（如 `AudioEngine.onError`）。

---

## 修复优先级总览

| 优先级 | 编号 | 说明 | 预估工作量 |
|--------|------|------|-----------|
| **P0** | C-1 | dryWetMix setter 对 4 个效果器崩溃 | 小 |
| **P0** | C-2 | Tap 未 stop 导致 EXC_BAD_ACCESS | 小 |
| **P0** | C-3 | rampNodeParameter 缺 Reverb dryWetMix | 小 |
| **P0** | C-4 | Oscillator.dispose() 无幂等守卫 | 小 |
| **P0** | C-5 | completionHandler 设置顺序错误 | 小 |
| **P1** | H-1 | pubspec 直接依赖 iOS 包 | 小 |
| **P1** | H-2 | ConnectStrategy 被静默丢弃 | 中 |
| **P1** | H-3 | disposeEngine 不清理 nodes | 中 |
| **P1** | H-4 | isStarted 语义错误 | 小 |
| **P1** | H-5 | 方法缺少 isDisposed 检查 | 中 |
| **P1** | H-6 | Swift 无主线程保证 | 中 |
| **P2** | M-1~M-11 | 边界情况和数据不一致 | 中 |
| **P3** | L-1~L-7 | 代码质量和文档 | 小 |
| **P3** | 测试 | 补充 flutter_audiokit 和 iOS 层测试 | 大 |

---

*审查工具：Claude Code*
*审查模型：Claude Opus 4.6*
