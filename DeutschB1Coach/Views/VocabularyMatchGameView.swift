import SwiftData
import SwiftUI

struct VocabularyMatchTerm: Hashable, Identifiable {
    let id: String
    let german: String
    let article: String?
    let meaning: String
    let theme: String
    let symbol: String

    init(
        id: String,
        german: String,
        article: String?,
        meaning: String,
        theme: String,
        symbol: String
    ) {
        self.id = id
        self.german = german
        self.article = article
        self.meaning = meaning
        self.theme = theme
        self.symbol = symbol
    }

    init(word: VocabWord) {
        self.init(
            id: word.id,
            german: word.german,
            article: word.article,
            meaning: word.english,
            theme: word.theme,
            symbol: VocabularyVisualCatalog.symbol(
                theme: word.theme,
                german: word.german,
                english: word.english
            )
        )
    }

    var lemma: String {
        guard let article, !article.isEmpty else { return german }
        let prefix = article + " "
        return german.lowercased().hasPrefix(prefix.lowercased())
            ? String(german.dropFirst(prefix.count))
            : german
    }
}

enum VocabularyMatchCardSide: String, Hashable {
    case german
    case meaning
}

struct VocabularyMatchCard: Hashable, Identifiable {
    let id: String
    let pairID: String
    let side: VocabularyMatchCardSide
    let term: VocabularyMatchTerm
}

struct VocabularyMatchRound: Hashable, Identifiable {
    let id: UUID
    let theme: String
    let terms: [VocabularyMatchTerm]
    let cards: [VocabularyMatchCard]
}

enum VocabularyMatchSelectionOutcome: Equatable {
    case ignored
    case firstSelection
    case match(VocabularyMatchTerm)
    case miss
}

struct VocabularyMatchGameState {
    let round: VocabularyMatchRound
    private(set) var selectedCardIDs: [String] = []
    private(set) var matchedPairIDs: Set<String> = []
    private(set) var moves = 0
    private(set) var score = 0
    private(set) var combo = 0
    private(set) var bestCombo = 0

    var isComplete: Bool {
        matchedPairIDs.count == round.terms.count
    }

    var accuracy: Double {
        guard moves > 0 else { return 1 }
        return min(1, Double(round.terms.count) / Double(moves))
    }

    func isRevealed(_ card: VocabularyMatchCard) -> Bool {
        selectedCardIDs.contains(card.id) || matchedPairIDs.contains(card.pairID)
    }

    func isMatched(_ card: VocabularyMatchCard) -> Bool {
        matchedPairIDs.contains(card.pairID)
    }

    mutating func select(_ card: VocabularyMatchCard, isResolving: Bool) -> VocabularyMatchSelectionOutcome {
        guard !isResolving,
              !isComplete,
              !selectedCardIDs.contains(card.id),
              !matchedPairIDs.contains(card.pairID),
              selectedCardIDs.count < 2
        else { return .ignored }

        selectedCardIDs.append(card.id)
        guard selectedCardIDs.count == 2,
              let firstCard = round.cards.first(where: { $0.id == selectedCardIDs[0] })
        else { return .firstSelection }

        moves += 1
        guard firstCard.pairID == card.pairID else {
            combo = 0
            return .miss
        }

        matchedPairIDs.insert(card.pairID)
        combo += 1
        bestCombo = max(bestCombo, combo)
        score += 100 + ((combo - 1) * 25)
        selectedCardIDs.removeAll(keepingCapacity: true)
        return .match(card.term)
    }

    mutating func resolveMiss() {
        selectedCardIDs.removeAll(keepingCapacity: true)
    }
}

enum VocabularyMatchDeckFactory {
    static let pairCount = 4

    static func makeRound(
        from terms: [VocabularyMatchTerm],
        excluding excludedIDs: Set<String> = [],
        pairCount: Int = pairCount
    ) -> VocabularyMatchRound? {
        guard pairCount > 0 else { return nil }
        let unique = uniqueTerms(from: terms)
        guard unique.count >= pairCount else { return nil }

        let groups = Dictionary(grouping: unique, by: \VocabularyMatchTerm.theme)
        let freshGroups = groups
            .mapValues { $0.filter { !excludedIDs.contains($0.id) } }
            .filter { $0.value.count >= pairCount }
        let fullGroups = groups.filter { $0.value.count >= pairCount }
        let sourceGroups = freshGroups.isEmpty ? fullGroups : freshGroups

        let selected: [VocabularyMatchTerm]
        if let group = sourceGroups.values.randomElement() {
            selected = Array(group.shuffled().prefix(pairCount))
        } else {
            let fresh = unique.filter { !excludedIDs.contains($0.id) }
            let pool = fresh.count >= pairCount ? fresh : unique
            selected = Array(pool.shuffled().prefix(pairCount))
        }

        guard selected.count == pairCount else { return nil }
        let selectedThemes = Set(selected.map(\.theme))
        let theme = selectedThemes.count == 1 ? selected[0].theme : "Mixed life"
        let cards = selected.flatMap { term in
            [
                VocabularyMatchCard(
                    id: "\(term.id)-german",
                    pairID: term.id,
                    side: .german,
                    term: term
                ),
                VocabularyMatchCard(
                    id: "\(term.id)-meaning",
                    pairID: term.id,
                    side: .meaning,
                    term: term
                )
            ]
        }

        return VocabularyMatchRound(
            id: UUID(),
            theme: theme,
            terms: selected,
            cards: cards.shuffled()
        )
    }

    static func uniqueTerms(from terms: [VocabularyMatchTerm]) -> [VocabularyMatchTerm] {
        var germanWords: Set<String> = []
        var meanings: Set<String> = []

        return terms.filter { term in
            let german = normalized(term.german)
            let meaning = normalized(term.meaning)
            guard !german.isEmpty,
                  !meaning.isEmpty,
                  !germanWords.contains(german),
                  !meanings.contains(meaning)
            else { return false }
            germanWords.insert(german)
            meanings.insert(meaning)
            return true
        }
    }

    private static func normalized(_ value: String) -> String {
        value
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "de_DE"))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}

struct VocabularyMatchGameView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VocabWord.german) private var allWords: [VocabWord]
    @AppStorage private var bestScore: Int
    @AppStorage private var roundsWon: Int
    @AppStorage("vocabularyMatch.soundEnabled") private var soundEnabled = true

    let level: CEFRLevel
    @State private var game: VocabularyMatchGameState?
    @State private var isResolving = false
    @State private var feedback: MatchGameFeedback?
    @State private var completedRound: VocabularyMatchRoundSummary?
    @State private var resolveTask: Task<Void, Never>?
    @State private var terms: [VocabularyMatchTerm] = []

    init(level: CEFRLevel) {
        self.level = level
        _bestScore = AppStorage(wrappedValue: 0, "vocabularyMatch.bestScore.\(level.rawValue)")
        _roundsWon = AppStorage(wrappedValue: 0, "vocabularyMatch.roundsWon.\(level.rawValue)")
    }

    private var availableWordCount: Int {
        allWords.lazy.filter { $0.level == level.rawValue }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if let game {
                    roundHeader(game)
                    scoreStrip(game)
                    feedbackStrip
                    gameBoard(game)

                    if game.isComplete {
                        Button {
                            startRound()
                        } label: {
                            TeachingLabel(english: "Play next round", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(PrimaryCoachButton(tint: CoachTheme.correct))
                    }
                } else if availableWordCount >= VocabularyMatchDeckFactory.pairCount {
                    CoachLoadingState(title: "Building your word game", message: "Choosing a clear real-life vocabulary set")
                } else {
                    CoachCard(tint: CoachTheme.accent) {
                        CoachEmptyState(
                            icon: "square.grid.2x2.fill",
                            title: "Game unavailable",
                            message: "Finish preparing the \(level.rawValue) vocabulary, then try again.",
                            tint: CoachTheme.accent
                        )
                    }
                }
            }
            .frame(maxWidth: 620)
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity)
        }
        .teachingNavigationTitle("Word Match")
        .navigationBarTitleDisplayMode(.inline)
        .coachBackground()
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    soundEnabled.toggle()
                    CoachFeedback.selection()
                    if !soundEnabled { GermanSpeechService.shared.stop() }
                } label: {
                    Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                }
                .teachingAccessibilityLabel(soundEnabled ? "Turn match pronunciation off" : "Turn match pronunciation on")

                Button {
                    startRound()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .teachingAccessibilityLabel("Start a new word match round")
            }
        }
        .task(id: availableWordCount) {
            terms = allWords
                .filter { $0.level == level.rawValue }
                .map(VocabularyMatchTerm.init(word:))
            if game == nil, terms.count >= VocabularyMatchDeckFactory.pairCount {
                startRound()
#if DEBUG
                if ProcessInfo.processInfo.arguments.contains("-visualQAGameReveal") {
                    try? await Task.sleep(for: .milliseconds(180))
                }
#endif
                applyVisualQAStateIfNeeded()
            }
        }
        .onDisappear {
            resolveTask?.cancel()
            GermanSpeechService.shared.stop()
        }
        .sheet(item: $completedRound) { summary in
            VocabularyMatchCompletionSheet(
                summary: summary,
                onNextRound: {
                    completedRound = nil
                    startRound()
                },
                onReviewBoard: {
                    completedRound = nil
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    private func roundHeader(_ game: VocabularyMatchGameState) -> some View {
        CoachCard(padding: 11, tint: CoachTheme.listening) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    ZStack(alignment: .bottomTrailing) {
                        CoachMascot(mood: avatarMood(for: game), size: 44)
                        Image(systemName: game.round.terms.first?.symbol ?? "square.grid.2x2.fill")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 20, height: 20)
                            .background(CoachTheme.listening, in: Circle())
                            .overlay(Circle().stroke(.white.opacity(0.55), lineWidth: 1))
                    }
                    .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 7) {
                            SkillChip(title: level.rawValue, color: CoachTheme.primary)
                            SkillChip(title: game.round.theme, color: CoachTheme.listening, translatesTitle: false)
                        }
                        TeachingText(english: "Match each German word with its meaning.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                LessonProgressBar(
                    progress: Double(game.matchedPairIDs.count) / Double(max(game.round.terms.count, 1))
                )
            }
        }
    }

    private func avatarMood(for game: VocabularyMatchGameState) -> CoachMascotMood {
        if game.isComplete { return .achievement }
        switch feedback?.icon {
        case "checkmark.circle.fill": return .correct
        case "arrow.uturn.backward.circle.fill": return .supportive
        default: return .welcome
        }
    }

    private func scoreStrip(_ game: VocabularyMatchGameState) -> some View {
        HStack(spacing: 0) {
            gameMetric(value: "\(game.score)", label: "Score", icon: "star.fill", tint: CoachTheme.reward)
            Divider().frame(height: 38)
            gameMetric(
                value: "\(game.matchedPairIDs.count)/\(game.round.terms.count)",
                label: "Pairs",
                icon: "link",
                tint: CoachTheme.correct
            )
            Divider().frame(height: 38)
            gameMetric(value: "x\(game.combo)", label: "Combo", icon: "bolt.fill", tint: CoachTheme.accent)
        }
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                colors: [
                    CoachTheme.elevatedSurface,
                    CoachTheme.rewardGlow.opacity(0.08),
                    CoachTheme.primary.opacity(0.07)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
        )
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(CoachTheme.stroke))
        .accessibilityElement(children: .combine)
        .teachingAccessibilityLabel("Score \(game.score), \(game.matchedPairIDs.count) of \(game.round.terms.count) pairs, combo \(game.combo)")
    }

    private func gameMetric(value: String, label: String, icon: String, tint: Color) -> some View {
        VStack(spacing: 3) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .foregroundStyle(tint)
                Text(value)
                    .monospacedDigit()
            }
            .font(.system(.callout, design: .rounded, weight: .bold))
            .contentTransition(.numericText())
            TeachingText(english: label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder private var feedbackStrip: some View {
        HStack(spacing: 8) {
            if let feedback {
                Image(systemName: feedback.icon)
                    .foregroundStyle(feedback.tint)
                TeachingText(english: feedback.message)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(feedback.tint)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(reduceMotion ? .identity : .opacity.combined(with: .scale(scale: 0.96)))
            } else {
                Image(systemName: "hand.tap.fill")
                    .foregroundStyle(CoachTheme.primary)
                TeachingText(english: "Choose any card to begin.")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
        .animation(reduceMotion ? nil : CoachMotion.quick, value: feedback)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
    }

    private func gameBoard(_ game: VocabularyMatchGameState) -> some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
            spacing: 10
        ) {
            ForEach(game.round.cards) { card in
                Button {
                    choose(card)
                } label: {
                    VocabularyMatchCardView(
                        card: card,
                        isRevealed: game.isRevealed(card),
                        isMatched: game.isMatched(card),
                        isIncorrect: isResolving && game.selectedCardIDs.contains(card.id),
                        colorScheme: colorScheme
                    )
                }
                .buttonStyle(CoachCardButtonStyle())
                .disabled(isResolving || game.isMatched(card))
                .teachingAccessibilityLabel(
                    accessibilityLabel(for: card, in: game),
                    protectedGerman: card.side == .german ? [card.term.german] : []
                )
                .teachingAccessibilityValue(game.isMatched(card) ? "Matched" : game.isRevealed(card) ? "Revealed" : "Hidden")
                .teachingAccessibilityHint(game.isMatched(card) ? "Pair completed" : "Double tap to select this card")
            }
        }
    }

    private func choose(_ card: VocabularyMatchCard) {
        guard var current = game else { return }
        let outcome = current.select(card, isResolving: isResolving)
        guard outcome != .ignored else { return }

        withAnimation(reduceMotion ? nil : CoachMotion.quick) {
            game = current
        }

        switch outcome {
        case .ignored:
            break
        case .firstSelection:
            CoachFeedback.selection()
            feedback = MatchGameFeedback(
                icon: "arrow.left.and.right",
                message: "Now find its matching card.",
                tint: CoachTheme.primary
            )
            if soundEnabled, card.side == .german {
                GermanSpeechService.shared.speak(card.term.german, style: .word)
            }
        case let .match(term):
            CoachFeedback.success()
            feedback = MatchGameFeedback(
                icon: "checkmark.circle.fill",
                message: "Match! \(term.german) means \(term.meaning).",
                tint: CoachTheme.correct
            )
            if soundEnabled {
                GermanSpeechService.shared.speak(term.german, style: .word)
            }
            if current.isComplete {
                finish(current)
            }
        case .miss:
            CoachFeedback.warning()
            feedback = MatchGameFeedback(
                icon: "arrow.uturn.backward.circle.fill",
                message: "Not a pair. Compare the article and meaning, then retry.",
                tint: CoachTheme.incorrect
            )
            resolveMiss(for: current.round.id)
        }
    }

    private func resolveMiss(for roundID: UUID) {
        isResolving = true
        resolveTask?.cancel()
        resolveTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(280))
            guard !Task.isCancelled, var current = game, current.round.id == roundID else { return }
            withAnimation(reduceMotion ? nil : CoachMotion.flip) {
                current.resolveMiss()
                game = current
                feedback = nil
                isResolving = false
            }
        }
    }

    private func finish(_ completedGame: VocabularyMatchGameState) {
        isResolving = true
        let xp = 6 + Int((completedGame.accuracy * 6).rounded()) + min(completedGame.bestCombo, 4)
        try? ProgressService().recordPractice(
            level: level,
            skill: .vocabulary,
            score: completedGame.accuracy,
            xp: xp,
            sourceId: "vocabulary-match-\(level.rawValue.lowercased())-\(completedGame.round.id.uuidString)",
            modelContext: modelContext
        )

        let isNewBest = completedGame.score > bestScore
        bestScore = max(bestScore, completedGame.score)
        roundsWon += 1
        let summary = VocabularyMatchRoundSummary(
            id: completedGame.round.id,
            theme: completedGame.round.theme,
            score: completedGame.score,
            bestScore: bestScore,
            moves: completedGame.moves,
            combo: completedGame.bestCombo,
            xp: xp,
            isNewBest: isNewBest
        )

        resolveTask?.cancel()
        resolveTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(180))
            guard !Task.isCancelled, game?.round.id == completedGame.round.id else { return }
            isResolving = false
            completedRound = summary
        }
    }

    private func startRound() {
        resolveTask?.cancel()
        GermanSpeechService.shared.stop()
        let previousIDs = Set(game?.round.terms.map(\.id) ?? [])
        guard let round = VocabularyMatchDeckFactory.makeRound(from: terms, excluding: previousIDs) else {
            game = nil
            return
        }
        withAnimation(reduceMotion ? nil : CoachMotion.spring) {
            game = VocabularyMatchGameState(round: round)
            feedback = nil
            isResolving = false
        }
        CoachFeedback.selection()
    }

    private func applyVisualQAStateIfNeeded() {
#if DEBUG
        guard ProcessInfo.processInfo.arguments.contains("-visualQAGameReveal"),
              var current = game,
              let german = current.round.cards.first(where: { $0.side == .german }),
              let meaning = current.round.cards.first(where: {
                  $0.side == .meaning && $0.pairID != german.pairID
              })
        else { return }
        _ = current.select(german, isResolving: false)
        _ = current.select(meaning, isResolving: false)
        game = current
        feedback = MatchGameFeedback(
            icon: "arrow.uturn.backward.circle.fill",
            message: "Not a pair. Look again and retry.",
            tint: CoachTheme.incorrect
        )
#endif
    }

    private func accessibilityLabel(for card: VocabularyMatchCard, in game: VocabularyMatchGameState) -> String {
        guard game.isRevealed(card) else { return "Hidden word match card" }
        switch card.side {
        case .german: return "German card, \(card.term.german)"
        case .meaning: return "Meaning card, \(card.term.meaning)"
        }
    }
}

private struct VocabularyMatchCardView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let card: VocabularyMatchCard
    let isRevealed: Bool
    let isMatched: Bool
    let isIncorrect: Bool
    let colorScheme: ColorScheme
    @State private var matchScale: CGFloat = 1
    @State private var shakeOffset: CGFloat = 0

    var body: some View {
        Color.clear
            .aspectRatio(1.65, contentMode: .fit)
            .overlay {
                CoachFlipCard(isFlipped: isRevealed) {
                    faceDown
                } back: {
                    faceUp
                }
            }
            .clipped()
            .scaleEffect(matchScale)
            .offset(x: shakeOffset)
            .opacity(isMatched ? 0.90 : 1)
            .onChange(of: isMatched) { _, matched in
                guard matched, !reduceMotion else { return }
                withAnimation(CoachMotion.celebration) {
                    matchScale = 1.035
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                    withAnimation(CoachMotion.quick) {
                        matchScale = 1
                    }
                }
            }
            .onChange(of: isIncorrect) { _, incorrect in
                guard incorrect, !reduceMotion else {
                    shakeOffset = 0
                    return
                }
                withAnimation(.timingCurve(0.3, 0.8, 0.3, 1, duration: 0.07)) {
                    shakeOffset = -5
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                    withAnimation(.timingCurve(0.3, 0.8, 0.3, 1, duration: 0.08)) {
                        shakeOffset = 5
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(CoachMotion.quick) {
                        shakeOffset = 0
                    }
                }
            }
    }

    private var faceDown: some View {
        ZStack {
            CoachTheme.actionGradient(tint: CoachTheme.primary, companion: CoachTheme.listening)
            VStack(spacing: 7) {
                Image(systemName: "questionmark")
                    .font(.system(size: 25, weight: .black, design: .rounded))
                Text("WORT-PAAR")
                    .font(.caption2.weight(.black))
            }
            .foregroundStyle(.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.cardRadius).stroke(.white.opacity(0.30)))
    }

    private var faceUp: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 6) {
                Group {
                    if card.side == .german {
                        Text("DEUTSCH")
                    } else {
                        TeachingText(english: "Meaning")
                    }
                }
                .font(.caption2.weight(.black))
                .foregroundStyle(card.side == .german ? CoachTheme.primary : CoachTheme.listening)
                Spacer(minLength: 2)
                Image(systemName: card.side == .german ? card.term.symbol : "text.bubble.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(card.side == .german ? CoachTheme.accent : CoachTheme.listening)
            }

            Spacer(minLength: 0)
            if card.side == .german {
                HStack(alignment: .center, spacing: 6) {
                    if let article = card.term.article, !article.isEmpty {
                        GermanArticleChip(article: article)
                    }
                    Text(card.term.lemma)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.72)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .environment(\.layoutDirection, .leftToRight)
            } else {
                TeachingText(english: card.term.meaning)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.72)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(11)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(
            CoachTheme.surfaceGradient(
                tint: isMatched ? CoachTheme.correct : card.side == .german ? CoachTheme.accent : CoachTheme.listening,
                colorScheme: colorScheme
            ),
            in: RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
                .stroke(isMatched ? CoachTheme.correct : CoachTheme.stroke, lineWidth: isMatched ? 2 : 1)
        }
        .overlay(alignment: .bottomTrailing) {
            if isMatched {
                CoachAnimatedCheckmark(size: 23, tint: CoachTheme.correct)
                    .padding(8)
            }
        }
    }
}

private struct MatchGameFeedback: Equatable {
    let icon: String
    let message: String
    let tint: Color

    static func == (lhs: MatchGameFeedback, rhs: MatchGameFeedback) -> Bool {
        lhs.icon == rhs.icon && lhs.message == rhs.message
    }
}

private struct VocabularyMatchRoundSummary: Identifiable {
    let id: UUID
    let theme: String
    let score: Int
    let bestScore: Int
    let moves: Int
    let combo: Int
    let xp: Int
    let isNewBest: Bool
}

private struct VocabularyMatchCompletionSheet: View {
    let summary: VocabularyMatchRoundSummary
    let onNextRound: () -> Void
    let onReviewBoard: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                CoachCelebrationMark()
                VStack(spacing: 4) {
                    TeachingText(english: "Round complete")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    Text(summary.theme)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(CoachTheme.listening)
                }

                HStack(spacing: 10) {
                    completionMetric("\(summary.score)", label: "Score", icon: "star.fill", tint: CoachTheme.reward)
                    completionMetric("\(summary.moves)", label: "Moves", icon: "hand.tap.fill", tint: CoachTheme.listening)
                    completionMetric("+\(summary.xp)", label: "XP", icon: "bolt.fill", tint: CoachTheme.accent)
                }

                if summary.isNewBest {
                    TeachingLabel(english: "New best score", systemImage: "trophy.fill")
                        .font(.callout.weight(.bold))
                        .foregroundStyle(CoachTheme.reward)
                } else {
                    TeachingText(english: "Best score: \(summary.bestScore) · Best combo: x\(summary.combo)")
                        .font(.callout.monospacedDigit().weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Button(action: onNextRound) {
                    TeachingLabel(english: "Play next round", systemImage: "play.fill")
                }
                .buttonStyle(PrimaryCoachButton(tint: CoachTheme.correct))

                Button(action: onReviewBoard) {
                    TeachingLabel(english: "Review this board", systemImage: "eye.fill")
                }
                .buttonStyle(SecondaryCoachButton(tint: CoachTheme.primary))
            }
            .frame(maxWidth: 520)
            .padding(20)
            .frame(maxWidth: .infinity)
        }
        .coachBackground()
    }

    private func completionMetric(_ value: String, label: String, icon: String, tint: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold).monospacedDigit())
            TeachingText(english: label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 74)
        .background(tint.opacity(0.10), in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
        .accessibilityElement(children: .combine)
    }
}
