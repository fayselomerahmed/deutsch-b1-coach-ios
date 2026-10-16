import Foundation

enum B1ExamSection: String, CaseIterable, Identifiable {
    case listening = "Hören"
    case reading = "Lesen"
    case writing = "Schreiben"
    case speaking = "Sprechen"

    var id: String { rawValue }

    var activitySourceID: String { "mock-\(rawValue)" }

    var skillArea: SkillArea {
        switch self {
        case .listening: .listening
        case .reading: .reading
        case .writing: .writing
        case .speaking: .speaking
        }
    }

    var icon: String {
        switch self {
        case .listening: "headphones"
        case .reading: "doc.text.magnifyingglass"
        case .writing: "square.and.pencil"
        case .speaking: "mic.fill"
        }
    }
}

struct ExamSectionReadiness: Identifiable, Equatable {
    let section: B1ExamSection
    let latestScore: Double?
    let bestScore: Double?
    let attemptCount: Int
    let latestAttemptDate: Date?

    var id: B1ExamSection { section }
    var isAtPracticeLevel: Bool { latestScore.map { $0 >= ExamReadinessSnapshot.practiceThreshold } ?? false }
}

struct ExamReadinessSnapshot {
    static let practiceThreshold = 0.6

    let sections: [ExamSectionReadiness]

    init(activities: [LearningActivity]) {
        sections = B1ExamSection.allCases.map { section in
            let attempts = activities
                .filter { $0.sourceId == section.activitySourceID }
                .sorted { $0.createdAt > $1.createdAt }

            return ExamSectionReadiness(
                section: section,
                latestScore: attempts.first?.score,
                bestScore: attempts.map(\.score).max(),
                attemptCount: attempts.count,
                latestAttemptDate: attempts.first?.createdAt
            )
        }
    }

    var progress: Double {
        sections.map { $0.latestScore ?? 0 }.reduce(0, +) / Double(B1ExamSection.allCases.count)
    }

    var passedSectionCount: Int {
        sections.filter(\.isAtPracticeLevel).count
    }

    var totalAttemptCount: Int {
        sections.reduce(0) { $0 + $1.attemptCount }
    }

    var isPracticeReady: Bool {
        sections.count == B1ExamSection.allCases.count && sections.allSatisfy(\.isAtPracticeLevel)
    }

    var nextSection: B1ExamSection {
        sections.enumerated().min { lhs, rhs in
            let lhsScore = lhs.element.latestScore ?? -1
            let rhsScore = rhs.element.latestScore ?? -1
            if lhsScore == rhsScore { return lhs.offset < rhs.offset }
            return lhsScore < rhsScore
        }?.element.section ?? .listening
    }

    var latestAttemptDate: Date? {
        sections.compactMap(\.latestAttemptDate).max()
    }

    func readiness(for section: B1ExamSection) -> ExamSectionReadiness {
        sections.first { $0.section == section } ?? ExamSectionReadiness(
            section: section,
            latestScore: nil,
            bestScore: nil,
            attemptCount: 0,
            latestAttemptDate: nil
        )
    }
}

enum ExamTargetDate {
    static let storageKey = "examTargetDateInterval"

    static func date(from interval: Double) -> Date? {
        interval > 0 ? Date(timeIntervalSince1970: interval) : nil
    }

    static func daysRemaining(interval: Double, now: Date = .now, calendar: Calendar = .current) -> Int? {
        guard let targetDate = date(from: interval) else { return nil }
        let today = calendar.startOfDay(for: now)
        let target = calendar.startOfDay(for: targetDate)
        return calendar.dateComponents([.day], from: today, to: target).day
    }
}
