import SwiftData
import SwiftUI

struct VocabularyLibraryView: View {
    @Query(sort: \VocabWord.german) private var allWords: [VocabWord]
    @Query private var activities: [LearningActivity]
    @Query private var reviewItems: [ReviewItem]
    @State private var level: CEFRLevel = .a1
    @State private var searchText = ""
    @State private var premium = PremiumAccessService.shared
    @State private var showsPremium = false

    private var levelWords: [VocabWord] {
        allWords.filter { $0.level == level.rawValue }
    }

    private var themes: [String] {
        CurriculumProgression.orderedVocabularyThemes(
            level: level,
            available: Set(levelWords.map(\.theme))
        )
    }

    private var modules: [CurriculumModuleDescriptor] {
        CurriculumProgression.vocabularyModules(level: level)
    }

    private var completedSourceIDs: Set<String> {
        Set(activities.map(\.sourceId))
    }

    private var nextTheme: String? {
        themes.first { !isThemeComplete($0) }
    }

    private var searchResults: [VocabWord] {
        guard !searchText.isEmpty else { return [] }
        return levelWords.filter {
            $0.german.localizedCaseInsensitiveContains(searchText)
                || $0.english.localizedCaseInsensitiveContains(searchText)
                || $0.theme.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                Picker(selection: $level) {
                    ForEach(CEFRLevel.allCases) { Text($0.rawValue).tag($0) }
                } label: {
                    TeachingText(english: "Level")
                }
                .pickerStyle(.segmented)

                if searchText.isEmpty {
                    libraryHeader
                    continueSection
                    studyActions

                    CoachSectionHeader(
                        title: "Vocabulary modules",
                        subtitle: "Small groups in teaching order"
                    )

                    LazyVGrid(columns: moduleColumns, spacing: 10) {
                        ForEach(Array(modules.enumerated()), id: \.element.id) { index, module in
                            if isModuleUnlocked(module) {
                                NavigationLink {
                                    VocabularyModuleView(level: level, module: module)
                                } label: {
                                    CurriculumModuleTile(
                                        module: module,
                                        tint: moduleTint(index),
                                        progress: moduleProgress(module),
                                        isUnlocked: true,
                                        isComplete: isModuleComplete(module)
                                    )
                                }
                                .buttonStyle(CoachCardButtonStyle())
                            } else {
                                CurriculumModuleTile(
                                    module: module,
                                    tint: moduleTint(index),
                                    progress: moduleProgress(module),
                                    isUnlocked: false,
                                    isComplete: false
                                )
                                .teachingAccessibilityLabel("Module \(module.number), \(module.title), locked")
                            }
                        }
                    }
                } else {
                    CoachSectionHeader(
                        title: "Search results",
                        subtitle: "\(searchResults.count) matches in \(level.rawValue)"
                    )
                    if searchResults.isEmpty {
                        CoachCard {
                            CoachEmptyState(
                                icon: "magnifyingglass",
                                title: "No matching words",
                                message: "Try a German word, an English meaning, or a topic name."
                            )
                        }
                    } else {
                        ForEach(searchResults) { word in
                            VocabularyWordCard(word: word, reviewItem: reviewItem(for: word))
                        }
                    }
                }
            }
            .padding()
        }
        .teachingNavigationTitle("Vocabulary")
        .searchable(text: $searchText, prompt: "Find a word or topic")
        .coachBackground()
        .sheet(isPresented: $showsPremium) { PremiumView() }
        .onChange(of: level) { _, newLevel in
            guard PremiumAccessPolicy.canOpenLevel(newLevel, isPremium: premium.isPremium) else {
                level = .a1
                showsPremium = true
                return
            }
            CoachFeedback.selection()
        }
    }

    private var libraryHeader: some View {
        HStack(spacing: 12) {
            CoachMascot(mood: .welcome, size: 50, animates: false)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                TeachingText(english: "Words you can use")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Text("\(levelWords.count) words · \(memorizedCount) memorized")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    CoachTheme.elevatedSurface.opacity(0.94),
                    CoachTheme.accent.opacity(0.12),
                    CoachTheme.rewardGlow.opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: CoachTheme.cardRadius)
        )
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.cardRadius).stroke(CoachTheme.accent.opacity(0.16)))
    }

    @ViewBuilder private var continueSection: some View {
        if let nextTheme {
            NavigationLink {
                VocabularyTopicDetailView(level: level, theme: nextTheme)
            } label: {
                ContinuePathCard(
                    eyebrow: "CONTINUE VOCABULARY",
                    title: nextTheme,
                    subtitle: "Next topic · \(levelWords.filter { $0.theme == nextTheme }.count) words",
                    icon: themeSymbol(nextTheme),
                    tint: CoachTheme.accent
                )
            }
            .buttonStyle(CoachCardButtonStyle())
        } else {
            CoachCard(tint: CoachTheme.correct) {
                TeachingLabel(english: "All \(level.rawValue) vocabulary modules complete", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(CoachTheme.correct)
            }
        }
    }

    private var studyActions: some View {
        HStack(spacing: 10) {
            NavigationLink {
                VocabularyFlashcardsView(level: level, category: .learning)
            } label: {
                VocabularyQuickActionTile(
                    title: "Cards",
                    icon: "rectangle.stack.fill",
                    tint: CoachTheme.listening
                )
            }
            NavigationLink {
                VocabularyFlashcardsView(level: level, category: .marked)
            } label: {
                VocabularyQuickActionTile(
                    title: "Marked",
                    icon: "bookmark.fill",
                    tint: CoachTheme.accent,
                    count: markedCount
                )
            }
            NavigationLink {
                VocabularyWordBrowserView(level: level)
            } label: {
                VocabularyQuickActionTile(
                    title: "Word list",
                    icon: "character.book.closed.fill",
                    tint: CoachTheme.primary
                )
            }
        }
        .buttonStyle(CoachCardButtonStyle())
    }

    private func isThemeComplete(_ theme: String) -> Bool {
        CurriculumProgression.isVocabularyThemeComplete(
            level: level,
            theme: theme,
            lessonIDs: VocabularyTopicLesson.allCases.map(\.rawValue),
            completedSourceIDs: completedSourceIDs
        )
    }

    private func isModuleComplete(_ module: CurriculumModuleDescriptor) -> Bool {
        module.itemIDs.allSatisfy(isThemeComplete)
    }

    private func isModuleUnlocked(_ module: CurriculumModuleDescriptor) -> Bool {
        isModuleComplete(module) || module.itemIDs.contains(nextTheme ?? "")
    }

    private func moduleProgress(_ module: CurriculumModuleDescriptor) -> String {
        "\(module.itemIDs.filter(isThemeComplete).count)/\(module.itemIDs.count) topics"
    }

    private func themeSymbol(_ theme: String) -> String {
        guard let word = levelWords.first(where: { $0.theme == theme }) else { return "sparkles" }
        return VocabularyVisualCatalog.symbol(theme: theme, german: word.german, english: word.english)
    }

    private var markedCount: Int {
        let wordIDs = Set(levelWords.map(\.id))
        return reviewItems.filter { wordIDs.contains($0.contentId) && $0.isMarked }.count
    }

    private var memorizedCount: Int {
        let wordIDs = Set(levelWords.map(\.id))
        return reviewItems.filter { wordIDs.contains($0.contentId) && $0.isMemorized }.count
    }

    private func reviewItem(for word: VocabWord) -> ReviewItem? {
        reviewItems.first { $0.contentId == word.id && $0.kind == ReviewItemKind.vocabulary.rawValue }
    }
}

private struct VocabularyModuleView: View {
    @Query(sort: \VocabWord.german) private var allWords: [VocabWord]
    @Query private var activities: [LearningActivity]
    let level: CEFRLevel
    let module: CurriculumModuleDescriptor

    private var levelWords: [VocabWord] {
        allWords.filter { $0.level == level.rawValue }
    }

    private var allThemes: [String] {
        CurriculumProgression.orderedVocabularyThemes(
            level: level,
            available: Set(levelWords.map(\.theme))
        )
    }

    private var completedSourceIDs: Set<String> {
        Set(activities.map(\.sourceId))
    }

    private var nextTheme: String? {
        allThemes.first { !isComplete($0) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ModuleHeader(module: module, tint: CoachTheme.accent)

                ForEach(module.itemIDs, id: \.self) { theme in
                    let index = allThemes.firstIndex(of: theme) ?? 0
                    let words = levelWords.filter { $0.theme == theme }
                    if isUnlocked(theme) {
                        NavigationLink {
                            VocabularyTopicDetailView(level: level, theme: theme)
                        } label: {
                            VocabularyTopicPathRow(
                                number: index + 1,
                                theme: theme,
                                words: words,
                                isUnlocked: true,
                                isComplete: isComplete(theme),
                                prerequisite: nil
                            )
                        }
                        .buttonStyle(CoachCardButtonStyle())
                    } else {
                        VocabularyTopicPathRow(
                            number: index + 1,
                            theme: theme,
                            words: words,
                            isUnlocked: false,
                            isComplete: false,
                            prerequisite: index > 0 ? allThemes[index - 1] : nil
                        )
                    }
                }
            }
            .padding()
        }
        .teachingNavigationTitle(module.title)
        .navigationBarTitleDisplayMode(.inline)
        .coachBackground()
    }

    private func isComplete(_ theme: String) -> Bool {
        CurriculumProgression.isVocabularyThemeComplete(
            level: level,
            theme: theme,
            lessonIDs: VocabularyTopicLesson.allCases.map(\.rawValue),
            completedSourceIDs: completedSourceIDs
        )
    }

    private func isUnlocked(_ theme: String) -> Bool {
        isComplete(theme) || nextTheme == theme
    }
}

private struct VocabularyWordBrowserView: View {
    @Query(sort: \VocabWord.german) private var allWords: [VocabWord]
    @Query private var reviewItems: [ReviewItem]
    @State private var level: CEFRLevel
    @State private var selectedTheme = "All"
    @State private var searchText = ""
    @State private var premium = PremiumAccessService.shared
    @State private var showsPremium = false

    init(level: CEFRLevel) {
        _level = State(initialValue: level)
    }

    private var themes: [String] {
        let available = Set(allWords.filter { $0.level == level.rawValue }.map(\.theme))
        return ["All"] + CurriculumProgression.orderedVocabularyThemes(level: level, available: available)
    }

    private var words: [VocabWord] {
        allWords.filter { word in
            word.level == level.rawValue
                && (selectedTheme == "All" || word.theme == selectedTheme)
                && (searchText.isEmpty
                    || word.german.localizedCaseInsensitiveContains(searchText)
                    || word.english.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                Picker(selection: $level) {
                    ForEach(CEFRLevel.allCases) { Text($0.rawValue).tag($0) }
                } label: {
                    TeachingText(english: "Level")
                }
                .pickerStyle(.segmented)

                HStack {
                    Menu {
                        ForEach(themes, id: \.self) { theme in
                            Button {
                                selectedTheme = theme
                            } label: {
                                Text(theme)
                            }
                        }
                    } label: {
                        TeachingLabel(
                            english: selectedTheme,
                            systemImage: "line.3.horizontal.decrease.circle"
                        )
                    }
                    Spacer()
                    TeachingText(english: "\(words.count) words")
                        .font(.callout.weight(.semibold).monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                NavigationLink {
                    VocabularyFlashcardsView(level: level, theme: selectedTheme)
                } label: {
                    TeachingLabel(english: "Study this selection", systemImage: "rectangle.stack.fill")
                }
                .buttonStyle(PrimaryCoachButton(tint: CoachTheme.listening))

                ForEach(words) { word in
                    VocabularyWordCard(word: word, reviewItem: reviewItem(for: word))
                }
            }
            .padding()
        }
        .teachingNavigationTitle("Word Index")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "German or English")
        .coachBackground()
        .sheet(isPresented: $showsPremium) { PremiumView() }
        .onAppear {
            if !PremiumAccessPolicy.canOpenLevel(level, isPremium: premium.isPremium) {
                level = .a1
            }
        }
        .onChange(of: level) { _, newLevel in
            guard PremiumAccessPolicy.canOpenLevel(newLevel, isPremium: premium.isPremium) else {
                level = .a1
                showsPremium = true
                return
            }
            selectedTheme = "All"
        }
    }

    private func reviewItem(for word: VocabWord) -> ReviewItem? {
        reviewItems.first { $0.contentId == word.id && $0.kind == ReviewItemKind.vocabulary.rawValue }
    }
}

struct GrammarLibraryView: View {
    @Query(sort: \GrammarTopic.order) private var allTopics: [GrammarTopic]
    @Query private var activities: [LearningActivity]
    @State private var level: CEFRLevel = .a1
    @State private var searchText = ""
    @State private var premium = PremiumAccessService.shared
    @State private var showsPremium = false

    private var topics: [GrammarTopic] {
        CurriculumProgression.orderedGrammarTopics(allTopics, level: level)
    }

    private var modules: [CurriculumModuleDescriptor] {
        CurriculumProgression.grammarModules(level: level)
    }

    private var completedSourceIDs: Set<String> {
        Set(activities.map(\.sourceId))
    }

    private var nextTopic: GrammarTopic? {
        topics.first { !isTopicComplete($0) }
    }

    private var searchResults: [GrammarTopic] {
        guard !searchText.isEmpty else { return [] }
        return topics.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                Picker(selection: $level) {
                    ForEach(CEFRLevel.allCases) { Text($0.rawValue).tag($0) }
                } label: {
                    TeachingText(english: "Level")
                }
                .pickerStyle(.segmented)

                if searchText.isEmpty {
                    libraryHeader
                    continueSection

                    NavigationLink {
                        GrammarFlashcardsView(level: level)
                    } label: {
                        TeachingLabel(english: "Review grammar flashcards", systemImage: "text.book.closed.fill")
                    }
                    .buttonStyle(PrimaryCoachButton(tint: CoachTheme.primary))

                    CoachSectionHeader(
                        title: "Grammar modules",
                        subtitle: "\(modules.count) clear stages in teaching order"
                    )

                    LazyVGrid(columns: moduleColumns, spacing: 10) {
                        ForEach(Array(modules.enumerated()), id: \.element.id) { index, module in
                            if isModuleUnlocked(module) {
                                NavigationLink {
                                    GrammarModuleView(level: level, module: module)
                                } label: {
                                    CurriculumModuleTile(
                                        module: module,
                                        tint: moduleTint(index),
                                        progress: moduleProgress(module),
                                        isUnlocked: true,
                                        isComplete: isModuleComplete(module)
                                    )
                                }
                                .buttonStyle(CoachCardButtonStyle())
                            } else {
                                CurriculumModuleTile(
                                    module: module,
                                    tint: moduleTint(index),
                                    progress: moduleProgress(module),
                                    isUnlocked: false,
                                    isComplete: false
                                )
                                .teachingAccessibilityLabel("Module \(module.number), \(module.title), locked")
                            }
                        }
                    }
                } else {
                    CoachSectionHeader(
                        title: "Search results",
                        subtitle: "\(searchResults.count) matches in \(level.rawValue)"
                    )
                    ForEach(searchResults) { topic in
                        grammarTopicDestination(topic)
                    }
                }
            }
            .padding()
        }
        .teachingNavigationTitle("Grammar")
        .searchable(text: $searchText, prompt: "Find a grammar topic")
        .coachBackground()
        .sheet(isPresented: $showsPremium) { PremiumView() }
        .onChange(of: level) { _, newLevel in
            guard PremiumAccessPolicy.canOpenLevel(newLevel, isPremium: premium.isPremium) else {
                level = .a1
                showsPremium = true
                return
            }
            CoachFeedback.selection()
        }
    }

    private var libraryHeader: some View {
        HStack(spacing: 12) {
            CoachMascot(mood: .supportive, size: 58, animates: false)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                TeachingText(english: "Grammar in a clear order")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Text("\(topics.count) topics organised into \(modules.count) modules")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CoachTheme.elevatedSurface.opacity(0.84), in: RoundedRectangle(cornerRadius: CoachTheme.cardRadius))
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.cardRadius).stroke(CoachTheme.primary.opacity(0.16)))
    }

    @ViewBuilder private var continueSection: some View {
        if let nextTopic {
            NavigationLink {
                GrammarTopicDetailView(topic: nextTopic)
            } label: {
                ContinuePathCard(
                    eyebrow: "CONTINUE GRAMMAR",
                    title: nextTopic.title,
                    subtitle: "Next topic · \(nextTopic.practice.count) exercises",
                    icon: GrammarVisualCatalog.spec(for: nextTopic.id).symbol,
                    tint: CoachTheme.primary
                )
            }
            .buttonStyle(CoachCardButtonStyle())
        } else {
            CoachCard(tint: CoachTheme.correct) {
                TeachingLabel(english: "All \(level.rawValue) grammar modules complete", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(CoachTheme.correct)
            }
        }
    }

    private func isTopicComplete(_ topic: GrammarTopic) -> Bool {
        CurriculumProgression.isGrammarTopicComplete(
            topicID: topic.id,
            lessonIDs: GrammarTopicLesson.allCases.map(\.rawValue),
            completedSourceIDs: completedSourceIDs
        )
    }

    private func isTopicUnlocked(_ topic: GrammarTopic) -> Bool {
        isTopicComplete(topic) || nextTopic?.id == topic.id
    }

    private func isModuleComplete(_ module: CurriculumModuleDescriptor) -> Bool {
        module.itemIDs.allSatisfy { id in
            topics.first(where: { $0.id == id }).map(isTopicComplete) == true
        }
    }

    private func isModuleUnlocked(_ module: CurriculumModuleDescriptor) -> Bool {
        isModuleComplete(module) || module.itemIDs.contains(nextTopic?.id ?? "")
    }

    private func moduleProgress(_ module: CurriculumModuleDescriptor) -> String {
        let complete = module.itemIDs.filter { id in
            topics.first(where: { $0.id == id }).map(isTopicComplete) == true
        }.count
        return "\(complete)/\(module.itemIDs.count) topics"
    }

    @ViewBuilder private func grammarTopicDestination(_ topic: GrammarTopic) -> some View {
        let index = topics.firstIndex(where: { $0.id == topic.id }) ?? 0
        if isTopicUnlocked(topic) {
            NavigationLink {
                GrammarTopicDetailView(topic: topic)
            } label: {
                GrammarTopicPathRow(
                    topic: topic,
                    number: index + 1,
                    tint: moduleTint(index),
                    isUnlocked: true,
                    isComplete: isTopicComplete(topic),
                    prerequisite: nil
                )
            }
            .buttonStyle(CoachCardButtonStyle())
        } else {
            GrammarTopicPathRow(
                topic: topic,
                number: index + 1,
                tint: moduleTint(index),
                isUnlocked: false,
                isComplete: false,
                prerequisite: index > 0 ? topics[index - 1].title : nil
            )
        }
    }
}

private struct GrammarModuleView: View {
    @Query(sort: \GrammarTopic.order) private var allTopics: [GrammarTopic]
    @Query private var activities: [LearningActivity]
    let level: CEFRLevel
    let module: CurriculumModuleDescriptor
    @State private var quickCheckTopic: GrammarTopic?

    private var topics: [GrammarTopic] {
        CurriculumProgression.orderedGrammarTopics(allTopics, level: level)
    }

    private var moduleTopics: [GrammarTopic] {
        module.itemIDs.compactMap { id in topics.first(where: { $0.id == id }) }
    }

    private var completedSourceIDs: Set<String> {
        Set(activities.map(\.sourceId))
    }

    private var nextTopicID: String? {
        topics.first { !isComplete($0) }?.id
    }

    var body: some View {
        List {
            Section {
                ModuleHeader(module: module, tint: CoachTheme.primary)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            Section {
                ForEach(moduleTopics) { topic in
                    grammarTopicRow(topic)
                }
            }
            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .contentMargins(.vertical, 14, for: .scrollContent)
        .teachingNavigationTitle(module.title)
        .navigationBarTitleDisplayMode(.inline)
        .coachBackground()
        .sheet(item: $quickCheckTopic) { topic in
            GrammarQuickCheckSheet(topic: topic)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder private func grammarTopicRow(_ topic: GrammarTopic) -> some View {
        let index = topics.firstIndex(where: { $0.id == topic.id }) ?? 0
        if isUnlocked(topic) {
            NavigationLink {
                GrammarTopicDetailView(topic: topic)
            } label: {
                GrammarTopicPathRow(
                    topic: topic,
                    number: index + 1,
                    tint: moduleTint(module.number - 1),
                    isUnlocked: true,
                    isComplete: isComplete(topic),
                    prerequisite: nil
                )
            }
            .buttonStyle(CoachCardButtonStyle())
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button {
                    CoachFeedback.selection()
                    quickCheckTopic = topic
                } label: {
                    TeachingLabel(english: "Quick check", systemImage: "text.magnifyingglass")
                }
                .tint(GermanGrammarCase.inferred(from: "\(topic.id) \(topic.title)")?.color ?? CoachTheme.primary)
            }
        } else {
            GrammarTopicPathRow(
                topic: topic,
                number: index + 1,
                tint: moduleTint(module.number - 1),
                isUnlocked: false,
                isComplete: false,
                prerequisite: index > 0 ? topics[index - 1].title : nil
            )
        }
    }

    private func isComplete(_ topic: GrammarTopic) -> Bool {
        CurriculumProgression.isGrammarTopicComplete(
            topicID: topic.id,
            lessonIDs: GrammarTopicLesson.allCases.map(\.rawValue),
            completedSourceIDs: completedSourceIDs
        )
    }

    private func isUnlocked(_ topic: GrammarTopic) -> Bool {
        isComplete(topic) || nextTopicID == topic.id
    }
}

private struct CurriculumModuleTile: View {
    @Environment(\.colorScheme) private var colorScheme
    let module: CurriculumModuleDescriptor
    let tint: Color
    let progress: String
    let isUnlocked: Bool
    let isComplete: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                ZStack(alignment: .bottomTrailing) {
                    CoachIconTile(icon: isUnlocked ? module.icon : "lock.fill", tint: isUnlocked ? tint : .secondary, size: 42)
                    Text("\(module.number)")
                        .font(.caption2.weight(.heavy).monospacedDigit())
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                        .background(isUnlocked ? tint : Color.secondary, in: Circle())
                }
                Spacer()
                Image(systemName: isComplete ? "checkmark.circle.fill" : isUnlocked ? "chevron.right" : "lock.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isComplete ? CoachTheme.correct : isUnlocked ? tint : Color.secondary)
            }
            TeachingText(english: module.title)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(isUnlocked ? Color.primary : Color.secondary)
                .lineLimit(2)
            TeachingText(english: module.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Spacer(minLength: 0)
            TeachingText(english: isComplete ? "Complete" : isUnlocked ? progress : "Finish prior stage")
                .font(.caption.weight(.semibold).monospacedDigit())
                .foregroundStyle(isComplete ? CoachTheme.correct : isUnlocked ? tint : Color.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(13)
        .frame(maxWidth: .infinity, minHeight: 158, alignment: .topLeading)
        .background(
            CoachTheme.surfaceGradient(
                tint: isUnlocked ? tint : Color.secondary,
                colorScheme: colorScheme
            ),
            in: RoundedRectangle(cornerRadius: CoachTheme.cardRadius)
        )
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.cardRadius).stroke((isUnlocked ? tint : Color.secondary).opacity(0.18)))
        .opacity(isUnlocked ? 1 : 0.82)
    }
}

private struct ContinuePathCard: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: 13) {
            CoachIconTile(icon: icon, tint: tint, size: 50)
            VStack(alignment: .leading, spacing: 3) {
                TeachingText(english: eyebrow)
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(tint)
                TeachingText(english: title)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                TeachingText(english: subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 4)
            Image(systemName: "play.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(tint, in: Circle())
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    CoachTheme.elevatedSurface.opacity(0.92),
                    tint.opacity(0.15),
                    CoachTheme.rewardGlow.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: CoachTheme.cardRadius)
        )
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.cardRadius).stroke(tint.opacity(0.20)))
    }
}

private struct LibraryActionTile: View {
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            CoachIconTile(icon: icon, tint: tint, size: 38)
            TeachingText(english: title)
                .font(.callout.weight(.bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
            TeachingText(english: subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .background(CoachTheme.surface, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(tint.opacity(0.16)))
    }
}

private struct ModuleHeader: View {
    let module: CurriculumModuleDescriptor
    let tint: Color

    var body: some View {
        HStack(spacing: 13) {
            CoachIconTile(icon: module.icon, tint: tint, size: 50)
            VStack(alignment: .leading, spacing: 3) {
                TeachingText(english: "MODULE \(module.number)")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(tint)
                TeachingText(english: module.title)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                TeachingText(english: module.subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    CoachTheme.elevatedSurface.opacity(0.92),
                    tint.opacity(0.14),
                    CoachTheme.listening.opacity(0.07)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: CoachTheme.cardRadius)
        )
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.cardRadius).stroke(tint.opacity(0.16)))
    }
}

private struct VocabularyTopicPathRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let number: Int
    let theme: String
    let words: [VocabWord]
    let isUnlocked: Bool
    let isComplete: Bool
    let prerequisite: String?

    private var symbol: String {
        guard let word = words.first else { return "sparkles" }
        return VocabularyVisualCatalog.symbol(theme: theme, german: word.german, english: word.english)
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                CoachIconTile(icon: isUnlocked ? symbol : "lock.fill", tint: isUnlocked ? CoachTheme.accent : .secondary, size: 46)
                Text("\(number)")
                    .font(.caption2.weight(.heavy).monospacedDigit())
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(isUnlocked ? CoachTheme.accent : Color.secondary, in: Circle())
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(theme)
                    .font(.headline)
                    .foregroundStyle(isUnlocked ? Color.primary : Color.secondary)
                TeachingText(
                    english: isComplete
                        ? "Path complete"
                        : isUnlocked
                            ? "\(words.count) words · 4 short lessons"
                            : "Complete \(prerequisite ?? "the previous topic") first"
                )
                    .font(.caption)
                    .foregroundStyle(isComplete ? CoachTheme.correct : .secondary)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: isComplete ? "checkmark.circle.fill" : isUnlocked ? "chevron.right" : "lock.fill")
                .foregroundStyle(isComplete ? CoachTheme.correct : Color.secondary)
        }
        .padding(13)
        .background(
            CoachTheme.surfaceGradient(
                tint: isUnlocked ? CoachTheme.accent : Color.secondary,
                colorScheme: colorScheme
            ),
            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
        )
        .overlay(
            RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
                .stroke((isUnlocked ? CoachTheme.accent : Color.secondary).opacity(0.16))
        )
        .opacity(isUnlocked ? 1 : 0.82)
    }
}

private struct GrammarTopicPathRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let topic: GrammarTopic
    let number: Int
    let tint: Color
    let isUnlocked: Bool
    let isComplete: Bool
    let prerequisite: String?

    private var semanticTint: Color {
        GermanGrammarCase.inferred(from: "\(topic.id) \(topic.title)")?.color ?? tint
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                CoachIconTile(
                    icon: isUnlocked ? GrammarVisualCatalog.spec(for: topic.id).symbol : "lock.fill",
                    tint: isUnlocked ? semanticTint : .secondary,
                    size: 46
                )
                Text("\(number)")
                    .font(.caption2.weight(.heavy).monospacedDigit())
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(isUnlocked ? semanticTint : Color.secondary, in: Circle())
            }
            VStack(alignment: .leading, spacing: 3) {
                TeachingText(english: topic.title)
                    .font(.headline)
                    .foregroundStyle(isUnlocked ? Color.primary : Color.secondary)
                    .lineLimit(2)
                TeachingText(
                    english: isComplete
                        ? "Path complete"
                        : isUnlocked
                            ? "5 short lessons · \(topic.practice.count) exercises"
                            : "Complete \(prerequisite ?? "the previous topic") first"
                )
                    .font(.caption)
                    .foregroundStyle(isComplete ? CoachTheme.correct : .secondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 4)
            Image(systemName: isComplete ? "checkmark.circle.fill" : isUnlocked ? "chevron.right" : "lock.fill")
                .foregroundStyle(isComplete ? CoachTheme.correct : Color.secondary)
        }
        .padding(13)
        .background(
            CoachTheme.surfaceGradient(
                tint: isUnlocked ? semanticTint : Color.secondary,
                colorScheme: colorScheme
            ),
            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
        )
        .overlay(
            RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
                .stroke((isUnlocked ? semanticTint : Color.secondary).opacity(0.20))
        )
        .opacity(isUnlocked ? 1 : 0.82)
    }
}

private struct VocabularyWordCard: View {
    @Environment(\.modelContext) private var modelContext
    let word: VocabWord
    let reviewItem: ReviewItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SkillChip(title: word.theme, color: CoachTheme.listening, translatesTitle: false)
                Spacer(minLength: 8)
                GermanSpeechButton(text: word.ttsText, style: .word, label: "Play pronunciation")
                GermanSpeechButton(text: word.exampleSentence, label: "Play example sentence")
            }
            VocabularyVisualExplanation(word: word, compact: true)
            Divider()
            HStack(spacing: 10) {
                wordStatusButton(
                    "Memorized",
                    icon: reviewItem?.isMemorized == true ? "checkmark.square.fill" : "square",
                    isSelected: reviewItem?.isMemorized == true,
                    tint: CoachTheme.correct
                ) {
                    toggleMemorized()
                }
                wordStatusButton(
                    "Marked",
                    icon: reviewItem?.isMarked == true ? "bookmark.fill" : "bookmark",
                    isSelected: reviewItem?.isMarked == true,
                    tint: CoachTheme.accent
                ) {
                    toggleMarked()
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [CoachTheme.surface, CoachTheme.listening.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
        )
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(CoachTheme.stroke))
    }

    private func wordStatusButton(
        _ title: String,
        icon: String,
        isSelected: Bool,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            TeachingLabel(english: title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? tint : CoachTheme.ink)
                .frame(maxWidth: .infinity, minHeight: 36)
        }
        .buttonStyle(.plain)
        .background(
            LinearGradient(
                colors: [CoachTheme.elevatedSurface.opacity(0.88), tint.opacity(isSelected ? 0.18 : 0.06)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius)
        )
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.smallRadius).stroke(tint.opacity(isSelected ? 0.30 : 0.14)))
        .teachingAccessibilityValue(isSelected ? "Selected" : "Not selected")
    }

    private func toggleMemorized() {
        let item = ensureReviewItem()
        item.isMemorized.toggle()
        item.isActive = item.isActive || item.isMemorized
        if item.isMemorized {
            CoachFeedback.success()
        } else {
            CoachFeedback.selection()
        }
        try? modelContext.save()
    }

    private func toggleMarked() {
        let item = ensureReviewItem()
        item.isMarked.toggle()
        CoachFeedback.selection()
        try? modelContext.save()
    }

    private func ensureReviewItem() -> ReviewItem {
        if let reviewItem {
            return reviewItem
        }
        let item = ReviewItem(id: "review-\(word.id)", contentId: word.id, kind: .vocabulary)
        modelContext.insert(item)
        return item
    }
}

private struct VocabularyQuickActionTile: View {
    let title: String
    let icon: String
    let tint: Color
    var count: Int?

    var body: some View {
        VStack(spacing: 7) {
            ZStack(alignment: .topTrailing) {
                CoachIconTile(icon: icon, tint: tint, size: 42)
                if let count, count > 0 {
                    Text("\(count)")
                        .font(.caption2.bold().monospacedDigit())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .frame(minHeight: 18)
                        .background(tint, in: Capsule())
                        .offset(x: 9, y: -5)
                }
            }
            TeachingText(english: title)
                .font(.caption.weight(.bold))
                .foregroundStyle(CoachTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 84)
        .background(
            LinearGradient(
                colors: [CoachTheme.elevatedSurface.opacity(0.92), tint.opacity(0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
        )
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(tint.opacity(0.18)))
    }
}

private let moduleColumns = [
    GridItem(.flexible(), spacing: 10),
    GridItem(.flexible(), spacing: 10)
]

private func moduleTint(_ index: Int) -> Color {
    let palette = [CoachTheme.accent, CoachTheme.primary, CoachTheme.listening, CoachTheme.speaking, CoachTheme.writing]
    return palette[index % palette.count]
}
