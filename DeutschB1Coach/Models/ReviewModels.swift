import Foundation
import SwiftData

enum ReviewItemKind: String, Codable {
    case vocabulary
    case grammar
}

@Model
final class ReviewItem {
    @Attribute(.unique) var id: String
    var contentId: String
    var kind: String
    var easeFactor: Double
    var intervalDays: Int
    var repetitions: Int
    var dueDate: Date
    var lastReviewedAt: Date?
    var lapseCount: Int
    var isActive: Bool = false
    var isMemorized: Bool = false
    var isMarked: Bool = false

    init(
        id: String,
        contentId: String,
        kind: ReviewItemKind,
        easeFactor: Double = 2.5,
        intervalDays: Int = 0,
        repetitions: Int = 0,
        dueDate: Date = .now,
        lastReviewedAt: Date? = nil,
        lapseCount: Int = 0,
        isActive: Bool = false,
        isMemorized: Bool = false,
        isMarked: Bool = false
    ) {
        self.id = id
        self.contentId = contentId
        self.kind = kind.rawValue
        self.easeFactor = easeFactor
        self.intervalDays = intervalDays
        self.repetitions = repetitions
        self.dueDate = dueDate
        self.lastReviewedAt = lastReviewedAt
        self.lapseCount = lapseCount
        self.isActive = isActive
        self.isMemorized = isMemorized
        self.isMarked = isMarked
    }
}
