import Foundation
import Observation

@Observable
final class DashboardViewModel {
    var dailyGrammarGoal = 1
    var dailySpeakingGoal = 1

    func milestoneText(for progress: UserProgress) -> String {
        if progress.grammarMastery >= 0.85 && progress.vocabularyRetention >= 0.85 {
            return "\(progress.level) exam checkpoint ready"
        }
        if progress.grammarMastery < 0.5 {
            return "Build grammar foundations"
        }
        return "Keep strengthening active recall"
    }
}
