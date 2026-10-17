#if os(iOS) || PERSISTENCE_STARTUP_TESTING
import XCTest
@testable import DeutschB1Coach

final class ModelContainerStartupTests: XCTestCase {
    private enum StoreError: Error { case unavailable }
    private final class StoreToken {}

    func testSuccessfulStartupRetainsOneContainer() async {
        await MainActor.run {
            let expected = StoreToken()
            var attempts = 0
            let startup = ModelContainerStartup {
                attempts += 1
                return expected
            }

            XCTAssertTrue(startup.container === expected)
            XCTAssertFalse(startup.hasFailed)
            startup.retry()
            XCTAssertEqual(attempts, 1)
            XCTAssertTrue(startup.container === expected)
        }
    }

    func testFailureDoesNotCreateAFallbackContainer() async {
        await MainActor.run {
            var attempts = 0
            let startup = ModelContainerStartup<StoreToken> {
                attempts += 1
                throw StoreError.unavailable
            }

            XCTAssertNil(startup.container)
            XCTAssertTrue(startup.hasFailed)
            XCTAssertEqual(attempts, 1)
            startup.retry()
            XCTAssertNil(startup.container)
            XCTAssertTrue(startup.hasFailed)
            XCTAssertEqual(attempts, 2)
        }
    }

    func testRetryReopensThroughTheSameBuilderAfterFailure() async {
        await MainActor.run {
            let expected = StoreToken()
            var attempts = 0
            let startup = ModelContainerStartup {
                attempts += 1
                if attempts == 1 { throw StoreError.unavailable }
                return expected
            }

            XCTAssertTrue(startup.hasFailed)
            startup.retry()
            XCTAssertEqual(attempts, 2)
            XCTAssertFalse(startup.hasFailed)
            XCTAssertTrue(startup.container === expected)
            startup.retry()
            XCTAssertEqual(attempts, 2)
        }
    }
}
#endif
