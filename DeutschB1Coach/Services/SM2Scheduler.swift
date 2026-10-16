import Foundation

struct SM2Result: Equatable {
    let easeFactor: Double
    let intervalDays: Int
    let repetitions: Int
    let dueDate: Date
    let lapseCount: Int
}

struct SM2Scheduler {
    func schedule(
        quality: Int,
        easeFactor: Double,
        intervalDays: Int,
        repetitions: Int,
        lapseCount: Int,
        reviewedAt: Date = .now,
        calendar: Calendar = .current
    ) -> SM2Result {
        let clampedQuality = min(max(quality, 0), 5)
        var nextEase = easeFactor
        var nextInterval = intervalDays
        var nextRepetitions = repetitions
        var nextLapseCount = lapseCount

        if clampedQuality < 3 {
            nextRepetitions = 0
            nextInterval = 1
            nextLapseCount += 1
        } else {
            if nextRepetitions == 0 {
                nextInterval = 1
            } else if nextRepetitions == 1 {
                nextInterval = 6
            } else {
                nextInterval = Int(round(Double(nextInterval) * nextEase))
            }
            nextRepetitions += 1
        }

        let quality = Double(clampedQuality)
        nextEase += 0.1 - (5.0 - quality) * (0.08 + (5.0 - quality) * 0.02)
        nextEase = max(1.3, nextEase)

        let dueDate = calendar.date(byAdding: .day, value: nextInterval, to: reviewedAt) ?? reviewedAt
        return SM2Result(
            easeFactor: nextEase,
            intervalDays: nextInterval,
            repetitions: nextRepetitions,
            dueDate: dueDate,
            lapseCount: nextLapseCount
        )
    }
}
