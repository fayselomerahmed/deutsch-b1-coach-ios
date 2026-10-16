import SwiftData
import SwiftUI

struct VocabularyFlashcardsView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VocabWord.german) private var allWords: [VocabWord]
    @Query private var reviewItems: [ReviewItem]
    @State private var selectedLevel: CEFRLevel
    @State private var selectedTheme = "All"
    @State private var selectedCategory: VocabularyStudyCategory
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var dragOffset: CGSize = .zero
    @State private var lastAction: VocabularyCardUndoState?
    @State private var words: [VocabWord] = []
    @State private var reviewLookup: [String: ReviewItem] = [:]
    @State private var premium = PremiumAccessService.shared
    @State private var showsPremium = false

    init(
        level: CEFRLevel? = nil,
        theme: String? = nil,
        category: VocabularyStudyCategory? = nil
    ) {
        let lastSelection = VocabularyDeckProgressStore.lastSelection()
        let initialLevel = level ?? lastSelection.level
        let initialCategory = category ?? (level == nil ? lastSelection.category : .learning)
        let resumesTheme = theme == nil
            && lastSelection.level == initialLevel
            && lastSelection.category == initialCategory
        _selectedLevel = State(initialValue: initialLevel)
        _selectedTheme = State(initialValue: theme ?? (resumesTheme ? lastSelection.theme : "All"))
        _selectedCategory = State(initialValue: initialCategory)
    }

    private var themes: [String] {
        let available = Set(allWords.filter { $0.level == selectedLevel.rawValue }.map(\.theme))
        return ["All"] + CurriculumProgression.orderedVocabularyThemes(level: selectedLevel, available: available)
    }

    private var currentWord: VocabWord? {
        words.indices.contains(currentIndex) ? words[currentIndex] : words.first
    }

    var body: some View {
        VStack(spacing: 0) {
            controls
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)

            if let word = currentWord {
                ViewThatFits(in: .vertical) {
                    flashcardStudyContent(word)
                    ScrollView {
                        flashcardStudyContent(word)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }
            } else {
                CoachCard {
                    CoachEmptyState(
                        icon: selectedCategory.icon,
                        title: emptyStateTitle,
                        message: emptyStateMessage,
                        tint: categoryTint
                    )
                }
                .padding()
            }
            Spacer(minLength: 0)
        }
        .teachingNavigationTitle("Vocabulary Cards")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if lastAction != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        undoLastAction()
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    .teachingAccessibilityLabel("Undo last vocabulary action")
                }
            }
        }
        .coachBackground()
        .sheet(isPresented: $showsPremium) { PremiumView() }
        .onAppear {
            if !PremiumAccessPolicy.canOpenLevel(selectedLevel, isPremium: premium.isPremium) {
                selectedLevel = .a1
            }
            restoreDeck()
        }
        .onChange(of: selectedLevel) { _, newLevel in
            guard PremiumAccessPolicy.canOpenLevel(newLevel, isPremium: premium.isPremium) else {
                selectedLevel = .a1
                showsPremium = true
                return
            }
            selectedTheme = "All"
            restoreDeck()
        }
        .onChange(of: selectedTheme) { _, _ in restoreDeck() }
        .onChange(of: selectedCategory) { _, _ in restoreDeck() }
        .onChange(of: allWords.count) { _, _ in restoreDeck() }
        .onChange(of: reviewItems.count) { _, _ in restoreDeck() }
    }

    private func flashcardStudyContent(_ word: VocabWord) -> some View {
        VStack(spacing: 12) {
            CoachFlipCard(isFlipped: isFlipped) {
                vocabularyFace(word, revealed: false)
            } back: {
                vocabularyFace(word, revealed: true)
            }
            .id(word.id)
            .onTapGesture {
                CoachFeedback.selection()
                isFlipped.toggle()
            }
            .accessibilityAction(named: "Flip card") {
                CoachFeedback.selection()
                isFlipped.toggle()
            }
            .accessibilityAction(named: "Previous card") {
                CoachFeedback.selection()
                move(by: -1)
            }
            .accessibilityAction(named: "Next card") {
                CoachFeedback.selection()
                move(by: 1)
            }
            .flashcardNavigationSwipe(dragOffset: $dragOffset, onNavigate: move)

            statusControls(word)

            ZStack {
                if isFlipped {
                    VStack(spacing: 8) {
                        LearningMomentPrompt(moment: .understand)
                        gradeControls(word)
                    }
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else {
                    LearningMomentPrompt(moment: .recall)
                        .transition(.opacity)
                }
            }
            .frame(minHeight: 68)
            .animation(reduceMotion ? nil : CoachMotion.quick, value: isFlipped)

            HStack(spacing: 12) {
                Button {
                    move(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(CoachIconButtonStyle(tint: CoachTheme.primary))
                .teachingAccessibilityLabel("Previous card")

                Spacer()
                Text("\(min(currentIndex + 1, words.count)) of \(words.count)")
                    .font(.body.monospacedDigit().weight(.semibold))
                Spacer()

                Button {
                    move(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(CoachIconButtonStyle(tint: CoachTheme.primary))
                .teachingAccessibilityLabel("Next card")
            }

            LessonProgressBar(
                progress: Double(min(currentIndex + 1, words.count)) / Double(max(words.count, 1))
            )
            .teachingAccessibilityLabel("Card progress")
            .teachingAccessibilityValue("\(min(currentIndex + 1, words.count)) of \(words.count)")
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
        .coachReveal(index: 1)
    }

    private var controls: some View {
        VStack(spacing: 10) {
            Picker(selection: $selectedLevel) {
                ForEach(CEFRLevel.allCases) { Text($0.rawValue).tag($0) }
            } label: {
                TeachingText(english: "Level")
            }
            .pickerStyle(.segmented)

            HStack(spacing: 14) {
                Menu {
                    ForEach(VocabularyStudyCategory.allCases) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            TeachingLabel(
                                english: category.title,
                                systemImage: category == selectedCategory ? "checkmark" : category.icon
                            )
                        }
                    }
                } label: {
                    TeachingLabel(english: selectedCategory.title, systemImage: selectedCategory.icon)
                        .foregroundStyle(categoryTint)
                }
                .teachingAccessibilityLabel("Card deck: \(selectedCategory.title)")

                Menu {
                    ForEach(themes, id: \.self) { theme in
                        Button {
                            selectedTheme = theme
                        } label: {
                            Label {
                                if theme == "All" {
                                    TeachingText(english: theme)
                                } else {
                                    Text(theme)
                                }
                            } icon: {
                                Image(systemName: theme == selectedTheme ? "checkmark" : "circle")
                            }
                        }
                    }
                } label: {
                    Label {
                        if selectedTheme == "All" {
                            TeachingText(english: selectedTheme)
                        } else {
                            Text(selectedTheme)
                        }
                    } icon: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                        .lineLimit(1)
                }

                Spacer()
                TeachingText(english: "\(words.count) cards")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            .font(.callout.weight(.semibold))
        }
    }

    private func vocabularyFace(_ word: VocabWord, revealed: Bool) -> some View {
        VStack(spacing: 15) {
            HStack {
                SkillChip(title: word.level, color: CoachTheme.primary)
                SkillChip(title: word.theme, color: CoachTheme.listening, translatesTitle: false)
                Spacer()
                if revealed || word.article?.isEmpty != false {
                    Button {
                        GermanSpeechService.shared.speak(
                            revealed ? word.exampleSentence : word.ttsText,
                            style: revealed ? .sentence : .word
                        )
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(CoachIconButtonStyle(tint: CoachTheme.listening))
                    .teachingAccessibilityLabel(revealed ? "Play example sentence" : "Play pronunciation")
                }
            }

            Spacer(minLength: 0)

            if !revealed {
                VocabularyMemoryPicture(
                    word: word,
                    featured: !dynamicTypeSize.isAccessibilitySize
                )
            }

            if revealed {
                TeachingText(english: word.english)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(CoachTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            } else if word.article?.isEmpty == false {
                GermanNounForms(word: word, prominent: true)
            } else {
                GermanVocabularyTitle(
                    word: word,
                    font: .system(.largeTitle, design: .rounded, weight: .bold),
                    alignment: .center
                )
                .foregroundStyle(CoachTheme.ink)
            }

            if revealed {
                Divider()
                VocabularyVisualExplanation(
                    word: word,
                    compact: true,
                    showsIdentity: false
                )
            } else {
                TeachingText(english: "Recall the picture, article, singular, and plural.")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(22)
        .frame(
            maxWidth: .infinity,
            minHeight: dynamicTypeSize.isAccessibilitySize ? 360 : 390
        )
        .background(
            LinearGradient(
                colors: [
                    CoachTheme.elevatedSurface,
                    CoachTheme.listening.opacity(0.12),
                    CoachTheme.rewardGlow.opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
        )
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(CoachTheme.listening.opacity(0.22)))
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
        .teachingAccessibilityHint("Tap to flip. Swipe left for next or right for previous.")
    }

    private func statusControls(_ word: VocabWord) -> some View {
        let item = reviewItem(for: word)
        return HStack(spacing: 10) {
            vocabularyStatusButton(
                "Memorized",
                icon: item?.isMemorized == true ? "checkmark.square.fill" : "square",
                isSelected: item?.isMemorized == true,
                tint: CoachTheme.correct
            ) {
                toggleMemorized(word)
            }

            vocabularyStatusButton(
                "Marked",
                icon: item?.isMarked == true ? "bookmark.fill" : "bookmark",
                isSelected: item?.isMarked == true,
                tint: CoachTheme.accent
            ) {
                toggleMarked(word)
            }
        }
    }

    private func vocabularyStatusButton(
        _ title: String,
        icon: String,
        isSelected: Bool,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            TeachingLabel(english: title, systemImage: icon)
                .font(.callout.weight(.semibold))
                .foregroundStyle(isSelected ? tint : CoachTheme.ink)
                .frame(maxWidth: .infinity, minHeight: 42)
        }
        .buttonStyle(.plain)
        .background(
            LinearGradient(
                colors: [CoachTheme.elevatedSurface.opacity(0.90), tint.opacity(isSelected ? 0.20 : 0.07)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
        )
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(tint.opacity(isSelected ? 0.34 : 0.16)))
        .teachingAccessibilityValue(isSelected ? "Selected" : "Not selected")
    }

    private func gradeControls(_ word: VocabWord) -> some View {
        HStack(spacing: 8) {
            gradeButton("Again", icon: "arrow.counterclockwise", quality: 1, color: CoachTheme.incorrect, word: word)
            gradeButton("Hard", icon: "bookmark.fill", quality: 3, color: CoachTheme.accent, word: word)
            gradeButton("Good", icon: "checkmark", quality: 4, color: CoachTheme.primary, word: word)
            gradeButton("Easy", icon: "bolt.fill", quality: 5, color: CoachTheme.correct, word: word)
        }
    }

    private func gradeButton(
        _ title: String,
        icon: String,
        quality: Int,
        color: Color,
        word: VocabWord
    ) -> some View {
        Button {
            grade(word, quality: quality)
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon)
                TeachingText(english: title).font(.footnote.weight(.semibold))
            }
            .frame(maxWidth: .infinity, minHeight: 48)
        }
        .buttonStyle(SecondaryCoachButton(tint: color))
    }

    private func grade(_ word: VocabWord, quality: Int) {
        lastAction = nil
        if quality >= 3 {
            CoachFeedback.success()
        } else {
            CoachFeedback.warning()
        }
        let item = ensureReviewItem(for: word)
        if quality <= 3 {
            item.isMarked = true
        }
        ReviewViewModel().applyGrade(quality, to: item)
        item.isActive = true
        try? ProgressService().recordReview(
            quality: quality,
            item: item,
            level: CEFRLevel(rawValue: word.level) ?? .a1,
            modelContext: modelContext
        )
        try? modelContext.save()
        move(by: 1)
    }

    private func move(by offset: Int) {
        guard !words.isEmpty else { return }
        dragOffset = .zero
        let update = {
            currentIndex = (currentIndex + offset + words.count) % words.count
            isFlipped = false
        }
        if reduceMotion {
            update()
        } else {
            withAnimation(CoachMotion.quick) {
                update()
            }
        }
        persistCurrentPosition()
        preloadNearbyCards()
    }

    private func restoreDeck() {
        rebuildReviewLookup()
        if !themes.contains(selectedTheme) {
            selectedTheme = "All"
        }

        rebuildDeck()
        if let lastWordID = VocabularyDeckProgressStore.lastWordID(
            level: selectedLevel,
            theme: selectedTheme,
            category: selectedCategory
        ), let savedIndex = words.firstIndex(where: { $0.id == lastWordID }) {
            currentIndex = savedIndex
        } else {
            currentIndex = 0
        }
        isFlipped = false
        dragOffset = .zero
        lastAction = nil
        VocabularyDeckProgressStore.saveSelection(
            level: selectedLevel,
            theme: selectedTheme,
            category: selectedCategory
        )
        persistCurrentPosition()
        preloadNearbyCards()
    }

    private func persistCurrentPosition() {
        guard let word = currentWord else { return }
        VocabularyDeckProgressStore.save(
            wordID: word.id,
            level: selectedLevel,
            theme: selectedTheme,
            category: selectedCategory
        )
    }

    private func reviewItem(for word: VocabWord) -> ReviewItem? {
        reviewLookup[word.id]
    }

    private func ensureReviewItem(for word: VocabWord) -> ReviewItem {
        if let item = reviewItem(for: word) {
            return item
        }
        let item = ReviewItem(id: "review-\(word.id)", contentId: word.id, kind: .vocabulary)
        modelContext.insert(item)
        reviewLookup[word.id] = item
        return item
    }

    private func isIncludedInSelectedCategory(_ word: VocabWord) -> Bool {
        let item = reviewItem(for: word)
        switch selectedCategory {
        case .learning:
            return item?.isMemorized != true
        case .marked:
            return item?.isMarked == true
        case .memorized:
            return item?.isMemorized == true
        }
    }

    private func toggleMemorized(_ word: VocabWord) {
        let item = ensureReviewItem(for: word)
        rememberState(word: word, item: item)
        item.isMemorized.toggle()
        item.isActive = item.isActive || item.isMemorized
        if item.isMemorized {
            CoachFeedback.success()
        } else {
            CoachFeedback.selection()
        }
        saveStatusAndNormalizeDeck()
    }

    private func toggleMarked(_ word: VocabWord) {
        let item = ensureReviewItem(for: word)
        rememberState(word: word, item: item)
        item.isMarked.toggle()
        CoachFeedback.selection()
        saveStatusAndNormalizeDeck()
    }

    private func saveStatusAndNormalizeDeck() {
        try? modelContext.save()
        let previousIndex = currentIndex
        rebuildDeck()
        let update = {
            currentIndex = words.isEmpty ? 0 : min(previousIndex, words.count - 1)
            isFlipped = false
        }
        if reduceMotion {
            update()
        } else {
            withAnimation(CoachMotion.quick) {
                update()
            }
        }
        persistCurrentPosition()
        preloadNearbyCards()
    }

    private func rememberState(word: VocabWord, item: ReviewItem) {
        lastAction = VocabularyCardUndoState(
            wordID: word.id,
            wasMemorized: item.isMemorized,
            wasMarked: item.isMarked
        )
    }

    private func undoLastAction() {
        guard let action = lastAction,
              let word = allWords.first(where: { $0.id == action.wordID }) else { return }
        let item = ensureReviewItem(for: word)
        item.isMemorized = action.wasMemorized
        item.isMarked = action.wasMarked
        try? modelContext.save()
        rebuildDeck()
        currentIndex = words.firstIndex(where: { $0.id == word.id }) ?? min(currentIndex, max(words.count - 1, 0))
        isFlipped = false
        dragOffset = .zero
        lastAction = nil
        persistCurrentPosition()
        preloadNearbyCards()
        CoachFeedback.selection()
    }

    private func rebuildReviewLookup() {
        reviewLookup = Dictionary(
            reviewItems
                .filter { $0.kind == ReviewItemKind.vocabulary.rawValue }
                .map { ($0.contentId, $0) },
            uniquingKeysWith: { first, _ in first }
        )
    }

    private func rebuildDeck() {
        words = allWords.filter {
            $0.level == selectedLevel.rawValue
                && (selectedTheme == "All" || $0.theme == selectedTheme)
                && isIncludedInSelectedCategory($0)
        }
    }

    private func preloadNearbyCards() {
        guard !words.isEmpty else { return }
        let indexes = [
            currentIndex,
            (currentIndex + 1) % words.count,
            (currentIndex - 1 + words.count) % words.count
        ]
        VocabularyObjectAtlas.preload(
            englishWords: indexes.map { words[$0].english }
        )
    }

    private var categoryTint: Color {
        switch selectedCategory {
        case .learning: CoachTheme.listening
        case .marked: CoachTheme.accent
        case .memorized: CoachTheme.correct
        }
    }

    private var emptyStateTitle: String {
        switch selectedCategory {
        case .learning: "Learning deck complete"
        case .marked: "No marked words"
        case .memorized: "No memorized words yet"
        }
    }

    private var emptyStateMessage: String {
        switch selectedCategory {
        case .learning:
            "Every word in this selection is checked as memorized."
        case .marked:
            "Use the bookmark on a difficult card, or choose Hard after revealing it."
        case .memorized:
            "Use the Memorized checkbox on any card when the word feels secure."
        }
    }

    private func displayGerman(_ word: VocabWord) -> String {
        if let article = word.article, !word.german.hasPrefix(article + " ") {
            return "\(article) \(word.german)"
        }
        return word.german
    }

}

private struct VocabularyCardUndoState {
    let wordID: String
    let wasMemorized: Bool
    let wasMarked: Bool
}

struct GrammarFlashcardsView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GrammarTopic.order) private var allTopics: [GrammarTopic]
    @Query private var reviewItems: [ReviewItem]
    @State private var selectedLevel: CEFRLevel
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var dragOffset: CGSize = .zero
    @State private var showsStructurePractice = false
    @State private var premium = PremiumAccessService.shared
    @State private var showsPremium = false

    init(level: CEFRLevel = .a1) {
        _selectedLevel = State(initialValue: level)
    }

    private var topics: [GrammarTopic] {
        allTopics.filter { $0.level == selectedLevel.rawValue }
    }

    private var currentTopic: GrammarTopic? {
        topics.indices.contains(currentIndex) ? topics[currentIndex] : topics.first
    }

    var body: some View {
        VStack(spacing: 16) {
            Picker(selection: $selectedLevel) {
                ForEach(CEFRLevel.allCases) { Text($0.rawValue).tag($0) }
            } label: {
                TeachingText(english: "Level")
            }
            .pickerStyle(.segmented)

            if let topic = currentTopic {
                CoachFlipCard(isFlipped: isFlipped) {
                    grammarFace(topic, revealed: false)
                } back: {
                    grammarFace(topic, revealed: true)
                }
                .id(topic.id)
                .onTapGesture {
                    CoachFeedback.selection()
                    isFlipped.toggle()
                }
                .accessibilityAction(named: "Flip card") {
                    CoachFeedback.selection()
                    isFlipped.toggle()
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

                VStack(spacing: 9) {
                    if isFlipped {
                        LearningMomentPrompt(moment: .understand)

                        Button {
                            CoachFeedback.selection()
                            showsStructurePractice = true
                        } label: {
                            HStack {
                                TeachingLabel(english: "Build the sentence", systemImage: "rectangle.3.group.fill")
                                Spacer()
                                if !premium.isPremium {
                                    PremiumLockBadge()
                                }
                            }
                        }
                        .buttonStyle(PrimaryCoachButton(tint: CoachTheme.accent))

                        HStack(spacing: 8) {
                            grammarGrade("Again", quality: 1, topic: topic)
                            grammarGrade("Hard", quality: 3, topic: topic)
                            grammarGrade("Good", quality: 4, topic: topic)
                            grammarGrade("Easy", quality: 5, topic: topic)
                        }
                    } else {
                        LearningMomentPrompt(moment: .recall)
                    }
                }
                .frame(minHeight: 112)
                .animation(reduceMotion ? nil : CoachMotion.quick, value: isFlipped)

                HStack {
                    Button { move(by: -1) } label: { Image(systemName: "chevron.left").frame(width: 44, height: 44) }
                    Spacer()
                    Text("\(currentIndex + 1) of \(topics.count)")
                        .font(.callout.monospacedDigit().weight(.semibold))
                    Spacer()
                    Button { move(by: 1) } label: { Image(systemName: "chevron.right").frame(width: 44, height: 44) }
                }
                .buttonStyle(CoachIconButtonStyle(tint: CoachTheme.primary))
            } else {
                CoachCard {
                    CoachEmptyState(
                        icon: "text.book.closed.fill",
                        title: "No grammar cards",
                        message: "Choose another level to continue your grammar practice."
                    )
                }
            }
            Spacer()
        }
        .padding()
        .teachingNavigationTitle("Grammar Cards")
        .navigationBarTitleDisplayMode(.inline)
        .coachBackground()
        .onAppear {
            if !PremiumAccessPolicy.canOpenLevel(selectedLevel, isPremium: premium.isPremium) {
                selectedLevel = .a1
            }
        }
        .onChange(of: selectedLevel) { _, newLevel in
            guard PremiumAccessPolicy.canOpenLevel(newLevel, isPremium: premium.isPremium) else {
                selectedLevel = .a1
                showsPremium = true
                return
            }
            currentIndex = 0
            isFlipped = false
            dragOffset = .zero
        }
        .sheet(isPresented: $showsPremium) { PremiumView() }
        .sheet(isPresented: $showsStructurePractice) {
            if let topic = currentTopic {
                GrammarStructurePracticeSheet(topic: topic)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private func grammarFace(_ topic: GrammarTopic, revealed: Bool) -> some View {
        VStack(spacing: 18) {
            HStack {
                SkillChip(title: topic.level, color: CoachTheme.primary)
                Spacer()
                Image(systemName: revealed ? "text.book.closed.fill" : "questionmark.circle.fill")
                    .foregroundStyle(CoachTheme.accent)
            }
            Spacer()
            TeachingText(english: topic.title)
                .font(.system(revealed ? .title2 : .largeTitle, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.72)
            if revealed {
                GrammarVisualExplanation(topic: topic, compact: true)
                if let example = topic.examples.first {
                    Divider()
                    HStack(spacing: 8) {
                        Text(example.german).font(.title3.weight(.semibold))
                        Spacer()
                        GermanSpeechButton(text: example.german, label: "Play grammar example")
                        GrammarXRayButton(sentence: example.german, topic: topic)
                    }
                    TeachingText(english: example.english).foregroundStyle(.secondary)
                }
            } else {
                TeachingText(english: "Explain the rule and produce one example")
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(22)
        .frame(maxWidth: .infinity, minHeight: 390)
        .background(CoachTheme.surface, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(CoachTheme.primary.opacity(0.18)))
    }

    private func grammarGrade(_ title: String, quality: Int, topic: GrammarTopic) -> some View {
        Button {
            if quality >= 3 {
                CoachFeedback.success()
            } else {
                CoachFeedback.warning()
            }
            if let item = reviewItems.first(where: { $0.contentId == topic.id }) {
                ReviewViewModel().applyGrade(quality, to: item)
                item.isActive = true
                try? ProgressService().recordReview(
                    quality: quality,
                    item: item,
                    level: topic.cefrLevel,
                    modelContext: modelContext
                )
            }
            move(by: 1)
        } label: {
            TeachingText(english: title)
        }
        .buttonStyle(SecondaryCoachButton(
            tint: quality == 1 ? CoachTheme.incorrect : quality == 3 ? CoachTheme.accent : quality == 4 ? CoachTheme.primary : CoachTheme.correct
        ))
        .frame(maxWidth: .infinity)
    }

    private func move(by offset: Int) {
        guard !topics.isEmpty else { return }
        dragOffset = .zero
        let update = {
            currentIndex = (currentIndex + offset + topics.count) % topics.count
            isFlipped = false
        }
        if reduceMotion {
            update()
        } else {
            withAnimation(CoachMotion.quick) {
                update()
            }
        }
    }
}

enum FlashcardSwipeNavigation {
    static let threshold: CGFloat = 56

    static func indexOffset(for horizontalTranslation: CGFloat, threshold: CGFloat = threshold) -> Int? {
        guard abs(horizontalTranslation) >= threshold else { return nil }
        return horizontalTranslation < 0 ? 1 : -1
    }
}

private struct FlashcardNavigationSwipeModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var dragOffset: CGSize
    let onNavigate: (Int) -> Void

    func body(content: Content) -> some View {
        content
            .overlay {
                FlashcardNavigationCue(horizontalOffset: dragOffset.width)
            }
            .offset(x: dragOffset.width)
            .rotationEffect(.degrees(reduceMotion ? 0 : Double(dragOffset.width / 30)))
            .simultaneousGesture(
                DragGesture(minimumDistance: 12)
                    .onChanged { value in
                        guard abs(value.translation.width) > abs(value.translation.height) else { return }
                        dragOffset = CGSize(
                            width: min(max(value.translation.width, -132), 132),
                            height: 0
                        )
                    }
                    .onEnded { value in
                        guard abs(value.translation.width) > abs(value.translation.height) else {
                            resetCardPosition()
                            return
                        }

                        let projectedTranslation = abs(value.predictedEndTranslation.width) > abs(value.translation.width)
                            ? value.predictedEndTranslation.width
                            : value.translation.width
                        finishSwipe(horizontalTranslation: projectedTranslation)
                    }
            )
    }

    private func finishSwipe(horizontalTranslation: CGFloat) {
        guard let indexOffset = FlashcardSwipeNavigation.indexOffset(for: horizontalTranslation) else {
            resetCardPosition()
            return
        }

        CoachFeedback.selection()
        guard !reduceMotion else {
            dragOffset = .zero
            onNavigate(indexOffset)
            return
        }

        let exitOffset: CGFloat = horizontalTranslation < 0 ? -420 : 420
        withAnimation(CoachMotion.quick) {
            dragOffset.width = exitOffset
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.09) {
            onNavigate(indexOffset)
            var transaction = Transaction(animation: nil)
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                dragOffset.width = indexOffset > 0 ? 76 : -76
            }
            withAnimation(CoachMotion.navigation) {
                dragOffset = .zero
            }
        }
    }

    private func resetCardPosition() {
        withAnimation(CoachMotion.spring) {
            dragOffset = .zero
        }
    }
}

private struct FlashcardNavigationCue: View {
    let horizontalOffset: CGFloat

    var body: some View {
        if abs(horizontalOffset) > 18 {
            HStack {
                if horizontalOffset > 0 {
                    cue("Previous", icon: "chevron.left.circle.fill", tint: CoachTheme.listening)
                    Spacer()
                } else {
                    Spacer()
                    cue("Next", icon: "chevron.right.circle.fill", tint: CoachTheme.primary)
                }
            }
            .padding(22)
            .frame(maxHeight: .infinity, alignment: .top)
            .allowsHitTesting(false)
            .transition(.opacity)
        }
    }

    private func cue(_ title: String, icon: String, tint: Color) -> some View {
        TeachingLabel(english: title, systemImage: icon)
            .font(.callout.weight(.bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(tint.opacity(0.34)))
            .shadow(color: tint.opacity(0.14), radius: 8, y: 3)
            .opacity(min(abs(horizontalOffset) / FlashcardSwipeNavigation.threshold, 1))
    }
}

extension View {
    func flashcardNavigationSwipe(
        dragOffset: Binding<CGSize>,
        onNavigate: @escaping (Int) -> Void
    ) -> some View {
        modifier(FlashcardNavigationSwipeModifier(dragOffset: dragOffset, onNavigate: onNavigate))
    }
}
