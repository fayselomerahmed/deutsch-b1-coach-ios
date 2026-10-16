import XCTest
@testable import DeutschB1Coach

final class SM2SchedulerTests: XCTestCase {
    func testSuccessfulFirstReviewSchedulesTomorrow() {
        let scheduler = SM2Scheduler()
        let date = Date(timeIntervalSince1970: 0)

        let result = scheduler.schedule(
            quality: 5,
            easeFactor: 2.5,
            intervalDays: 0,
            repetitions: 0,
            lapseCount: 0,
            reviewedAt: date,
            calendar: Calendar(identifier: .gregorian)
        )

        XCTAssertEqual(result.repetitions, 1)
        XCTAssertEqual(result.intervalDays, 1)
        XCTAssertEqual(result.lapseCount, 0)
        XCTAssertGreaterThan(result.easeFactor, 2.5)
    }

    func testFailedReviewResetsRepetitions() {
        let scheduler = SM2Scheduler()

        let result = scheduler.schedule(
            quality: 2,
            easeFactor: 2.5,
            intervalDays: 12,
            repetitions: 4,
            lapseCount: 0
        )

        XCTAssertEqual(result.repetitions, 0)
        XCTAssertEqual(result.intervalDays, 1)
        XCTAssertEqual(result.lapseCount, 1)
    }
}
