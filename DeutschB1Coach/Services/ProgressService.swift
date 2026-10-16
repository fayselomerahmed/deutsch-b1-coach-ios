import Foundation
import SwiftData

@MainActor
struct ProgressService {
    func recordLesson(
        _ lesson: CompleteLessonDTO,
        completedStep: Int,
        isComplete: Bool,
        modelContext: ModelContext
    ) throws {
        let records = try modelContext.fetch(FetchDescriptor<LessonRecord>())
        let record: LessonRecord

        if let existing = records.first(where: { $0.lessonId == lesson.id }) {
            record = existing
        } else {
            record = LessonRecord(lessonId: lesson.id, level: lesson.level)
            modelContext.insert(record)
        }

        record.highestCompletedStep = max(record.highestCompletedStep, completedStep)
        record.updatedAt = .now

        if isComplete && !record.isCompleted {
            record.isCompleted = true
            record.xpEarned = lesson.xp
            record.completedAt = .now
            addActivity(
                level: lesson.level,
                skill: .reading,
                score: 1,
                xp: lesson.xp,
                sourceId: lesson.id,
                modelContext: modelContext
            )
            updateProgress(level: lesson.level, skill: .reading, score: 1, modelContext: modelContext)
            let reviewItems = (try? modelContext.fetch(FetchDescriptor<ReviewItem>())) ?? []
            let lessonContentIds = Set(lesson.vocabularyIds + [lesson.grammarTopicId])
            for item in reviewItems where lessonContentIds.contains(item.contentId) {
                item.isActive = true
                item.dueDate = min(item.dueDate, .now)
            }
        }

        try modelContext.save()
    }

    func recordReview(
        quality: Int,
        item: ReviewItem,
        level: CEFRLevel,
        modelContext: ModelContext
    ) throws {
        let skill: SkillArea = item.kind == ReviewItemKind.grammar.rawValue ? .grammar : .vocabulary
        item.isActive = true
        let score = Double(min(max(quality, 0), 5)) / 5
        addActivity(
            level: level,
            skill: skill,
            score: score,
            xp: quality >= 3 ? 2 : 1,
            sourceId: item.contentId,
            modelContext: modelContext
        )
        updateProgress(level: level, skill: skill, score: score, modelContext: modelContext)
        try modelContext.save()
    }

    func recordPractice(
        level: CEFRLevel,
        skill: SkillArea,
        score: Double,
        xp: Int,
        sourceId: String,
        modelContext: ModelContext
    ) throws {
        addActivity(level: level, skill: skill, score: score, xp: xp, sourceId: sourceId, modelContext: modelContext)
        updateProgress(level: level, skill: skill, score: score, modelContext: modelContext)
        try modelContext.save()
    }

    private func addActivity(
        level: CEFRLevel,
        skill: SkillArea,
        score: Double,
        xp: Int,
        sourceId: String,
        modelContext: ModelContext
    ) {
        modelContext.insert(
            LearningActivity(
                level: level,
                skill: skill,
                score: score,
                xp: xp,
                sourceId: sourceId
            )
        )
    }

    private func updateProgress(
        level: CEFRLevel,
        skill: SkillArea,
        score: Double,
        modelContext: ModelContext
    ) {
        let allProgress = (try? modelContext.fetch(FetchDescriptor<UserProgress>())) ?? []
        guard let progress = allProgress.first(where: { $0.level == level.rawValue }) else { return }

        switch skill {
        case .grammar:
            progress.grammarMastery = movingAverage(current: progress.grammarMastery, new: score)
        case .vocabulary:
            progress.vocabularyRetention = movingAverage(current: progress.vocabularyRetention, new: score)
        case .speaking:
            append(score, to: &progress.speakingTrend)
        case .listening:
            append(score, to: &progress.listeningTrend)
        case .writing:
            append(score, to: &progress.writingTrend)
        case .reading:
            append(score, to: &progress.readingTrend)
        }

        updateStreak(progress)
    }

    private func movingAverage(current: Double, new: Double) -> Double {
        current == 0 ? new : (current * 0.75) + (new * 0.25)
    }

    private func append(_ score: Double, to values: inout [Double]) {
        values.append(min(max(score, 0), 1))
        if values.count > 30 {
            values.removeFirst(values.count - 30)
        }
    }

    private func updateStreak(_ progress: UserProgress) {
        let calendar = Calendar.current
        defer { progress.lastStudyDate = .now }

        guard let lastStudyDate = progress.lastStudyDate else {
            progress.streakDays = 1
            return
        }

        if calendar.isDateInToday(lastStudyDate) { return }
        progress.streakDays = calendar.isDateInYesterday(lastStudyDate) ? progress.streakDays + 1 : 1
    }
}
