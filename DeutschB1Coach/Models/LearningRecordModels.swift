import Foundation
import SwiftData

@Model
final class LessonRecord {
    @Attribute(.unique) var lessonId: String
    var level: String
    var highestCompletedStep: Int
    var isCompleted: Bool
    var xpEarned: Int
    var updatedAt: Date
    var completedAt: Date?

    init(
        lessonId: String,
        level: CEFRLevel,
        highestCompletedStep: Int = 0,
        isCompleted: Bool = false,
        xpEarned: Int = 0,
        updatedAt: Date = .now,
        completedAt: Date? = nil
    ) {
        self.lessonId = lessonId
        self.level = level.rawValue
        self.highestCompletedStep = highestCompletedStep
        self.isCompleted = isCompleted
        self.xpEarned = xpEarned
        self.updatedAt = updatedAt
        self.completedAt = completedAt
    }
}

@Model
final class LearningActivity {
    @Attribute(.unique) var id: String
    var level: String
    var skill: String
    var score: Double
    var xp: Int
    var sourceId: String
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        level: CEFRLevel,
        skill: SkillArea,
        score: Double,
        xp: Int,
        sourceId: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.level = level.rawValue
        self.skill = skill.rawValue
        self.score = min(max(score, 0), 1)
        self.xp = max(0, xp)
        self.sourceId = sourceId
        self.createdAt = createdAt
    }
}
