import AVFoundation
import Combine
import Foundation

enum GermanSpeechStyle {
    case word
    case sentence
    case listening
    case model

    var rate: Float {
        switch self {
        case .word: 0.46
        case .sentence: 0.49
        case .listening: 0.47
        case .model: 0.48
        }
    }

    var neuralPlaybackRate: Float {
        switch self {
        case .word: 0.94
        case .sentence, .listening: 1.0
        case .model: 0.86
        }
    }
}

enum GermanSpeechPlaybackState: Equatable {
    case idle
    case preparing
    case playing
    case paused
}

enum GermanSpeechSpeed: Float, CaseIterable, Identifiable {
    case slow = 0.75
    case normal = 1
    case fast = 1.25

    var id: Float { rawValue }

    var title: String {
        switch self {
        case .slow: "0.75x"
        case .normal: "1x"
        case .fast: "1.25x"
        }
    }

    static func resolve(_ rawValue: Float) -> GermanSpeechSpeed {
        allCases.min { abs($0.rawValue - rawValue) < abs($1.rawValue - rawValue) } ?? .normal
    }
}

struct GermanVoiceOption: Identifiable, Hashable {
    let id: String
    let name: String
    let language: String
    let quality: String
}

final class GermanSpeechService: NSObject, AVSpeechSynthesizerDelegate, ObservableObject, @unchecked Sendable {
    static let shared = GermanSpeechService()
    static let previewText = "Guten Tag! Ich helfe dir, natürlich und sicher Deutsch zu sprechen."

    private let synthesizer = AVSpeechSynthesizer()
    private let neuralPlayback = NeuralAudioPlaybackController()
    private let dynamicNeuralVoice = OnDeviceGermanVoiceRenderer.shared
    private let preferenceKey = "germanSpeechVoiceIdentifier"
    private static let speedPreferenceKey = "germanSpeechPlaybackSpeed"
    private var speechRequestID = UUID()
    private var queuedSegments: [(text: String, style: GermanSpeechStyle)] = []
    private var appleSpeechRequestID: UUID?
    private var activeBackend = ActiveBackend.none
    private var activeStyle = GermanSpeechStyle.sentence

    @Published private(set) var playbackState = GermanSpeechPlaybackState.idle
    @Published private(set) var activeText = ""
    @Published private(set) var playbackSpeed: GermanSpeechSpeed

    override private init() {
        let savedSpeed = UserDefaults.standard.float(forKey: Self.speedPreferenceKey)
        playbackSpeed = savedSpeed > 0 ? GermanSpeechSpeed.resolve(savedSpeed) : .normal
        super.init()
        synthesizer.usesApplicationAudioSession = false
        synthesizer.delegate = self
    }

    func speak(_ text: String, style: GermanSpeechStyle = .sentence) {
        speakSequence([(text, style)])
    }

    func toggle(_ text: String, style: GermanSpeechStyle = .sentence) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.toggle(text, style: style)
            }
            return
        }

        let preparedText = Self.prepared(text)
        guard !preparedText.isEmpty else { return }
        if activeText == preparedText {
            switch playbackState {
            case .playing:
                pause()
            case .paused:
                resume()
            case .preparing:
                stop()
            case .idle:
                speak(preparedText, style: style)
            }
        } else {
            speak(preparedText, style: style)
        }
    }

    func isActive(_ text: String) -> Bool {
        playbackState != .idle && activeText == Self.prepared(text)
    }

    func speakSequence(_ texts: [String], style: GermanSpeechStyle = .sentence) {
        speakSequence(texts.map { ($0, style) })
    }

    func speakSequence(_ segments: [(String, GermanSpeechStyle)]) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.speakSequence(segments)
            }
            return
        }

        let preparedSegments = segments.compactMap { text, style -> (String, GermanSpeechStyle)? in
            let preparedText = Self.prepared(text)
            return preparedText.isEmpty ? nil : (preparedText, style)
        }
        guard !preparedSegments.isEmpty else { return }

        stop()
        let requestID = UUID()
        speechRequestID = requestID
        queuedSegments = preparedSegments
        activeText = preparedSegments.map(\.0).joined(separator: " ")
        playbackState = .preparing
        speakNext(requestID: requestID)
    }

    private func speakNext(requestID: UUID) {
        guard speechRequestID == requestID else { return }
        guard !queuedSegments.isEmpty else {
            finishPlayback(requestID: requestID)
            return
        }
        let segment = queuedSegments.removeFirst()
        activeStyle = segment.style
        activeBackend = .none
        playbackState = .preparing

        if let url = neuralAudioURL(for: segment.text) {
            playNaturalAudio(url, segment: segment, requestID: requestID)
            return
        }

        dynamicNeuralVoice.render(segment.text) { [weak self] url in
            guard let self, self.speechRequestID == requestID else { return }
            guard let url else {
                self.speakWithAppleVoice(
                    segment.text,
                    style: segment.style,
                    requestID: requestID
                )
                return
            }
            self.playNaturalAudio(url, segment: segment, requestID: requestID)
        }
    }

    private func playNaturalAudio(
        _ url: URL,
        segment: (text: String, style: GermanSpeechStyle),
        requestID: UUID
    ) {
        neuralPlayback.play(
            url: url,
            rate: segment.style.neuralPlaybackRate * playbackSpeed.rawValue,
            started: { [weak self] started in
                guard let self, self.speechRequestID == requestID else { return }
                if !started {
                    self.speakWithAppleVoice(
                        segment.text,
                        style: segment.style,
                        requestID: requestID
                    )
                } else {
                    self.activeBackend = .neural
                    self.playbackState = .playing
                }
            },
            finished: { [weak self] in
                guard let self, self.speechRequestID == requestID else { return }
                self.activeBackend = .none
                self.speakNext(requestID: requestID)
            }
        )
    }

    func pause() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in self?.pause() }
            return
        }
        guard playbackState == .playing else { return }

        switch activeBackend {
        case .apple:
            if synthesizer.pauseSpeaking(at: .word) {
                playbackState = .paused
            }
        case .neural:
            neuralPlayback.pause { [weak self] paused in
                guard let self, paused, self.activeBackend == .neural else { return }
                self.playbackState = .paused
            }
        case .none:
            break
        }
    }

    func resume() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in self?.resume() }
            return
        }
        guard playbackState == .paused else { return }

        switch activeBackend {
        case .apple:
            if synthesizer.continueSpeaking() {
                playbackState = .playing
            }
        case .neural:
            neuralPlayback.resume { [weak self] resumed in
                guard let self, resumed, self.activeBackend == .neural else { return }
                self.playbackState = .playing
            }
        case .none:
            break
        }
    }

    func setPlaybackSpeed(_ speed: GermanSpeechSpeed) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in self?.setPlaybackSpeed(speed) }
            return
        }

        playbackSpeed = speed
        UserDefaults.standard.set(speed.rawValue, forKey: Self.speedPreferenceKey)
        if activeBackend == .neural {
            neuralPlayback.setRate(activeStyle.neuralPlaybackRate * speed.rawValue)
        }
    }

    func stop() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.stop()
            }
            return
        }

        speechRequestID = UUID()
        appleSpeechRequestID = nil
        queuedSegments.removeAll()
        activeBackend = .none
        neuralPlayback.stop()
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        activeText = ""
        playbackState = .idle
    }

    private func speakWithAppleVoice(
        _ text: String,
        style: GermanSpeechStyle,
        requestID: UUID
    ) {
        guard speechRequestID == requestID else { return }
        appleSpeechRequestID = requestID
        activeBackend = .apple
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = selectedVoice()
        utterance.rate = min(
            max(style.rate * playbackSpeed.rawValue, AVSpeechUtteranceMinimumSpeechRate),
            AVSpeechUtteranceMaximumSpeechRate
        )
        utterance.pitchMultiplier = 1.02
        utterance.volume = 1
        utterance.preUtteranceDelay = 0.04
        utterance.postUtteranceDelay = 0.1
        playbackState = .playing
        synthesizer.speak(utterance)
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        finishAppleSpeech(continuesSequence: true)
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        finishAppleSpeech(continuesSequence: false)
    }

    func hasBundledNeuralAudio(for text: String) -> Bool {
        neuralAudioURL(for: text) != nil
    }

    var bundledNeuralClipCount: Int {
        guard let url = Bundle.main.url(forResource: "neural_audio_manifest", withExtension: "json")
                ?? Bundle.main.url(
                    forResource: "neural_audio_manifest",
                    withExtension: "json",
                    subdirectory: "NeuralAudio"
                ),
              let data = try? Data(contentsOf: url),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return 0 }
        return object["clipCount"] as? Int ?? 0
    }

    var hasDynamicNeuralVoice: Bool {
        dynamicNeuralVoice.hasBundledModel
    }

    static func neuralResourceName(for text: String) -> String {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in prepared(text).utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }
        return String(format: "neural_%016llx", hash)
    }

    func availableVoices() -> [GermanVoiceOption] {
        preferredGermanVoices().map {
            GermanVoiceOption(
                id: $0.identifier,
                name: $0.name,
                language: $0.language,
                quality: qualityLabel($0.quality)
            )
        }
    }

    private func selectedVoice() -> AVSpeechSynthesisVoice? {
        let preferredIdentifier = UserDefaults.standard.string(forKey: preferenceKey) ?? ""
        if !preferredIdentifier.isEmpty,
           let preferred = AVSpeechSynthesisVoice(identifier: preferredIdentifier),
           preferred.language.hasPrefix("de"),
           preferred.quality != .default {
            return preferred
        }
        return preferredGermanVoices().first ?? AVSpeechSynthesisVoice(language: "de-DE")
    }

    private func neuralAudioURL(for text: String) -> URL? {
        let name = Self.neuralResourceName(for: text)
        return Bundle.main.url(forResource: name, withExtension: "m4a")
            ?? Bundle.main.url(forResource: name, withExtension: "m4a", subdirectory: "NeuralAudio")
    }

    private static func prepared(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\n", with: " ")
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }

    private func germanVoices() -> [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("de") }
            .sorted { left, right in
                if left.quality.rawValue != right.quality.rawValue {
                    return left.quality.rawValue > right.quality.rawValue
                }
                let leftLocaleScore = left.language == "de-DE" ? 1 : 0
                let rightLocaleScore = right.language == "de-DE" ? 1 : 0
                if leftLocaleScore != rightLocaleScore {
                    return leftLocaleScore > rightLocaleScore
                }
                return left.name.localizedCaseInsensitiveCompare(right.name) == .orderedAscending
            }
    }

    private func preferredGermanVoices() -> [AVSpeechSynthesisVoice] {
        let voices = germanVoices()
        let naturalVoices = voices.filter { $0.quality != .default }
        return naturalVoices.isEmpty ? voices : naturalVoices
    }

    private func qualityLabel(_ quality: AVSpeechSynthesisVoiceQuality) -> String {
        switch quality {
        case .premium: "Premium"
        case .enhanced: "Enhanced"
        default: "Standard"
        }
    }

    private func finishAppleSpeech(continuesSequence: Bool) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.finishAppleSpeech(continuesSequence: continuesSequence)
            }
            return
        }

        guard let requestID = appleSpeechRequestID, speechRequestID == requestID else { return }
        appleSpeechRequestID = nil
        activeBackend = .none
        if continuesSequence {
            speakNext(requestID: requestID)
        } else {
            finishPlayback(requestID: requestID)
        }
    }

    private func finishPlayback(requestID: UUID) {
        guard speechRequestID == requestID else { return }
        appleSpeechRequestID = nil
        queuedSegments.removeAll()
        activeBackend = .none
        activeText = ""
        playbackState = .idle
    }

    private enum ActiveBackend {
        case none
        case neural
        case apple
    }
}

enum AudioSessionCoordinator {
    private static let queue = DispatchQueue(
        label: "com.faysel.DeutschB1Coach.audio-session",
        qos: .userInitiated
    )

    static func perform(_ work: @escaping () -> Void) {
        queue.async(execute: work)
    }

    static func activateForPlayback() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
        try session.setActive(true)
    }

    static func activateForRecording() async throws {
        try await withCheckedThrowingContinuation { continuation in
            perform {
                do {
                    let session = AVAudioSession.sharedInstance()
                    try session.setCategory(.record, mode: .measurement, options: .duckOthers)
                    try session.setActive(true)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    static func deactivate() {
        perform {
            deactivateOnQueue()
        }
    }

    static func deactivateOnQueue() {
        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )
    }
}

private final class NeuralAudioPlaybackController: NSObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?
    private var finished: (() -> Void)?

    func play(
        url: URL,
        rate: Float,
        started: @escaping (Bool) -> Void,
        finished: @escaping () -> Void
    ) {
        AudioSessionCoordinator.perform { [weak self] in
            guard let self else { return }

            do {
                player?.stop()
                player = nil
                self.finished = nil
                try AudioSessionCoordinator.activateForPlayback()

                let preparedPlayer = try AVAudioPlayer(contentsOf: url)
                preparedPlayer.delegate = self
                preparedPlayer.enableRate = true
                preparedPlayer.rate = min(max(rate, 0.5), 2)
                guard preparedPlayer.prepareToPlay(), preparedPlayer.play() else {
                    AudioSessionCoordinator.deactivateOnQueue()
                    DispatchQueue.main.async { started(false) }
                    return
                }

                player = preparedPlayer
                self.finished = finished
                DispatchQueue.main.async { started(true) }
            } catch {
                player = nil
                self.finished = nil
                AudioSessionCoordinator.deactivateOnQueue()
                DispatchQueue.main.async { started(false) }
            }
        }
    }

    func stop() {
        AudioSessionCoordinator.perform { [weak self] in
            guard let self else { return }
            player?.stop()
            player = nil
            finished = nil
            AudioSessionCoordinator.deactivateOnQueue()
        }
    }

    func pause(completion: @escaping (Bool) -> Void) {
        AudioSessionCoordinator.perform { [weak self] in
            guard let player = self?.player, player.isPlaying else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            player.pause()
            DispatchQueue.main.async { completion(true) }
        }
    }

    func resume(completion: @escaping (Bool) -> Void) {
        AudioSessionCoordinator.perform { [weak self] in
            guard let player = self?.player, !player.isPlaying else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            let resumed = player.play()
            DispatchQueue.main.async { completion(resumed) }
        }
    }

    func setRate(_ rate: Float) {
        AudioSessionCoordinator.perform { [weak self] in
            self?.player?.rate = min(max(rate, 0.5), 2)
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        finish(player)
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        finish(player)
    }

    private func finish(_ finishedPlayer: AVAudioPlayer) {
        AudioSessionCoordinator.perform { [weak self] in
            guard let self, player === finishedPlayer else { return }
            player = nil
            let completion = finished
            finished = nil
            AudioSessionCoordinator.deactivateOnQueue()
            DispatchQueue.main.async { completion?() }
        }
    }
}
