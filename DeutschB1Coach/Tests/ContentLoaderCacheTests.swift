#if os(iOS)
import XCTest
@testable import DeutschB1Coach

final class ContentLoaderCacheTests: XCTestCase {
    @MainActor
    func testRepeatedCourseLoadsReadEachBundledSourceOnlyOncePerRevision() throws {
        let revision = UUID()
        var reads: [String: Int] = [:]
        let loader = ContentLoader(contentRevision: { revision }) { fileName in
            reads[fileName, default: 0] += 1
            let url = try XCTUnwrap(Bundle.main.url(forResource: fileName, withExtension: "json"))
            return try Data(contentsOf: url)
        }

        let firstQuizIDs = try loader.loadQuizzes().map(\.id)
        let firstLessons = try loader.loadLessons()
        for _ in 0..<3 {
            XCTAssertEqual(try loader.loadQuizzes().map(\.id), firstQuizIDs)
            XCTAssertEqual(try loader.loadLessons(), firstLessons)
            _ = try loader.loadGrammar()
            _ = try loader.allVocabulary()
        }

        XCTAssertEqual(firstQuizIDs.count, 2_811)
        XCTAssertEqual(firstLessons.count, 76)
        XCTAssertEqual(reads, [
            "grammar": 1, "vocab_a1": 1, "vocab_a2": 1,
            "vocab_b1": 1, "quizzes": 1, "lessons": 1
        ])
    }

    @MainActor
    func testContentRevisionRefreshesGeneratedQuizzesWithoutRestartingTheLoader() throws {
        var revision = UUID()
        var prompt = "Original question"
        var reads: [String: Int] = [:]
        let loader = ContentLoader(contentRevision: { revision }) { fileName in
            reads[fileName, default: 0] += 1
            guard fileName == "quizzes" else { return Data("[]".utf8) }
            return try JSONEncoder().encode([
                QuizQuestionDTO(
                    id: "editable-question", level: .a1, unitId: "test",
                    type: .fillBlank, skill: .grammar, prompt: prompt,
                    choices: [], correctAnswer: "answer", explanation: "Explanation"
                )
            ])
        }

        XCTAssertEqual(try loader.loadQuizzes().first?.prompt, "Original question")
        prompt = "Published replacement"
        revision = UUID()
        XCTAssertEqual(try loader.loadQuizzes().first?.prompt, "Published replacement")
        XCTAssertEqual(try loader.loadQuizzes().first?.prompt, "Published replacement")
        XCTAssertTrue(reads.values.allSatisfy { $0 == 2 })
        XCTAssertEqual(reads.count, 5)
    }
}
#endif
