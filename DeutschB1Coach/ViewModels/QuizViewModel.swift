import Foundation
import Observation

@Observable
final class QuizViewModel {
    var index = 0
    var selected: String?
    var correctCount = 0

    func submit(currentQuestion: QuizQuestion) {
        if selected == currentQuestion.correctAnswer {
            correctCount += 1
        }
        selected = nil
        index += 1
    }

    func reset() {
        index = 0
        selected = nil
        correctCount = 0
    }
}
