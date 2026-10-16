import Foundation

struct FreeResponseEvaluation: Equatable {
    let score: Double

    var isCorrect: Bool { score >= 0.62 }
}

struct FreeResponseEvaluator {
    func evaluate(_ response: String, expected: String) -> FreeResponseEvaluation {
        let responseText = normalize(response)
        let expectedText = normalize(expected)
        guard !responseText.isEmpty, !expectedText.isEmpty else {
            return FreeResponseEvaluation(score: 0)
        }

        if responseText == expectedText || responseText.contains(expectedText) {
            return FreeResponseEvaluation(score: 1)
        }

        let responseWords = responseText.split(separator: " ").map(String.init)
        let expectedWords = expectedText.split(separator: " ").map(String.init)
        if expectedText.contains(responseText), responseWords.count * 2 >= expectedWords.count {
            return FreeResponseEvaluation(score: 0.92)
        }

        let responseTokens = contentTokens(responseText)
        let expectedTokens = contentTokens(expectedText)
        guard !expectedTokens.isEmpty else {
            return FreeResponseEvaluation(score: responseText == expectedText ? 1 : 0)
        }

        let overlap = responseTokens.intersection(expectedTokens).count
        let recall = Double(overlap) / Double(expectedTokens.count)
        let precision = responseTokens.isEmpty ? 0 : Double(overlap) / Double(responseTokens.count)
        let score = min(1, (recall * 0.78) + (precision * 0.22))
        return FreeResponseEvaluation(score: score)
    }

    private func normalize(_ value: String) -> String {
        value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "de_DE"))
            .lowercased()
            .replacingOccurrences(of: #"[^a-z0-9äöüß ]"#, with: " ", options: .regularExpression)
            .split(separator: " ")
            .joined(separator: " ")
    }

    private func contentTokens(_ value: String) -> Set<String> {
        let stopWords: Set<String> = [
            "a", "an", "and", "are", "as", "at", "because", "he", "her", "his", "i", "in", "is", "it",
            "of", "on", "she", "the", "they", "to", "we", "with", "you",
            "am", "an", "auf", "bei", "das", "dem", "den", "der", "die", "ein", "eine", "einer", "einen",
            "er", "es", "ich", "im", "ist", "mit", "sie", "und", "wir", "zu"
        ]
        return Set(value.split(separator: " ").map(String.init).filter { token in
            token.count > 1 && !stopWords.contains(token)
        })
    }
}
