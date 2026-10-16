import SwiftData
import SwiftUI

enum QuizSessionMode: Equatable {
    case standard
    case readinessPreview

    var questionLimit: Int {
        switch self {
        case .standard: 20
        case .readinessPreview: 8
        }
    }
}

struct QuizView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allQuestions: [QuizQuestion]
    @Query private var vocabulary: [VocabWord]
    @State private var level: CEFRLevel
    @State private var skillFilter = "All"
    @State private var index = 0
    @State private var selected = ""
    @State private var showsFeedback = false
    @State private var correctCount = 0
    @State private var deckOffset = 0
    @State private var premium = PremiumAccessService.shared
    @State private var showsPremium = false
    let sessionMode: QuizSessionMode

    init(
        level: CEFRLevel = .a1,
        skill: SkillArea? = nil,
        sessionMode: QuizSessionMode = .standard
    ) {
        _level = State(initialValue: level)
        _skillFilter = State(initialValue: skill?.rawValue.capitalized ?? "All")
        self.sessionMode = sessionMode
    }

    private var filteredQuestions: [QuizQuestion] {
        allQuestions
            .filter {
                $0.level == level.rawValue &&
                (skillFilter == "All" || $0.skill.capitalized == skillFilter)
            }
            .sorted { $0.id < $1.id }
    }

    private var sessionQuestions: [QuizQuestion] {
        guard !filteredQuestions.isEmpty else { return [] }
        let offset = deckOffset % filteredQuestions.count
        let rotated = Array(filteredQuestions[offset...]) + Array(filteredQuestions[..<offset])
        return Array(rotated.prefix(sessionMode.questionLimit))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if sessionMode == .standard {
                Picker(selection: $level) {
                    ForEach(CEFRLevel.allCases) { Text($0.rawValue).tag($0) }
                } label: {
                    TeachingText(english: "Level")
                }
                .pickerStyle(.segmented)
            } else {
                CoachCard(tint: CoachTheme.listening) {
                    HStack(spacing: 12) {
                        CoachIconTile(icon: "scope", tint: CoachTheme.listening, size: 46)
                        VStack(alignment: .leading, spacing: 3) {
                            TeachingText(english: "Free B1 readiness check")
                                .font(.headline)
                            TeachingText(english: "Eight short questions reveal your next useful focus. This is practice guidance, not an official exam result.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }

            HStack {
                Menu {
                    ForEach(["All", "Grammar", "Vocabulary", "Reading", "Listening"], id: \.self) { skill in
                        Button {
                            skillFilter = skill
                            reset()
                        } label: {
                            TeachingText(english: skill)
                        }
                    }
                } label: {
                    TeachingLabel(
                        english: skillFilter,
                        systemImage: "line.3.horizontal.decrease.circle"
                    )
                }
                Spacer()
                Text("\(min(index + 1, sessionQuestions.count))/\(sessionQuestions.count)")
                    .font(.callout.monospacedDigit().weight(.semibold))
            }

            if sessionQuestions.isEmpty {
                CoachCard {
                    CoachEmptyState(
                        icon: "questionmark.circle.fill",
                        title: "No questions in this filter",
                        message: "Choose another level or skill to keep practicing."
                    )
                }
            } else if index >= sessionQuestions.count {
                completion
                    .coachReveal(index: 1)
            } else {
                questionView(sessionQuestions[index])
                    .id(sessionQuestions[index].id)
                    .coachReveal(index: 1)
            }
            Spacer()
        }
        .padding()
        .teachingNavigationTitle(sessionMode == .readinessPreview ? "B1 Readiness Check" : "Quiz Trainer")
        .coachBackground()
        .sheet(isPresented: $showsPremium) {
            PremiumView(entryPoint: sessionMode == .readinessPreview ? .readinessResult : .advancedPractice)
        }
        .onAppear {
            if sessionMode == .standard,
               !PremiumAccessPolicy.canOpenLevel(level, isPremium: premium.isPremium) {
                level = .a1
            }
        }
        .onChange(of: level) { _, newLevel in
            guard sessionMode == .standard else { return }
            guard PremiumAccessPolicy.canOpenLevel(newLevel, isPremium: premium.isPremium) else {
                level = .a1
                showsPremium = true
                return
            }
            reset()
        }
    }

    private func questionView(_ question: QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SkillChip(title: question.skill.capitalized, color: CoachTheme.primary)
            TeachingText(
                english: question.prompt,
                protectedGerman: protectedGermanInPrompt(question)
            )
                .font(.system(.title2, design: .rounded, weight: .bold))
                .accessibilityAddTraits(.isHeader)

            if question.choices.isEmpty {
                TeachingTextField(prompt: "Type your answer", text: $selected, axis: .vertical)
                    .textFieldStyle(CoachTextFieldStyle(tint: CoachTheme.primary))
                    .germanKeyboardAccessory(text: $selected)
                    .disabled(showsFeedback)
            } else {
                ForEach(question.choices, id: \.self) { choice in
                    quizChoiceButton(
                        choice,
                        translatesMeaning: question.skill == SkillArea.vocabulary.rawValue
                            && question.id.hasSuffix("-meaning")
                    )
                }
            }

            if showsFeedback {
                CoachFeedbackPanel(
                    isCorrect: isCorrect(selected, answer: question.correctAnswer),
                    title: isCorrect(selected, answer: question.correctAnswer) ? "Correct" : "Answer: \(question.correctAnswer)",
                    message: vocabularyWord(for: question) == nil ? question.explanation : "Connect the word to this complete sentence.",
                    translatesMessage: true,
                    protectedGerman: protectedGermanAnswer(question)
                )
                if let word = vocabularyWord(for: question) {
                    VocabularyExampleSentence(word: word, compact: true)
                        .padding(12)
                        .background(CoachTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
                }
                TeachingButton("Next question") { next(question) }
                    .buttonStyle(PrimaryCoachButton())
            } else {
                TeachingButton("Check answer") { submit(question) }
                    .buttonStyle(PrimaryCoachButton())
                    .disabled(selected.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(16)
        .background(CoachTheme.surface, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
    }

    private func vocabularyWord(for question: QuizQuestion) -> VocabWord? {
        guard question.skill == SkillArea.vocabulary.rawValue else { return nil }
        return vocabulary.first { question.id.hasPrefix("quiz-\($0.id)-") }
    }

    private func quizChoiceButton(_ choice: String, translatesMeaning: Bool) -> some View {
        let isSelected = selected == choice
        let borderColor = isSelected ? CoachTheme.primary : CoachTheme.stroke
        let borderWidth: CGFloat = isSelected ? 2 : 1

        return Button {
            guard !showsFeedback else { return }
            selected = choice
        } label: {
            HStack {
                Group {
                    if translatesMeaning {
                        TeachingText(english: choice)
                    } else {
                        Text(choice)
                    }
                }
                .font(.body.weight(.medium))
                .foregroundStyle(CoachTheme.ink)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(CoachTheme.primary)
                }
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 48)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: isSelected
                        ? [CoachTheme.softMint, CoachTheme.primary.opacity(0.16), CoachTheme.rewardGlow.opacity(0.08)]
                        : [CoachTheme.elevatedSurface, CoachTheme.primary.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
            )
            .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(borderColor, lineWidth: borderWidth))
        }
        .buttonStyle(.plain)
        .disabled(showsFeedback)
        .teachingAccessibilityValue(isSelected ? "Selected" : "Not selected")
    }

    private var completion: some View {
        VStack(alignment: .leading, spacing: 16) {
            CoachCelebrationMark()
                .frame(maxWidth: .infinity)
            TeachingText(english: "Session complete")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
            TeachingText(english: "\(correctCount) of \(sessionQuestions.count) correct")
                .font(.title2.weight(.semibold))
            LessonProgressBar(progress: Double(correctCount) / Double(max(sessionQuestions.count, 1)))
            if sessionMode == .readinessPreview {
                CoachCard(tint: readinessTint) {
                    VStack(alignment: .leading, spacing: 7) {
                        TeachingText(english: readinessTitle)
                            .font(.headline)
                        TeachingText(english: readinessGuidance)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                if premium.isPremium {
                    TeachingButton("Practise another set") {
                        deckOffset += sessionMode.questionLimit
                        reset(keepOffset: true)
                    }
                    .buttonStyle(PrimaryCoachButton())
                } else {
                    TeachingButton("Open my complete B1 plan") {
                        showsPremium = true
                    }
                    .buttonStyle(PrimaryCoachButton(tint: CoachTheme.accent))
                    TeachingText(english: "Your result stays on this iPhone. Upgrade only when the full plan is useful to you.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                TeachingButton("Start a new set") {
                    deckOffset += sessionMode.questionLimit
                    reset(keepOffset: true)
                }
                .buttonStyle(PrimaryCoachButton())
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CoachTheme.surface, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
    }

    private func submit(_ question: QuizQuestion) {
        showsFeedback = true
        let correct = isCorrect(selected, answer: question.correctAnswer)
        if correct {
            correctCount += 1
            CoachFeedback.success()
        } else {
            CoachFeedback.warning()
        }
        try? ProgressService().recordPractice(
            level: CEFRLevel(rawValue: question.level) ?? level,
            skill: SkillArea(rawValue: question.skill) ?? .grammar,
            score: correct ? 1 : 0,
            xp: correct ? 2 : 0,
            sourceId: question.id,
            modelContext: modelContext
        )
    }

    private func protectedGermanInPrompt(_ question: QuizQuestion) -> [String] {
        if let word = vocabularyWord(for: question) {
            if question.id.hasSuffix("-meaning") {
                return [word.ttsText]
            }
            if question.id.hasSuffix("-article") {
                return [word.german]
            }
            return []
        }
        return GermanContentProtection.exercisePrompt(
            question.prompt,
            answer: question.correctAnswer
        )
    }

    private func protectedGermanAnswer(_ question: QuizQuestion) -> [String] {
        question.id.hasSuffix("-meaning") ? [] : [question.correctAnswer]
    }

    private func next(_ question: QuizQuestion) {
        selected = ""
        showsFeedback = false
        index += 1
        if sessionMode == .readinessPreview, index >= sessionQuestions.count {
            FreeExperienceStore.completeReadinessCheck()
        }
    }

    private func reset(keepOffset: Bool = false) {
        index = 0
        selected = ""
        showsFeedback = false
        correctCount = 0
        if !keepOffset { deckOffset = 0 }
    }

    private func isCorrect(_ response: String, answer: String) -> Bool {
        normalize(response) == normalize(answer)
    }

    private func normalize(_ value: String) -> String {
        value.lowercased().trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))
    }

    private var readinessRatio: Double {
        Double(correctCount) / Double(max(sessionQuestions.count, 1))
    }

    private var readinessTint: Color {
        readinessRatio >= 0.75 ? CoachTheme.correct : readinessRatio >= 0.5 ? CoachTheme.listening : CoachTheme.accent
    }

    private var readinessTitle: String {
        if readinessRatio >= 0.75 { return "Strong starting point" }
        if readinessRatio >= 0.5 { return "You are building toward B1" }
        return "Start with guided consolidation"
    }

    private var readinessGuidance: String {
        if readinessRatio >= 0.75 {
            return "Use timed four-skill practice and speaking feedback to make your performance more consistent."
        }
        if readinessRatio >= 0.5 {
            return "Strengthen sentence structure and everyday vocabulary, then repeat short listening and speaking tasks."
        }
        return "Build the A2 foundations first, especially word order and high-frequency language, before increasing exam pressure."
    }
}
