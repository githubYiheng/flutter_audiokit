import AVFoundation
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

    /// Active PitchTaps, keyed by node ID.
    private var pitchTaps: [String: PitchTap] = [:]

    /// Player completion observers.
    private var playerObservers: [String: Any] = [:]

    /// Playback progress timers, keyed by player node ID.
    private var progressTimers: [String: Timer] = [:]

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

    // MARK: - Progress Timer

    /// Starts a 10 Hz timer that periodically sends player state to Dart.
    private func startProgressTimer(nodeId: String) {
        stopProgressTimer(nodeId: nodeId)
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self,
                  let player = self.nodes[nodeId] as? AudioPlayer,
                  player.isPlaying else {
                self?.stopProgressTimer(nodeId: nodeId)
                return
            }
            self.sendPlayerState(nodeId: nodeId, player: player)
        }
        progressTimers[nodeId] = timer
    }

    private func stopProgressTimer(nodeId: String) {
        progressTimers.removeValue(forKey: nodeId)?.invalidate()
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

        player.completionHandler = { [weak self] in
            self?.stopProgressTimer(nodeId: nodeId)
            self?.flutterApi?.onPlaybackCompleted(nodeId: nodeId) { _ in }
        }

        sendPlayerState(nodeId: nodeId, player: player)
        startProgressTimer(nodeId: nodeId)
    }

    func playerPause(nodeId: String) throws {
        let player = try getPlayer(nodeId)
        player.pause()
        stopProgressTimer(nodeId: nodeId)
        sendPlayerState(nodeId: nodeId, player: player)
    }

    func playerResume(nodeId: String) throws {
        let player = try getPlayer(nodeId)
        player.resume()
        sendPlayerState(nodeId: nodeId, player: player)
        startProgressTimer(nodeId: nodeId)
    }

    func playerStop(nodeId: String) throws {
        let player = try getPlayer(nodeId)
        player.stop()
        stopProgressTimer(nodeId: nodeId)
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
        let mixer = Mixer(inputs, name: name ?? "(unset)")
        mixer.volume = AUValue(volume)
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
        stopProgressTimer(nodeId: nodeId)
        amplitudeTaps.removeValue(forKey: nodeId)
        pitchTaps.removeValue(forKey: nodeId)
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
        // Reverb's dryWetMix is a direct property, not a standard AudioKit parameter
        if let reverb = node as? Reverb, identifier == "dryWetMix" {
            reverb.dryWetMix = AUValue(value)
            return
        }
        // ZitaReverb's equalizerFrequency2Def has a mismatched identifier ("EQ Frequency 2")
        // in AudioKit's source; map our canonical name to the actual identifier.
        if node is ZitaReverb, identifier == "equalizerFrequency2" {
            for param in node.parameters {
                if param.def.identifier == "EQ Frequency 2" {
                    param.value = AUValue(value)
                    return
                }
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
        // ZitaReverb's equalizerFrequency2Def has a mismatched identifier in AudioKit's source
        if node is ZitaReverb, identifier == "equalizerFrequency2" {
            for param in node.parameters {
                if param.def.identifier == "EQ Frequency 2" {
                    param.ramp(to: AUValue(value), duration: Float(duration), delay: Float(delay))
                    return
                }
            }
        }
        throw PigeonError(code: "PARAM_NOT_FOUND",
                          message: "No parameter '\(identifier)' on node \(nodeId)",
                          details: nil)
    }

    // MARK: - Effects

    func createEffect(inputNodeId: String, effectType: String, params: [String: Double]) throws -> PlatformNodeHandle {
        let input = try getNode(inputNodeId)
        let nodeId = generateId()

        func p(_ key: String, _ defaultValue: Double) -> AUValue {
            AUValue(params[key] ?? defaultValue)
        }

        let node: Node
        switch effectType {
        // ---- AudioKit Core ----
        case "Delay":
            node = Delay(input,
                         time: p("time", 1),
                         feedback: p("feedback", 50),
                         lowPassCutoff: p("lowPassCutoff", 15000),
                         dryWetMix: p("dryWetMix", 100))
        case "Reverb":
            node = Reverb(input, dryWetMix: p("dryWetMix", 0.5))
        case "Distortion":
            node = Distortion(input,
                              delay: p("delay", 0.1),
                              decay: p("decay", 1),
                              delayMix: p("delayMix", 50),
                              ringModFreq1: p("ringModFreq1", 100),
                              ringModFreq2: p("ringModFreq2", 100),
                              ringModBalance: p("ringModBalance", 50),
                              ringModMix: p("ringModMix", 0),
                              decimation: p("decimation", 50),
                              rounding: p("rounding", 0),
                              decimationMix: p("decimationMix", 50),
                              linearTerm: p("linearTerm", 0.5),
                              squaredTerm: p("squaredTerm", 10),
                              cubicTerm: p("cubicTerm", 10),
                              polynomialMix: p("polynomialMix", 50),
                              softClipGain: p("softClipGain", -6),
                              finalMix: p("finalMix", 50))
        case "Compressor":
            node = Compressor(input,
                              threshold: p("threshold", -20),
                              headRoom: p("headRoom", 5),
                              attackTime: p("attackTime", 0.001),
                              releaseTime: p("releaseTime", 0.05),
                              masterGain: p("masterGain", 0))
        case "DynamicsProcessor":
            node = DynamicsProcessor(input,
                                     threshold: p("threshold", -20),
                                     headRoom: p("headRoom", 5),
                                     expansionRatio: p("expansionRatio", 2),
                                     expansionThreshold: p("expansionThreshold", 2),
                                     attackTime: p("attackTime", 0.001),
                                     releaseTime: p("releaseTime", 0.05),
                                     masterGain: p("masterGain", 0))
        case "PeakLimiter":
            node = PeakLimiter(input,
                               attackTime: p("attackTime", 0.012),
                               decayTime: p("decayTime", 0.024),
                               preGain: p("preGain", 0))
        case "LowPassFilter":
            node = LowPassFilter(input,
                                 cutoffFrequency: p("cutoffFrequency", 6900),
                                 resonance: p("resonance", 0))
        case "HighPassFilter":
            node = HighPassFilter(input,
                                  cutoffFrequency: p("cutoffFrequency", 6900),
                                  resonance: p("resonance", 0))
        case "BandPassFilter":
            node = BandPassFilter(input,
                                  centerFrequency: p("centerFrequency", 5000),
                                  bandwidth: p("bandwidth", 600))
        case "HighShelfFilter":
            node = HighShelfFilter(input,
                                   cutOffFrequency: p("cutOffFrequency", 10000),
                                   gain: p("gain", 0))
        case "LowShelfFilter":
            node = LowShelfFilter(input,
                                  cutoffFrequency: p("cutoffFrequency", 80),
                                  gain: p("gain", 0))
        case "ParametricEQ":
            node = ParametricEQ(input,
                                centerFreq: p("centerFreq", 2000),
                                q: p("q", 1),
                                gain: p("gain", 0))
        // ---- SoundpipeAudioKit ----
        case "ZitaReverb":
            node = ZitaReverb(input,
                              predelay: p("predelay", 60),
                              crossoverFrequency: p("crossoverFrequency", 200),
                              lowReleaseTime: p("lowReleaseTime", 3),
                              midReleaseTime: p("midReleaseTime", 2),
                              dampingFrequency: p("dampingFrequency", 6000),
                              equalizerFrequency1: p("equalizerFrequency1", 315),
                              equalizerLevel1: p("equalizerLevel1", 0),
                              equalizerFrequency2: p("equalizerFrequency2", 1000),
                              equalizerLevel2: p("equalizerLevel2", 0),
                              dryWetMix: p("dryWetMix", 1))
        case "CostelloReverb":
            node = CostelloReverb(input,
                                  balance: p("balance", 1),
                                  feedback: p("feedback", 0.6),
                                  cutoffFrequency: p("cutoffFrequency", 4000))
        case "MoogLadder":
            node = MoogLadder(input,
                              cutoffFrequency: p("cutoffFrequency", 1000),
                              resonance: p("resonance", 0.5))
        case "DynamicRangeCompressor":
            node = DynamicRangeCompressor(input,
                                          ratio: p("ratio", 1),
                                          threshold: p("threshold", 0),
                                          attackDuration: p("attackDuration", 0.1),
                                          releaseDuration: p("releaseDuration", 0.1),
                                          gain: p("gain", 1),
                                          dryWetMix: p("dryWetMix", 1))
        case "Panner":
            node = Panner(input, pan: p("pan", 0))
        case "PitchShifter":
            node = PitchShifter(input,
                                shift: p("shift", 0),
                                windowSize: p("windowSize", 1024),
                                crossfade: p("crossfade", 512),
                                dryWetMix: p("dryWetMix", 1))
        // ---- SoundpipeAudioKit Phase 3: Reverbs ----
        case "ChowningReverb":
            node = ChowningReverb(input, balance: p("balance", 1))
        case "FlatFrequencyResponseReverb":
            node = FlatFrequencyResponseReverb(input,
                                                reverbDuration: p("reverbDuration", 0.5),
                                                loopDuration: p("loopDuration", 0.1))
        case "CombFilterReverb":
            node = CombFilterReverb(input,
                                     reverbDuration: p("reverbDuration", 1),
                                     loopDuration: p("loopDuration", 0.1))
        // ---- SoundpipeAudioKit Phase 3: Delay ----
        case "VariableDelay":
            let vd = VariableDelay(input,
                                    time: p("time", 0),
                                    feedback: p("feedback", 0),
                                    maximumTime: p("maximumTime", 10))
            if let dwm = params["dryWetMix"] {
                vd.dryWetMix = AUValue(dwm)
            }
            node = vd
        // ---- SoundpipeAudioKit Phase 3: Filters ----
        case "KorgLowPassFilter":
            node = KorgLowPassFilter(input,
                                      cutoffFrequency: p("cutoffFrequency", 1000),
                                      resonance: p("resonance", 1),
                                      saturation: p("saturation", 0))
        case "RolandTB303Filter":
            node = RolandTB303Filter(input,
                                      cutoffFrequency: p("cutoffFrequency", 500),
                                      resonance: p("resonance", 0.5),
                                      distortion: p("distortion", 2),
                                      resonanceAsymmetry: p("resonanceAsymmetry", 0.5))
        case "DiodeLadderFilter":
            node = DiodeLadderFilter(input,
                                      cutoffFrequency: p("cutoffFrequency", 1000),
                                      resonance: p("resonance", 0.5))
        case "LowPassButterworthFilter":
            node = LowPassButterworthFilter(input,
                                             cutoffFrequency: p("cutoffFrequency", 1000))
        case "HighPassButterworthFilter":
            node = HighPassButterworthFilter(input,
                                              cutoffFrequency: p("cutoffFrequency", 500))
        case "BandPassButterworthFilter":
            node = BandPassButterworthFilter(input,
                                              centerFrequency: p("centerFrequency", 2000),
                                              bandwidth: p("bandwidth", 100))
        case "BandRejectButterworthFilter":
            node = BandRejectButterworthFilter(input,
                                                centerFrequency: p("centerFrequency", 3000),
                                                bandwidth: p("bandwidth", 2000))
        case "ThreePoleLowpassFilter":
            node = ThreePoleLowpassFilter(input,
                                           distortion: p("distortion", 0.5),
                                           cutoffFrequency: p("cutoffFrequency", 1500),
                                           resonance: p("resonance", 0.5))
        case "ResonantFilter":
            node = ResonantFilter(input,
                                   frequency: p("frequency", 4000),
                                   bandwidth: p("bandwidth", 1000))
        case "EqualizerFilter":
            node = EqualizerFilter(input,
                                    centerFrequency: p("centerFrequency", 1000),
                                    bandwidth: p("bandwidth", 100),
                                    gain: p("gain", 1))
        case "FormantFilter":
            node = FormantFilter(input,
                                  centerFrequency: p("centerFrequency", 1000),
                                  attackDuration: p("attackDuration", 0.007),
                                  decayDuration: p("decayDuration", 0.04))
        case "ToneFilter":
            node = ToneFilter(input, halfPowerPoint: p("halfPowerPoint", 1000))
        case "ToneComplementFilter":
            node = ToneComplementFilter(input, halfPowerPoint: p("halfPowerPoint", 1000))
        case "ModalResonanceFilter":
            node = ModalResonanceFilter(input,
                                         frequency: p("frequency", 500),
                                         qualityFactor: p("qualityFactor", 50))
        case "PeakingParametricEqualizerFilter":
            node = PeakingParametricEqualizerFilter(input,
                                                     centerFrequency: p("centerFrequency", 1000),
                                                     gain: p("gain", 1),
                                                     q: p("q", 0.707))
        case "LowShelfParametricEqualizerFilter":
            node = LowShelfParametricEqualizerFilter(input,
                                                      cornerFrequency: p("cornerFrequency", 1000),
                                                      gain: p("gain", 1),
                                                      q: p("q", 0.707))
        case "HighShelfParametricEqualizerFilter":
            node = HighShelfParametricEqualizerFilter(input,
                                                       centerFrequency: p("centerFrequency", 1000),
                                                       gain: p("gain", 1),
                                                       q: p("q", 0.707))
        // ---- SoundpipeAudioKit Phase 3: Distortion ----
        case "TanhDistortion":
            let td = TanhDistortion(input,
                                     pregain: p("pregain", 2),
                                     postgain: p("postgain", 0.5),
                                     positiveShapeParameter: p("positiveShapeParameter", 0),
                                     negativeShapeParameter: p("negativeShapeParameter", 0))
            if let dwm = params["dryWetMix"] {
                td.dryWetMix = AUValue(dwm)
            }
            node = td
        case "BitCrusher":
            let bc = BitCrusher(input,
                                 bitDepth: p("bitDepth", 8),
                                 sampleRate: p("sampleRate", 10000))
            if let dwm = params["dryWetMix"] {
                bc.dryWetMix = AUValue(dwm)
            }
            node = bc
        case "Clipper":
            node = Clipper(input, limit: p("limit", 1))
        // ---- SoundpipeAudioKit Phase 3: Modulation ----
        case "Phaser":
            let ph = Phaser(input,
                             notchMinimumFrequency: p("notchMinimumFrequency", 100),
                             notchMaximumFrequency: p("notchMaximumFrequency", 800),
                             notchWidth: p("notchWidth", 1000),
                             notchFrequency: p("notchFrequency", 1.5),
                             vibratoMode: p("vibratoMode", 1),
                             depth: p("depth", 1),
                             feedback: p("feedback", 0),
                             inverted: p("inverted", 0),
                             lfoBPM: p("lfoBPM", 30))
            if let dwm = params["dryWetMix"] {
                ph.dryWetMix = AUValue(dwm)
            }
            node = ph
        case "Tremolo":
            node = Tremolo(input, frequency: p("frequency", 10), depth: p("depth", 1))
        case "AutoWah":
            node = AutoWah(input,
                            wah: p("wah", 0),
                            mix: p("mix", 1),
                            amplitude: p("amplitude", 0.1))
        case "AutoPanner":
            node = AutoPanner(input, frequency: p("frequency", 10), depth: p("depth", 1))
        case "Vibrato":
            node = Vibrato(input, vibratoSpeed: p("speed", 1), vibratoDepth: p("depth", 1))
        // ---- SoundpipeAudioKit Phase 3: Spatial ----
        case "StringResonator":
            node = StringResonator(input,
                                    fundamentalFrequency: p("fundamentalFrequency", 100),
                                    feedback: p("feedback", 0.95))
        // ---- SoundpipeAudioKit Phase 3: Utility ----
        case "DCBlock":
            node = DCBlock(input)
        case "AmplitudeEnvelope":
            node = AmplitudeEnvelope(input,
                                      attackDuration: p("attackDuration", 0.1),
                                      decayDuration: p("decayDuration", 0.1),
                                      sustainLevel: p("sustainLevel", 1),
                                      releaseDuration: p("releaseDuration", 0.1))
        default:
            throw PigeonError(code: "UNKNOWN_EFFECT",
                              message: "Unknown effect type: \(effectType)",
                              details: nil)
        }

        nodes[nodeId] = node
        return PlatformNodeHandle(nodeId: nodeId, nodeType: effectType)
    }

    /// Loads a factory reverb preset on a Reverb node.
    func loadReverbPreset(nodeId: String, presetIndex: Int64) throws {
        guard let reverb = nodes[nodeId] as? Reverb else {
            throw PigeonError(code: "NODE_NOT_REVERB",
                              message: "Node \(nodeId) is not a Reverb",
                              details: nil)
        }
        guard let preset = AVAudioUnitReverbPreset(rawValue: Int(presetIndex)) else {
            throw PigeonError(code: "INVALID_PRESET",
                              message: "Invalid reverb preset index: \(presetIndex)",
                              details: nil)
        }
        reverb.loadFactoryPreset(preset)
    }

    // MARK: - Convolution

    func createConvolution(inputNodeId: String, impulseResponseFilePath: String, partitionLength: Int64) throws -> PlatformNodeHandle {
        let input = try getNode(inputNodeId)
        let nodeId = generateId()
        let url = URL(fileURLWithPath: impulseResponseFilePath)
        let conv = Convolution(input, impulseResponseFileURL: url, partitionLength: Int(partitionLength))
        nodes[nodeId] = conv
        return PlatformNodeHandle(nodeId: nodeId, nodeType: "Convolution")
    }

    // MARK: - AmplitudeTap

    func startAmplitudeTap(nodeId: String, bufferSize: Int64) throws {
        let node = try getNode(nodeId)
        let tap = AmplitudeTap(node, bufferSize: UInt32(bufferSize)) { [weak self] amplitude in
            guard let self = self, let tap = self.amplitudeTaps[nodeId] else { return }
            let data = PlatformAudioLevelData(
                nodeId: nodeId,
                amplitude: Double(amplitude),
                leftAmplitude: Double(tap.leftAmplitude),
                rightAmplitude: Double(tap.rightAmplitude)
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

    // MARK: - PitchTap

    func startPitchTap(nodeId: String, bufferSize: Int64) throws {
        let node = try getNode(nodeId)
        let tap = PitchTap(node, bufferSize: UInt32(bufferSize)) { [weak self] pitches, amplitudes in
            guard let self = self else { return }
            let data = PlatformPitchData(
                nodeId: nodeId,
                leftPitch: Double(pitches[0]),
                rightPitch: pitches.count > 1 ? Double(pitches[1]) : Double(pitches[0]),
                leftAmplitude: Double(amplitudes[0]),
                rightAmplitude: amplitudes.count > 1 ? Double(amplitudes[1]) : Double(amplitudes[0])
            )
            self.flutterApi?.onPitchData(data: data) { _ in }
        }
        tap.start()
        pitchTaps[nodeId] = tap
    }

    func stopPitchTap(nodeId: String) throws {
        if let tap = pitchTaps.removeValue(forKey: nodeId) {
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
