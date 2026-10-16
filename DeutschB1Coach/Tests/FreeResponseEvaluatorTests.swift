import XCTest
@testable import DeutschB1Coach

final class FreeResponseEvaluatorTests: XCTestCase {
    func testAcceptsAConciseAnswerWithTheEssentialMeaning() {
        let evaluation = FreeResponseEvaluator().evaluate(
            "Berlin",
            expected: "in Berlin"
        )

        XCTAssertTrue(evaluation.isCorrect)
        XCTAssertGreaterThan(evaluation.score, 0.8)
    }

    func testRejectsAnUnrelatedAnswerEvenWhenItIsLong() {
        let evaluation = FreeResponseEvaluator().evaluate(
            "I wrote a complete sentence with many words but no useful information.",
            expected: "because he wants to work here"
        )

        XCTAssertFalse(evaluation.isCorrect)
        XCTAssertLessThan(evaluation.score, 0.4)
    }
}
