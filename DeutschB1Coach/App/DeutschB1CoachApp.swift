import SwiftUI
import SwiftData

@main
struct DeutschB1CoachApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .task {
                    // Seeding is triggered from views that have modelContext access.
                }
        }
        .modelContainer(for: [
            GrammarTopic.self,
            VocabWord.self,
            QuizQuestion.self,
            ReviewItem.self,
            UserProgress.self,
            LessonRecord.self,
            LearningActivity.self
        ])
    }
}
