import Foundation
import Observation

@Observable
@MainActor
final class LessonViewModel {
    var selectedLevel: CEFRLevel = .a1
    var lessons: [CompleteLessonDTO] = []
    var loadError: String?

    func topics(_ allTopics: [GrammarTopic]) -> [GrammarTopic] {
        allTopics
            .filter { $0.level == selectedLevel.rawValue }
            .sorted { $0.order < $1.order }
    }

    func lessonsForSelectedLevel() -> [CompleteLessonDTO] {
        lessons
            .filter { $0.level == selectedLevel }
            .sorted { $0.order < $1.order }
    }

    func loadLessons() {
        do {
            lessons = try ContentLoader.shared.loadLessons()
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }
}
