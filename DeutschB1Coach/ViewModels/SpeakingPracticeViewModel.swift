import Foundation
import Observation

@Observable
final class SpeakingPracticeViewModel {
    var recognizedText = ""
    var score: SpeechScore?
    var startedAt: Date?
    var errorMessage: String?

    var prompt: SpeechPrompt
    init(
        prompt: SpeechPrompt = SpeechPrompt(
            expectedAnswer: "Ich wohne seit zwei Jahren in Deutschland und lerne Deutsch, weil ich die B1-Prüfung bestehen möchte.",
            requiredPhrases: ["ich wohne", "seit zwei Jahren", "weil ich", "bestehen möchte"],
            grammarMarkers: ["seit", "weil", "möchte"],
            targetDuration: 8...18
        )
    ) {
        self.prompt = prompt
    }

    func playModel() {
        GermanSpeechService.shared.speak(prompt.expectedAnswer, style: .model)
    }

    func start() {
        startedAt = .now
        recognizedText = ""
        score = nil
        errorMessage = nil
    }

    func scoreCurrentAnswer() {
        let duration = startedAt.map { Date().timeIntervalSince($0) } ?? 12
        score = SpeechScorer().score(recognizedText: recognizedText, prompt: prompt, duration: duration)
    }
}
