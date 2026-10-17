import XCTest
@testable import DeutschB1Coach

final class ManagedAccessRefreshPolicyTests: XCTestCase {
    func testSuccessfulForegroundRefreshUsesFifteenMinuteCadence() {
        XCTAssertEqual(ManagedAccessRefreshPolicy.refreshInterval(consecutiveFailures: 0), 900)
    }

    func testFailuresBackOffFromThirtySecondsToFifteenMinutes() {
        XCTAssertEqual((1...7).map(ManagedAccessRefreshPolicy.refreshInterval), [30, 60, 120, 240, 480, 900, 900])
        XCTAssertEqual(ManagedAccessRefreshPolicy.refreshInterval(consecutiveFailures: .max), 900)
    }

    func testFirstRefreshIsImmediateButRecentForegroundChecksAreReused() {
        let now = Date(timeIntervalSince1970: 10_000)
        XCTAssertEqual(ManagedAccessRefreshPolicy.remainingDelay(lastCheck: nil, consecutiveFailures: 0, now: now), 0)
        XCTAssertEqual(ManagedAccessRefreshPolicy.remainingDelay(lastCheck: now.addingTimeInterval(-100), consecutiveFailures: 0, now: now), 800)
        XCTAssertEqual(ManagedAccessRefreshPolicy.remainingDelay(lastCheck: now.addingTimeInterval(-901), consecutiveFailures: 0, now: now), 0)
    }

    func testRetryCadenceAndClockRollbackRemainBounded() {
        let now = Date(timeIntervalSince1970: 10_000)
        XCTAssertEqual(ManagedAccessRefreshPolicy.remainingDelay(lastCheck: now.addingTimeInterval(-10), consecutiveFailures: 2, now: now), 50)
        XCTAssertEqual(ManagedAccessRefreshPolicy.remainingDelay(lastCheck: now.addingTimeInterval(100), consecutiveFailures: 0, now: now), 900)
    }

    func testCacheAcceptsOnlyPastVerificationsWithinTheOfflineGrace() {
        let now = Date(timeIntervalSince1970: 500_000)
        XCTAssertTrue(ManagedAccessRefreshPolicy.isCacheFresh(verifiedAt: now.timeIntervalSince1970, now: now))
        XCTAssertTrue(ManagedAccessRefreshPolicy.isCacheFresh(verifiedAt: now.timeIntervalSince1970 - 259_200, now: now))
        XCTAssertFalse(ManagedAccessRefreshPolicy.isCacheFresh(verifiedAt: now.timeIntervalSince1970 - 259_201, now: now))
        XCTAssertFalse(ManagedAccessRefreshPolicy.isCacheFresh(verifiedAt: now.timeIntervalSince1970 + 1, now: now))
    }

    func testCacheRejectsMissingAndNonFiniteTimestamps() {
        for value in [0, -1, Double.nan, Double.infinity, -Double.infinity] {
            XCTAssertFalse(ManagedAccessRefreshPolicy.isCacheFresh(verifiedAt: value))
        }
    }
}
