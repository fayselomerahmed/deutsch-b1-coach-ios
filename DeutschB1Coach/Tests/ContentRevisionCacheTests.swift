import XCTest
@testable import DeutschB1Coach

final class ContentRevisionCacheTests: XCTestCase {
    private enum ReadError: Error { case unavailable }

    func testRepeatedReadsReuseOnlyTheRequestedKey() async {
        await MainActor.run {
            let cache = ContentRevisionCache()
            let revision = UUID()
            var loads = 0
            let first = cache.value(forKey: "grammar", revision: revision) {
                loads += 1
                return ["A1"]
            }
            let repeated = cache.value(forKey: "grammar", revision: revision) {
                loads += 1
                return ["unexpected"]
            }
            let other = cache.value(forKey: "vocabulary", revision: revision) {
                loads += 1
                return ["Hallo"]
            }

            XCTAssertEqual(first, repeated)
            XCTAssertEqual(other, ["Hallo"])
            XCTAssertEqual(loads, 2)
        }
    }

    func testNewRevisionInvalidatesAllDecodedAndGeneratedValues() async {
        await MainActor.run {
            let cache = ContentRevisionCache()
            let oldRevision = UUID()
            _ = cache.value(forKey: "decoded", revision: oldRevision) { "old source" }
            _ = cache.value(forKey: "generated", revision: oldRevision) { "old lessons" }

            let newRevision = UUID()
            XCTAssertEqual(
                cache.value(forKey: "decoded", revision: newRevision) { "new source" },
                "new source"
            )
            XCTAssertEqual(
                cache.value(forKey: "generated", revision: newRevision) { "new lessons" },
                "new lessons"
            )
        }
    }

    func testFailedReadCanRecoverWithoutAnotherRevisionChange() async throws {
        try await MainActor.run {
            let cache = ContentRevisionCache()
            let revision = UUID()
            XCTAssertThrowsError(
                try cache.value(forKey: "grammar", revision: revision) { () throws -> [String] in
                    throw ReadError.unavailable
                }
            )
            XCTAssertEqual(
                cache.value(forKey: "grammar", revision: revision) { ["recovered"] },
                ["recovered"]
            )
        }
    }

    func testGeneratedValueCanReuseNestedSourceReads() async {
        await MainActor.run {
            let cache = ContentRevisionCache()
            let revision = UUID()
            var sourceReads = 0
            var builds = 0
            for _ in 0..<3 {
                let lessons = cache.value(forKey: "lessons", revision: revision) {
                    builds += 1
                    return cache.value(forKey: "grammar", revision: revision) {
                        sourceReads += 1
                        return ["lesson"]
                    }
                }
                XCTAssertEqual(lessons, ["lesson"])
            }
            _ = cache.value(forKey: "grammar", revision: revision) {
                sourceReads += 1
                return ["unexpected"]
            }
            XCTAssertEqual(sourceReads, 1)
            XCTAssertEqual(builds, 1)
        }
    }

    func testCallerMutationDoesNotChangeCachedValueTypes() async {
        await MainActor.run {
            let cache = ContentRevisionCache()
            let revision = UUID()
            var result = cache.value(forKey: "grammar", revision: revision) { ["original"] }
            result.append("caller-only")

            XCTAssertEqual(
                cache.value(forKey: "grammar", revision: revision) { ["unexpected"] },
                ["original"]
            )
        }
    }
}
