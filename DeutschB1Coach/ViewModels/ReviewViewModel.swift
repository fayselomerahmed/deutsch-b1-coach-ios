import Foundation
import Observation

@Observable
final class ReviewViewModel {
    private let scheduler = SM2Scheduler()

    func applyGrade(_ quality: Int, to item: ReviewItem) {
        let result = scheduler.schedule(
            quality: quality,
            easeFactor: item.easeFactor,
            intervalDays: item.intervalDays,
            repetitions: item.repetitions,
            lapseCount: item.lapseCount
        )
        item.easeFactor = result.easeFactor
        item.intervalDays = result.intervalDays
        item.repetitions = result.repetitions
        item.dueDate = result.dueDate
        item.lapseCount = result.lapseCount
        item.lastReviewedAt = .now
    }
}
