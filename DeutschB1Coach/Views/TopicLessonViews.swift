import SwiftData
import SwiftUI

enum VocabularyTopicLesson: String, CaseIterable, Identifiable {
    case discover
    case context
    case match
    case recall

    var id: String { rawValue }

    var title: String {
        switch self {
        case .discover: "Discover"
        case .context: "In context"
        case .match: "Quick match"
        case .recall: "Active recall"
        }
    }

    var subtitle: String {
        switch self {
        case .discover: "See, hear, remember"
        case .context: "Listen inside a sentence"
        case .match: "Connect word and meaning"
        case .recall: "Produce it yourself"
        }
    }

    var icon: String {
        switch self {
        case .discover: "eye.fill"
        case .context: "ear.fill"
        case .match: "link"
        case .recall: "bolt.fill"
        }
    }

    var tint: Color {
        switch self {
        case .discover: CoachTheme.accent
        case .context: CoachTheme.listening
        case .match: CoachTheme.primary
        case .recall: CoachTheme.speaking
        }
    }
}

enum GrammarTopicLesson: String, CaseIterable, Identifiable {
    case understand
    case notice
    case repair
    case practice
    case create

    var id: String { rawValue }

    var title: String {
        switch self {
        case .understand: "Understand"
        case .notice: "Notice"
        case .repair: "Repair"
        case .practice: "Practise"
        case .create: "Create"
        }
    }

    var subtitle: String {
        switch self {
        case .understand: "Make the rule visible"
        case .notice: "Compare real examples"
        case .repair: "Catch common errors"
        case .practice: "Build accuracy"
        case .create: "Use your own voice"
        }
    }

    var icon: String {
        switch self {
        case .understand: "lightbulb.fill"
        case .notice: "text.magnifyingglass"
        case .repair: "wrench.and.screwdriver.fill"
        case .practice: "pencil.and.list.clipboard"
        case .create: "sparkles"
        }
    }

    var tint: Color {
        switch self {
        case .understand: CoachTheme.reward
        case .notice: CoachTheme.listening
        case .repair: CoachTheme.accent
        case .practice: CoachTheme.primary
        case .create: CoachTheme.speaking
        }
    }
}

struct VocabularyTopicDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VocabWord.german) private var allWords: [VocabWord]
    @Query private var activities: [LearningActivity]

    let level: CEFRLevel
    let theme: String

    @State private var selectedLesson: VocabularyTopicLesson = .discover
    @State private var recentlyCompleted: Set<VocabularyTopicLesson> = []
    @State private var achievementTitle: String?

    private var words: [VocabWord] {
        allWords.filter { $0.level == level.rawValue && $0.theme == theme }
    }

    private var progress: Double {
        Double(completedLessons.count) / Double(VocabularyTopicLesson.allCases.count)
    }

    private var completedLessons: Set<VocabularyTopicLesson> {
        let persisted = VocabularyTopicLesson.allCases.filter { lesson in
            activities.contains { $0.sourceId == sourceId(for: lesson) }
        }
        return Set(persisted).union(recentlyCompleted)
    }

    private var unlockedLessons: Set<VocabularyTopicLesson> {
        let stages = VocabularyTopicLesson.allCases
        let completedIndexes = Set(stages.indices.filter { completedLessons.contains(stages[$0]) })
        let unlockedIndexes = CurriculumProgression.unlockedStageIndexes(
            completed: completedIndexes,
            count: stages.count
        )
        return Set(unlockedIndexes.map { stages[$0] })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                topicHeader
                SimplifiedExplanationButton(
                    explanation: SimplifiedExplanationCatalog.vocabularyTheme(
                        level: level,
                        theme: theme,
                        words: words
                    ),
                    tint: CoachTheme.listening
                )
                TopicLessonSelector(
                    stages: VocabularyTopicLesson.allCases,
                    selected: selectedLesson,
                    completed: completedLessons,
                    unlocked: unlockedLessons,
                    title: { $0.title },
                    subtitle: { $0.subtitle },
                    icon: { $0.icon },
                    tint: { $0.tint },
                    select: select
                )

                if words.isEmpty {
                    CoachCard {
                        CoachEmptyState(
                            icon: "character.book.closed.fill",
                            title: "This topic is being prepared",
                            message: "Return to the vocabulary library and choose another topic."
                        )
                    }
                } else {
                    selectedLessonView
                        .id(selectedLesson)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }

                NavigationLink {
                    VocabularyFlashcardsView(level: level, theme: theme)
                } label: {
                    TeachingLabel(english: "Keep reviewing with flashcards", systemImage: "rectangle.stack.fill")
                }
                .buttonStyle(PrimaryCoachButton(tint: CoachTheme.listening))
            }
            .padding()
        }
        .navigationTitle(theme)
        .teachingLanguageSwitcher()
        .navigationBarTitleDisplayMode(.inline)
        .coachBackground()
        .overlay(alignment: .top) {
            if let achievementTitle {
                CoachAchievementToast(
                    title: achievementTitle,
                    detail: "The next vocabulary step is ready. +6 XP",
                    tint: selectedLesson.tint
                )
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private var topicHeader: some View {
        CoachCard(padding: 14, tint: selectedLesson.tint) {
            HStack(spacing: 12) {
                CoachMascot(mood: progress == 1 ? .achievement : .welcome, size: 54, animates: false)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        SkillChip(title: level.rawValue, color: CoachTheme.primary)
                        SkillChip(title: "\(words.count) words", color: CoachTheme.listening)
                    }
                    LessonProgressBar(progress: progress)
                    TeachingText(
                        english: "\(completedLessons.count) of \(VocabularyTopicLesson.allCases.count) lessons complete"
                    )
                        .font(.caption.weight(.semibold).monospacedDigit())
                        .foregroundStyle(selectedLesson.tint)
                }
            }
        }
    }

    @ViewBuilder private var selectedLessonView: some View {
        switch selectedLesson {
        case .discover:
            VocabularyExploreLesson(words: words) { complete(.discover, score: 1) }
        case .context:
            VocabularyChoiceLesson(words: words, mode: .context) { score in complete(.context, score: score) }
        case .match:
            VocabularyChoiceLesson(words: words, mode: .match) { score in complete(.match, score: score) }
        case .recall:
            VocabularyRecallLesson(words: words) { score in complete(.recall, score: score) }
        }
    }

    private func select(_ lesson: VocabularyTopicLesson) {
        guard unlockedLessons.contains(lesson) else {
            CoachFeedback.warning()
            return
        }
        CoachFeedback.selection()
        withAnimation(CoachMotion.spring) { selectedLesson = lesson }
    }

    private func complete(_ lesson: VocabularyTopicLesson, score: Double) {
        guard !completedLessons.contains(lesson) else { return }
        recentlyCompleted.insert(lesson)
        CoachFeedback.success()
        try? ProgressService().recordPractice(
            level: level,
            skill: .vocabulary,
            score: score,
            xp: 6,
            sourceId: sourceId(for: lesson),
            modelContext: modelContext
        )
        showAchievement("\(lesson.title) complete")
    }

    private func showAchievement(_ title: String) {
        withAnimation(CoachMotion.celebration) {
            achievementTitle = title
        }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            guard achievementTitle == title else { return }
            withAnimation(CoachMotion.quick) {
                achievementTitle = nil
            }
        }
    }

    private func sourceId(for lesson: VocabularyTopicLesson) -> String {
        CurriculumProgression.vocabularySourceID(
            level: level,
            theme: theme,
            lessonID: lesson.rawValue
        )
    }
}

struct GrammarTopicDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var activities: [LearningActivity]
    let topic: GrammarTopic

    @State private var selectedLesson: GrammarTopicLesson = .understand
    @State private var recentlyCompleted: Set<GrammarTopicLesson> = []
    @State private var achievementTitle: String?

    private var progress: Double {
        Double(completedLessons.count) / Double(GrammarTopicLesson.allCases.count)
    }

    private var completedLessons: Set<GrammarTopicLesson> {
        let persisted = GrammarTopicLesson.allCases.filter { lesson in
            activities.contains { $0.sourceId == sourceId(for: lesson) }
        }
        return Set(persisted).union(recentlyCompleted)
    }

    private var unlockedLessons: Set<GrammarTopicLesson> {
        let stages = GrammarTopicLesson.allCases
        let completedIndexes = Set(stages.indices.filter { completedLessons.contains(stages[$0]) })
        let unlockedIndexes = CurriculumProgression.unlockedStageIndexes(
            completed: completedIndexes,
            count: stages.count
        )
        return Set(unlockedIndexes.map { stages[$0] })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                topicHeader
                SimplifiedExplanationButton(
                    explanation: SimplifiedExplanationCatalog.grammar(topic),
                    tint: CoachTheme.primary
                )
                TopicLessonSelector(
                    stages: GrammarTopicLesson.allCases,
                    selected: selectedLesson,
                    completed: completedLessons,
                    unlocked: unlockedLessons,
                    title: { $0.title },
                    subtitle: { $0.subtitle },
                    icon: { $0.icon },
                    tint: { $0.tint },
                    select: select
                )

                selectedLessonView
                    .id(selectedLesson)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
            .padding()
        }
        .teachingNavigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
        .coachBackground()
        .overlay(alignment: .top) {
            if let achievementTitle {
                CoachAchievementToast(
                    title: achievementTitle,
                    detail: "The next grammar step is ready. Keep building.",
                    tint: selectedLesson.tint
                )
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private var topicHeader: some View {
        CoachCard(padding: 14, tint: selectedLesson.tint) {
            HStack(spacing: 12) {
                CoachMascot(mood: progress == 1 ? .achievement : .supportive, size: 54, animates: false)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        SkillChip(title: topic.level, color: CoachTheme.primary)
                        SkillChip(title: "\(topic.practice.count) exercises", color: CoachTheme.accent)
                    }
                    LessonProgressBar(progress: progress)
                    TeachingText(
                        english: "\(completedLessons.count) of \(GrammarTopicLesson.allCases.count) lessons complete"
                    )
                        .font(.caption.weight(.semibold).monospacedDigit())
                        .foregroundStyle(selectedLesson.tint)
                }
            }
        }
    }

    @ViewBuilder private var selectedLessonView: some View {
        switch selectedLesson {
        case .understand:
            GrammarUnderstandLesson(topic: topic) { complete(.understand, score: 1) }
        case .notice:
            GrammarNoticeLesson(topic: topic) { complete(.notice, score: 1) }
        case .repair:
            GrammarRepairLesson(topic: topic) { complete(.repair, score: 1) }
        case .practice:
            GrammarPracticeLesson(topic: topic) { score in complete(.practice, score: score) }
        case .create:
            GrammarCreateLesson(topic: topic) { complete(.create, score: 1) }
        }
    }

    private func select(_ lesson: GrammarTopicLesson) {
        guard unlockedLessons.contains(lesson) else {
            CoachFeedback.warning()
            return
        }
        CoachFeedback.selection()
        withAnimation(CoachMotion.spring) { selectedLesson = lesson }
    }

    private func complete(_ lesson: GrammarTopicLesson, score: Double) {
        guard !completedLessons.contains(lesson) else { return }
        recentlyCompleted.insert(lesson)
        CoachFeedback.success()
        try? ProgressService().recordPractice(
            level: topic.cefrLevel,
            skill: .grammar,
            score: score,
            xp: lesson == .practice ? 10 : 5,
            sourceId: sourceId(for: lesson),
            modelContext: modelContext
        )
        showAchievement("\(lesson.title) complete")
    }

    private func showAchievement(_ title: String) {
        withAnimation(CoachMotion.celebration) {
            achievementTitle = title
        }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            guard achievementTitle == title else { return }
            withAnimation(CoachMotion.quick) {
                achievementTitle = nil
            }
        }
    }

    private func sourceId(for lesson: GrammarTopicLesson) -> String {
        CurriculumProgression.grammarSourceID(topicID: topic.id, lessonID: lesson.rawValue)
    }
}

private struct TopicLessonSelector<Stage: Hashable>: View {
    let stages: [Stage]
    let selected: Stage
    let completed: Set<Stage>
    let unlocked: Set<Stage>
    let title: (Stage) -> String
    let subtitle: (Stage) -> String
    let icon: (Stage) -> String
    let tint: (Stage) -> Color
    let select: (Stage) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Canvas { context, size in
                    guard stages.count > 1 else { return }
                    let inset: CGFloat = 23
                    let available = max(size.width - inset * 2, 0)
                    let segment = available / CGFloat(stages.count - 1)
                    var basePath = Path()
                    basePath.move(to: CGPoint(x: inset, y: size.height / 2))
                    basePath.addLine(to: CGPoint(x: size.width - inset, y: size.height / 2))
                    context.stroke(basePath, with: .color(CoachTheme.stroke), lineWidth: 3)

                    let completedSegments = stages.indices.dropLast().prefix {
                        completed.contains(stages[$0])
                    }.count
                    if completedSegments > 0 {
                        var completedPath = Path()
                        completedPath.move(to: CGPoint(x: inset, y: size.height / 2))
                        completedPath.addLine(
                            to: CGPoint(
                                x: inset + segment * CGFloat(completedSegments),
                                y: size.height / 2
                            )
                        )
                        context.stroke(completedPath, with: .color(CoachTheme.correct), lineWidth: 3)
                    }
                }
                .frame(height: 46)
                .accessibilityHidden(true)

                HStack(spacing: 5) {
                    ForEach(Array(stages.enumerated()), id: \.offset) { index, stage in
                        let isUnlocked = unlocked.contains(stage)
                        if index > 0 { Spacer(minLength: 3) }
                        Button { select(stage) } label: {
                            ZStack(alignment: .bottomTrailing) {
                                Circle()
                                    .fill(selected == stage ? tint(stage).opacity(0.18) : CoachTheme.surface)
                                    .overlay(
                                        Circle().stroke(
                                            selected == stage ? tint(stage) : CoachTheme.stroke,
                                            lineWidth: selected == stage ? 2 : 1
                                        )
                                    )
                                Image(systemName: isUnlocked ? icon(stage) : "lock.fill")
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(isUnlocked ? tint(stage) : Color.secondary)
                                if completed.contains(stage) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 8, weight: .heavy))
                                        .foregroundStyle(.white)
                                        .frame(width: 17, height: 17)
                                        .background(CoachTheme.correct, in: Circle())
                                }
                            }
                            .frame(width: 46, height: 46)
                        }
                        .buttonStyle(CoachCardButtonStyle())
                        .disabled(!isUnlocked)
                        .teachingAccessibilityLabel(
                            "Lesson \(index + 1), \(title(stage))"
                                + (completed.contains(stage) ? ", complete" : isUnlocked ? ", unlocked" : ", locked")
                        )
                    }
                }
            }

            HStack(spacing: 10) {
                Image(systemName: icon(selected))
                    .foregroundStyle(tint(selected))
                    .frame(width: 30, height: 30)
                    .background(tint(selected).opacity(0.12), in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    TeachingText(english: "Step \((stages.firstIndex(of: selected) ?? 0) + 1) of \(stages.count) · \(title(selected))")
                        .font(.callout.weight(.bold))
                    TeachingText(english: subtitle(selected))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(CoachTheme.surface, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(CoachTheme.stroke))
    }
}

private struct TopicLessonHeading: View {
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            CoachIconTile(icon: icon, tint: tint, size: 46)
            VStack(alignment: .leading, spacing: 3) {
                TeachingText(english: title)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                TeachingText(english: subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct VocabularyExploreLesson: View {
    let words: [VocabWord]
    let onComplete: () -> Void

    @State private var index = 0
    @State private var isComplete = false

    private var word: VocabWord { words[min(index, words.count - 1)] }

    var body: some View {
        VStack(spacing: 14) {
            CoachCard(tint: VocabularyTopicLesson.discover.tint) {
                VStack(alignment: .leading, spacing: 16) {
                    TopicLessonHeading(
                        title: "Discover the topic",
                        subtitle: "Give every word a visual, a sound, and a useful sentence.",
                        icon: VocabularyTopicLesson.discover.icon,
                        tint: VocabularyTopicLesson.discover.tint
                    )
                    LessonProgressBar(progress: Double(index + 1) / Double(words.count))
                    HStack {
                        TeachingText(english: "Word \(index + 1) of \(words.count)")
                            .font(.caption.weight(.semibold).monospacedDigit())
                            .foregroundStyle(.secondary)
                        Spacer()
                        SkillChip(title: word.difficultyTag, color: VocabularyTopicLesson.discover.tint)
                    }
                    VocabularyVisualExplanation(word: word, compact: false, prefersVisualRecall: true)
                    HStack(spacing: 10) {
                        GermanSpeechButton(text: word.ttsText, style: .word, label: "Play pronunciation")
                        GermanSpeechButton(text: word.exampleSentence, label: "Play example sentence")
                        TeachingText(english: "Hear the word, then shadow the complete sentence aloud.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            HStack(spacing: 10) {
                Button {
                    CoachFeedback.selection()
                    index = max(0, index - 1)
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(CoachIconButtonStyle(tint: VocabularyTopicLesson.discover.tint))
                .disabled(index == 0)
                .teachingAccessibilityLabel("Previous word")

                Button {
                    if index + 1 < words.count {
                        CoachFeedback.selection()
                        withAnimation(CoachMotion.spring) { index += 1 }
                    } else {
                        isComplete = true
                        onComplete()
                    }
                } label: {
                    TeachingLabel(
                        english: index + 1 < words.count ? "Next word" : "Complete lesson",
                        systemImage: index + 1 < words.count ? "arrow.right" : "checkmark"
                    )
                }
                .buttonStyle(PrimaryCoachButton(tint: VocabularyTopicLesson.discover.tint))
            }

            if isComplete {
                TopicCompletionView(
                    title: "Every word now has a memory hook",
                    message: "You explored all \(words.count) words. Continue with In context to strengthen the connections.",
                    score: nil,
                    tint: VocabularyTopicLesson.discover.tint
                ) {
                    index = 0
                    isComplete = false
                }
            }
        }
        .coachReveal()
    }
}

private enum VocabularyChoiceMode {
    case context
    case match

    var lesson: VocabularyTopicLesson { self == .context ? .context : .match }
}

private struct VocabularyChoiceLesson: View {
    let words: [VocabWord]
    let mode: VocabularyChoiceMode
    let onComplete: (Double) -> Void

    @State private var index = 0
    @State private var selectedChoice: String?
    @State private var correctCount = 0
    @State private var isComplete = false

    private var word: VocabWord { words[min(index, words.count - 1)] }
    private var isCorrect: Bool { selectedChoice == word.english }

    var body: some View {
        VStack(spacing: 14) {
            CoachCard(tint: mode.lesson.tint) {
                VStack(alignment: .leading, spacing: 16) {
                    TopicLessonHeading(
                        title: mode == .context ? "Listen in context" : "Quick meaning match",
                        subtitle: mode == .context
                            ? "Use a whole sentence to make the meaning memorable."
                            : "Strengthen fast recognition before active recall.",
                        icon: mode.lesson.icon,
                        tint: mode.lesson.tint
                    )
                    LessonProgressBar(progress: Double(index + 1) / Double(words.count))
                    TeachingText(english: "Question \(index + 1) of \(words.count)")
                        .font(.caption.weight(.semibold).monospacedDigit())
                        .foregroundStyle(.secondary)

                    if mode == .context {
                        HStack(alignment: .top, spacing: 12) {
                            GermanSpeechButton(text: word.exampleSentence, label: "Play example sentence")
                            VStack(alignment: .leading, spacing: 5) {
                                VocabularyExampleSentence(word: word)
                                TeachingText(english: "What does the highlighted idea mean here?")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        HStack(spacing: 14) {
                            CoachIconTile(
                                icon: VocabularyVisualCatalog.symbol(theme: word.theme, german: word.german, english: word.english),
                                tint: mode.lesson.tint,
                                size: 52
                            )
                            Text(displayGerman(word))
                                .font(.system(.title2, design: .rounded, weight: .bold))
                            Spacer()
                            GermanSpeechButton(text: word.ttsText, style: .word, label: "Play pronunciation")
                        }
                        TeachingText(english: "Choose the closest meaning.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 8) {
                        ForEach(answerChoices(for: index, in: words), id: \.self) { choice in
                            Button {
                                choose(choice)
                            } label: {
                                HStack {
                                    Image(systemName: choiceIcon(choice))
                                    TeachingText(english: choice)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(choiceColor(choice))
                                .padding(.horizontal, 12)
                                .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                                .background(choiceColor(choice).opacity(selectedChoice == nil ? 0.07 : 0.11), in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
                                .overlay(RoundedRectangle(cornerRadius: CoachTheme.smallRadius).stroke(choiceColor(choice).opacity(0.18)))
                            }
                            .buttonStyle(CoachCardButtonStyle())
                            .disabled(selectedChoice != nil)
                        }
                    }

                    if selectedChoice != nil {
                        CoachFeedbackPanel(
                            isCorrect: isCorrect,
                            title: isCorrect ? "Connection made" : "Good attempt",
                            message: isCorrect
                                ? "\(displayGerman(word)) means \(word.english)."
                                : "The answer is \(word.english). Listen once more and link it to the sentence.",
                            protectedGerman: [displayGerman(word)]
                        )
                        Button {
                            advance()
                        } label: {
                            TeachingLabel(
                                english: index + 1 < words.count ? "Next question" : "Finish lesson",
                                systemImage: "arrow.right"
                            )
                        }
                        .buttonStyle(PrimaryCoachButton(tint: mode.lesson.tint))
                    }
                }
            }

            if isComplete {
                TopicCompletionView(
                    title: mode == .context ? "Context connections complete" : "Meaning match complete",
                    message: "You matched \(correctCount) of \(words.count) on the first try. Repeating the lesson will make retrieval faster.",
                    score: Double(correctCount) / Double(words.count),
                    tint: mode.lesson.tint,
                    restart: restart
                )
            }
        }
        .coachReveal()
    }

    private func choose(_ choice: String) {
        selectedChoice = choice
        if choice == word.english {
            correctCount += 1
            CoachFeedback.success()
        } else {
            CoachFeedback.warning()
        }
    }

    private func advance() {
        if index + 1 < words.count {
            withAnimation(CoachMotion.spring) {
                index += 1
                selectedChoice = nil
            }
        } else {
            isComplete = true
            onComplete(Double(correctCount) / Double(words.count))
        }
    }

    private func restart() {
        index = 0
        selectedChoice = nil
        correctCount = 0
        isComplete = false
    }

    private func choiceIcon(_ choice: String) -> String {
        guard let selectedChoice else { return "circle" }
        if choice == word.english { return "checkmark.circle.fill" }
        return choice == selectedChoice ? "xmark.circle.fill" : "circle"
    }

    private func choiceColor(_ choice: String) -> Color {
        guard let selectedChoice else { return mode.lesson.tint }
        if choice == word.english { return CoachTheme.correct }
        return choice == selectedChoice ? CoachTheme.incorrect : .secondary
    }
}

private struct VocabularyRecallLesson: View {
    let words: [VocabWord]
    let onComplete: (Double) -> Void

    @State private var index = 0
    @State private var response = ""
    @State private var showsAnswer = false
    @State private var correctCount = 0
    @State private var isComplete = false

    private var word: VocabWord { words[min(index, words.count - 1)] }
    private var isCorrect: Bool {
        normalize(response) == normalize(displayGerman(word))
            || (word.article == nil && normalize(response) == normalize(word.german))
    }

    var body: some View {
        VStack(spacing: 14) {
            CoachCard(tint: VocabularyTopicLesson.recall.tint) {
                VStack(alignment: .leading, spacing: 16) {
                    TopicLessonHeading(
                        title: "Active recall",
                        subtitle: "Retrieve the German before you see or hear it.",
                        icon: VocabularyTopicLesson.recall.icon,
                        tint: VocabularyTopicLesson.recall.tint
                    )
                    LessonProgressBar(progress: Double(index + 1) / Double(words.count))
                    TeachingText(english: "Word \(index + 1) of \(words.count)")
                        .font(.caption.weight(.semibold).monospacedDigit())
                        .foregroundStyle(.secondary)
                    TeachingText(english: word.english)
                        .font(.system(.title, design: .rounded, weight: .bold))
                    if word.article != nil {
                        TeachingLabel(english: "Include the article", systemImage: "a.circle.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CoachTheme.accent)
                    }
                    TeachingTextField(prompt: "Type the German word", text: $response)
                        .textFieldStyle(CoachTextFieldStyle(tint: VocabularyTopicLesson.recall.tint))
                        .germanKeyboardAccessory(text: $response)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .disabled(showsAnswer)

                    if showsAnswer {
                        CoachFeedbackPanel(
                            isCorrect: isCorrect,
                            title: isCorrect ? "You retrieved it" : "Add this memory hook",
                            message: "\(displayGerman(word)) means \(word.english).",
                            protectedGerman: [displayGerman(word)]
                        )
                        VocabularyExampleSentence(word: word, compact: true)
                        HStack(spacing: 10) {
                            GermanSpeechButton(text: word.ttsText, style: .word, label: "Play pronunciation")
                            GermanSpeechButton(text: word.exampleSentence, label: "Play example sentence")
                            TeachingText(english: "Say the answer and example aloud before moving on.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Button { advance() } label: {
                            TeachingLabel(
                                english: index + 1 < words.count ? "Next word" : "Finish lesson",
                                systemImage: "arrow.right"
                            )
                        }
                        .buttonStyle(PrimaryCoachButton(tint: VocabularyTopicLesson.recall.tint))
                    } else {
                        TeachingButton("Check answer") { check() }
                            .buttonStyle(PrimaryCoachButton(tint: VocabularyTopicLesson.recall.tint))
                            .disabled(response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }

            if isComplete {
                TopicCompletionView(
                    title: "Active recall complete",
                    message: "You produced \(correctCount) of \(words.count) words independently. Difficult words are perfect flashcard candidates.",
                    score: Double(correctCount) / Double(words.count),
                    tint: VocabularyTopicLesson.recall.tint
                ) {
                    index = 0
                    response = ""
                    showsAnswer = false
                    correctCount = 0
                    isComplete = false
                }
            }
        }
        .coachReveal()
    }

    private func check() {
        showsAnswer = true
        if isCorrect {
            correctCount += 1
            CoachFeedback.success()
        } else {
            CoachFeedback.warning()
        }
    }

    private func advance() {
        if index + 1 < words.count {
            withAnimation(CoachMotion.spring) {
                index += 1
                response = ""
                showsAnswer = false
            }
        } else {
            isComplete = true
            onComplete(Double(correctCount) / Double(words.count))
        }
    }
}

private struct GrammarUnderstandLesson: View {
    let topic: GrammarTopic
    let onComplete: () -> Void

    @State private var isComplete = false

    var body: some View {
        VStack(spacing: 14) {
            CoachCard(tint: GrammarTopicLesson.understand.tint) {
                VStack(alignment: .leading, spacing: 16) {
                    TopicLessonHeading(
                        title: "Make the rule visible",
                        subtitle: "Understand what the pattern does before memorising forms.",
                        icon: GrammarTopicLesson.understand.icon,
                        tint: GrammarTopicLesson.understand.tint
                    )
                    GrammarVisualExplanation(topic: topic)
                }
            }

            CoachCard(tint: CoachTheme.primary) {
                GrammarPlainLanguageGuide(topic: topic)
            }

            SentenceBuilderGameLink(topic: topic)

            Button {
                isComplete = true
                onComplete()
            } label: {
                TeachingLabel(
                    english: isComplete ? "Lesson complete" : "I understand the pattern",
                    systemImage: isComplete ? "checkmark.circle.fill" : "lightbulb.fill"
                )
            }
            .buttonStyle(PrimaryCoachButton(tint: GrammarTopicLesson.understand.tint))

            if isComplete {
                TopicCompletionView(
                    title: "The pattern has a shape now",
                    message: "Continue to Notice and compare the pattern in real German sentences.",
                    score: nil,
                    tint: GrammarTopicLesson.understand.tint,
                    restart: nil
                )
            }
        }
        .coachReveal()
    }
}

private struct GrammarNoticeLesson: View {
    let topic: GrammarTopic
    let onComplete: () -> Void

    @State private var noticed: Set<Int> = []
    @State private var isComplete = false

    var body: some View {
        VStack(spacing: 14) {
            CoachCard(tint: GrammarTopicLesson.notice.tint) {
                VStack(alignment: .leading, spacing: 16) {
                    TopicLessonHeading(
                        title: "Notice it in real sentences",
                        subtitle: "Listen, compare the translation, and mark the pattern you noticed.",
                        icon: GrammarTopicLesson.notice.icon,
                        tint: GrammarTopicLesson.notice.tint
                    )
                    LessonProgressBar(progress: topic.examples.isEmpty ? 0 : Double(noticed.count) / Double(topic.examples.count))

                    ForEach(Array(topic.examples.enumerated()), id: \.offset) { index, example in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(index + 1)")
                                    .font(.caption.weight(.bold).monospacedDigit())
                                    .foregroundStyle(.white)
                                    .frame(width: 28, height: 28)
                                    .background(GrammarTopicLesson.notice.tint, in: Circle())
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(example.german)
                                        .font(.headline)
                                    TeachingText(english: example.english)
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 4)
                                GermanSpeechButton(text: example.german, label: "Play grammar example")
                                GrammarXRayButton(sentence: example.german, topic: topic)
                            }
                            Button {
                                CoachFeedback.selection()
                                if noticed.contains(index) {
                                    noticed.remove(index)
                                } else {
                                    noticed.insert(index)
                                }
                            } label: {
                                TeachingLabel(
                                    english: noticed.contains(index) ? "Pattern noticed" : "I can see the pattern",
                                    systemImage: noticed.contains(index) ? "checkmark.circle.fill" : "circle"
                                )
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(noticed.contains(index) ? CoachTheme.correct : GrammarTopicLesson.notice.tint)
                            }
                        }
                        if index + 1 < topic.examples.count { Divider() }
                    }
                }
            }

            Button {
                isComplete = true
                onComplete()
            } label: {
                TeachingLabel(english: "Complete noticing lesson", systemImage: "checkmark")
            }
            .buttonStyle(PrimaryCoachButton(tint: GrammarTopicLesson.notice.tint))
            .disabled(noticed.count < topic.examples.count)

            if isComplete {
                TopicCompletionView(
                    title: "You found the pattern \(topic.examples.count) times",
                    message: "That noticing skill helps grammar move from a rule into instinct.",
                    score: nil,
                    tint: GrammarTopicLesson.notice.tint,
                    restart: nil
                )
            }
        }
        .coachReveal()
    }
}

private struct GrammarRepairLesson: View {
    let topic: GrammarTopic
    let onComplete: () -> Void

    @State private var revealed: Set<Int> = []
    @State private var isComplete = false

    var body: some View {
        VStack(spacing: 14) {
            CoachCard(tint: GrammarTopicLesson.repair.tint) {
                VStack(alignment: .leading, spacing: 16) {
                    TopicLessonHeading(
                        title: "Repair common mistakes",
                        subtitle: "Spot the trap, then anchor the correct pattern to a safe model.",
                        icon: GrammarTopicLesson.repair.icon,
                        tint: GrammarTopicLesson.repair.tint
                    )
                    LessonProgressBar(progress: topic.commonMistakes.isEmpty ? 0 : Double(revealed.count) / Double(topic.commonMistakes.count))

                    ForEach(Array(topic.commonMistakes.enumerated()), id: \.offset) { index, mistake in
                        VStack(alignment: .leading, spacing: 10) {
                            Label {
                                TeachingText(english: mistake)
                            } icon: {
                                Image(systemName: "exclamationmark.triangle.fill")
                            }
                                .font(.headline)
                                .foregroundStyle(CoachTheme.incorrect)
                            if revealed.contains(index), !topic.examples.isEmpty {
                                let model = topic.examples[index % topic.examples.count]
                                VStack(alignment: .leading, spacing: 5) {
                                    TeachingLabel(english: "Safe model", systemImage: "checkmark.circle.fill")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(CoachTheme.correct)
                                    HStack(alignment: .top, spacing: 8) {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(model.german).font(.headline)
                                            TeachingText(english: model.english).font(.caption).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        GermanSpeechButton(text: model.german, label: "Play correct model")
                                        GrammarXRayButton(sentence: model.german, topic: topic)
                                    }
                                    TeachingText(english: GrammarVisualCatalog.spec(for: topic.id).caption)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(11)
                                .background(CoachTheme.softMint, in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
                            } else {
                                Button {
                                    CoachFeedback.selection()
                                    withAnimation(CoachMotion.spring) { _ = revealed.insert(index) }
                                } label: {
                                    TeachingLabel(english: "Reveal the repair", systemImage: "wrench.adjustable.fill")
                                }
                                .buttonStyle(SecondaryCoachButton(tint: GrammarTopicLesson.repair.tint))
                            }
                        }
                        if index + 1 < topic.commonMistakes.count { Divider() }
                    }
                }
            }

            Button {
                isComplete = true
                onComplete()
            } label: {
                TeachingLabel(english: "Complete repair lesson", systemImage: "checkmark")
            }
            .buttonStyle(PrimaryCoachButton(tint: GrammarTopicLesson.repair.tint))
            .disabled(revealed.count < topic.commonMistakes.count)

            if isComplete {
                TopicCompletionView(
                    title: "Mistake radar switched on",
                    message: "You repaired \(topic.commonMistakes.count) common traps. Now build accuracy in practice.",
                    score: nil,
                    tint: GrammarTopicLesson.repair.tint,
                    restart: nil
                )
            }
        }
        .coachReveal()
    }
}

private struct GrammarPracticeLesson: View {
    let topic: GrammarTopic
    let onComplete: (Double) -> Void

    @State private var index = 0
    @State private var response = ""
    @State private var showsAnswer = false
    @State private var correctCount = 0
    @State private var isComplete = false

    private var question: PracticeQuestion? {
        topic.practice.indices.contains(index) ? topic.practice[index] : nil
    }

    private var answerIsCorrect: Bool {
        guard let question else { return false }
        return normalize(response) == normalize(question.answer)
    }

    var body: some View {
        VStack(spacing: 14) {
            CoachCard(tint: GrammarTopicLesson.practice.tint) {
                VStack(alignment: .leading, spacing: 16) {
                    TopicLessonHeading(
                        title: "Accuracy challenge",
                        subtitle: "Work through every exercise and use the feedback immediately.",
                        icon: GrammarTopicLesson.practice.icon,
                        tint: GrammarTopicLesson.practice.tint
                    )

                    if let question {
                        LessonProgressBar(progress: Double(index + 1) / Double(topic.practice.count))
                        TeachingText(english: "Question \(index + 1) of \(topic.practice.count)")
                            .font(.caption.weight(.semibold).monospacedDigit())
                            .foregroundStyle(.secondary)
                        TeachingText(
                            english: question.prompt,
                            protectedGerman: GermanContentProtection.exercisePrompt(
                                question.prompt,
                                answer: question.answer
                            )
                        )
                            .font(.title3.weight(.semibold))
                        TeachingTextField(prompt: "Type your answer", text: $response, axis: .vertical)
                            .textFieldStyle(CoachTextFieldStyle(tint: GrammarTopicLesson.practice.tint))
                            .textInputAutocapitalization(.sentences)
                            .germanKeyboardAccessory(text: $response)
                            .disabled(showsAnswer)

                        if showsAnswer {
                            CoachFeedbackPanel(
                                isCorrect: answerIsCorrect,
                                title: answerIsCorrect ? "Exactly right" : "Learn from this one",
                                message: answerIsCorrect ? question.explanation : "Answer: \(question.answer) · \(question.explanation)",
                                protectedGerman: [question.answer]
                            )
                            HStack(spacing: 10) {
                                GermanSpeechButton(text: question.answer, label: "Play correct answer")
                                TeachingText(english: "Say the complete answer once before continuing.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Button { advance() } label: {
                                TeachingLabel(
                                    english: index + 1 < topic.practice.count ? "Next question" : "Finish challenge",
                                    systemImage: "arrow.right"
                                )
                            }
                            .buttonStyle(PrimaryCoachButton(tint: GrammarTopicLesson.practice.tint))
                        } else {
                            TeachingButton("Check answer") { check() }
                                .buttonStyle(PrimaryCoachButton(tint: GrammarTopicLesson.practice.tint))
                                .disabled(response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
            }

            if isComplete {
                TopicCompletionView(
                    title: "Accuracy challenge complete",
                    message: "You solved \(correctCount) of \(topic.practice.count) on the first try. Practice again to improve your score.",
                    score: topic.practice.isEmpty ? 0 : Double(correctCount) / Double(topic.practice.count),
                    tint: GrammarTopicLesson.practice.tint
                ) {
                    index = 0
                    response = ""
                    showsAnswer = false
                    correctCount = 0
                    isComplete = false
                }
            }
        }
        .coachReveal()
    }

    private func check() {
        showsAnswer = true
        if answerIsCorrect {
            correctCount += 1
            CoachFeedback.success()
        } else {
            CoachFeedback.warning()
        }
    }

    private func advance() {
        if index + 1 < topic.practice.count {
            withAnimation(CoachMotion.spring) {
                index += 1
                response = ""
                showsAnswer = false
            }
        } else {
            isComplete = true
            onComplete(topic.practice.isEmpty ? 0 : Double(correctCount) / Double(topic.practice.count))
        }
    }
}

private struct GrammarCreateLesson: View {
    let topic: GrammarTopic
    let onComplete: () -> Void

    @State private var response = ""
    @State private var checked: Set<Int> = []
    @State private var isComplete = false

    private var model: ExampleSentence? { topic.examples.first }
    private var checklist: [String] {
        [
            "Follow the pattern shown in the visual explanation.",
            "Use a new person, place, time, or opinion of your own.",
            "Read the sentence aloud and check the verb position."
        ]
    }

    var body: some View {
        VStack(spacing: 14) {
            CoachCard(tint: GrammarTopicLesson.create.tint) {
                VStack(alignment: .leading, spacing: 16) {
                    TopicLessonHeading(
                        title: "Create with your own voice",
                        subtitle: "Move beyond recognition by making the pattern personally meaningful.",
                        icon: GrammarTopicLesson.create.icon,
                        tint: GrammarTopicLesson.create.tint
                    )

                    if let model {
                        VStack(alignment: .leading, spacing: 6) {
                            TeachingText(english: "MODEL")
                                .font(.caption2.weight(.heavy))
                                .foregroundStyle(GrammarTopicLesson.create.tint)
                            HStack(alignment: .top, spacing: 8) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(model.german).font(.headline)
                                    TeachingText(english: model.english).font(.callout).foregroundStyle(.secondary)
                                }
                                Spacer()
                                GermanSpeechButton(text: model.german, label: "Play model sentence")
                                GrammarXRayButton(sentence: model.german, topic: topic)
                            }
                        }
                        .padding(12)
                        .background(GrammarTopicLesson.create.tint.opacity(0.09), in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
                    }

                    TeachingText(english: "Write a new sentence about your real life using the same grammar pattern.")
                        .font(.title3.weight(.semibold))
                    CoachTextEditor(
                        placeholder: "Write one personal German sentence...",
                        text: $response,
                        minHeight: 120,
                        tint: GrammarTopicLesson.create.tint
                    )

                    VStack(alignment: .leading, spacing: 9) {
                        TeachingText(english: "Self-check")
                            .font(.headline)
                        ForEach(Array(checklist.enumerated()), id: \.offset) { index, item in
                            Button {
                                CoachFeedback.selection()
                                if checked.contains(index) { checked.remove(index) } else { checked.insert(index) }
                            } label: {
                                Label {
                                    TeachingText(english: item)
                                } icon: {
                                    Image(systemName: checked.contains(index) ? "checkmark.circle.fill" : "circle")
                                }
                                    .font(.callout)
                                    .foregroundStyle(checked.contains(index) ? CoachTheme.correct : .primary)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }

                    if !response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button {
                            GermanSpeechService.shared.speak(response)
                        } label: {
                            TeachingLabel(english: "Hear my sentence", systemImage: "speaker.wave.2.fill")
                        }
                        .buttonStyle(SecondaryCoachButton(tint: CoachTheme.listening))
                    }

                    Button {
                        isComplete = true
                        onComplete()
                    } label: {
                        TeachingLabel(english: "Complete creative mission", systemImage: "sparkles")
                    }
                    .buttonStyle(PrimaryCoachButton(tint: GrammarTopicLesson.create.tint))
                    .disabled(response.trimmingCharacters(in: .whitespacesAndNewlines).count < 8 || checked.count < checklist.count)
                }
            }

            if isComplete {
                TopicCompletionView(
                    title: "You made the grammar yours",
                    message: "Personal sentences are easier to remember because they connect the pattern to your own life.",
                    score: nil,
                    tint: GrammarTopicLesson.create.tint,
                    restart: nil
                )
            }
        }
        .coachReveal()
    }
}

private struct ElaborationPoint: View {
    let number: Int
    let title: String
    let text: String
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption.weight(.heavy).monospacedDigit())
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(tint, in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                TeachingText(english: title).font(.headline)
                TeachingText(english: text)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct TopicCompletionView: View {
    let title: String
    let message: String
    let score: Double?
    let tint: Color
    let restart: (() -> Void)?

    var body: some View {
        CoachCard(tint: tint) {
            VStack(spacing: 10) {
                CoachCelebrationMark()
                TeachingText(english: title)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                if let score {
                    Text("\(Int(score * 100))%")
                        .font(.system(.title, design: .rounded, weight: .bold).monospacedDigit())
                        .foregroundStyle(tint)
                }
                TeachingText(english: message)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                if let restart {
                    Button(action: restart) {
                        TeachingLabel(english: "Practice again", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(SecondaryCoachButton(tint: tint))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .coachReveal()
    }
}

private func displayGerman(_ word: VocabWord) -> String {
    guard let article = word.article, !article.isEmpty else { return word.german }
    return word.german.lowercased().hasPrefix(article.lowercased() + " ")
        ? word.german
        : "\(article) \(word.german)"
}

private func answerChoices(for index: Int, in words: [VocabWord]) -> [String] {
    guard words.indices.contains(index) else { return [] }
    let answer = words[index].english
    let following = Array(words.dropFirst(index + 1)) + Array(words.prefix(index))
    var uniqueDistractors: [String] = []
    for candidate in following.map(\.english) where candidate != answer && !uniqueDistractors.contains(candidate) {
        uniqueDistractors.append(candidate)
        if uniqueDistractors.count == 3 { break }
    }
    var choices = [answer] + uniqueDistractors
    guard choices.count > 1 else { return choices }
    let rotation = index % choices.count
    choices = Array(choices[rotation...]) + Array(choices[..<rotation])
    return choices
}

private func normalize(_ value: String) -> String {
    value
        .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "de_DE"))
        .lowercased()
        .trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))
        .split(whereSeparator: \.isWhitespace)
        .joined(separator: " ")
}
