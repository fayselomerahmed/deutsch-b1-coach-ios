import SwiftData
import SwiftUI

struct ReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AppStorage(TeachingLanguage.storageKey) private var teachingLanguageCode = TeachingLanguage.defaultLanguage.rawValue
    @Query(sort: \ReviewItem.dueDate) private var items: [ReviewItem]
    @Query private var vocabWords: [VocabWord]
    @Query private var grammarTopics: [GrammarTopic]
    @State private var currentIndex = 0
    @State private var showsAnswer = false
    @State private var sessionStartCount = 0
    @State private var dragOffset: CGSize = .zero
    @State private var selectedQueue = ReviewQueue.due

    private var teachingLanguage: TeachingLanguage {
        TeachingLanguage.resolve(teachingLanguageCode)
    }

    private var dueItems: [ReviewItem] {
        items.filter { $0.isActive && $0.dueDate <= .now }
    }

    private var displayedItems: [ReviewItem] {
        switch selectedQueue {
        case .due:
            dueItems
        case .marked:
            items.filter { $0.isMarked }
        case .memorized:
            items.filter { $0.isMemorized }
        }
    }

    private var currentItem: ReviewItem? {
        displayedItems.indices.contains(currentIndex) ? displayedItems[currentIndex] : displayedItems.first
    }

    private var reviewedTodayCount: Int {
        items.filter { $0.lastReviewedAt.map(Calendar.current.isDateInToday) == true }.count
    }

    private var sessionProgress: Double {
        if selectedQueue != .due {
            guard !displayedItems.isEmpty else { return 0 }
            return Double(min(currentIndex + 1, displayedItems.count)) / Double(displayedItems.count)
        }
        guard sessionStartCount > 0 else { return dueItems.isEmpty ? 1 : 0 }
        return Double(sessionStartCount - min(dueItems.count, sessionStartCount)) / Double(sessionStartCount)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                reviewQueuePicker
                    .coachReveal(index: 0)

                HStack {
                    CoachMetric(
                        value: "\(dueItems.count)",
                        label: "due",
                        icon: "rectangle.stack.fill",
                        tint: CoachTheme.accent
                    )
                    Spacer()
                    CoachMetric(
                        value: "\(reviewedTodayCount)",
                        label: "today",
                        icon: "checkmark.circle.fill",
                        tint: CoachTheme.correct
                    )
                }
                .coachReveal(index: 1)

                if !displayedItems.isEmpty {
                    LessonProgressBar(progress: sessionProgress)
                        .frame(height: 8)
                        .coachReveal(index: 2)
                }

                if let item = currentItem {
                    CoachFlipCard(isFlipped: showsAnswer) {
                        reviewCard(item, revealed: false)
                    } back: {
                        reviewCard(item, revealed: true)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        CoachFeedback.selection()
                        withAnimation(CoachMotion.spring) {
                            showsAnswer.toggle()
                        }
                    }
                    .accessibilityAction(named: "Flip card") {
                        CoachFeedback.selection()
                        showsAnswer.toggle()
                    }
                    .accessibilityAction(named: "Previous card") {
                        CoachFeedback.selection()
                        move(by: -1)
                    }
                    .accessibilityAction(named: "Next card") {
                        CoachFeedback.selection()
                        move(by: 1)
                    }
                    .teachingAccessibilityHint("Tap to flip. Swipe left for next or right for previous.")
                    .flashcardNavigationSwipe(dragOffset: $dragOffset, onNavigate: move)
                    .coachReveal(index: 3)

                    if showsAnswer {
                        VStack(spacing: 8) {
                            LearningMomentPrompt(moment: .understand)
                            gradeControls(for: item)
                        }
                    } else {
                        LearningMomentPrompt(moment: .recall)
                    }
                } else {
                    CoachCard {
                        CoachEmptyState(
                            icon: "checkmark.seal.fill",
                            title: emptyStateTitle,
                            message: emptyStateMessage,
                            tint: CoachTheme.correct
                        )
                    }
                    .coachReveal(index: 1)

                    VStack(alignment: .leading, spacing: 10) {
                        TeachingText(english: "Keep the momentum")
                            .font(.headline)
                        NavigationLink {
                            VocabularyFlashcardsView()
                        } label: {
                            extraStudyRow(
                                "Vocabulary cards",
                                detail: "Learn a few new words",
                                icon: "rectangle.stack.fill",
                                tint: CoachTheme.accent
                            )
                        }
                        .buttonStyle(CoachCardButtonStyle())
                        NavigationLink {
                            GrammarFlashcardsView()
                        } label: {
                            extraStudyRow(
                                "Grammar cards",
                                detail: "Strengthen a rule",
                                icon: "text.book.closed.fill",
                                tint: CoachTheme.primary
                            )
                        }
                        .buttonStyle(CoachCardButtonStyle())
                    }
                    .coachReveal(index: 2)
                }
                Spacer()
            }
            .padding()
            .navigationTitle(teachingLanguage.interfaceText(.review))
            .teachingLanguageSwitcher()
            .coachBackground()
            .onAppear {
                if sessionStartCount == 0 {
                    sessionStartCount = dueItems.count
                }
            }
            .onChange(of: selectedQueue) { _, _ in
                currentIndex = 0
                showsAnswer = false
                dragOffset = .zero
                CoachFeedback.selection()
            }
        }
    }

    private var reviewQueuePicker: some View {
        Picker(selection: $selectedQueue) {
            ForEach(ReviewQueue.allCases) { queue in
                TeachingText(english: queue.title).tag(queue)
            }
        } label: {
            TeachingText(english: "Review collection")
        }
        .pickerStyle(.segmented)
    }

    private var emptyStateTitle: String {
        switch selectedQueue {
        case .due: "Review complete"
        case .marked: "No marked cards"
        case .memorized: "No memorized cards yet"
        }
    }

    private var emptyStateMessage: String {
        switch selectedQueue {
        case .due:
            reviewedTodayCount == 0
                ? "Nothing is due right now. Learn a few fresh cards or enjoy the clear queue."
                : "Great recall session. Your next cards will return at the right time."
        case .marked:
            "Mark difficult words or grammar cards and they will stay together here."
        case .memorized:
            "Cards you mark as memorized will appear here for confidence checks."
        }
    }

    private func reviewCard(_ item: ReviewItem, revealed: Bool) -> some View {
        VStack(spacing: 18) {
            HStack {
                SkillChip(title: item.kind.capitalized, color: item.kind == ReviewItemKind.grammar.rawValue ? CoachTheme.primary : CoachTheme.accent)
                Spacer()
                TeachingText(english: "Card \(min(currentIndex + 1, displayedItems.count)) of \(displayedItems.count)")
                    .font(.footnote.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if item.kind == ReviewItemKind.grammar.rawValue, let topic = grammarTopic(for: item) {
                TeachingText(english: topic.title)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                if revealed {
                    GrammarVisualExplanation(topic: topic, compact: true)
                    if let example = topic.examples.first {
                        Divider()
                        HStack(spacing: 8) {
                            Text(example.german)
                                .font(.title3.weight(.semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                            GermanSpeechButton(text: example.german, label: "Play grammar example")
                            GrammarXRayButton(sentence: example.german, topic: topic)
                        }
                        TeachingText(english: example.english).foregroundStyle(.secondary)
                    }
                } else {
                    TeachingText(english: "Explain this rule and give an example")
                        .foregroundStyle(.secondary)
                }
            } else if let word = vocabWord(for: item) {
                if revealed {
                    TeachingText(english: word.english)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.center)
                } else {
                    GermanVocabularyTitle(
                        word: word,
                        font: .system(.largeTitle, design: .rounded, weight: .bold),
                        alignment: .center
                    )
                }
                if revealed {
                    Divider()
                    VocabularyVisualExplanation(word: word, compact: true, showsIdentity: false)
                } else {
                    TeachingText(english: "Recall the meaning, article, and plural")
                        .foregroundStyle(.secondary)
                }
            } else {
                CoachEmptyState(
                    icon: "exclamationmark.triangle.fill",
                    title: "Linked content missing",
                    message: "This review item is no longer available in your course."
                )
            }
            Spacer()
        }
        .padding(22)
        .frame(maxWidth: .infinity, minHeight: 350)
        .background(
            CoachTheme.surfaceGradient(tint: tint(for: item), colorScheme: colorScheme),
            in: RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
        )
        .overlay(alignment: .top) {
            Capsule()
                .fill(tint(for: item))
                .frame(width: 64, height: 4)
                .padding(.top, 9)
                .accessibilityHidden(true)
        }
        .overlay(
            RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
                .stroke(tint(for: item).opacity(colorScheme == .dark ? 0.30 : 0.18))
        )
        .shadow(color: tint(for: item).opacity(colorScheme == .dark ? 0.10 : 0.07), radius: 9, y: 4)
    }

    @ViewBuilder private func gradeControls(for item: ReviewItem) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                gradeButtons(for: item)
            }
        } else {
            HStack(spacing: 7) {
                gradeButtons(for: item)
            }
        }
    }

    @ViewBuilder private func gradeButtons(for item: ReviewItem) -> some View {
        gradeButton("Again", icon: "arrow.counterclockwise", quality: 1, tint: CoachTheme.incorrect, item: item)
        gradeButton("Hard", icon: "gauge.with.dots.needle.33percent", quality: 3, tint: CoachTheme.accent, item: item)
        gradeButton("Good", icon: "checkmark", quality: 4, tint: CoachTheme.primary, item: item)
        gradeButton("Easy", icon: "bolt.fill", quality: 5, tint: CoachTheme.correct, item: item)
    }

    private func tint(for item: ReviewItem) -> Color {
        item.kind == ReviewItemKind.grammar.rawValue ? CoachTheme.primary : CoachTheme.accent
    }

    private func gradeButton(
        _ title: String,
        icon: String,
        quality: Int,
        tint: Color,
        item: ReviewItem
    ) -> some View {
        Button {
            grade(item, quality: quality)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.callout.weight(.bold))
                TeachingText(english: title)
                    .font(.footnote.weight(.semibold))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: 48)
        }
            .buttonStyle(SecondaryCoachButton(tint: tint))
    }

    private func grade(_ item: ReviewItem, quality: Int) {
        if item.kind == ReviewItemKind.vocabulary.rawValue, quality <= 3 {
            item.isMarked = true
        }
        ReviewViewModel().applyGrade(quality, to: item)
        let level = vocabWord(for: item).flatMap { CEFRLevel(rawValue: $0.level) }
            ?? grammarTopic(for: item)?.cefrLevel
            ?? .a1
        try? ProgressService().recordReview(quality: quality, item: item, level: level, modelContext: modelContext)
        if quality >= 3 {
            CoachFeedback.success()
        } else {
            CoachFeedback.warning()
        }
        showsAnswer = false
        currentIndex = 0
        dragOffset = .zero
    }

    private func move(by offset: Int) {
        guard !displayedItems.isEmpty else { return }
        dragOffset = .zero
        currentIndex = (currentIndex + offset + displayedItems.count) % displayedItems.count
        showsAnswer = false
    }

    private func extraStudyRow(_ title: String, detail: String, icon: String, tint: Color) -> some View {
        CoachCard(padding: 13) {
            HStack(spacing: 12) {
                CoachIconTile(icon: icon, tint: tint)
                VStack(alignment: .leading, spacing: 2) {
                    TeachingText(english: title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    TeachingText(english: detail)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private func vocabWord(for item: ReviewItem) -> VocabWord? {
        vocabWords.first { $0.id == item.contentId }
    }

    private func grammarTopic(for item: ReviewItem) -> GrammarTopic? {
        grammarTopics.first { $0.id == item.contentId }
    }

    private func displayGerman(_ word: VocabWord) -> String {
        if let article = word.article, !word.german.hasPrefix(article + " ") {
            return "\(article) \(word.german)"
        }
        return word.german
    }
}

private enum ReviewQueue: String, CaseIterable, Identifiable {
    case due
    case marked
    case memorized

    var id: String { rawValue }

    var title: String {
        switch self {
        case .due: "Due"
        case .marked: "Marked"
        case .memorized: "Memorized"
        }
    }
}
