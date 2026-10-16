import SwiftData
import SwiftUI

struct WritingPracticeView: View {
    @Environment(\.modelContext) private var modelContext
    let prompt: String
    let checklist: [String]
    let level: CEFRLevel
    @SceneStorage("writingDraft") private var response = ""
    @SceneStorage("writingDraftPrompt") private var draftPrompt = ""
    @State private var checkedItems: Set<String> = []
    @State private var score: Double?

    init(
        prompt: String? = nil,
        checklist: [String]? = nil,
        level: CEFRLevel = .b1
    ) {
        let task = FluencyTaskCatalog.writing(level: level)
        self.prompt = prompt ?? task.prompt
        self.checklist = checklist ?? task.checklist
        self.level = level
    }

    private var words: [Substring] {
        response.split(whereSeparator: \.isWhitespace)
    }

    private var targetRange: ClosedRange<Int> {
        switch level {
        case .a1: 30...60
        case .a2: 50...90
        case .b1: 80...120
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    SkillChip(title: level.rawValue, color: CoachTheme.primary)
                    TeachingText(english: "Writing task")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    TeachingText(english: prompt).font(.title3)
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        TeachingLabel(english: "Draft", systemImage: "square.and.pencil")
                            .font(.headline)
                        Spacer()
                        TeachingText(english: "\(words.count) words")
                            .font(.callout.monospacedDigit().weight(.semibold))
                            .foregroundStyle(targetRange.contains(words.count) ? CoachTheme.correct : .secondary)
                    }
                    CoachTextEditor(
                        placeholder: "Write your German response here...",
                        text: $response,
                        minHeight: 230,
                        tint: CoachTheme.writing
                    )
                        .teachingAccessibilityLabel("Writing response")
                    TeachingText(english: "Target: \(targetRange.lowerBound)-\(targetRange.upperBound) words. Your draft is kept while the app is open.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .background(CoachTheme.surface, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))

                VStack(alignment: .leading, spacing: 12) {
                    TeachingText(english: "Self-check").font(.title2.weight(.semibold))
                    ForEach(checklist, id: \.self) { item in
                        Button {
                            if checkedItems.contains(item) {
                                checkedItems.remove(item)
                            } else {
                                checkedItems.insert(item)
                            }
                        } label: {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: checkedItems.contains(item) ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(checkedItems.contains(item) ? CoachTheme.correct : .secondary)
                                TeachingText(english: item)
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                        .teachingAccessibilityLabel(item)
                        .teachingAccessibilityValue(checkedItems.contains(item) ? "Checked" : "Not checked")
                    }
                }
                .padding(16)
                .background(CoachTheme.surface, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))

                if let score {
                    CoachFeedbackPanel(
                        isCorrect: score >= 0.7,
                        title: "Rubric score: \(Int(score * 100))%",
                        message: feedback(for: score)
                    )
                }

                Button {
                    evaluate()
                } label: {
                    CoachActionLabel(
                        title: "Evaluate with rubric",
                        successTitle: "Evaluation complete",
                        icon: "checkmark.seal.fill",
                        isComplete: score != nil
                    )
                }
                .buttonStyle(PrimaryCoachButton())
                .disabled(response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Button(role: .destructive) {
                    response = ""
                    checkedItems.removeAll()
                    score = nil
                } label: {
                    TeachingLabel(english: "Clear draft", systemImage: "trash")
                }
                .buttonStyle(SecondaryCoachButton(tint: CoachTheme.incorrect))
            }
            .padding()
        }
        .teachingNavigationTitle("Writing Lab")
        .navigationBarTitleDisplayMode(.inline)
        .coachBackground()
        .onAppear {
            guard draftPrompt != prompt else { return }
            response = ""
            checkedItems.removeAll()
            score = nil
            draftPrompt = prompt
        }
    }

    private func evaluate() {
        let checklistScore = checklist.isEmpty ? 1 : Double(checkedItems.count) / Double(checklist.count)
        let lengthScore: Double
        if targetRange.contains(words.count) {
            lengthScore = 1
        } else if words.count < targetRange.lowerBound {
            lengthScore = min(1, Double(words.count) / Double(targetRange.lowerBound))
        } else {
            lengthScore = max(0.5, Double(targetRange.upperBound) / Double(words.count))
        }

        let structureSignals = ["hallo", "sehr geehrte", "liebe", "viele grüße", "mit freundlichen grüßen"]
        let normalized = response.lowercased()
        let structureScore = structureSignals.contains(where: normalized.contains) ? 1.0 : 0.55
        let result = (checklistScore * 0.55) + (lengthScore * 0.3) + (structureScore * 0.15)
        score = result
        result >= 0.7 ? CoachFeedback.success() : CoachFeedback.warning()
        try? ProgressService().recordPractice(
            level: level,
            skill: .writing,
            score: result,
            xp: result >= 0.7 ? 12 : 6,
            sourceId: "writing-\(prompt.hashValue)",
            modelContext: modelContext
        )
    }

    private func feedback(for score: Double) -> String {
        if score >= 0.85 { return "Strong task coverage and structure. Revise once for natural word choice and accuracy." }
        if score >= 0.65 { return "Good foundation. Complete the unchecked rubric items and revise verb position." }
        return "Add the missing task points, reach the target length, and use a clear greeting and closing."
    }
}
