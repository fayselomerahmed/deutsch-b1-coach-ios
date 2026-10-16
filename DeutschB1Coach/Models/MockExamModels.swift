import Foundation

struct MockExam: Codable {
    let id: String
    let level: String
    let title: String
    let sections: [MockExamSection]
}

struct MockExamSection: Codable, Identifiable {
    var id: String { skill }
    let skill: String
    let durationMinutes: Int
    let tasks: [MockExamTask]
}

struct MockExamTask: Codable, Hashable {
    let prompt: String
    let audioScript: String?
    let text: String?
    let questions: [MockExamQuestion]?
    let rubric: [String]?
}

struct MockExamQuestion: Codable, Hashable {
    let question: String
    let choices: [String]
    let answer: String
}
