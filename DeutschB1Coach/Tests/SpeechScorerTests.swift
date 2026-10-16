import XCTest
@testable import DeutschB1Coach

final class SpeechScorerTests: XCTestCase {
    func testExactModelRepetitionReceivesFullScore() {
        let model = "Ich möchte einen Termin vereinbaren, weil ich vormittags Zeit habe."

        let result = SpeechScorer().scoreRepetition(
            recognizedText: model,
            expectedText: model
        )

        XCTAssertEqual(result.accuracy, 1, accuracy: 0.001)
        XCTAssertEqual(result.matchedWords, result.targetWords)
        XCTAssertTrue(result.isSuccessful)
        XCTAssertTrue(result.correction.issues.isEmpty)
    }

    func testIncompleteModelRepetitionReturnsSpecificCorrections() {
        let result = SpeechScorer().scoreRepetition(
            recognizedText: "Ich möchte Termin weil vormittags",
            expectedText: "Ich möchte einen Termin vereinbaren, weil ich vormittags Zeit habe."
        )

        XCTAssertFalse(result.isSuccessful)
        XCTAssertLessThan(result.matchedWords, result.targetWords)
        XCTAssertFalse(result.correction.issues.isEmpty)
        XCTAssertEqual(
            result.correction.correctedText,
            "Ich möchte einen Termin vereinbaren, weil ich vormittags Zeit habe."
        )
    }

    func testRepetitionTreatsWrittenAndSpokenNumbersAsEquivalent() {
        let result = SpeechScorer().scoreRepetition(
            recognizedText: "Ich habe sechs Jahre Erfahrung in der Softwareentwicklung.",
            expectedText: "Ich habe 6 Jahre Erfahrung in der Softwareentwicklung."
        )

        XCTAssertEqual(result.accuracy, 1, accuracy: 0.001)
        XCTAssertTrue(result.isSuccessful)
        XCTAssertTrue(result.correction.issues.isEmpty)
    }

    func testRepetitionHighlightsMissingGermanArticle() {
        let result = SpeechScorer().scoreRepetition(
            recognizedText: "Ich habe sechs Jahre Erfahrung in Softwareentwicklung.",
            expectedText: "Ich habe 6 Jahre Erfahrung in der Softwareentwicklung."
        )

        XCTAssertTrue(result.correction.issues.contains {
            $0.kind == .missingWord && $0.message.contains("der")
        })
    }

    func testStrongAnswerScoresHigh() {
        let prompt = SpeechPrompt(
            expectedAnswer: "Ich wohne seit zwei Jahren in Deutschland.",
            requiredPhrases: ["ich wohne", "seit zwei Jahren"],
            grammarMarkers: ["seit"],
            targetDuration: 4...12
        )

        let score = SpeechScorer().score(
            recognizedText: "Ich wohne seit zwei Jahren in Deutschland.",
            prompt: prompt,
            duration: 6
        )

        XCTAssertGreaterThan(score.overall, 0.85)
        XCTAssertEqual(score.correction.correctedText, prompt.expectedAnswer)
        XCTAssertTrue(score.correction.issues.isEmpty)
        XCTAssertFalse(score.correction.suggestions.isEmpty)
    }

    func testMissingRequiredPhrasesProducesFeedback() {
        let prompt = SpeechPrompt(
            expectedAnswer: "Ich möchte einen Termin machen.",
            requiredPhrases: ["einen Termin machen"],
            grammarMarkers: ["möchte"],
            targetDuration: 4...10
        )

        let score = SpeechScorer().score(
            recognizedText: "Hallo ich komme morgen",
            prompt: prompt,
            duration: 3
        )

        XCTAssertLessThan(score.overall, 0.8)
        XCTAssertFalse(score.feedback.isEmpty)
        XCTAssertFalse(score.correction.issues.isEmpty)
        XCTAssertFalse(score.correction.suggestions.isEmpty)
    }

    func testCorrectionIdentifiesArticleAndCaseForm() {
        let prompt = SpeechPrompt(
            expectedAnswer: "Ich möchte einen Termin machen.",
            requiredPhrases: ["einen Termin machen"],
            grammarMarkers: ["möchte"],
            targetDuration: 4...10
        )

        let score = SpeechScorer().score(
            recognizedText: "Ich möchte ein Termin machen.",
            prompt: prompt,
            duration: 6
        )

        XCTAssertEqual(score.correction.correctedText, "Ich möchte einen Termin machen.")
        XCTAssertTrue(score.correction.issues.contains {
            $0.kind == .wordChoice && $0.message.contains("einen")
        })
        XCTAssertFalse(score.correction.suggestions.isEmpty)
    }

    func testPersonalizedCorrectionPreservesExperienceInsteadOfUsingScript() async {
        let result = await IntentPreservingGermanCoach.shared.correct(
            "ich habe 6 jahre erfahrung in software entwickelung",
            partnerCue: "Wie viel Berufserfahrung haben Sie?",
            scenario: "Vorstellungsgespräch",
            level: "B1",
            allowsOnDeviceAI: false
        )

        XCTAssertEqual(
            result.correctedText,
            "Ich habe 6 Jahre Erfahrung in der Softwareentwicklung."
        )
        XCTAssertTrue(result.correctedText.contains("6"))
        XCTAssertFalse(result.issues.isEmpty)
        XCTAssertEqual(result.source, .offlineGrammar)
    }

    func testPersonalizedCorrectionUsesDativeAfterSeit() async {
        let result = await IntentPreservingGermanCoach.shared.correct(
            "ich arbeite seit sechs jahre bei dieser firma",
            partnerCue: "Wie lange arbeiten Sie schon hier?",
            scenario: "Arbeitsplatz",
            level: "B1",
            allowsOnDeviceAI: false
        )

        XCTAssertEqual(
            result.correctedText,
            "Ich arbeite seit sechs Jahren bei dieser Firma."
        )
        XCTAssertTrue(result.correctedText.contains("sechs"))
        XCTAssertTrue(result.issues.contains { $0.message.contains("seit") })
    }
}
