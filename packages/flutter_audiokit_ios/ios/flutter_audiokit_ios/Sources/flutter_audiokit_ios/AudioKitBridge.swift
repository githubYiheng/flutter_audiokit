import Flutter
import AudioKit
import SoundpipeAudioKit

/// Bridge between Flutter Pigeon API and AudioKit.
///
/// Manages a registry of native AudioKit objects keyed by UUID strings.
/// All AudioKit operations are performed on the main thread.
class AudioKitBridge: AudioKitHostApi {

    /// Callback channel for sending events to Dart.
    var flutterApi: AudioKitFlutterApi?

    // MARK: - Node Registry

    /// All active AudioKit engines, keyed by engine ID.
    private var engines: [String: AudioEngine] = [:]

    /// All active AudioKit nodes, keyed by node ID.
    private var nodes: [String: Node] = [:]

    /// Active AmplitudeTaps, keyed by node ID.
    private var amplitudeTaps: [String: AmplitudeTap] = [:]

    /// Player completion observers.
    private var playerObservers: [String: Any] = [:]

    // MARK: - Helpers

    private func generateId() -> String {
        UUID().uuidString
    }

    private func getEngine(_ id: String) throws -> AudioEngine {
        guard let engine = engines[id] else {
            throw PigeonError(code: "ENGINE_NOT_FOUND",
                              message: "No engine with id: \(id)",
                              details: nil)
        }
        return engine
    }

    private func getNode(_ id: String) throws -> Node {
        guard let node = nodes[id] else {
            throw PigeonError(code: "NODE_NOT_FOUND",
                              message: "No node with id: \(id)",
                              details: nil)
        }
        return node
    }

    private func getPlayer(_ id: String) throws -> AudioPlayer {
        guard let player = nodes[id] as? AudioPlayer else {
            throw PigeonError(code: "NODE_NOT_PLAYER",
                              message: "Node \(id) is not an AudioPlayer",
                              details: nil)
        }
        return player
    }

    private func getMixer(_ id: String) throws -> Mixer {
        guard let mixer = nodes[id] as? Mixer else {
            throw PigeonError(code: "NODE_NOT_MIXER",
                              message: "Node \(id) is not a Mixer",
                              details: nil)
        }
        return mixer
    }

    private func getTimePitch(_ id: String) throws -> TimePitch {
        guard let tp = nodes[id] as? TimePitch else {
            throw PigeonError(code: "NODE_NOT_TIMEPITCH",
                              message: "Node \(id) is not a TimePitch",
                              details: nil)
        }
        return tp
    }

    private func getVariSpeed(_ id: String) throws -> VariSpeed {
        guard let vs = nodes[id] as? VariSpeed else {
            throw PigeonError(code: "NODE_NOT_VARISPEED",
                              message: "Node \(id) is not a VariSpeed",
                              details: nil)
        }
        return vs
    }

    // MARK: - AudioEngine

    func createEngine(completion: @escaping (Result<String, any Error>) -> Void) {
        let engineId = generateId()
        let engine = AudioEngine()
        engines[engineId] = engine
        completion(.success(engineId))
    }

    func startEngine(engineId: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        do {
            let engine = try getEngine(engineId)
            try engine.start()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    func stopEngine(engineId: String) throws {
        let engine = try getEngine(engineId)
        engine.stop()
    }

    func pauseEngine(engineId: String) throws {
        let engine = try getEngine(engineId)
        engine.pause()
    }

    func setEngineOutput(engineId: String, nodeId: String) throws {
        let engine = try getEngine(engineId)
        let node = try getNode(nodeId)
        engine.output = node
    }

    func disposeEngine(engineId: String) throws {
        if let engine = engines.removeValue(forKey: engineId) {
            engine.stop()
        }
    }

    // MARK: - AudioPlayer

    func createAudioPlayer(completion: @escaping (Result<PlatformNodeHandle, any Error>) -> Void) {
        let nodeId = generateId()
        let player = AudioPlayer()
        nodes[nodeId] = player
        completion(.success(PlatformNodeHandle(nodeId: nodeId, nodeType: "AudioPlayer")))
    }

    func loadAudioFile(nodeId: String, filePath: String, completion: @escaping (Result<PlatformAudioFileInfo, any Error>) -> Void) {
        do {
            let player = try getPlayer(nodeId)
            let url = URL(fileURLWithPath: filePath)
            try player.load(url: url)

            let info = PlatformAudioFileInfo(
                duration: player.duration,
                sampleRate: player.file?.fileFormat.sampleRate ?? 44100,
                channels: Int64(player.file?.fileFormat.channelCount ?? 2)
            )
            completion(.success(info))
        } catch {
            completion(.failure(error))
        }
    }

    func playerPlay(nodeId: String, startTime: Double?, endTime: Double?) throws {
        let player = try getPlayer(nodeId)
        player.play(
            from: startTime.map { TimeInterval($0) },
            to: endTime.map { TimeInterval($0) }
        )

        // Set up completion handler
        player.completionHandler = { [weak self] in
            self?.flutterApi?.onPlaybackCompleted(nodeId: nodeId) { _ in }
        }

        // Notify state change
        sendPlayerState(nodeId: nodeId, player: player)
    }

    func playerPause(nodeId: String) throws {
        let player = try getPlayer(nodeId)
        player.pause()
        sendPlayerState(nodeId: nodeId, player: player)
    }

    func playerResume(nodeId: String) throws {
        let player = try getPlayer(nodeId)
        player.resume()
        sendPlayerState(nodeId: nodeId, player: player)
    }

    func playerStop(nodeId: String) throws {
        let player = try getPlayer(nodeId)
        player.stop()
        sendPlayerState(nodeId: nodeId, player: player)
    }

    func playerSeek(nodeId: String, time: Double) throws {
        let player = try getPlayer(nodeId)
        player.seek(time: TimeInterval(time))
        sendPlayerState(nodeId: nodeId, player: player)
    }

    func setPlayerVolume(nodeId: String, volume: Double) throws {
        let player = try getPlayer(nodeId)
        player.volume = AUValue(volume)
    }

    func setPlayerIsLooping(nodeId: String, isLooping: Bool) throws {
        let player = try getPlayer(nodeId)
        player.isLooping = isLooping
    }

    func setPlayerIsReversed(nodeId: String, isReversed: Bool) throws {
        let player = try getPlayer(nodeId)
        player.isReversed = isReversed
    }

    func getPlayerState(nodeId: String, completion: @escaping (Result<PlatformPlaybackState, any Error>) -> Void) {
        do {
            let player = try getPlayer(nodeId)
            let state = makePlaybackState(nodeId: nodeId, player: player)
            completion(.success(state))
        } catch {
            completion(.failure(error))
        }
    }

    private func sendPlayerState(nodeId: String, player: AudioPlayer) {
        let state = makePlaybackState(nodeId: nodeId, player: player)
        flutterApi?.onPlaybackStateChanged(state: state) { _ in }
    }

    private func makePlaybackState(nodeId: String, player: AudioPlayer) -> PlatformPlaybackState {
        let statusIndex: Int64
        switch player.status {
        case .stopped: statusIndex = 0
        case .playing: statusIndex = 1
        case .paused: statusIndex = 2
        case .scheduling: statusIndex = 3
        @unknown default: statusIndex = 0
        }
        return PlatformPlaybackState(
            nodeId: nodeId,
            statusIndex: statusIndex,
            currentTime: player.currentTime,
            duration: player.duration
        )
    }

    // MARK: - Mixer

    func createMixer(inputNodeIds: [String], volume: Double, name: String?) throws -> PlatformNodeHandle {
        let nodeId = generateId()
        let inputs: [Node] = try inputNodeIds.map { try getNode($0) }
        let mixer: Mixer
        if inputs.isEmpty {
            mixer = Mixer(volume: AUValue(volume), name: name)
        } else {
            mixer = Mixer(inputs, name: name)
            mixer.volume = AUValue(volume)
        }
        nodes[nodeId] = mixer
        return PlatformNodeHandle(nodeId: nodeId, nodeType: "Mixer")
    }

    func mixerAddInput(mixerId: String, nodeId: String) throws {
        let mixer = try getMixer(mixerId)
        let node = try getNode(nodeId)
        mixer.addInput(node)
    }

    func mixerRemoveInput(mixerId: String, nodeId: String) throws {
        let mixer = try getMixer(mixerId)
        let node = try getNode(nodeId)
        mixer.removeInput(node)
    }

    func mixerRemoveAllInputs(mixerId: String) throws {
        let mixer = try getMixer(mixerId)
        mixer.removeAllInputs()
    }

    func setMixerVolume(mixerId: String, volume: Double) throws {
        let mixer = try getMixer(mixerId)
        mixer.volume = AUValue(volume)
    }

    func setMixerPan(mixerId: String, pan: Double) throws {
        let mixer = try getMixer(mixerId)
        mixer.pan = AUValue(pan)
    }

    func setMixerName(mixerId: String, name: String) throws {
        let mixer = try getMixer(mixerId)
        mixer.name = name
    }

    // MARK: - TimePitch

    func createTimePitch(inputNodeId: String, rate: Double, pitch: Double, overlap: Double) throws -> PlatformNodeHandle {
        let input = try getNode(inputNodeId)
        let nodeId = generateId()
        let tp = TimePitch(input, rate: AUValue(rate), pitch: AUValue(pitch), overlap: AUValue(overlap))
        nodes[nodeId] = tp
        return PlatformNodeHandle(nodeId: nodeId, nodeType: "TimePitch")
    }

    func setTimePitchRate(nodeId: String, rate: Double) throws {
        let tp = try getTimePitch(nodeId)
        tp.rate = AUValue(rate)
    }

    func setTimePitchPitch(nodeId: String, pitch: Double) throws {
        let tp = try getTimePitch(nodeId)
        tp.pitch = AUValue(pitch)
    }

    func setTimePitchOverlap(nodeId: String, overlap: Double) throws {
        let tp = try getTimePitch(nodeId)
        tp.overlap = AUValue(overlap)
    }

    // MARK: - VariSpeed

    func createVariSpeed(inputNodeId: String, rate: Double) throws -> PlatformNodeHandle {
        let input = try getNode(inputNodeId)
        let nodeId = generateId()
        let vs = VariSpeed(input, rate: AUValue(rate))
        nodes[nodeId] = vs
        return PlatformNodeHandle(nodeId: nodeId, nodeType: "VariSpeed")
    }

    func setVariSpeedRate(nodeId: String, rate: Double) throws {
        let vs = try getVariSpeed(nodeId)
        vs.rate = AUValue(rate)
    }

    // MARK: - Generic Node Operations

    func startNode(nodeId: String) throws {
        let node = try getNode(nodeId)
        node.start()
    }

    func stopNode(nodeId: String) throws {
        let node = try getNode(nodeId)
        node.stop()
    }

    func bypassNode(nodeId: String) throws {
        let node = try getNode(nodeId)
        node.bypass()
    }

    func disposeNode(nodeId: String) throws {
        amplitudeTaps.removeValue(forKey: nodeId)
        nodes.removeValue(forKey: nodeId)
    }

    func isNodeStarted(nodeId: String) throws -> Bool {
        let node = try getNode(nodeId)
        return node.isStarted
    }

    func getNodeParameters(nodeId: String) throws -> [PlatformNodeParameterInfo] {
        let node = try getNode(nodeId)
        return node.parameters.map { param in
            PlatformNodeParameterInfo(
                identifier: param.def.identifier,
                name: param.def.name,
                value: Double(param.value),
                defaultValue: Double(param.def.defaultValue),
                minValue: Double(param.def.range.lowerBound),
                maxValue: Double(param.def.range.upperBound)
            )
        }
    }

    func setNodeParameter(nodeId: String, identifier: String, value: Double) throws {
        let node = try getNode(nodeId)
        for param in node.parameters {
            if param.def.identifier == identifier {
                param.value = AUValue(value)
                return
            }
        }
        throw PigeonError(code: "PARAM_NOT_FOUND",
                          message: "No parameter '\(identifier)' on node \(nodeId)",
                          details: nil)
    }

    func rampNodeParameter(nodeId: String, identifier: String, value: Double, duration: Double, delay: Double) throws {
        let node = try getNode(nodeId)
        for param in node.parameters {
            if param.def.identifier == identifier {
                param.ramp(to: AUValue(value), duration: Float(duration), delay: Float(delay))
                return
            }
        }
        throw PigeonError(code: "PARAM_NOT_FOUND",
                          message: "No parameter '\(identifier)' on node \(nodeId)",
                          details: nil)
    }

    // MARK: - Effects (Phase 2)

    func createEffect(inputNodeId: String, effectType: String, params: [String: Double]) throws -> PlatformNodeHandle {
        let input = try getNode(inputNodeId)
        let nodeId = generateId()

        // Phase 2: Factory pattern for effect creation
        // For now, throw unimplemented
        throw PigeonError(code: "NOT_IMPLEMENTED",
                          message: "Effect '\(effectType)' not yet implemented. Coming in Phase 2.",
                          details: nil)
    }

    // MARK: - AmplitudeTap

    func startAmplitudeTap(nodeId: String, bufferSize: Int64) throws {
        let node = try getNode(nodeId)
        let tap = AmplitudeTap(node, bufferSize: UInt32(bufferSize)) { [weak self] amplitude in
            guard let self = self else { return }
            let data = PlatformAudioLevelData(
                nodeId: nodeId,
                amplitude: Double(amplitude),
                leftAmplitude: Double(amplitude),
                rightAmplitude: Double(amplitude)
            )
            self.flutterApi?.onAmplitudeData(data: data) { _ in }
        }
        tap.start()
        amplitudeTaps[nodeId] = tap
    }

    func stopAmplitudeTap(nodeId: String) throws {
        if let tap = amplitudeTaps.removeValue(forKey: nodeId) {
            tap.stop()
        }
    }

    // MARK: - Settings

    func setGlobalSampleRate(sampleRate: Double) throws {
        Settings.sampleRate = sampleRate
    }

    func setGlobalBufferLength(bufferLengthPower: Int64) throws {
        if let length = Settings.BufferLength(rawValue: Int(bufferLengthPower)) {
            Settings.bufferLength = length
        }
    }
}
