import SwiftUI
import UIKit

enum GermanGrammarCase: String, CaseIterable, Identifiable {
    case nominative = "Nominative"
    case accusative = "Accusative"
    case dative = "Dative"
    case genitive = "Genitive"

    var id: String { rawValue }

    var abbreviation: String {
        switch self {
        case .nominative: "NOM"
        case .accusative: "AKK"
        case .dative: "DAT"
        case .genitive: "GEN"
        }
    }

    var icon: String {
        switch self {
        case .nominative: "person.fill"
        case .accusative: "scope"
        case .dative: "arrow.turn.down.right"
        case .genitive: "link"
        }
    }

    var uiColor: UIColor {
        switch self {
        case .nominative:
            UIColor(named: "GrammarNominative") ?? UIColor { traits in
                traits.userInterfaceStyle == .dark
                    ? UIColor(red: 0.38, green: 0.66, blue: 1.00, alpha: 1)
                    : UIColor(red: 0.00, green: 0.31, blue: 0.67, alpha: 1)
            }
        case .accusative:
            UIColor(named: "GrammarAccusative") ?? UIColor { traits in
                traits.userInterfaceStyle == .dark
                    ? UIColor(red: 1.00, green: 0.45, blue: 0.49, alpha: 1)
                    : UIColor(red: 0.68, green: 0.08, blue: 0.15, alpha: 1)
            }
        case .dative:
            UIColor(named: "GrammarDative") ?? UIColor { traits in
                traits.userInterfaceStyle == .dark
                    ? UIColor(red: 0.34, green: 0.84, blue: 0.56, alpha: 1)
                    : UIColor(red: 0.00, green: 0.40, blue: 0.21, alpha: 1)
            }
        case .genitive:
            UIColor(named: "GrammarGenitive") ?? UIColor { traits in
                traits.userInterfaceStyle == .dark
                    ? UIColor(red: 1.00, green: 0.82, blue: 0.35, alpha: 1)
                    : UIColor(red: 0.49, green: 0.34, blue: 0.00, alpha: 1)
            }
        }
    }

    var color: Color { Color(uiColor: uiColor) }

    var accessibilityDescription: String {
        "\(rawValue) case, marked with \(colorName) and the \(icon) symbol"
    }

    private var colorName: String {
        switch self {
        case .nominative: "blue"
        case .accusative: "red"
        case .dative: "green"
        case .genitive: "yellow"
        }
    }

    static func inferred(from value: String) -> GermanGrammarCase? {
        let normalized = value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "de_DE"))
            .lowercased()
        if normalized.contains("akk") || normalized.contains("accus") { return .accusative }
        if normalized.contains("dat") { return .dative }
        if normalized.contains("gen") { return .genitive }
        if normalized.contains("nom") || normalized.contains("subject") { return .nominative }
        return nil
    }
}

enum GermanArticleStyle {
    case der
    case die
    case das
    case neutral

    init(_ article: String) {
        switch article.lowercased() {
        case "der": self = .der
        case "die": self = .die
        case "das": self = .das
        default: self = .neutral
        }
    }

    var color: Color {
        switch self {
        case .der: GermanGrammarCase.nominative.color
        case .die: GermanGrammarCase.accusative.color
        case .das: GermanGrammarCase.genitive.color
        case .neutral: .secondary
        }
    }

    var colorName: String {
        switch self {
        case .der: "blue"
        case .die: "red"
        case .das: "yellow"
        case .neutral: "neutral"
        }
    }
}

struct GermanArticleChip: View {
    let article: String
    var isPlural = false
    var prominent = false

    private var style: GermanArticleStyle {
        isPlural ? .die : GermanArticleStyle(article)
    }

    var body: some View {
        Text(article)
            .font(.system(prominent ? .headline : .callout, design: .rounded, weight: .bold))
            .foregroundStyle(style.color)
            .padding(.horizontal, prominent ? 12 : 10)
            .frame(minHeight: prominent ? 40 : 34)
            .background(style.color.opacity(prominent ? 0.19 : 0.13), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(style.color.opacity(prominent ? 0.62 : 0.38), lineWidth: prominent ? 1.5 : 1)
            }
            .teachingAccessibilityLabel(
                "Article \(article), marked in \(style.colorName)",
                protectedGerman: [article]
            )
            .teachingAccessibilityHint("Article colors are paired with text so meaning never depends on color alone")
    }
}

struct GermanNounForms: View {
    let word: VocabWord
    var prominent = false

    private var lemma: String {
        guard let article = word.article else { return word.german }
        let prefix = article + " "
        return word.german.lowercased().hasPrefix(prefix.lowercased())
            ? String(word.german.dropFirst(prefix.count))
            : word.german
    }

    private var pluralLemma: String? {
        guard let plural = word.plural?.trimmingCharacters(in: .whitespacesAndNewlines),
              !plural.isEmpty else { return nil }
        return plural.lowercased().hasPrefix("die ") ? String(plural.dropFirst(4)) : plural
    }

    private var isPluralOnly: Bool {
        let normalized = lemma
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "de_DE"))
            .lowercased()
        return ["eltern", "ferien", "leute", "mobel"].contains(normalized)
    }

    private var singularTint: Color {
        word.article.map { GermanArticleStyle($0).color } ?? CoachTheme.listening
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 10) {
                singularForm
                pluralForm
            }
            VStack(spacing: 10) {
                singularForm
                pluralForm
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var singularForm: some View {
        nounForm(
            label: "Singular",
            article: isPluralOnly ? nil : word.article,
            value: isPluralOnly ? nil : lemma,
            note: isPluralOnly ? "This noun is normally used in the plural." : nil,
            tint: singularTint
        )
    }

    private var pluralForm: some View {
        nounForm(
            label: "Plural",
            article: pluralLemma != nil || isPluralOnly ? "die" : nil,
            value: isPluralOnly ? lemma : pluralLemma,
            note: pluralLemma == nil && !isPluralOnly ? "Usually no plural" : nil,
            tint: GermanArticleStyle.die.color
        )
    }

    private func nounForm(
        label: String,
        article: String?,
        value: String?,
        note: String?,
        tint: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 6) {
                TeachingText(english: label)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(tint)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 2)

                if let article {
                    GermanArticleChip(
                        article: article,
                        isPlural: label == "Plural",
                        prominent: prominent
                    )
                }
            }

            if let value {
                HStack(alignment: .center, spacing: 8) {
                    Text(value)
                        .font(
                            prominent
                                ? .system(.title3, design: .rounded, weight: .semibold)
                                : .system(.body, design: .rounded, weight: .semibold)
                        )
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .fixedSize(horizontal: false, vertical: true)
                        .layoutPriority(1)

                    formSpeechButton(
                        text: [article, value].compactMap { $0 }.joined(separator: " "),
                        label: label
                    )
                }
                .environment(\.layoutDirection, .leftToRight)
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("—")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(tint)
                    if let note {
                        TeachingText(english: note)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(prominent ? 12 : 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(prominent ? 0.10 : 0.075), in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
        .overlay {
            RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
                .stroke(tint.opacity(prominent ? 0.30 : 0.18), lineWidth: 1)
        }
    }

    private func formSpeechButton(text: String, label: String) -> some View {
        Button {
            GermanSpeechService.shared.speak(text, style: .word)
        } label: {
            Image(systemName: "speaker.wave.2.fill")
                .font(.callout.weight(.semibold))
                .foregroundStyle(CoachTheme.listening)
                .frame(width: 34, height: 34)
                .background(CoachTheme.listening.opacity(0.10), in: Circle())
                .overlay(Circle().stroke(CoachTheme.listening.opacity(0.18)))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(CoachCardButtonStyle())
        .teachingAccessibilityLabel(
            "Play \(label.lowercased()): \(text)",
            protectedGerman: [text]
        )
    }
}

struct GermanVocabularyTitle: View {
    let word: VocabWord
    var font: Font = .system(.title3, design: .rounded, weight: .bold)
    var alignment: TextAlignment = .leading

    private var lemma: String {
        guard let article = word.article else { return word.german }
        let prefix = article + " "
        return word.german.lowercased().hasPrefix(prefix.lowercased())
            ? String(word.german.dropFirst(prefix.count))
            : word.german
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 7) {
            if let article = word.article, !article.isEmpty {
                GermanArticleChip(article: article)
            }
            Text(lemma)
                .font(font)
                .multilineTextAlignment(alignment)
                .fixedSize(horizontal: false, vertical: true)
        }
        .environment(\.layoutDirection, .leftToRight)
        .contextMenu {
            Button {
                UIPasteboard.general.string = word.english
            } label: {
                TeachingLabel(
                    english: "\(word.english) · Copy definition",
                    systemImage: "doc.on.doc"
                )
            }
            Button {
                GermanSpeechService.shared.speak(word.ttsText, style: .word)
            } label: {
                TeachingLabel(english: "Play pronunciation", systemImage: "speaker.wave.2.fill")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel([word.article, lemma].compactMap { $0 }.joined(separator: " "))
        .teachingAccessibilityHint("Touch and hold for the definition and pronunciation")
    }
}

struct GrammarCaseBadge: View {
    let grammarCase: GermanGrammarCase
    var isSelected = true

    var body: some View {
        Label(grammarCase.abbreviation, systemImage: grammarCase.icon)
            .font(.system(.caption2, design: .rounded, weight: .bold))
            .foregroundStyle(isSelected ? grammarCase.color : Color.secondary)
            .padding(.horizontal, 8)
            .frame(minHeight: 28)
            .background(
                (isSelected ? grammarCase.color : Color.secondary).opacity(0.12),
                in: RoundedRectangle(cornerRadius: 8, style: .continuous)
            )
            .teachingAccessibilityLabel(grammarCase.accessibilityDescription)
            .teachingAccessibilityValue(isSelected ? "present in this explanation" : "not explicitly marked")
    }
}

enum LessonScenarioStyle: String {
    case bakery
    case bureaucracy
    case apartment
    case work
    case health
    case travel
    case everyday

    static func resolve(scenario: String, theme: String? = nil) -> LessonScenarioStyle {
        let value = "\(scenario) \(theme ?? "")"
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "de_DE"))
            .lowercased()

        if value.contains("back") || value.contains("brot") || value.contains("cafe") || value.contains("essen") {
            return .bakery
        }
        if value.contains("behord") || value.contains("amt") || value.contains("formular") || value.contains("antrag") {
            return .bureaucracy
        }
        if value.contains("wohnung") || value.contains("miete") || value.contains("vermieter") || value.contains("apartment") {
            return .apartment
        }
        if value.contains("arbeit") || value.contains("beruf") || value.contains("job") { return .work }
        if value.contains("gesund") || value.contains("arzt") || value.contains("termin") { return .health }
        if value.contains("reise") || value.contains("bahn") || value.contains("verkehr") { return .travel }
        return .everyday
    }

    var icon: String {
        switch self {
        case .bakery: "takeoutbag.and.cup.and.straw.fill"
        case .bureaucracy: "doc.text.fill"
        case .apartment: "house.and.flag.fill"
        case .work: "briefcase.fill"
        case .health: "cross.case.fill"
        case .travel: "tram.fill"
        case .everyday: "figure.walk"
        }
    }

    var tint: Color {
        switch self {
        case .bakery: Color(red: 0.76, green: 0.28, blue: 0.17)
        case .bureaucracy: GermanGrammarCase.nominative.color
        case .apartment: Color(red: 0.00, green: 0.43, blue: 0.35)
        case .work: Color(red: 0.35, green: 0.31, blue: 0.62)
        case .health: Color(red: 0.68, green: 0.12, blue: 0.30)
        case .travel: Color(red: 0.00, green: 0.40, blue: 0.51)
        case .everyday: CoachTheme.primary
        }
    }
}

struct ScenarioHeroView: View {
    let lesson: CompleteLessonDTO

    private var style: LessonScenarioStyle {
        LessonScenarioStyle.resolve(scenario: lesson.scenario)
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LessonMemoryVisual(lesson: lesson, animates: true)
                .frame(maxWidth: .infinity)
                .frame(height: 218)
                .visualEffect { content, proxy in
                    content.offset(
                        y: proxy.frame(in: .scrollView).minY > 0
                            ? -min(proxy.frame(in: .scrollView).minY * 0.14, 16)
                            : 0
                    )
                }

            LinearGradient(
                colors: [.clear, .black.opacity(0.58)],
                startPoint: .center,
                endPoint: .bottom
            )

            TeachingLabel(english: lesson.scenario, systemImage: style.icon)
                .font(.system(.callout, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 218)
        .background(style.tint.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                .stroke(style.tint.opacity(0.30), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .teachingAccessibilityLabel("Scenario: \(lesson.scenario)")
    }
}

struct GrammarXRayButton: View {
    let sentence: String
    let topicID: String?
    let topicTitle: String?
    @State private var showsXRay = false

    init(sentence: String, topic: GrammarTopic? = nil) {
        self.sentence = sentence
        self.topicID = topic?.id
        self.topicTitle = topic?.title
    }

    var body: some View {
        Button {
            CoachFeedback.selection()
            showsXRay = true
        } label: {
            Image(systemName: "text.magnifyingglass")
        }
        .buttonStyle(CoachIconButtonStyle(tint: GermanGrammarCase.nominative.color))
        .teachingAccessibilityLabel("Open Grammar X-Ray")
        .teachingAccessibilityHint("Shows case, gender, and number cues for this German sentence")
        .sheet(isPresented: $showsXRay) {
            GrammarXRaySheet(sentence: sentence, topicID: topicID, topicTitle: topicTitle)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
        }
    }
}

private struct GrammarAnalysisSlot: Identifiable {
    let id = UUID()
    let token: String
    let grammarCase: GermanGrammarCase
    let gender: String
    let number: String
}

private enum GrammarSentenceAnalyzer {
    private static let subjectPronouns: Set<String> = ["ich", "du", "er", "es", "wir", "ihr"]
    private static let accusativePronouns: Set<String> = ["mich", "dich", "ihn"]
    private static let dativePronouns: Set<String> = ["mir", "dir", "ihm", "uns", "euch", "ihnen"]

    static func analyze(sentence: String, topicID: String?, topicTitle: String?) -> [GrammarAnalysisSlot] {
        let hint = GermanGrammarCase.inferred(from: "\(topicID ?? "") \(topicTitle ?? "")")
        let tokens = sentence
            .components(separatedBy: CharacterSet.letters.inverted)
            .filter { !$0.isEmpty }

        return tokens.compactMap { token in
            let word = token.lowercased()
            if subjectPronouns.contains(word) {
                return GrammarAnalysisSlot(token: token, grammarCase: .nominative, gender: pronounGender(word), number: pronounNumber(word))
            }
            if accusativePronouns.contains(word) {
                return GrammarAnalysisSlot(token: token, grammarCase: .accusative, gender: pronounGender(word), number: "singular")
            }
            if dativePronouns.contains(word) {
                return GrammarAnalysisSlot(token: token, grammarCase: .dative, gender: pronounGender(word), number: word == "ihnen" ? "plural" : "singular")
            }

            guard let article = articleAnalysis(word, hint: hint) else { return nil }
            return GrammarAnalysisSlot(
                token: token,
                grammarCase: article.grammarCase,
                gender: article.gender,
                number: article.number
            )
        }
    }

    private static func articleAnalysis(
        _ word: String,
        hint: GermanGrammarCase?
    ) -> (grammarCase: GermanGrammarCase, gender: String, number: String)? {
        switch word {
        case "den": return (hint == .dative ? .dative : .accusative, hint == .dative ? "all genders" : "masculine", hint == .dative ? "plural" : "singular")
        case "dem", "einem": return (.dative, "masculine / neuter", "singular")
        case "des", "eines": return (.genitive, "masculine / neuter", "singular")
        case "einen": return (.accusative, "masculine", "singular")
        case "einer": return (hint == .genitive ? .genitive : .dative, "feminine", "singular")
        case "der":
            if hint == .dative || hint == .genitive { return (hint!, "feminine", "singular") }
            return (.nominative, "masculine", "singular")
        case "die":
            return (hint == .accusative ? .accusative : .nominative, "feminine / plural", "context decides")
        case "das": return (hint == .accusative ? .accusative : .nominative, "neuter", "singular")
        case "ein": return (.nominative, "masculine / neuter", "singular")
        case "eine": return (hint == .accusative ? .accusative : .nominative, "feminine", "singular")
        default: return nil
        }
    }

    private static func pronounGender(_ word: String) -> String {
        switch word {
        case "er", "ihn", "ihm": "masculine"
        case "es": "neuter"
        default: "person"
        }
    }

    private static func pronounNumber(_ word: String) -> String {
        ["wir", "ihr"].contains(word) ? "plural" : "singular"
    }
}

private struct GrammarXRaySheet: View {
    @Environment(\.dismiss) private var dismiss
    let sentence: String
    let topicID: String?
    let topicTitle: String?

    private var slots: [GrammarAnalysisSlot] {
        GrammarSentenceAnalyzer.analyze(sentence: sentence, topicID: topicID, topicTitle: topicTitle)
    }

    private var detectedCases: Set<GermanGrammarCase> {
        Set(slots.map(\.grammarCase))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(sentence)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .environment(\.layoutDirection, .leftToRight)
                        .fixedSize(horizontal: false, vertical: true)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 7) {
                            ForEach(GermanGrammarCase.allCases) { grammarCase in
                                GrammarCaseBadge(grammarCase: grammarCase, isSelected: detectedCases.contains(grammarCase))
                            }
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)

                    if slots.isEmpty {
                        VStack(spacing: 9) {
                            Image(systemName: "text.magnifyingglass")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            TeachingText(english: "No explicit case marker")
                                .font(.headline)
                            TeachingText(
                                english: "This sentence has no article or pronoun that identifies a case with confidence."
                            )
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    } else {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 138), spacing: 10)],
                            alignment: .leading,
                            spacing: 10
                        ) {
                            ForEach(Array(slots.enumerated()), id: \.element.id) { index, slot in
                                GrammarAnalysisSlotView(slot: slot, index: index)
                            }
                        }
                    }

                    TeachingLabel(
                        english: "Color is always paired with a case label and symbol.",
                        systemImage: "accessibility"
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
            }
            .teachingNavigationTitle("Grammar X-Ray")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    TeachingButton("Done") { dismiss() }
                }
            }
            .coachBackground()
        }
    }
}

struct GrammarQuickCheckSheet: View {
    @Environment(\.dismiss) private var dismiss
    let topic: GrammarTopic

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TeachingText(english: topic.title)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .fixedSize(horizontal: false, vertical: true)
                    GrammarVisualExplanation(topic: topic)
                    Divider()
                    SentenceBuilderGameLink(topic: topic)
                    if let example = topic.examples.first {
                        Divider()
                        HStack(alignment: .top, spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(example.german)
                                    .font(.headline)
                                    .environment(\.layoutDirection, .leftToRight)
                                TeachingText(english: example.english)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 4)
                            GermanSpeechButton(text: example.german, label: "Play grammar example")
                            GrammarXRayButton(sentence: example.german, topic: topic)
                        }
                    }
                }
                .padding()
            }
            .teachingNavigationTitle("Quick Grammar Check")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    TeachingButton("Done") { dismiss() }
                }
            }
            .coachBackground()
        }
    }
}

private struct GrammarAnalysisSlotView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let slot: GrammarAnalysisSlot
    let index: Int
    @State private var isFilled = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                GrammarCaseBadge(grammarCase: slot.grammarCase)
                Spacer(minLength: 6)
                Image(systemName: slot.grammarCase.icon)
                    .foregroundStyle(slot.grammarCase.color)
                    .accessibilityHidden(true)
            }
            Text(slot.token)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .environment(\.layoutDirection, .leftToRight)
            HStack(spacing: 4) {
                TeachingText(english: slot.gender)
                Text("·")
                TeachingText(english: slot.number)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .background(slot.grammarCase.color.opacity(0.11), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(slot.grammarCase.color.opacity(0.30))
        }
        .opacity(isFilled ? 1 : 0)
        .offset(y: reduceMotion || isFilled ? 0 : -18)
        .onAppear {
            if reduceMotion {
                isFilled = true
            } else {
                withAnimation(CoachMotion.spring.delay(min(Double(index) * 0.045, 0.18))) {
                    isFilled = true
                }
            }
        }
        .accessibilityElement(children: .combine)
        .teachingAccessibilityLabel(
            "\(slot.token), \(slot.grammarCase.rawValue), \(slot.gender), \(slot.number)",
            protectedGerman: [slot.token]
        )
        .teachingAccessibilityHint(slot.grammarCase.accessibilityDescription)
    }
}

struct GermanKeyboardAccessory: View {
    @Binding var text: String

    private let keys = [
        (letter: "ä", ipa: "/ɛː/"),
        (letter: "ö", ipa: "/øː/"),
        (letter: "ü", ipa: "/yː/"),
        (letter: "ß", ipa: "/s/")
    ]

    var body: some View {
        HStack(spacing: 7) {
            ForEach(keys, id: \.letter) { key in
                Button {
                    text.append(key.letter)
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } label: {
                    VStack(spacing: 0) {
                        Text(key.letter)
                            .font(.system(.headline, design: .rounded, weight: .bold))
                        Text(key.ipa)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.35).onEnded { _ in
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.75)
                    }
                )
                .teachingAccessibilityLabel(
                    "German letter \(key.letter)",
                    protectedGerman: [key.letter]
                )
                .teachingAccessibilityHint(
                    "Pronounced approximately \(key.ipa). Inserts the letter",
                    protectedGerman: [key.ipa]
                )
            }
        }
        .frame(maxWidth: 270)
    }
}

private struct GermanKeyboardAccessoryModifier: ViewModifier {
    @Binding var text: String

    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                GermanKeyboardAccessory(text: $text)
            }
        }
    }
}

struct CompoundWordPart: Identifiable, Hashable {
    let id: String
    let text: String
    let isConnector: Bool

    init(text: String, isConnector: Bool = false, index: Int) {
        self.id = "\(index)-\(text)"
        self.text = text
        self.isConnector = isConnector
    }
}

enum GermanCompoundAnalyzer {
    private static let roots = [
        "aufenthalt", "erlaubnis", "versicherung", "gesundheit", "ruck", "schmerz",
        "wohnung", "miete", "vertrag", "arbeit", "sprach", "schule", "kurs", "kind",
        "familie", "leben", "mittel", "einkauf", "stadt", "reise", "termin", "antrag",
        "bescheid", "formular", "steuer", "konto", "nachricht", "brief", "schein", "haus"
    ]

    static func parts(for word: String) -> [CompoundWordPart] {
        let clean = word.components(separatedBy: .whitespacesAndNewlines).joined()
        guard clean.count >= 12, !clean.contains("-") else { return [] }
        let normalized = clean
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "de_DE"))
            .lowercased()

        guard let split = bestSplit(normalized), split.count >= 2 else { return [] }
        var cursor = clean.startIndex
        return split.enumerated().map { index, item in
            let length = min(item.text.count, clean.distance(from: cursor, to: clean.endIndex))
            let end = clean.index(cursor, offsetBy: length)
            let original = String(clean[cursor..<end])
            cursor = end
            return CompoundWordPart(text: original, isConnector: item.connector, index: index)
        }
    }

    private static func bestSplit(_ word: String) -> [(text: String, connector: Bool)]? {
        for root in roots.sorted(by: { $0.count > $1.count }) where word.hasPrefix(root) {
            let remainder = String(word.dropFirst(root.count))
            for connector in ["s", "n", "en", "e", ""] {
                guard remainder.hasPrefix(connector) else { continue }
                let tail = String(remainder.dropFirst(connector.count))
                guard roots.contains(tail) else { continue }
                var result = [(root, false)]
                if !connector.isEmpty { result.append((connector, true)) }
                result.append((tail, false))
                return result
            }
        }
        return nil
    }
}

struct CompoundWordBuilder: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let word: String
    let parts: [CompoundWordPart]
    @State private var assembled: [CompoundWordPart] = []

    init?(word: String) {
        let parts = GermanCompoundAnalyzer.parts(for: word)
        guard !parts.isEmpty else { return nil }
        self.word = word
        self.parts = parts
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                TeachingLabel(english: "Word parts", systemImage: "puzzlepiece.extension.fill")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(CoachTheme.primary)
                Spacer()
                if !assembled.isEmpty {
                    Button {
                        withAnimation(reduceMotion ? nil : CoachMotion.quick) { assembled.removeAll() }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .teachingAccessibilityLabel("Reset compound word")
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(parts) { part in
                        partChip(part)
                            .draggable(part.id)
                            .onTapGesture { append(part) }
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)

            HStack(spacing: 3) {
                if assembled.isEmpty {
                    TeachingText(english: "Drag or tap the parts here")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(assembled) { part in
                        Text(part.text)
                            .font(.system(.callout, design: .rounded, weight: part.isConnector ? .bold : .semibold))
                            .italic(part.isConnector)
                            .foregroundStyle(part.isConnector ? GermanGrammarCase.genitive.color : Color.primary)
                            .overlay(alignment: .bottom) {
                                if part.isConnector {
                                    Capsule()
                                        .fill(GermanGrammarCase.genitive.color)
                                        .frame(height: 2)
                                        .offset(y: 3)
                                        .transition(.scale(scale: 0.2, anchor: .leading).combined(with: .opacity))
                                }
                            }
                    }
                }
                Spacer(minLength: 0)
                if assembled.map(\.id) == parts.map(\.id) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(CoachTheme.correct)
                        .transition(.scale.combined(with: .opacity))
                        .teachingAccessibilityLabel("Compound word assembled")
                }
            }
            .padding(11)
            .frame(maxWidth: .infinity, minHeight: 46, alignment: .leading)
            .background(CoachTheme.primary.opacity(0.07), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(CoachTheme.primary.opacity(0.22), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
            }
            .dropDestination(for: String.self) { ids, _ in
                guard let id = ids.first, let part = parts.first(where: { $0.id == id }) else { return false }
                append(part)
                return true
            }
        }
        .padding(11)
        .background(CoachTheme.elevatedSurface.opacity(0.72), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    private func partChip(_ part: CompoundWordPart) -> some View {
        Text(part.text)
            .font(.system(.callout, design: .rounded, weight: part.isConnector ? .bold : .semibold))
            .italic(part.isConnector)
            .foregroundStyle(part.isConnector ? GermanGrammarCase.genitive.color : CoachTheme.primary)
            .padding(.horizontal, 10)
            .frame(minHeight: 36)
            .background(
                (part.isConnector ? GermanGrammarCase.genitive.color : CoachTheme.primary).opacity(0.12),
                in: RoundedRectangle(cornerRadius: 8, style: .continuous)
            )
            .teachingAccessibilityLabel(
                part.isConnector ? "Connecting element \(part.text)" : "Word part \(part.text)",
                protectedGerman: [part.text]
            )
            .teachingAccessibilityHint("Drag or tap to add this part")
    }

    private func append(_ part: CompoundWordPart) {
        guard assembled.count < parts.count,
              parts[assembled.count].id == part.id
        else {
            CoachFeedback.warning()
            return
        }
        CoachFeedback.selection()
        withAnimation(reduceMotion ? nil : CoachMotion.spring) {
            assembled.append(part)
        }
    }
}

struct FormalityStyleToggle: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var isFormal: Bool
    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 5) {
            option(title: "du", icon: "face.smiling.fill", formal: false)
            option(title: "Sie", icon: "person.crop.circle.badge.checkmark", formal: true)
        }
        .padding(4)
        .background(.secondary.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    private func option(title: String, icon: String, formal: Bool) -> some View {
        let selected = isFormal == formal
        let tint = formal ? GermanGrammarCase.nominative.color : Color(red: 0.77, green: 0.30, blue: 0.22)

        return Button {
            CoachFeedback.selection()
            if reduceMotion {
                isFormal = formal
            } else {
                withAnimation(CoachMotion.spring) { isFormal = formal }
            }
        } label: {
            Label(title, systemImage: icon)
                .font(.system(.callout, design: .rounded, weight: .bold))
                .foregroundStyle(selected ? tint : Color.secondary)
                .frame(maxWidth: .infinity, minHeight: 42)
                .background {
                    if selected {
                        RoundedRectangle(
                            cornerRadius: formal ? 7 : 15,
                            style: .continuous
                        )
                        .fill(CoachTheme.elevatedSurface)
                        .matchedGeometryEffect(id: "formality-selection", in: namespace)
                    }
                }
        }
        .buttonStyle(.plain)
        .teachingAccessibilityLabel(
            formal ? "Formal Sie context" : "Familiar du context",
            protectedGerman: formal ? ["Sie"] : ["du"]
        )
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct OrdnungStreakRing: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let days: Int
    var goal = 7
    var size: CGFloat = 54
    @State private var displayedProgress = 0.0

    private var progress: Double {
        min(Double(max(days, 0)) / Double(max(goal, 1)), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(.primary.opacity(0.10), lineWidth: max(5, size * 0.10))
            Circle()
                .trim(from: 0, to: displayedProgress)
                .stroke(
                    CoachTheme.accent,
                    style: StrokeStyle(lineWidth: max(5, size * 0.10), lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Image(systemName: "flame.fill")
                    .font(.system(size: size * 0.25, weight: .bold))
                    .foregroundStyle(CoachTheme.accent)
                Text("\(days)")
                    .font(.system(size: size * 0.20, weight: .bold, design: .rounded).monospacedDigit())
            }
        }
        .frame(width: size, height: size)
        .onAppear { update(animated: !reduceMotion) }
        .onChange(of: days) { _, _ in update(animated: !reduceMotion) }
        .onChange(of: reduceMotion) { _, _ in update(animated: false) }
        .accessibilityElement(children: .ignore)
        .teachingAccessibilityLabel("Ordnung streak", protectedGerman: ["Ordnung"])
        .teachingAccessibilityValue("\(days) days, \(Int(progress * 100)) percent toward the \(goal)-day goal")
    }

    private func update(animated: Bool) {
        if animated {
            withAnimation(CoachMotion.spring) { displayedProgress = progress }
        } else {
            displayedProgress = progress
        }
    }
}

struct NativeAchievementBadge: View {
    let title: String
    let detail: String
    let icon: String
    let tint: Color
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? tint.opacity(0.15) : Color.secondary.opacity(0.10))
                Circle()
                    .stroke(isUnlocked ? tint.opacity(0.42) : Color.secondary.opacity(0.18), lineWidth: 2)
                Image(systemName: isUnlocked ? icon : "lock.fill")
                    .font(.system(size: 27, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isUnlocked ? tint : Color.secondary)
            }
            .frame(width: 70, height: 70)
            .saturation(isUnlocked ? 1 : 0)
            .opacity(isUnlocked ? 1 : 0.52)

            TeachingText(english: title)
                .font(.system(.caption, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            TeachingText(english: detail)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .accessibilityElement(children: .ignore)
        .teachingAccessibilityLabel("\(title). \(detail)")
        .teachingAccessibilityValue(isUnlocked ? "Unlocked" : "Locked")
    }
}

extension View {
    func germanKeyboardAccessory(text: Binding<String>) -> some View {
        modifier(GermanKeyboardAccessoryModifier(text: text))
    }
}
