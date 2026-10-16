import Foundation
import SwiftUI
import Translation

/// Shows cached teaching-language text immediately and queues missing text for one shared session.
struct TeachingText: View {
    let english: String
    let protectedGerman: [String]
    @AppStorage(TeachingLanguage.storageKey) private var languageCode = TeachingLanguage.defaultLanguage.rawValue
    @ObservedObject private var translations = TeachingTranslationStore.shared

    init(english: String, protectedGerman: [String] = []) {
        self.english = english
        self.protectedGerman = protectedGerman
    }

    private var language: TeachingLanguage { TeachingLanguage.resolve(languageCode) }
    private var payload: TeachingTranslationPayload {
        TeachingTranslationPayload(source: english, protectedGerman: protectedGerman)
    }
    private var requestKey: String {
        TeachingTranslationCache.key(for: payload.translationSource, language: language)
    }
    private var displayedText: String {
        guard language != .english else { return english }
        return payload.restoringGerman(
            in: translations.text(for: payload.translationSource, language: language)
        )
    }

    var body: some View {
        Text(displayedText)
            .environment(\.layoutDirection, language.isRightToLeft ? .rightToLeft : .leftToRight)
            .multilineTextAlignment(language.isRightToLeft ? .trailing : .leading)
            .task(id: requestKey) {
                translations.request(payload.translationSource, language: language)
            }
    }
}

struct TeachingLabel: View {
    let english: String
    let systemImage: String
    let protectedGerman: [String]

    init(english: String, systemImage: String, protectedGerman: [String] = []) {
        self.english = english
        self.systemImage = systemImage
        self.protectedGerman = protectedGerman
    }

    var body: some View {
        Label {
            TeachingText(english: english, protectedGerman: protectedGerman)
        } icon: {
            Image(systemName: systemImage)
        }
    }
}

struct TeachingButton: View {
    let english: String
    let role: ButtonRole?
    let action: () -> Void

    init(
        _ english: String,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.english = english
        self.role = role
        self.action = action
    }

    var body: some View {
        Button(role: role, action: action) {
            TeachingText(english: english)
        }
    }
}

struct TeachingTextField: View {
    let prompt: String
    @Binding var text: String
    var axis: Axis = .horizontal

    @AppStorage(TeachingLanguage.storageKey) private var languageCode = TeachingLanguage.defaultLanguage.rawValue
    @ObservedObject private var translations = TeachingTranslationStore.shared

    private var language: TeachingLanguage { TeachingLanguage.resolve(languageCode) }
    private var requestKey: String { TeachingTranslationCache.key(for: prompt, language: language) }

    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(translations.text(for: prompt, language: language)),
            axis: axis
        )
        .environment(\.layoutDirection, language.isRightToLeft ? .rightToLeft : .leftToRight)
        .multilineTextAlignment(language.isRightToLeft ? .trailing : .leading)
        .accessibilityLabel(translations.text(for: prompt, language: language))
        .task(id: requestKey) {
            translations.request(prompt, language: language)
        }
    }
}

private struct TeachingNavigationTitleModifier: ViewModifier {
    let english: String

    @AppStorage(TeachingLanguage.storageKey) private var languageCode = TeachingLanguage.defaultLanguage.rawValue
    @ObservedObject private var translations = TeachingTranslationStore.shared

    private var language: TeachingLanguage { TeachingLanguage.resolve(languageCode) }
    private var requestKey: String { TeachingTranslationCache.key(for: english, language: language) }

    func body(content: Content) -> some View {
        content
            .navigationTitle(translations.text(for: english, language: language))
            .teachingLanguageSwitcher()
            .task(id: requestKey) {
                translations.request(english, language: language)
            }
    }
}

private struct TeachingAccessibilityLabelModifier: ViewModifier {
    let english: String
    let protectedGerman: [String]

    @AppStorage(TeachingLanguage.storageKey) private var languageCode = TeachingLanguage.defaultLanguage.rawValue
    @ObservedObject private var translations = TeachingTranslationStore.shared

    private var language: TeachingLanguage { TeachingLanguage.resolve(languageCode) }
    private var payload: TeachingTranslationPayload {
        TeachingTranslationPayload(source: english, protectedGerman: protectedGerman)
    }
    private var requestKey: String {
        TeachingTranslationCache.key(for: payload.translationSource, language: language)
    }
    private var label: String {
        guard language != .english else { return english }
        return payload.restoringGerman(
            in: translations.text(for: payload.translationSource, language: language)
        )
    }

    func body(content: Content) -> some View {
        content
            .accessibilityLabel(label)
            .task(id: requestKey) {
                translations.request(payload.translationSource, language: language)
            }
    }
}

private struct TeachingAccessibilityHintModifier: ViewModifier {
    let english: String
    let protectedGerman: [String]

    @AppStorage(TeachingLanguage.storageKey) private var languageCode = TeachingLanguage.defaultLanguage.rawValue
    @ObservedObject private var translations = TeachingTranslationStore.shared

    private var language: TeachingLanguage { TeachingLanguage.resolve(languageCode) }
    private var payload: TeachingTranslationPayload {
        TeachingTranslationPayload(source: english, protectedGerman: protectedGerman)
    }
    private var requestKey: String {
        TeachingTranslationCache.key(for: payload.translationSource, language: language)
    }
    private var hint: String {
        guard language != .english else { return english }
        return payload.restoringGerman(
            in: translations.text(for: payload.translationSource, language: language)
        )
    }

    func body(content: Content) -> some View {
        content
            .accessibilityHint(hint)
            .task(id: requestKey) {
                translations.request(payload.translationSource, language: language)
            }
    }
}

private struct TeachingAccessibilityValueModifier: ViewModifier {
    let english: String
    let protectedGerman: [String]

    @AppStorage(TeachingLanguage.storageKey) private var languageCode = TeachingLanguage.defaultLanguage.rawValue
    @ObservedObject private var translations = TeachingTranslationStore.shared

    private var language: TeachingLanguage { TeachingLanguage.resolve(languageCode) }
    private var payload: TeachingTranslationPayload {
        TeachingTranslationPayload(source: english, protectedGerman: protectedGerman)
    }
    private var requestKey: String {
        TeachingTranslationCache.key(for: payload.translationSource, language: language)
    }
    private var value: String {
        guard language != .english else { return english }
        return payload.restoringGerman(
            in: translations.text(for: payload.translationSource, language: language)
        )
    }

    func body(content: Content) -> some View {
        content
            .accessibilityValue(value)
            .task(id: requestKey) {
                translations.request(payload.translationSource, language: language)
            }
    }
}

extension View {
    func teachingNavigationTitle(_ english: String) -> some View {
        modifier(TeachingNavigationTitleModifier(english: english))
    }

    func teachingAccessibilityLabel(
        _ english: String,
        protectedGerman: [String] = []
    ) -> some View {
        modifier(
            TeachingAccessibilityLabelModifier(
                english: english,
                protectedGerman: protectedGerman
            )
        )
    }

    func teachingAccessibilityHint(
        _ english: String,
        protectedGerman: [String] = []
    ) -> some View {
        modifier(
            TeachingAccessibilityHintModifier(
                english: english,
                protectedGerman: protectedGerman
            )
        )
    }

    func teachingAccessibilityValue(
        _ english: String,
        protectedGerman: [String] = []
    ) -> some View {
        modifier(
            TeachingAccessibilityValueModifier(
                english: english,
                protectedGerman: protectedGerman
            )
        )
    }
}

struct TeachingTranslationPayload {
    let translationSource: String
    let replacements: [(token: String, german: String)]

    init(source: String, protectedGerman: [String]) {
        var masked = source
        var replacements: [(String, String)] = []
        let requestedSegments = protectedGerman
            + GermanContentProtection.inlineSegments(in: source)
            + GermanContentProtection.standaloneGermanSegments(in: source)
        let matchingSegments = requestedSegments.compactMap {
            GermanContentProtection.matchingSegment($0, in: source)
        }
        let deduplicatedSegments = Array(Set(matchingSegments))
        let uniqueSegments = deduplicatedSegments.sorted {
            $0.count == $1.count ? $0 < $1 : $0.count > $1.count
        }

        for german in uniqueSegments {
            let token = "ZXQGERMAN\(replacements.count)QXZ"
            let next = GermanContentProtection.replacingExactSegment(
                german,
                with: token,
                in: masked
            )
            guard next != masked else { continue }
            masked = next
            replacements.append((token, german))
        }
        translationSource = masked
        self.replacements = replacements
    }

    var hasSupportLanguageText: Bool {
        let withoutTokens = translationSource.replacingOccurrences(
            of: #"ZXQGERMAN\d+QXZ"#,
            with: "",
            options: .regularExpression
        )
        return withoutTokens.range(
            of: #"[\p{L}\p{N}]"#,
            options: .regularExpression
        ) != nil
    }

    func restoringGerman(in translated: String) -> String {
        replacements.reduce(translated) { result, replacement in
            result.replacingOccurrences(
                of: replacement.token,
                with: replacement.german,
                options: [.caseInsensitive]
            )
        }
    }
}

enum GermanContentProtection {
    static let grammarTerms = [
        "Konjunktiv II", "Plusquamperfekt", "Partizip II",
        "N-Deklination", "Nominalisierung", "Relativsatz",
        "Nominativ", "Akkusativ", "Dativ", "Genitiv",
        "Perfekt", "Präteritum", "Passiv",
        "Ä", "Ö", "Ü", "ß",
        "um ... zu", "um...zu", "ohne ... zu", "ohne...zu",
        "statt ... zu", "statt...zu",
        "sein", "haben", "werden",
        "ich", "du", "er", "sie", "es", "wir", "ihr", "Sie",
        "mich", "dich", "ihn", "uns", "euch", "ihnen",
        "mir", "dir", "ihm",
        "der", "die", "das", "den", "dem", "des",
        "ein", "eine", "einen", "einem", "einer", "eines",
        "kein", "keine", "keinen", "keinem", "keiner", "keines",
        "nicht", "weil", "dass", "wenn", "obwohl", "trotzdem",
        "damit", "als", "bevor", "nachdem", "indem", "sodass",
        "doch", "mal", "eben", "wohl",
    ]

    static func inlineSegments(in source: String) -> [String] {
        let terms = grammarTerms.flatMap { term -> [String] in
            let escaped = NSRegularExpression.escapedPattern(for: term)
            let pattern = "(?<!\\w)\(escaped)(?!\\w)"
            guard let matcher = try? NSRegularExpression(
                pattern: pattern,
                options: .caseInsensitive
            ) else { return [] }
            let range = NSRange(source.startIndex..., in: source)
            return matcher.matches(in: source, range: range).compactMap {
                Range($0.range, in: source).map { String(source[$0]) }
            }
        }
        return terms + quotedGermanSegments(in: source)
    }

    static func standaloneGermanSegments(in source: String) -> [String] {
        let lower = " \(source.lowercased()) "
        let englishSignals = [
            " the ", " a ", " an ", " use ", " uses ", " is ", " are ",
            " with ", " for ", " from ", " after ", " before ", " means ",
            " sentence ", " answer ", " complete ", " choose ", " translate "
        ]
        guard !englishSignals.contains(where: lower.contains) else { return [] }

        let germanSignals = grammarTerms + [
            "war", "waren", "hatte", "hatten", "gelernt", "gegangen",
            "gestern", "früher", "heute", "morgen", "bitte"
        ]
        let containsGermanSignal = germanSignals.contains { term in
            let escaped = NSRegularExpression.escapedPattern(for: term)
            return source.range(
                of: "(?<!\\w)\(escaped)(?!\\w)",
                options: [.regularExpression, .caseInsensitive]
            ) != nil
        }
        let hasGermanCharacter = source.range(
            of: "[äöüÄÖÜß]",
            options: .regularExpression
        ) != nil
        return containsGermanSignal || hasGermanCharacter ? [source] : []
    }

    static func matchingSegment(_ candidate: String, in source: String) -> String? {
        let cleaned = candidate.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return nil }
        let isSingleWord = cleaned.unicodeScalars.allSatisfy {
            CharacterSet.letters.union(.decimalDigits).contains($0)
        }
        if isSingleWord {
            let escaped = NSRegularExpression.escapedPattern(for: cleaned)
            let pattern = "(?<!\\w)\(escaped)(?!\\w)"
            let exactRange = source.range(of: pattern, options: .regularExpression)
            let range = exactRange ?? source.range(
                of: pattern,
                options: [.regularExpression, .caseInsensitive]
            )
            guard let range else { return nil }
            return String(source[range])
        }
        guard let range = source.range(of: cleaned) else { return nil }
        return String(source[range])
    }

    static func replacingExactSegment(
        _ segment: String,
        with replacement: String,
        in source: String
    ) -> String {
        let isSingleWord = segment.unicodeScalars.allSatisfy {
            CharacterSet.letters.union(.decimalDigits).contains($0)
        }
        guard isSingleWord else {
            return source.replacingOccurrences(of: segment, with: replacement)
        }
        let escaped = NSRegularExpression.escapedPattern(for: segment)
        guard let matcher = try? NSRegularExpression(
            pattern: "(?<!\\w)\(escaped)(?!\\w)"
        ) else { return source }
        let range = NSRange(source.startIndex..., in: source)
        return matcher.stringByReplacingMatches(
            in: source,
            range: range,
            withTemplate: NSRegularExpression.escapedTemplate(for: replacement)
        )
    }

    private static func quotedGermanSegments(in source: String) -> [String] {
        guard let matcher = try? NSRegularExpression(pattern: "“([^”]+)”")
        else { return [] }
        let range = NSRange(source.startIndex..., in: source)
        return matcher.matches(in: source, range: range).compactMap { match in
            guard let innerRange = Range(match.range(at: 1), in: source),
                  let fullRange = Range(match.range, in: source)
            else { return nil }
            let inner = String(source[innerRange])
            guard looksLikeGerman(inner) else { return nil }
            return String(source[fullRange])
        }
    }

    private static func looksLikeGerman(_ value: String) -> Bool {
        if value.range(of: "[äöüÄÖÜß]", options: .regularExpression) != nil {
            return true
        }
        let signals = grammarTerms + [
            "ist", "sind", "bin", "bist", "hat", "habe", "hast",
            "kann", "können", "muss", "müssen", "wird", "würde",
            "mit", "für", "auf", "zu", "im", "am", "von", "nach",
            "und", "aber", "oder", "auch"
        ]
        return signals.contains { term in
            let escaped = NSRegularExpression.escapedPattern(for: term)
            return value.range(
                of: "(?<!\\w)\(escaped)(?!\\w)",
                options: [.regularExpression, .caseInsensitive]
            ) != nil
        } || (!value.contains(" ") && value.first?.isUppercase == true)
    }

    static func exercisePrompt(
        _ prompt: String,
        answer: String? = nil
    ) -> [String] {
        var protected: [String] = []
        let lower = prompt.lowercased()
        let supportOnlyPrefixes = ["translate:", "translate for "]

        if !supportOnlyPrefixes.contains(where: lower.hasPrefix),
           let colon = prompt.firstIndex(of: ":") {
            let tailStart = prompt.index(after: colon)
            var tail = String(prompt[tailStart...])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if let hintStart = tail.range(of: " (") {
                tail = String(tail[..<hintStart.lowerBound])
            }
            if !tail.isEmpty {
                protected.append(tail)
            }
        } else if !looksLikeSupportInstruction(lower) {
            protected.append(prompt)
        }

        if let answer,
           !answer.isEmpty,
           prompt.range(of: answer, options: [.caseInsensitive, .diacriticInsensitive]) != nil {
            protected.append(answer)
        }
        return protected
    }

    private static func looksLikeSupportInstruction(_ lower: String) -> Bool {
        [
            "what ", "which ", "why ", "how ", "where ", "when ", "choose ",
            "fill ", "build ", "reorder", "translate", "complete", "spell ",
            "formal ", "best ", "write ", "say "
        ].contains(where: lower.hasPrefix)
    }
}

enum TeachingTranslationState: Equatable {
    case english
    case checking
    case preparing
    case ready
    case unavailable
    case failed
}

enum BundledTeachingTranslationCatalog {
    static func translation(for source: String, language: TeachingLanguage) -> String? {
        switch language {
        case .amharic:
            exactAmharicTranslation(for: source)
                ?? AmharicCurriculumComposer.translation(
                    for: source,
                    lookup: exactAmharicTranslation
                )
        case .tigrinya:
            tigrinya[source] ?? exactGeneratedTranslation(for: source, language: language)
        case .english:
            nil
        default:
            exactGeneratedTranslation(for: source, language: language)
        }
    }

    static var amharicTranslationCount: Int {
        Set(amharic.keys).union(Set(generatedAmharic.keys)).count
    }

    static func translationCount(for language: TeachingLanguage) -> Int {
        switch language {
        case .english:
            0
        case .amharic:
            amharicTranslationCount
        case .tigrinya:
            Set(tigrinya.keys)
                .union(Set(generatedCatalogs[language]?.keys.map { $0 } ?? []))
                .count
        default:
            generatedCatalogs[language]?.count ?? 0
        }
    }

    private static let generatedCatalogs: [TeachingLanguage: [String: String]] = {
        let bundles = [
            Bundle.main,
            Bundle(for: TeachingTranslationBundleToken.self)
        ] + Bundle.allBundles

        var catalogs: [TeachingLanguage: [String: String]] = [:]
        for language in TeachingLanguage.allCases where language != .english {
            let resourceName = language == .amharic
                ? "amharic_translations"
                : "\(language.rawValue)_translations"
            for bundle in bundles {
                guard let url = bundle.url(forResource: resourceName, withExtension: "json"),
                      let data = try? Data(contentsOf: url),
                      let catalog = try? JSONDecoder().decode([String: String].self, from: data)
                else { continue }
                catalogs[language] = catalog
                break
            }
        }
        return catalogs
    }()

    private static var generatedAmharic: [String: String] {
        generatedCatalogs[.amharic] ?? [:]
    }

    private static let foldedAmharic: [String: String] = {
        var translations: [String: String] = [:]
        for (source, target) in generatedAmharic {
            translations[source.folding(
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: Locale(identifier: "en")
            )] = target
        }
        for (source, target) in amharic {
            translations[source.folding(
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: Locale(identifier: "en")
            )] = target
        }
        return translations
    }()

    private static func exactAmharicTranslation(for source: String) -> String? {
        amharic[source]
            ?? generatedAmharic[source]
            ?? foldedAmharic[source.folding(
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: Locale(identifier: "en")
            )]
    }

    private static func exactGeneratedTranslation(
        for source: String,
        language: TeachingLanguage
    ) -> String? {
        guard let catalog = generatedCatalogs[language] else { return nil }
        if let translation = catalog[source] {
            return translation
        }
        let foldedSource = source.folding(
            options: [.caseInsensitive, .diacriticInsensitive],
            locale: Locale(identifier: "en")
        )
        return catalog.first { key, _ in
            key.folding(
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: Locale(identifier: "en")
            ) == foldedSource
        }?.value
    }

    private static let amharic: [String: String] = [
        "Word meanings, grammar explanations, instructions, and feedback use this language. German examples stay German.":
            "የቃላት ትርጉሞች፣ የሰዋሰው ማብራሪያዎች፣ መመሪያዎች እና ግብረመልስ በዚህ ቋንቋ ይቀርባሉ። የጀርመንኛ ምሳሌዎች በጀርመንኛ ይቆያሉ።",
        "Singular": "ነጠላ",
        "Plural": "ብዙ",
        "Usually no plural": "ብዙውን ጊዜ ብዙ ቁጥር የለውም",
        "This noun is normally used in the plural.": "ይህ ስም ብዙውን ጊዜ በብዙ ቁጥር ይጠቀማል።",
        "Recall the picture, article, singular, and plural.": "ምስሉን፣ አርቲክሉን፣ ነጠላና ብዙ ቁጥሩን አስታውስ።",
        "Recall the meaning, article, and plural": "ትርጉሙን፣ አርቲክሉን እና ብዙ ቁጥሩን አስታውስ",
        "Tap the card to reveal the answer": "መልሱን ለማየት ካርዱን ይንኩ",
        "Reveal meaning": "ትርጉሙን አሳይ",
        "Meaning": "ትርጉም",
        "Example": "ምሳሌ",
        "Build the German structure": "የጀርመንኛውን አወቃቀር ገንባ",
        "Tap words in order. The reason changes with each sentence position.":
            "ቃላቱን በቅደም ተከተል ይንኩ። ምክንያቱ እንደ ዓረፍተ ነገሩ ቦታ ይለወጣል።",
        "Meaning to express": "ለመግለጽ የታሰበው ትርጉም",
        "Your sentence": "የእርስዎ ዓረፍተ ነገር",
        "Choose the sentence opening": "የዓረፍተ ነገሩን መጀመሪያ ይምረጡ",
        "Choose the next word": "ቀጣዩን ቃል ይምረጡ",
        "Try a different position": "ሌላ ቦታ ይሞክሩ",
        "Perfect structure": "ትክክለኛ አወቃቀር",
        "Sentence structure complete": "የዓረፍተ ነገሩ አወቃቀር ተጠናቋል",
        "You built the sentence without a positioning mistake.": "ዓረፍተ ነገሩን ያለ የቃላት አቀማመጥ ስህተት ገንብተዋል።",
        "You corrected the word order and completed the sentence.": "የቃላቱን ቅደም ተከተል አስተካክለው ዓረፍተ ነገሩን ጨርሰዋል።",
        "Reset": "እንደገና ጀምር",
        "Hear model": "ትክክለኛውን አዳምጥ",
        "Correct": "ትክክል",
        "Try again": "እንደገና ሞክር",
        "Continue lesson": "ትምህርቱን ቀጥል",
        "Practice again": "እንደገና ተለማመድ"
    ]

    private static let tigrinya: [String: String] = [
        "Word meanings, grammar explanations, instructions, and feedback use this language. German examples stay German.":
            "ትርጉም ቃላት፣ መብርሂ ሰዋስው፣ መምርሒታትን ግብረመልስን በዚ ቋንቋ ይቐርቡ። ናይ ጀርመንኛ ኣብነታት ብጀርመንኛ ይቕጽሉ።",
        "Singular": "ነጠላ",
        "Plural": "ብዙሕ",
        "Usually no plural": "መብዛሕትኡ ብዙሕ ቁጽሪ የብሉን",
        "This noun is normally used in the plural.": "እዚ ስም መብዛሕትኡ ብብዙሕ ቁጽሪ ይጥቀም።",
        "Recall the picture, article, singular, and plural.": "ስእሉ፣ ኣርቲክሉ፣ ነጠላን ብዙሕን ዘክር።",
        "Recall the meaning, article, and plural": "ትርጉሙ፣ ኣርቲክሉን ብዙሕ ቁጽሩን ዘክር",
        "Tap the card to reveal the answer": "መልሲ ንምርኣይ ነቲ ካርድ ጠውቕ",
        "Reveal meaning": "ትርጉም ኣርኢ",
        "Meaning": "ትርጉም",
        "Example": "ኣብነት",
        "Build the German structure": "ኣቃውማ ጀርመንኛ ስራሕ",
        "Tap words in order. The reason changes with each sentence position.":
            "ነቶም ቃላት ብቕደም ተኸተል ጠውቕ። ምኽንያቱ ምስ ቦታ ሓረግ ይቕየር።",
        "Meaning to express": "ክትገልጾ እትደሊ ትርጉም",
        "Your sentence": "ሓረግካ",
        "Choose the sentence opening": "መጀመርታ ሓረግ ምረጽ",
        "Choose the next word": "ዝቕጽል ቃል ምረጽ",
        "Try a different position": "ካልእ ቦታ ፈትን",
        "Perfect structure": "ትኽክለኛ ኣቃውማ",
        "Sentence structure complete": "ኣቃውማ ሓረግ ተዛዚሙ",
        "You built the sentence without a positioning mistake.": "ነቲ ሓረግ ብዘይ ጌጋ ኣቀማምጣ ቃላት ሰሪሕካዮ።",
        "You corrected the word order and completed the sentence.": "ቅደም ተኸተል ቃላት ኣሪምካ ነቲ ሓረግ ወዲእካዮ።",
        "Reset": "እንደገና ጀምር",
        "Hear model": "ትኽክለኛ ኣብነት ስማዕ",
        "Correct": "ትኽክል",
        "Try again": "እንደገና ፈትን",
        "Continue lesson": "ትምህርቲ ቀጽል",
        "Practice again": "እንደገና ተለማመድ"
    ]
}

private enum AmharicCurriculumComposer {
    typealias Lookup = (String) -> String?

    static func translation(for source: String, lookup: Lookup) -> String? {
        manual[source]
            ?? afterPracticing(source, lookup: lookup)
            ?? generatedScenario(source, lookup: lookup)
            ?? canDoRecap(source, lookup: lookup)
            ?? recognitionRecap(source, lookup: lookup)
            ?? reviewDeckRecap(source, lookup: lookup)
            ?? writingPrompt(source, lookup: lookup)
            ?? rolePlayPrompt(source, lookup: lookup)
            ?? textTypeChecklist(source, lookup: lookup)
            ?? grammarChecklist(source, lookup: lookup)
    }

    private static func afterPracticing(_ source: String, lookup: Lookup) -> String? {
        guard let body = source.removingPrefix("After practicing "),
              let parts = body.splitOnce(separator: ", complete this transfer mission: "),
              let grammar = component(parts.before, lookup: lookup),
              let task = component(normalizedTask(parts.after), lookup: lookup)
        else { return nil }
        return "የ\(grammar) ልምምድ ካደረጉ በኋላ፣ ይህን የተግባር ተልዕኮ ያጠናቅቁ፡ \(task)"
    }

    private static func generatedScenario(_ source: String, lookup: Lookup) -> String? {
        guard let body = source.removingPrefix("The setting is "),
              let contextAndRest = body.splitOnce(separator: ". You need "),
              let complexityAndRest = contextAndRest.after.splitOnce(
                separator: " The active vocabulary theme is "
              ),
              let themeAndRest = complexityAndRest.after.splitOnce(separator: ". I can "),
              let canDoAndGrammar = themeAndRest.after.splitOnce(separator: ". Use "),
              let grammar = canDoAndGrammar.after.removingSuffix(
                " as the language tool for the task."
              ),
              let context = component(contextAndRest.before, lookup: lookup),
              let complexity = component(
                "You need \(complexityAndRest.before)",
                lookup: lookup
              ),
              let canDo = component("I can \(canDoAndGrammar.before).", lookup: lookup),
              let grammarTranslation = component(grammar, lookup: lookup)
        else { return nil }

        let theme = themeAndRest.before
        return "የትምህርቱ ሁኔታ \(context) ነው። \(complexity) ንቁው የጀርመንኛ ቃላት ጭብጥ \(theme) ነው። \(canDo) ለተግባሩ \(grammarTranslation) እንደ የቋንቋ መሣሪያ ይጠቀሙ።"
    }

    private static func canDoRecap(_ source: String, lookup: Lookup) -> String? {
        guard let body = source.removingPrefix("With "),
              let grammarAndRest = body.splitOnce(separator: ", you can now act in "),
              let fieldAndAction = grammarAndRest.after.splitOnce(separator: ": "),
              let grammar = component(grammarAndRest.before, lookup: lookup),
              let field = component(fieldAndAction.before, lookup: lookup),
              let action = component("I can \(fieldAndAction.after)", lookup: lookup)
        else { return nil }
        return "በ\(grammar)፣ አሁን በ\(field) ሁኔታ ይህን ማድረግ ይችላሉ፡ \(action)"
    }

    private static func recognitionRecap(_ source: String, lookup: Lookup) -> String? {
        guard let body = source.removingPrefix("You can recognize "),
              let parts = body.splitOnce(separator: " in a sentence such as “"),
              let german = parts.after.removingSuffix("”."),
              let grammar = component(parts.before, lookup: lookup)
        else { return nil }
        return "\(grammar) እንደ “\(german)” ባለ የጀርመንኛ ዓረፍተ ነገር ውስጥ ማወቅ ይችላሉ።"
    }

    private static func reviewDeckRecap(_ source: String, lookup: Lookup) -> String? {
        guard let body = source.removingPrefix("Your "),
              let grammarAndRest = body.splitOnce(separator: " review deck gained "),
              let countAndTheme = grammarAndRest.after.splitOnce(
                separator: " useful words from "
              ),
              let theme = countAndTheme.after.removingSuffix("."),
              let grammar = component(grammarAndRest.before, lookup: lookup)
        else { return nil }
        return "የ\(grammar) የክለሳ ካርዶችዎ \(countAndTheme.before) ጠቃሚ የጀርመንኛ ቃላትን ከ\(theme) ጭብጥ አግኝተዋል።"
    }

    private static func writingPrompt(_ source: String, lookup: Lookup) -> String? {
        guard let body = source.removingPrefix("Write a "),
              let parts = body.splitOnce(separator: " for this situation: "),
              let textType = component(parts.before, lookup: lookup),
              let task = component(normalizedTask(parts.after), lookup: lookup)
        else { return nil }
        return "ለዚህ ሁኔታ \(textType) ይጻፉ፡ \(task)"
    }

    private static func rolePlayPrompt(_ source: String, lookup: Lookup) -> String? {
        let ending = " Speak in complete turns, react to the other person, and confirm the next step."
        guard let body = source.removingPrefix("Role-play a "),
              let prompt = body.removingSuffix(ending),
              let parts = prompt.splitOnce(separator: " situation: "),
              let field = component(parts.before, lookup: lookup),
              let task = component(normalizedTask(parts.after), lookup: lookup)
        else { return nil }
        return "የ\(field) ሁኔታን በሚና ጨዋታ ይለማመዱ፡ \(task) በሙሉ ዓረፍተ ነገሮች ይናገሩ፣ ለሌላው ሰው ምላሽ ይስጡ እና ቀጣዩን እርምጃ ያረጋግጡ።"
    }

    private static func grammarChecklist(_ source: String, lookup: Lookup) -> String? {
        guard let body = source.removingPrefix("I used "),
              let grammar = body.removingSuffix(" at least twice."),
              let translatedGrammar = component(grammar, lookup: lookup)
        else { return nil }
        return "\(translatedGrammar) ቢያንስ ሁለት ጊዜ ተጠቅሜያለሁ።"
    }

    private static func textTypeChecklist(_ source: String, lookup: Lookup) -> String? {
        guard let body = source.removingPrefix("I used the conventions of a "),
              let textType = body.removingSuffix("."),
              let translatedTextType = component(textType, lookup: lookup)
        else { return nil }
        return "የ\(translatedTextType) አጻጻፍ ደንቦችን ተጠቅሜያለሁ።"
    }

    private static func normalizedTask(_ source: String) -> String {
        source.replacingOccurrences(of: ", then ", with: ", and ")
    }

    private static func component(_ source: String, lookup: Lookup) -> String? {
        let cleaned = source.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return nil }
        return components[cleaned]
            ?? foldedComponents[cleaned.folding(
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: Locale(identifier: "en")
            )]
            ?? manual[cleaned]
            ?? lookup(cleaned)
    }

    private static let manual: [String: String] = [
        "Arrive and connect": "ይድረሱ እና ይገናኙ",
        "Use local services": "የአካባቢ አገልግሎቶችን ይጠቀሙ",
        "Work and participate": "ይስሩ እና ይሳተፉ",
        "Communicate independently": "ራስዎን ችለው ይግባቡ",
        "B1 and DTZ readiness": "ለB1 እና DTZ ዝግጁነት",
        "Basiskurs 1 · Identity, first contacts, and essential daily tasks":
            "Basiskurs 1 · ማንነት፣ የመጀመሪያ ግንኙነቶችና አስፈላጊ የዕለት ተዕለት ተግባራት",
        "Basiskurs 2 · Mobility, health, work, learning, and public services":
            "Basiskurs 2 · መጓጓዣ፣ ጤና፣ ሥራ፣ ትምህርትና ሕዝባዊ አገልግሎቶች",
        "Basiskurs 3 · Housing, travel, health, work, and family services":
            "Basiskurs 3 · መኖሪያ ቤት፣ ጉዞ፣ ጤና፣ ሥራና የቤተሰብ አገልግሎቶች",
        "Aufbausprachkurs 1 · Communication, public life, education, and administration":
            "Aufbausprachkurs 1 · ግንኙነት፣ ሕዝባዊ ሕይወት፣ ትምህርትና አስተዳደር",
        "Aufbausprachkurs 2 · Work, education, media, society, and health":
            "Aufbausprachkurs 2 · ሥራ፣ ትምህርት፣ ሚዲያ፣ ማህበረሰብና ጤና",
        "Aufbausprachkurs 3 · Formal requests, conflict resolution, participation, and exam transfer":
            "Aufbausprachkurs 3 · መደበኛ ጥያቄዎች፣ ግጭት መፍታት፣ ተሳትፎና የፈተና ልምምድ"
    ]

    private static let components: [String: String] = [
        "a registration, neighborhood, or personal-background conversation":
            "የምዝገባ፣ የሰፈር ወይም የግል ታሪክ ውይይት",
        "a conversation where people have different experiences or preferences":
            "ሰዎች የተለያዩ ልምዶች ወይም ምርጫዎች ያሏቸው ውይይት",
        "an everyday disagreement that needs a calm, fair solution":
            "ረጋ ያለና ፍትሐዊ መፍትሔ የሚፈልግ የዕለት ተዕለት አለመግባባት",
        "a first meeting, invitation, or conversation with neighbors and colleagues":
            "የመጀመሪያ ስብሰባ፣ ግብዣ ወይም ከጎረቤቶችና ባልደረቦች ጋር ውይይት",
        "a German lesson, study group, or exam-feedback conversation":
            "የጀርመንኛ ትምህርት፣ የጥናት ቡድን ወይም የፈተና ግብረመልስ ውይይት",
        "an appointment, phone call, or letter involving a public office":
            "ከመንግሥታዊ ቢሮ ጋር የተያያዘ ቀጠሮ፣ ስልክ ጥሪ ወይም ደብዳቤ",
        "a workplace handover, schedule discussion, or team conversation":
            "የሥራ ርክክብ፣ የጊዜ ሰሌዳ ውይይት ወይም የቡድን ውይይት",
        "a vacancy inquiry, application, or interview":
            "የክፍት የሥራ ቦታ ጥያቄ፣ ማመልከቻ ወይም ቃለ መጠይቅ",
        "a course registration, qualification, or education-advice appointment":
            "የኮርስ ምዝገባ፣ የብቃት ወይም የትምህርት ምክር ቀጠሮ",
        "a payment, account, contract, or insurance inquiry":
            "የክፍያ፣ የሒሳብ፣ የውል ወይም የኢንሹራንስ ጥያቄ",
        "a daycare, school, or parent-teacher conversation":
            "የመዋዕለ ሕፃናት፣ የትምህርት ቤት ወይም የወላጅና መምህር ውይይት",
        "a shop, service counter, order, or consumer problem":
            "የሱቅ፣ የአገልግሎት ቆጣሪ፣ የትዕዛዝ ወይም የሸማች ችግር",
        "a medical appointment, pharmacy visit, or health-insurance conversation":
            "የሕክምና ቀጠሮ፣ የፋርማሲ ጉብኝት ወይም የጤና ኢንሹራንስ ውይይት",
        "a message, website, news item, app, or online service":
            "መልዕክት፣ ድረ ገጽ፣ ዜና፣ መተግበሪያ ወይም የመስመር ላይ አገልግሎት",
        "a journey, ticket purchase, route question, or travel disruption":
            "ጉዞ፣ ትኬት ግዢ፣ የመንገድ ጥያቄ ወይም የጉዞ መስተጓጎል",
        "a classroom task that requires clarification and cooperation":
            "ማብራሪያና ትብብር የሚፈልግ የክፍል ውስጥ ተግባር",
        "an apartment search, tenancy conversation, or repair request":
            "የአፓርታማ ፍለጋ፣ የኪራይ ውይይት ወይም የጥገና ጥያቄ",
        "Explain the relevant personal facts, ask one clarifying question, and confirm what happens next.":
            "አስፈላጊዎቹን የግል መረጃዎች ያብራሩ፣ አንድ ማብራሪያ ጥያቄ ይጠይቁ እና ቀጥሎ ምን እንደሚሆን ያረጋግጡ።",
        "State your view, give a reason, react respectfully, and identify one point of agreement.":
            "አስተያየትዎን ይግለጹ፣ ምክንያት ይስጡ፣ በአክብሮት ምላሽ ይስጡ እና አንድ የስምምነት ነጥብ ይለዩ።",
        "Describe the problem without blame, listen to the response, and propose a workable solution.":
            "ማንንም ሳይወቅሱ ችግሩን ይግለጹ፣ ምላሹን ያዳምጡ እና ተግባራዊ መፍትሔ ያቅርቡ።",
        "Open the conversation, exchange information, respond to a detail, and make or decline an arrangement politely.":
            "ውይይቱን ይጀምሩ፣ መረጃ ይለዋወጡ፣ ለአንድ ዝርዝር ምላሽ ይስጡ እና ቀጠሮን በጨዋነት ይቀበሉ ወይም ይከልክሉ።",
        "Identify what is difficult, ask for useful feedback, and choose one specific practice step.":
            "የሚያስቸግርዎትን ይለዩ፣ ጠቃሚ ግብረመልስ ይጠይቁ እና አንድ ግልጽ የልምምድ እርምጃ ይምረጡ።",
        "State your request, identify the relevant document or deadline, and repeat the agreed next step.":
            "ጥያቄዎን ይግለጹ፣ አስፈላጊውን ሰነድ ወይም የጊዜ ገደብ ይለዩ እና የተስማሙበትን ቀጣይ እርምጃ ይድገሙ።",
        "Explain the work situation, check the other person's understanding, and agree who will do what by when.":
            "የሥራውን ሁኔታ ያብራሩ፣ ሌላው ሰው መረዳቱን ያረጋግጡ እና ማን ምንን መቼ እንደሚያደርግ ይስማሙ።",
        "Present relevant experience, answer one follow-up question, and ask about the role or next stage.":
            "ተዛማጅ ልምድዎን ያቅርቡ፣ አንድ ተከታታይ ጥያቄ ይመልሱ እና ስለ ሥራው ወይም ቀጣዩ ደረጃ ይጠይቁ።",
        "Explain your goal, compare available routes, and ask about requirements and the next application step.":
            "ግብዎን ያብራሩ፣ ያሉትን መንገዶች ያወዳድሩ እና ስለ መስፈርቶችና ቀጣዩ የማመልከቻ እርምጃ ይጠይቁ።",
        "Identify the transaction or contract, explain the issue, and request a written or clearly confirmed solution.":
            "ግብይቱን ወይም ውሉን ይለዩ፣ ችግሩን ያብራሩ እና በጽሑፍ ወይም በግልጽ የተረጋገጠ መፍትሔ ይጠይቁ።",
        "Share the important observation, ask how the child is doing, and agree on one support step.":
            "አስፈላጊውን ምልከታ ያጋሩ፣ ልጁ እንዴት እንዳለ ይጠይቁ እና በአንድ የድጋፍ እርምጃ ላይ ይስማሙ።",
        "Ask for the product or service, check the key condition, and complete or correct the transaction.":
            "ምርቱን ወይም አገልግሎቱን ይጠይቁ፣ ዋናውን ሁኔታ ያረጋግጡ እና ግብይቱን ያጠናቅቁ ወይም ያስተካክሉ።",
        "Describe the main symptom and duration, answer follow-up questions, and repeat the advice or appointment details.":
            "ዋናውን ምልክትና ቆይታውን ይግለጹ፣ ተከታታይ ጥያቄዎችን ይመልሱ እና ምክሩን ወይም የቀጠሮውን ዝርዝር ይድገሙ።",
        "Identify the source and purpose, extract the key information, and decide on a safe response.":
            "ምንጩንና ዓላማውን ይለዩ፣ ዋናውን መረጃ ያውጡ እና ደህንነቱ የተጠበቀ ምላሽ ይምረጡ።",
        "Explain where you need to go, confirm route and time details, and handle one change or delay.":
            "ወዴት መሄድ እንዳለብዎት ያብራሩ፣ የመንገድና የሰዓት ዝርዝሮችን ያረጋግጡ እና አንድ ለውጥ ወይም መዘግየት ይፍቱ።",
        "Clarify the instruction, contribute your answer, compare it with a partner, and note one correction.":
            "መመሪያውን ያብራሩ፣ መልስዎን ያቅርቡ፣ ከአጋር ጋር ያወዳድሩ እና አንድ እርማት ይመዝግቡ።",
        "Describe the apartment or problem precisely, ask about costs or responsibility, and agree on the next action.":
            "አፓርታማውን ወይም ችግሩን በትክክል ይግለጹ፣ ስለ ወጪ ወይም ኃላፊነት ይጠይቁ እና በቀጣዩ እርምጃ ላይ ይስማሙ።",
        "Migration and identity": "ፍልሰትና ማንነት",
        "Feelings and opinions": "ስሜቶችና አስተያየቶች",
        "Disagreement and conflict": "አለመግባባትና ግጭት",
        "Social contacts": "ማህበራዊ ግንኙነቶች",
        "Learning German": "ጀርመንኛ መማር",
        "Public offices": "መንግሥታዊ ቢሮዎች",
        "Work": "ሥራ",
        "Job search": "ሥራ ፍለጋ",
        "Education and training": "ትምህርትና ሥልጠና",
        "Banks and insurance": "ባንኮችና ኢንሹራንስ",
        "Childcare and school": "የሕፃናት እንክብካቤና ትምህርት ቤት",
        "Shopping and services": "ግብይትና አገልግሎቶች",
        "Health": "ጤና",
        "Media use": "የሚዲያ አጠቃቀም",
        "Mobility": "መጓጓዣ",
        "Course participation": "የኮርስ ተሳትፎ",
        "Housing": "መኖሪያ ቤት",
        "structured personal statement": "የተደራጀ የግል መግለጫ",
        "personal-information message": "የግል መረጃ መልዕክት",
        "short opinion text": "አጭር የአስተያየት ጽሑፍ",
        "personal message": "የግል መልዕክት",
        "solution-focused complaint": "መፍትሔ ላይ ያተኮረ ቅሬታ",
        "problem-and-solution message": "የችግርና መፍትሔ መልዕክት",
        "message or invitation": "መልዕክት ወይም ግብዣ",
        "learning reflection": "የትምህርት ነጸብራቅ",
        "formal request": "መደበኛ ጥያቄ",
        "appointment or document inquiry": "የቀጠሮ ወይም የሰነድ ጥያቄ",
        "workplace message": "የሥራ ቦታ መልዕክት",
        "application paragraph": "የማመልከቻ አንቀጽ",
        "job inquiry": "የሥራ ጥያቄ",
        "course or qualification inquiry": "የኮርስ ወይም የብቃት ጥያቄ",
        "account or contract inquiry": "የሒሳብ ወይም የውል ጥያቄ",
        "message to daycare or school": "ለመዋዕለ ሕፃናት ወይም ለትምህርት ቤት መልዕክት",
        "shopping note": "የግብይት ማስታወሻ",
        "service request": "የአገልግሎት ጥያቄ",
        "appointment or health message": "የቀጠሮ ወይም የጤና መልዕክት",
        "source summary": "የምንጭ ማጠቃለያ",
        "information note": "የመረጃ ማስታወሻ",
        "travel inquiry": "የጉዞ ጥያቄ",
        "study note": "የጥናት ማስታወሻ",
        "documented repair request": "በሰነድ የተደገፈ የጥገና ጥያቄ",
        "housing inquiry": "የመኖሪያ ቤት ጥያቄ"
    ]

    private static let foldedComponents: [String: String] = {
        var result: [String: String] = [:]
        for (source, target) in components {
            result[source.folding(
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: Locale(identifier: "en")
            )] = target
        }
        return result
    }()
}

private extension String {
    func removingPrefix(_ prefix: String) -> String? {
        guard hasPrefix(prefix) else { return nil }
        return String(dropFirst(prefix.count))
    }

    func removingSuffix(_ suffix: String) -> String? {
        guard hasSuffix(suffix) else { return nil }
        return String(dropLast(suffix.count))
    }

    func splitOnce(separator: String) -> (before: String, after: String)? {
        guard let range = range(of: separator) else { return nil }
        return (String(self[..<range.lowerBound]), String(self[range.upperBound...]))
    }
}

private final class TeachingTranslationBundleToken: NSObject {}

@MainActor
final class TeachingTranslationStore: ObservableObject {
    static let shared = TeachingTranslationStore()

    @Published private(set) var state: TeachingTranslationState = .english
    @Published private(set) var requestVersion = 0
    @Published private(set) var isProcessing = false
    @Published private var translatedText: [String: String] = [:]

    private(set) var activeLanguage = TeachingLanguage.defaultLanguage
    private var pendingSources: [String] = []
    private var queuedKeys: Set<String> = []

    func activate(_ language: TeachingLanguage) {
        guard activeLanguage != language else { return }
        activeLanguage = language
        pendingSources.removeAll(keepingCapacity: true)
        queuedKeys.removeAll(keepingCapacity: true)
        isProcessing = false
        state = language == .english ? .english : .checking
    }

    func request(_ source: String, language: TeachingLanguage) {
        let cleaned = source.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty, language != .english else { return }
        if activeLanguage != language {
            activate(language)
        }
        if BundledTeachingTranslationCatalog.translation(for: source, language: language) != nil {
            return
        }
        guard !language.usesBundledExplanations else { return }
        let key = TeachingTranslationCache.key(for: source, language: language)
        if let cached = TeachingTranslationCache.shared.translation(for: source, language: language) {
            if translatedText[key] != cached {
                translatedText[key] = cached
            }
            return
        }
        guard queuedKeys.insert(key).inserted else { return }
        pendingSources.append(source)
        requestVersion &+= 1
    }

    func text(for source: String, language: TeachingLanguage) -> String {
        guard language != .english else { return source }
        if let bundled = BundledTeachingTranslationCatalog.translation(for: source, language: language) {
            return bundled
        }
        let key = TeachingTranslationCache.key(for: source, language: language)
        return translatedText[key]
            ?? TeachingTranslationCache.shared.translation(for: source, language: language)
            ?? source
    }

    func takeBatch(for language: TeachingLanguage, limit: Int = 24) -> [String]? {
        guard activeLanguage == language else { return nil }
        guard !pendingSources.isEmpty else { return [] }
        let count = min(limit, pendingSources.count)
        let batch = Array(pendingSources.prefix(count))
        pendingSources.removeFirst(count)
        for source in batch {
            queuedKeys.remove(TeachingTranslationCache.key(for: source, language: language))
        }
        return batch
    }

    func hasPendingText(for language: TeachingLanguage) -> Bool {
        activeLanguage == language && !pendingSources.isEmpty
    }

    func beginProcessing(for language: TeachingLanguage) {
        guard activeLanguage == language else { return }
        isProcessing = true
    }

    func endProcessing(for language: TeachingLanguage) {
        guard activeLanguage == language else { return }
        isProcessing = false
    }

    func accept(source: String, translation: String, language: TeachingLanguage) {
        let cleaned = translation.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        TeachingTranslationCache.shared.store(cleaned, for: source, language: language)
        translatedText[TeachingTranslationCache.key(for: source, language: language)] = cleaned
    }

    func updateState(_ newState: TeachingTranslationState, for language: TeachingLanguage) {
        guard activeLanguage == language else { return }
        state = newState
    }
}

/// Owns the only TranslationSession in the app and safely batches requests from every screen.
struct TeachingTranslationHost: View {
    @AppStorage(TeachingLanguage.storageKey) private var languageCode = TeachingLanguage.defaultLanguage.rawValue

    private var language: TeachingLanguage { TeachingLanguage.resolve(languageCode) }

    @ViewBuilder var body: some View {
        if #available(iOS 18.0, *) {
            OnDeviceTeachingTranslationHost(language: language)
        } else {
            Color.clear
                .frame(width: 1, height: 1)
                .onAppear {
                    TeachingTranslationStore.shared.activate(language)
                    if language.usesBundledExplanations {
                        TeachingTranslationStore.shared.updateState(.ready, for: language)
                    } else if language != .english {
                        TeachingTranslationStore.shared.updateState(.unavailable, for: language)
                    }
                }
        }
    }
}

@available(iOS 18.0, *)
private struct OnDeviceTeachingTranslationHost: View {
    let language: TeachingLanguage
    @State private var configuration: TranslationSession.Configuration?
    @ObservedObject private var translations = TeachingTranslationStore.shared

    var body: some View {
        Color.clear
            .frame(width: 1, height: 1)
            .accessibilityHidden(true)
            .task(id: language.rawValue) {
                await configureSession()
            }
            .task(id: translations.requestVersion) {
                await scheduleQueuedTranslation()
            }
            .translationTask(configuration) { session in
                await run(session)
            }
    }

    private func configureSession() async {
        configuration?.invalidate()
        configuration = nil
        translations.activate(language)
        guard language != .english else { return }
        if language.usesBundledExplanations {
            translations.updateState(.ready, for: language)
            return
        }
        translations.updateState(.checking, for: language)
        let source = Locale.Language(identifier: TeachingLanguage.english.rawValue)
        let target = Locale.Language(identifier: language.rawValue)
        let availability: LanguageAvailability.Status
        if #available(iOS 26.4, *) {
            availability = await LanguageAvailability(preferredStrategy: .highFidelity)
                .status(from: source, to: target)
        } else {
            availability = await LanguageAvailability().status(from: source, to: target)
        }
        guard !Task.isCancelled else { return }

        switch availability {
        case .installed:
            translations.updateState(.ready, for: language)
        case .supported:
            translations.updateState(.preparing, for: language)
        case .unsupported:
            translations.updateState(.unavailable, for: language)
            return
        @unknown default:
            translations.updateState(.unavailable, for: language)
            return
        }
        if #available(iOS 26.4, *) {
            configuration = TranslationSession.Configuration(
                source: source,
                target: target,
                preferredStrategy: .highFidelity
            )
        } else {
            configuration = TranslationSession.Configuration(source: source, target: target)
        }
    }

    private func scheduleQueuedTranslation() async {
        guard language != .english else { return }
        do {
            try await Task.sleep(nanoseconds: 180_000_000)
            while translations.isProcessing && !Task.isCancelled {
                try await Task.sleep(nanoseconds: 60_000_000)
            }
        } catch {
            return
        }
        guard !Task.isCancelled,
              configuration != nil,
              translations.hasPendingText(for: language)
        else { return }
        configuration?.invalidate()
    }

    private func run(_ session: TranslationSession) async {
        translations.beginProcessing(for: language)
        defer { translations.endProcessing(for: language) }
        do {
            try await session.prepareTranslation()
            translations.updateState(.ready, for: language)

            while !Task.isCancelled {
                guard let sources = translations.takeBatch(for: language) else { return }
                guard !sources.isEmpty else { return }

                let requests = sources.map {
                    TranslationSession.Request(
                        sourceText: $0,
                        clientIdentifier: TeachingTranslationCache.key(for: $0, language: language)
                    )
                }
                let responses = try await session.translations(from: requests)
                for response in responses {
                    translations.accept(
                        source: response.sourceText,
                        translation: response.targetText,
                        language: language
                    )
                }
            }
        } catch is CancellationError {
            return
        } catch {
            translations.updateState(.failed, for: language)
        }
    }
}

struct TeachingLanguageStatusView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage(TeachingLanguage.storageKey) private var languageCode = TeachingLanguage.defaultLanguage.rawValue
    @ObservedObject private var translations = TeachingTranslationStore.shared

    private var language: TeachingLanguage { TeachingLanguage.resolve(languageCode) }

    @ViewBuilder var body: some View {
        if language != .english {
            HStack(spacing: 8) {
                statusSymbol
                Group {
                    if translations.state == .ready,
                       let bundledStatus = language.bundledExplanationStatus {
                        Text(bundledStatus)
                    } else {
                        TeachingText(english: statusMessage)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .animation(reduceMotion ? nil : CoachMotion.standard, value: translations.state)
        }
    }

    @ViewBuilder private var statusSymbol: some View {
        switch translations.state {
        case .checking, .preparing:
            ProgressView().controlSize(.small)
        case .ready:
            Image(systemName: "checkmark.circle.fill").foregroundStyle(CoachTheme.correct)
        case .unavailable, .failed:
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(CoachTheme.reward)
        case .english:
            EmptyView()
        }
    }

    private var statusMessage: String {
        switch translations.state {
        case .english:
            return ""
        case .checking:
            return "Checking on-device support for \(language.englishName)…"
        case .preparing:
            return "Preparing \(language.englishName) on this iPhone…"
        case .ready:
            return language.bundledExplanationStatus
                ?? "\(language.englishName) explanations are ready offline."
        case .unavailable:
            return "This iPhone cannot translate to \(language.englishName); English stays available."
        case .failed:
            return "The language pack could not be prepared; English stays available."
        }
    }
}

private struct TeachingLanguageSwitcherModifier: ViewModifier {
    @AppStorage(TeachingLanguage.storageKey) private var languageCode =
        TeachingLanguage.defaultLanguage.rawValue
    @State private var showsLanguagePicker = false

    private var language: TeachingLanguage {
        TeachingLanguage.resolve(languageCode)
    }

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        CoachFeedback.selection()
                        showsLanguagePicker = true
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "globe")
                            Text(language.flag)
                                .font(.body)
                                .accessibilityHidden(true)
                        }
                        .padding(.horizontal, 8)
                        .frame(minHeight: 34)
                        .background(
                            CoachTheme.primary.opacity(0.11),
                            in: Capsule()
                        )
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(CoachTheme.primary)
                    .accessibilityLabel(
                        "\(language.interfaceText(.teachingLanguage)): \(language.nativeName)"
                    )
                    .teachingAccessibilityHint("Opens the teaching language picker")
                }
            }
            .sheet(isPresented: $showsLanguagePicker) {
                TeachingLanguagePickerSheet(languageCode: $languageCode)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
    }
}

private struct TeachingLanguagePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var languageCode: String
    @State private var searchText = ""

    private var selectedLanguage: TeachingLanguage {
        TeachingLanguage.resolve(languageCode)
    }

    private var visibleLanguages: [TeachingLanguage] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return TeachingLanguage.allCases }
        return TeachingLanguage.allCases.filter {
            $0.nativeName.localizedCaseInsensitiveContains(query)
                || $0.englishName.localizedCaseInsensitiveContains(query)
                || $0.rawValue.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(alignment: .top, spacing: 11) {
                        Image(systemName: "character.bubble.fill")
                            .foregroundStyle(CoachTheme.listening)
                            .accessibilityHidden(true)
                        TeachingText(
                            english: "Explanations and instructions use this language. German learning content always stays German."
                        )
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Section {
                    ForEach(visibleLanguages) { language in
                        Button {
                            CoachFeedback.selection()
                            if reduceMotion {
                                languageCode = language.rawValue
                            } else {
                                withAnimation(CoachMotion.standard) {
                                    languageCode = language.rawValue
                                }
                            }
                            dismiss()
                        } label: {
                            languageRow(language)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(language.pickerName)
                        .teachingAccessibilityValue(
                            language == selectedLanguage ? "Selected" : "Not selected"
                        )
                    }
                } header: {
                    Text(selectedLanguage.interfaceText(.teachingLanguage))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(selectedLanguage.interfaceText(.teachingLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: selectedLanguage.interfaceText(.teachingLanguage)
            )
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(selectedLanguage.interfaceText(.done)) {
                        dismiss()
                    }
                }
            }
        }
    }

    private func languageRow(_ language: TeachingLanguage) -> some View {
        HStack(spacing: 12) {
            Text(language.flag)
                .font(.system(size: 25))
                .frame(width: 42, height: 42)
                .background(
                    language == selectedLanguage
                        ? CoachTheme.primary.opacity(0.18)
                        : CoachTheme.primary.opacity(0.10),
                    in: Circle()
                )
                .overlay(
                    Circle().stroke(
                        CoachTheme.primary.opacity(language == selectedLanguage ? 0.42 : 0.16)
                    )
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(language.nativeName)
                    .font(.body.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                if language.nativeName != language.englishName {
                    Text(language.englishName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if language == selectedLanguage {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(CoachTheme.correct)
                    .accessibilityHidden(true)
            }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 3)
    }
}

extension View {
    func teachingLanguageSwitcher() -> some View {
        modifier(TeachingLanguageSwitcherModifier())
    }
}

@MainActor
private final class TeachingTranslationCache {
    static let shared = TeachingTranslationCache()
    private static let defaultsPrefix = "teachingTranslation.v3."
    private let memory = NSCache<NSString, NSString>()

    static func key(for source: String, language: TeachingLanguage) -> String {
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in "\(language.rawValue)|\(source)".utf8 {
            hash ^= UInt64(byte)
            hash &*= 1_099_511_628_211
        }
        return "\(language.rawValue).\(String(hash, radix: 16))"
    }

    func translation(for source: String, language: TeachingLanguage) -> String? {
        let cacheKey = Self.key(for: source, language: language)
        if let cached = memory.object(forKey: cacheKey as NSString) {
            return cached as String
        }
        guard let persisted = UserDefaults.standard.string(forKey: Self.defaultsPrefix + cacheKey) else {
            return nil
        }
        memory.setObject(persisted as NSString, forKey: cacheKey as NSString)
        return persisted
    }

    func store(_ translation: String, for source: String, language: TeachingLanguage) {
        let cacheKey = Self.key(for: source, language: language)
        memory.setObject(translation as NSString, forKey: cacheKey as NSString)
        UserDefaults.standard.set(translation, forKey: Self.defaultsPrefix + cacheKey)
    }
}
