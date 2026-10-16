import Foundation

struct OrientationMockExamAttempt: Identifiable, Hashable {
    let id: UUID
    let state: GermanFederalState
    let questions: [OrientationQuestion]

    init(id: UUID = UUID(), state: GermanFederalState, questions: [OrientationQuestion]) {
        self.id = id
        self.state = state
        self.questions = questions
    }
}

struct OrientationMockExamResult: Hashable {
    let correctQuestionIDs: Set<String>
    let answeredCount: Int
    let stateCorrectCount: Int

    var correctCount: Int { correctQuestionIDs.count }
    var unansweredCount: Int { OrientationMockExamFactory.totalQuestionCount - answeredCount }
    var passedLifeInGermany: Bool { correctCount >= OrientationMockExamFactory.lifeInGermanyPassScore }
    var reachedCitizenshipThreshold: Bool { correctCount >= OrientationMockExamFactory.citizenshipPassScore }
}

enum OrientationMockExamFactory {
    static let generalQuestionCount = 30
    static let stateQuestionCount = 3
    static let totalQuestionCount = generalQuestionCount + stateQuestionCount
    static let durationSeconds = 60 * 60
    static let lifeInGermanyPassScore = 15
    static let citizenshipPassScore = 17

    static func make(for state: GermanFederalState) -> OrientationMockExamAttempt? {
        var generator = SystemRandomNumberGenerator()
        return make(for: state, using: &generator)
    }

    static func make<R: RandomNumberGenerator>(
        for state: GermanFederalState,
        using generator: inout R
    ) -> OrientationMockExamAttempt? {
        let generalPool = OrientationQuestionRepository.generalQuestions
        let statePool = OrientationQuestionRepository.questions(for: state)
        guard generalPool.count >= generalQuestionCount,
              statePool.count >= stateQuestionCount
        else { return nil }

        let general = Array(generalPool.shuffled(using: &generator).prefix(generalQuestionCount))
        let stateQuestions = Array(statePool.shuffled(using: &generator).prefix(stateQuestionCount))
        return OrientationMockExamAttempt(state: state, questions: general + stateQuestions)
    }

    static func result(
        for attempt: OrientationMockExamAttempt,
        answers: [String: Int]
    ) -> OrientationMockExamResult {
        let relevantAnswers = answers.filter { answer in
            attempt.questions.contains { $0.id == answer.key }
        }
        let correctIDs = Set(attempt.questions.compactMap { question in
            answers[question.id] == question.answerIndex ? question.id : nil
        })
        let stateIDs = Set(attempt.questions.suffix(stateQuestionCount).map(\.id))

        return OrientationMockExamResult(
            correctQuestionIDs: correctIDs,
            answeredCount: relevantAnswers.count,
            stateCorrectCount: correctIDs.intersection(stateIDs).count
        )
    }
}

enum OrientationMockExamProgress {
    static let bestScoresStorageKey = "orientationMockBestScores.v1"

    static func bestScores(from rawValue: String) -> [String: Int] {
        guard let data = rawValue.data(using: .utf8),
              let values = try? JSONDecoder().decode([String: Int].self, from: data)
        else { return [:] }
        return values
    }

    static func bestScore(for state: GermanFederalState, from rawValue: String) -> Int? {
        bestScores(from: rawValue)[state.rawValue]
    }

    static func recording(
        score: Int,
        for state: GermanFederalState,
        in rawValue: String
    ) -> String {
        var values = bestScores(from: rawValue)
        values[state.rawValue] = max(values[state.rawValue] ?? 0, score)
        guard let data = try? JSONEncoder().encode(values) else { return rawValue }
        return String(decoding: data, as: UTF8.self)
    }
}
