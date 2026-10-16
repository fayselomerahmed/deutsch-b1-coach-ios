import Foundation

struct PlacementAnswer {
    let level: CEFRLevel
    let skill: SkillArea
    let isCorrect: Bool
}

struct PlacementResult {
    let recommendedLevel: CEFRLevel
    let confidence: Double
    let message: String
}

struct PlacementEngine {
    func place(answers: [PlacementAnswer]) -> PlacementResult {
        guard !answers.isEmpty else {
            return PlacementResult(recommendedLevel: .a1, confidence: 0.4, message: "Start at A1 foundations.")
        }

        let grouped = Dictionary(grouping: answers, by: \.level)
        let scores = CEFRLevel.allCases.map { level -> (CEFRLevel, Double) in
            let levelAnswers = grouped[level] ?? []
            guard !levelAnswers.isEmpty else { return (level, 0) }
            let correct = levelAnswers.filter(\.isCorrect).count
            return (level, Double(correct) / Double(levelAnswers.count))
        }

        let a1 = scores.first { $0.0 == .a1 }?.1 ?? 0
        let a2 = scores.first { $0.0 == .a2 }?.1 ?? 0
        let b1 = scores.first { $0.0 == .b1 }?.1 ?? 0

        if b1 >= 0.7 {
            return PlacementResult(recommendedLevel: .b1, confidence: b1, message: "Begin with B1 consolidation and exam practice.")
        }
        if a2 >= 0.65 && a1 >= 0.75 {
            return PlacementResult(recommendedLevel: .b1, confidence: min(a2, 0.9), message: "You are ready to work toward B1.")
        }
        if a1 >= 0.65 {
            return PlacementResult(recommendedLevel: .a2, confidence: a1, message: "Start at A2 and review weak A1 topics.")
        }
        return PlacementResult(recommendedLevel: .a1, confidence: max(a1, 0.5), message: "Start at A1 to build stable foundations.")
    }
}
