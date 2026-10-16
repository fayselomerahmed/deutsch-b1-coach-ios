import SwiftUI

struct EverydayPhrasebookView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AppStorage(EverydayPhraseFavorites.storageKey) private var savedPhraseIDs = ""
    @AppStorage(EverydayPhraseStudyState.hardStorageKey) private var hardPhraseIDs = ""
    @AppStorage(EverydayPhraseStudyState.learnedStorageKey) private var learnedPhraseIDs = ""
    @State private var categories: [EverydayPhraseCategoryDTO] = []
    @State private var searchText = ""

    let focusLevel: CEFRLevel

    private var allPhrases: [EverydayPhraseDTO] {
        categories.flatMap(\.phrases)
    }

    private var savedPhrases: [EverydayPhraseDTO] {
        let saved = EverydayPhraseFavorites.ids(from: savedPhraseIDs)
        return allPhrases.filter { saved.contains($0.id) }
    }

    private var practicePhrases: [EverydayPhraseDTO] {
        let hard = EverydayPhraseStudyState.ids(from: hardPhraseIDs)
        let saved = EverydayPhraseFavorites.ids(from: savedPhraseIDs)
        let learned = EverydayPhraseStudyState.ids(from: learnedPhraseIDs)
        return allPhrases
            .filter { hard.contains($0.id) || (saved.contains($0.id) && !learned.contains($0.id)) }
            .sorted { left, right in
                let leftIsHard = hard.contains(left.id)
                let rightIsHard = hard.contains(right.id)
                if leftIsHard != rightIsHard { return leftIsHard }
                return left.german.localizedCaseInsensitiveCompare(right.german) == .orderedAscending
            }
    }

    private var searchResults: [EverydayPhraseSearchResult] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }
        return categories.flatMap { category in
            category.phrases.compactMap { phrase in
                let matches = phrase.german.localizedCaseInsensitiveContains(query)
                    || phrase.english.localizedCaseInsensitiveContains(query)
                    || category.title.localizedCaseInsensitiveContains(query)
                return matches
                    ? EverydayPhraseSearchResult(categoryTitle: category.title, phrase: phrase)
                    : nil
            }
        }
    }

    private var categoryColumns: [GridItem] {
        dynamicTypeSize.isAccessibilitySize
            ? [GridItem(.flexible())]
            : [GridItem(.flexible()), GridItem(.flexible())]
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                if categories.isEmpty {
                    CoachLoadingState(
                        title: "Preparing everyday German",
                        message: "Your practical phrase collection is getting ready."
                    )
                } else if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    phrasebookHeader.coachReveal(index: 0)

                    if !savedPhrases.isEmpty {
                        savedPhrasesLink.coachReveal(index: 1)
                    }

                    if !practicePhrases.isEmpty {
                        practicePhrasesLink.coachReveal(index: 2)
                    }

                    CoachSectionHeader(
                        title: "Choose a situation",
                        subtitle: "Short, useful language from A1 through B1"
                    )
                    .coachReveal(index: 3)

                    LazyVGrid(columns: categoryColumns, spacing: 10) {
                        ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                            categoryLink(category, index: index)
                                .coachReveal(index: index + 4)
                        }
                    }
                } else if searchResults.isEmpty {
                    CoachEmptyState(
                        icon: "text.magnifyingglass",
                        title: "No phrase found",
                        message: "Try a German word, an English meaning, or a situation."
                    )
                } else {
                    CoachSectionHeader(
                        title: "\(searchResults.count) results",
                        subtitle: "Matching German phrases and meanings"
                    )
                    ForEach(Array(searchResults.enumerated()), id: \.element.id) { index, result in
                        EverydayPhraseRow(
                            phrase: result.phrase,
                            context: result.categoryTitle,
                            tint: categoryTint(index)
                        )
                        .coachReveal(index: index)
                    }
                }
            }
            .padding()
        }
        .teachingNavigationTitle("Everyday phrases")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search German or meaning")
        .coachBackground()
        .task {
            categories = (try? ContentLoader.shared.loadEverydayPhrasebook()) ?? []
        }
    }

    private var phrasebookHeader: some View {
        CoachCard(tint: CoachTheme.speaking) {
            HStack(spacing: 14) {
                CoachMascot(mood: .welcome, size: 58, animates: true)
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 7) {
                        SkillChip(title: "\(allPhrases.count) phrases", color: CoachTheme.speaking)
                        SkillChip(title: "Focus \(focusLevel.rawValue)", color: CoachTheme.primary)
                    }
                    TeachingText(english: "German for everyday life")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .fixedSize(horizontal: false, vertical: true)
                    TeachingText(english: "Polite, natural language for the moments that shape life in Germany.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .teachingAccessibilityLabel("\(allPhrases.count) everyday German phrases, focus level \(focusLevel.rawValue)")
    }

    private var savedPhrasesLink: some View {
        NavigationLink {
            EverydayPhraseListView(
                title: "Saved phrases",
                subtitle: "Your personal everyday German collection",
                icon: "bookmark.fill",
                phrases: savedPhrases,
                tint: CoachTheme.reward
            )
        } label: {
            CoachCard(padding: 14, tint: CoachTheme.reward) {
                HStack(spacing: 12) {
                    CoachIconTile(icon: "bookmark.fill", tint: CoachTheme.reward)
                    VStack(alignment: .leading, spacing: 3) {
                        TeachingText(english: "Saved phrases")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("\(savedPhrases.count) ready to review")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 4)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .buttonStyle(CoachCardButtonStyle())
    }

    private var practicePhrasesLink: some View {
        NavigationLink {
            EverydayPhraseListView(
                title: "Practice queue",
                subtitle: "Your saved phrases, with the difficult ones first",
                icon: "arrow.triangle.2.circlepath",
                phrases: practicePhrases,
                tint: CoachTheme.speaking
            )
        } label: {
            CoachCard(padding: 14, tint: CoachTheme.speaking) {
                HStack(spacing: 12) {
                    CoachIconTile(icon: "arrow.triangle.2.circlepath", tint: CoachTheme.speaking)
                    VStack(alignment: .leading, spacing: 3) {
                        TeachingText(english: "Practice queue")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("\(practicePhrases.count) phrases ready for another useful repetition")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 4)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .buttonStyle(CoachCardButtonStyle())
    }

    private func categoryLink(_ category: EverydayPhraseCategoryDTO, index: Int) -> some View {
        let tint = categoryTint(index)
        return NavigationLink {
            EverydayPhraseListView(
                title: category.title,
                subtitle: category.subtitle,
                icon: category.icon,
                phrases: category.phrases,
                tint: tint
            )
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    CoachIconTile(icon: category.icon, tint: tint, size: 44)
                    Spacer(minLength: 4)
                    SkillChip(title: "\(category.phrases.count)", color: tint)
                }
                TeachingText(english: category.title)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                TeachingText(english: category.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(13)
            .frame(maxWidth: .infinity, minHeight: dynamicTypeSize.isAccessibilitySize ? 0 : 150, alignment: .topLeading)
            .background(
                CoachTheme.surfaceGradient(tint: tint, colorScheme: colorScheme),
                in: RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
                    .stroke(tint.opacity(0.18))
            )
        }
        .buttonStyle(CoachCardButtonStyle())
        .teachingAccessibilityLabel("\(category.title), \(category.phrases.count) phrases")
        .teachingAccessibilityHint("Open this everyday phrase category")
    }

    private func categoryTint(_ index: Int) -> Color {
        let palette = [
            CoachTheme.speaking,
            CoachTheme.listening,
            CoachTheme.primary,
            CoachTheme.reward,
            CoachTheme.accent,
            CoachTheme.writing,
            CoachTheme.listening,
            CoachTheme.primary,
            CoachTheme.correct,
            CoachTheme.speaking,
            CoachTheme.reward,
            CoachTheme.incorrect
        ]
        return palette[index % palette.count]
    }
}

struct EverydayPhraseListView: View {
    let title: String
    let subtitle: String
    let icon: String
    let phrases: [EverydayPhraseDTO]
    let tint: Color

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                CoachCard(tint: tint) {
                    HStack(spacing: 13) {
                        CoachIconTile(icon: icon, tint: tint, size: 50)
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 6) {
                                SkillChip(title: "\(phrases.count) phrases", color: tint)
                                SkillChip(title: levelSummary, color: CoachTheme.primary)
                            }
                            TeachingText(english: subtitle)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .coachReveal(index: 0)

                ForEach(Array(phrases.enumerated()), id: \.element.id) { index, phrase in
                    EverydayPhraseRow(phrase: phrase, tint: tint)
                        .coachReveal(index: min(index + 1, 8))
                }
            }
            .padding()
        }
        .teachingNavigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .coachBackground()
    }

    private var levelSummary: String {
        let levels = Set(phrases.map(\.level))
        if levels.count == CEFRLevel.allCases.count { return "A1–B1" }
        return CEFRLevel.allCases.filter(levels.contains).map(\.rawValue).joined(separator: " · ")
    }
}

private struct EverydayPhraseRow: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage(EverydayPhraseFavorites.storageKey) private var savedPhraseIDs = ""
    @AppStorage(EverydayPhraseStudyState.hardStorageKey) private var hardPhraseIDs = ""
    @AppStorage(EverydayPhraseStudyState.learnedStorageKey) private var learnedPhraseIDs = ""

    let phrase: EverydayPhraseDTO
    var context: String?
    let tint: Color

    private var isSaved: Bool {
        EverydayPhraseFavorites.ids(from: savedPhraseIDs).contains(phrase.id)
    }

    private var isHard: Bool {
        EverydayPhraseStudyState.ids(from: hardPhraseIDs).contains(phrase.id)
    }

    private var isLearned: Bool {
        EverydayPhraseStudyState.ids(from: learnedPhraseIDs).contains(phrase.id)
    }

    var body: some View {
        CoachCard(padding: 13, tint: tint) {
            HStack(alignment: .top, spacing: 11) {
                Button {
                    GermanSpeechService.shared.speak(phrase.german, style: .model)
                    CoachFeedback.selection()
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                }
                .buttonStyle(CoachIconButtonStyle(tint: tint))
                .teachingAccessibilityLabel(
                    "Play \(phrase.german)",
                    protectedGerman: [phrase.german]
                )

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        SkillChip(title: phrase.level.rawValue, color: tint)
                        if isHard {
                            SkillChip(title: "Practice", color: CoachTheme.reward)
                        } else if isLearned {
                            SkillChip(title: "Learned", color: CoachTheme.correct)
                        }
                        if let context {
                            TeachingText(english: context)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    Text(phrase.german)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    TeachingText(english: phrase.english)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 4)

                Button {
                    withAnimation(reduceMotion ? nil : CoachMotion.spring) {
                        savedPhraseIDs = EverydayPhraseFavorites.toggled(
                            phrase.id,
                            in: savedPhraseIDs
                        )
                    }
                    CoachFeedback.selection()
                } label: {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(isSaved ? CoachTheme.reward : .secondary)
                        .frame(width: 32, height: 32)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
                .teachingAccessibilityLabel(isSaved ? "Remove from saved phrases" : "Save phrase")
                .accessibilityHint(phrase.german)

                Menu {
                    Button {
                        hardPhraseIDs = EverydayPhraseStudyState.toggled(
                            phrase.id,
                            in: hardPhraseIDs
                        )
                        if isHard {
                            learnedPhraseIDs = EverydayPhraseStudyState.removing(
                                phrase.id,
                                from: learnedPhraseIDs
                            )
                        }
                        CoachFeedback.selection()
                    } label: {
                        Label(
                            isHard ? "Remove from practice queue" : "Practice this again",
                            systemImage: isHard ? "checkmark.circle" : "arrow.triangle.2.circlepath"
                        )
                    }

                    Button {
                        learnedPhraseIDs = EverydayPhraseStudyState.toggled(
                            phrase.id,
                            in: learnedPhraseIDs
                        )
                        if isLearned {
                            hardPhraseIDs = EverydayPhraseStudyState.removing(
                                phrase.id,
                                from: hardPhraseIDs
                            )
                        }
                        CoachFeedback.success()
                    } label: {
                        Label(
                            isLearned ? "Mark as not learned" : "Mark as learned",
                            systemImage: isLearned ? "arrow.uturn.backward" : "checkmark.seal"
                        )
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .teachingAccessibilityLabel("Phrase study options")
                .accessibilityHint(phrase.german)
            }
        }
        .accessibilityElement(children: .contain)
    }
}

private struct EverydayPhraseSearchResult: Identifiable {
    var id: String { phrase.id }
    let categoryTitle: String
    let phrase: EverydayPhraseDTO
}

private enum EverydayPhraseFavorites {
    static let storageKey = "savedEverydayPhraseIDs"

    static func ids(from rawValue: String) -> Set<String> {
        Set(rawValue.split(separator: "|").map(String.init))
    }

    static func toggled(_ id: String, in rawValue: String) -> String {
        var saved = ids(from: rawValue)
        if !saved.insert(id).inserted {
            saved.remove(id)
        }
        return saved.sorted().joined(separator: "|")
    }
}

private enum EverydayPhraseStudyState {
    static let hardStorageKey = "hardEverydayPhraseIDs"
    static let learnedStorageKey = "learnedEverydayPhraseIDs"

    static func ids(from rawValue: String) -> Set<String> {
        Set(rawValue.split(separator: "|").map(String.init))
    }

    static func toggled(_ id: String, in rawValue: String) -> String {
        var values = ids(from: rawValue)
        if !values.insert(id).inserted {
            values.remove(id)
        }
        return values.sorted().joined(separator: "|")
    }

    static func removing(_ id: String, from rawValue: String) -> String {
        var values = ids(from: rawValue)
        values.remove(id)
        return values.sorted().joined(separator: "|")
    }
}
