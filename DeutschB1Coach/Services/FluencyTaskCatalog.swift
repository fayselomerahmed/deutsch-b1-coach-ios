import Foundation

struct StandaloneSpeakingTask {
    let prompt: String
    let speechPrompt: SpeechPrompt
}

struct StandaloneWritingTask {
    let prompt: String
    let checklist: [String]
}

enum FluencyTaskCatalog {
    static func speaking(level: CEFRLevel, prompt: String? = nil) -> StandaloneSpeakingTask {
        let requestedPrompt = prompt?.trimmingCharacters(in: .whitespacesAndNewlines)

        if let requestedPrompt, requestedPrompt.localizedCaseInsensitiveContains("Lernwochenende") {
            return StandaloneSpeakingTask(
                prompt: requestedPrompt,
                speechPrompt: SpeechPrompt(
                    expectedAnswer: "Wir könnten uns am Samstag um zehn Uhr in der Bibliothek treffen. Ich bringe die Bücher mit, und du könntest Getränke besorgen. Nach zwei Stunden machen wir eine Pause. Was hältst du davon?",
                    requiredPhrases: ["wir könnten", "ich bringe", "was hältst du davon"],
                    grammarMarkers: ["könnten", "und"],
                    targetDuration: 30...75
                )
            )
        }

        if let requestedPrompt, requestedPrompt.localizedCaseInsensitiveContains("öffentlichen Verkehrsmitteln") {
            return StandaloneSpeakingTask(
                prompt: requestedPrompt,
                speechPrompt: SpeechPrompt(
                    expectedAnswer: "Meiner Meinung nach sollte man in der Stadt häufiger öffentliche Verkehrsmittel benutzen. Dadurch gibt es weniger Verkehr und die Luft wird besser. Zum Beispiel fahre ich zur Arbeit mit der Bahn. Deshalb halte ich einen guten Nahverkehr für sehr wichtig.",
                    requiredPhrases: ["meiner Meinung nach", "zum Beispiel", "deshalb"],
                    grammarMarkers: ["sollte", "dadurch", "deshalb"],
                    targetDuration: 35...90
                )
            )
        }

        switch level {
        case .a1:
            let taskPrompt = requestedPrompt ?? "Stellen Sie sich kurz vor. Sagen Sie Ihren Namen, Ihren Wohnort und warum Sie Deutsch lernen."
            return StandaloneSpeakingTask(
                prompt: taskPrompt,
                speechPrompt: SpeechPrompt(
                    expectedAnswer: "Ich heiße Samira. Ich wohne in Hamburg und lerne Deutsch für meine Arbeit.",
                    requiredPhrases: ["ich heiße", "ich wohne", "ich lerne Deutsch"],
                    grammarMarkers: ["ich"],
                    targetDuration: 7...22
                )
            )
        case .a2:
            let taskPrompt = requestedPrompt ?? "Beschreiben Sie einen normalen Arbeitstag und sagen Sie, was Sie am Abend machen."
            return StandaloneSpeakingTask(
                prompt: taskPrompt,
                speechPrompt: SpeechPrompt(
                    expectedAnswer: "An Werktagen stehe ich um sieben Uhr auf und fahre mit dem Bus zur Arbeit. Nach der Arbeit kaufe ich ein. Am Abend koche ich und lerne noch dreißig Minuten Deutsch.",
                    requiredPhrases: ["an Werktagen", "nach der Arbeit", "am Abend"],
                    grammarMarkers: ["und", "nach"],
                    targetDuration: 15...40
                )
            )
        case .b1:
            let taskPrompt = requestedPrompt ?? "Stellen Sie sich vor und sprechen Sie über Ihre Arbeit, Ausbildung oder Ihren Deutschkurs."
            return StandaloneSpeakingTask(
                prompt: taskPrompt,
                speechPrompt: SpeechPrompt(
                    expectedAnswer: "Ich wohne seit zwei Jahren in Deutschland und lerne Deutsch, weil ich die B1-Prüfung bestehen möchte. Zurzeit besuche ich einen Abendkurs. Besonders wichtig ist für mich, im Beruf sicher mit anderen sprechen zu können.",
                    requiredPhrases: ["seit zwei Jahren", "weil ich", "besonders wichtig"],
                    grammarMarkers: ["seit", "weil", "zu können"],
                    targetDuration: 25...65
                )
            )
        }
    }

    static func writing(level: CEFRLevel) -> StandaloneWritingTask {
        switch level {
        case .a1:
            return StandaloneWritingTask(
                prompt: "Schreiben Sie eine kurze Nachricht an einen Freund. Sie kommen heute später. Sagen Sie warum, wann Sie kommen und wo Sie sich treffen.",
                checklist: [
                    "I used a greeting and a closing.",
                    "I explained why I am late.",
                    "I included a time and meeting place.",
                    "My conjugated verb is in position two."
                ]
            )
        case .a2:
            return StandaloneWritingTask(
                prompt: "Schreiben Sie Ihrem Vermieter. Die Heizung funktioniert nicht. Beschreiben Sie das Problem, sagen Sie seit wann es besteht und bitten Sie um einen Reparaturtermin.",
                checklist: [
                    "I described the problem clearly.",
                    "I said when the problem started.",
                    "I requested a concrete next step.",
                    "I used a suitable greeting and closing.",
                    "I checked verb position after weil or dass."
                ]
            )
        case .b1:
            return StandaloneWritingTask(
                prompt: "Schreiben Sie eine E-Mail an Ihre Sprachschule. Sie können morgen nicht kommen. Erklären Sie warum, schlagen Sie eine Lösung vor und bitten Sie um eine Rückmeldung.",
                checklist: [
                    "I answered every task point.",
                    "I used a suitable greeting and closing.",
                    "I explained the situation and proposed a solution.",
                    "I used connectors such as weil, deshalb, or trotzdem.",
                    "I checked verb position and noun capitalization."
                ]
            )
        }
    }
}
