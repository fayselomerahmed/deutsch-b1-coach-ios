import Foundation
import SwiftData

@Model
final class UserProgress {
    @Attribute(.unique) var id: String
    var level: String
    var grammarMastery: Double
    var vocabularyRetention: Double
    var speakingTrend: [Double]
    var listeningTrend: [Double]
    var writingTrend: [Double]
    var readingTrend: [Double]
    var streakDays: Int
    var lastStudyDate: Date?
    var weakTopicIds: [String]

    init(
        id: String,
        level: CEFRLevel,
        grammarMastery: Double = 0,
        vocabularyRetention: Double = 0,
        speakingTrend: [Double] = [],
        listeningTrend: [Double] = [],
        writingTrend: [Double] = [],
        readingTrend: [Double] = [],
        streakDays: Int = 0,
        lastStudyDate: Date? = nil,
        weakTopicIds: [String] = []
    ) {
        self.id = id
        self.level = level.rawValue
        self.grammarMastery = grammarMastery
        self.vocabularyRetention = vocabularyRetention
        self.speakingTrend = speakingTrend
        self.listeningTrend = listeningTrend
        self.writingTrend = writingTrend
        self.readingTrend = readingTrend
        self.streakDays = streakDays
        self.lastStudyDate = lastStudyDate
        self.weakTopicIds = weakTopicIds
    }
}
