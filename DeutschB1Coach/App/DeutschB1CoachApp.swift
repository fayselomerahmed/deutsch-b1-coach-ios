import SwiftUI
import SwiftData

@main
struct DeutschB1CoachApp: App {
    @StateObject private var storage = ModelContainerStartup {
        // Keep SwiftData's default persistent configuration and the exact
        // original schema. Do not rename, relocate, reset, or replace the store.
        let container = try ModelContainer(for:
            GrammarTopic.self,
            VocabWord.self,
            QuizQuestion.self,
            ReviewItem.self,
            UserProgress.self,
            LessonRecord.self,
            LearningActivity.self
        )
        // Match the previous scene modifier's default autosave behavior.
        container.mainContext.autosaveEnabled = true
        return container
    }

    var body: some Scene {
        WindowGroup {
            if let container = storage.container {
                RootTabView()
                    .modelContainer(container)
            } else {
                StorageRecoveryView(retry: storage.retry)
            }
        }
    }
}

private struct StorageRecoveryView: View {
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "externaldrive.badge.exclamationmark")
                .font(.largeTitle)
                .accessibilityHidden(true)

            Text("Study progress unavailable")
                .font(.title2.bold())
                .accessibilityAddTraits(.isHeader)

            Text("Your saved progress could not be opened. No reset has been performed. Try again, or restart the app. If this continues, keep the app installed and contact support before reinstalling.")
                .foregroundStyle(.secondary)

            Button("Try again", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .multilineTextAlignment(.center)
        .padding(24)
        .frame(maxWidth: 560)
    }
}
