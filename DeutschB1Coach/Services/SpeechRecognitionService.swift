import Foundation
import Speech
import AVFoundation

@MainActor
final class SpeechRecognitionService: ObservableObject {
    @Published var transcript = ""
    @Published var isRecording = false
    @Published var authorizationError: String?

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func requestAuthorization() async {
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }

        guard speechStatus == .authorized else {
            authorizationError = "Speech recognition permission is required for speaking practice."
            return
        }

        switch AVAudioApplication.shared.recordPermission {
        case .undetermined:
            let granted = await AVAudioApplication.requestRecordPermission()
            authorizationError = granted ? nil : "Microphone permission is required for speaking practice."
        case .denied:
            authorizationError = "Microphone permission is required for speaking practice."
        case .granted:
            authorizationError = nil
        @unknown default:
            authorizationError = "Microphone permission could not be determined."
        }
    }

    func start() async throws {
        #if targetEnvironment(simulator)
        throw SpeechRecognitionError.simulatorRecordingUnavailable
        #else
        stop()
        GermanSpeechService.shared.stop()
        transcript = ""

        guard let recognizer, recognizer.isAvailable else {
            throw SpeechRecognitionError.recognizerUnavailable
        }

        try await AudioSessionCoordinator.activateForRecording()

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = recognizer.supportsOnDeviceRecognition
        self.request = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak request] buffer, _ in
            request?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true

        task = recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                if let result {
                    self?.transcript = result.bestTranscription.formattedString
                }
                if error != nil || result?.isFinal == true {
                    self?.stop()
                }
            }
        }
        #endif
    }

    func stop() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        isRecording = false
        AudioSessionCoordinator.deactivate()
    }
}

enum SpeechRecognitionError: LocalizedError {
    case simulatorRecordingUnavailable
    case recognizerUnavailable

    var errorDescription: String? {
        switch self {
        case .simulatorRecordingUnavailable:
            return "Live recording is disabled in Simulator to avoid unstable simulator audio capture. Type a transcript here, or run on a physical iPhone for microphone scoring."
        case .recognizerUnavailable:
            return "German speech recognition is not available right now."
        }
    }
}
