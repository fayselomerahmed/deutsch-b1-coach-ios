import Foundation

@main
struct CurriculumSourceDumper {
    static func main() throws {
        guard (2...3).contains(CommandLine.arguments.count) else {
            throw DumpError.missingResourceDirectory
        }
        let resourceDirectory = URL(fileURLWithPath: CommandLine.arguments[1])
        let decoder = JSONDecoder()

        func decode<T: Decodable>(_ type: T.Type, _ name: String) throws -> T {
            let url = resourceDirectory.appendingPathComponent("\(name).json")
            return try decoder.decode(type, from: Data(contentsOf: url))
        }

        let grammar = try decode([GrammarTopicDTO].self, "grammar")
        let vocabulary = try ["vocab_a1", "vocab_a2", "vocab_b1"].flatMap {
            try decode([VocabWordDTO].self, $0)
        }
        let explicitLessons = try decode([CompleteLessonDTO].self, "lessons")
        let lessons = CurriculumFactory.lessons(
            explicit: explicitLessons,
            grammar: grammar,
            vocabulary: vocabulary
        )

        var sources = Set<String>()
        func add(_ value: String?) {
            guard let value else { return }
            let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
            if !cleaned.isEmpty {
                sources.insert(cleaned)
            }
        }

        for lesson in lessons {
            add(lesson.scenario)
            lesson.guidedPractice.forEach {
                add($0.prompt)
                add($0.explanation)
            }
            lesson.listening.questions.forEach {
                add($0.prompt)
                add($0.answer)
                add($0.explanation)
            }
            add(lesson.speaking.prompt)
            add(lesson.writing.prompt)
            lesson.writing.checklist.forEach(add)
            lesson.recap.forEach(add)
        }

        for level in CEFRLevel.allCases {
            for module in IntegrationCourseCurriculum.languageCourseModules(level: level) {
                add(module.title)
                add(module.subtitle)
            }
        }

        let grammarTermStrings = [
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
        let germanSignalStrings = grammarTermStrings + [
            "ist", "sind", "bin", "bist", "hat", "habe", "hast",
            "kann", "können", "muss", "müssen", "wird", "würde",
            "mit", "für", "auf", "zu", "im", "am", "von", "nach",
            "und", "aber", "oder", "auch",
        ]
        let grammarMatchers: [NSRegularExpression] = grammarTermStrings.compactMap { term in
            let escaped = NSRegularExpression.escapedPattern(for: term)
            return try? NSRegularExpression(
                pattern: "(?<!\\w)\(escaped)(?!\\w)",
                options: .caseInsensitive
            )
        }

        func protectedSource(_ source: String, explicitGerman: [String]) -> String {
            let fullRange = NSRange(source.startIndex..., in: source)
            let inlineTerms = grammarMatchers.flatMap { matcher -> [String] in
                matcher.matches(in: source, range: fullRange).compactMap {
                    Range($0.range, in: source).map { String(source[$0]) }
                }
            }
            let quoteMatcher = try? NSRegularExpression(pattern: "“([^”]+)”")
            let quotedGerman = quoteMatcher?.matches(
                in: source,
                range: fullRange
            ).compactMap { match -> String? in
                guard let innerRange = Range(match.range(at: 1), in: source),
                      let quoteRange = Range(match.range, in: source)
                else { return nil }
                let inner = String(source[innerRange])
                let hasGermanCharacter = inner.range(
                    of: "[äöüÄÖÜß]",
                    options: .regularExpression
                ) != nil
                let hasGermanSignal = germanSignalStrings.contains { term in
                    let escaped = NSRegularExpression.escapedPattern(for: term)
                    return inner.range(
                        of: "(?<!\\w)\(escaped)(?!\\w)",
                        options: [.regularExpression, .caseInsensitive]
                    ) != nil
                }
                let isCapitalizedSingleWord =
                    !inner.contains(" ") && inner.first?.isUppercase == true
                guard hasGermanCharacter || hasGermanSignal || isCapitalizedSingleWord
                else { return nil }
                return String(source[quoteRange])
            } ?? []
            let matching = Set((explicitGerman + inlineTerms + quotedGerman).compactMap { value -> String? in
                let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !cleaned.isEmpty else { return nil }
                let isSingleWord = cleaned.unicodeScalars.allSatisfy {
                    CharacterSet.letters.union(.decimalDigits).contains($0)
                }
                if isSingleWord {
                    let escaped = NSRegularExpression.escapedPattern(for: cleaned)
                    guard let matcher = try? NSRegularExpression(
                        pattern: "(?<!\\w)\(escaped)(?!\\w)",
                        options: .caseInsensitive
                    ),
                    let match = matcher.firstMatch(in: source, range: fullRange),
                    let range = Range(match.range, in: source)
                    else { return nil }
                    return String(source[range])
                }
                return source.contains(cleaned) ? cleaned : nil
            })
            let ordered = matching.sorted {
                $0.count == $1.count ? $0 < $1 : $0.count > $1.count
            }
            var masked = source
            var tokenIndex = 0
            for german in ordered {
                let isSingleWord = german.unicodeScalars.allSatisfy {
                    CharacterSet.letters.union(.decimalDigits).contains($0)
                }
                let next: String
                if isSingleWord,
                   let matcher = try? NSRegularExpression(
                       pattern: "(?<!\\w)\(NSRegularExpression.escapedPattern(for: german))(?!\\w)"
                   ) {
                    let range = NSRange(masked.startIndex..., in: masked)
                    next = matcher.stringByReplacingMatches(
                        in: masked,
                        range: range,
                        withTemplate: "ZXQGERMAN\(tokenIndex)QXZ"
                    )
                } else {
                    next = masked.replacingOccurrences(
                        of: german,
                        with: "ZXQGERMAN\(tokenIndex)QXZ"
                    )
                }
                guard next != masked else { continue }
                masked = next
                tokenIndex += 1
            }
            return masked
        }

        func add(_ explanation: SimplifiedExplanation) {
            func addSupport(_ value: String?) {
                guard let value else { return }
                add(protectedSource(value, explicitGerman: explanation.protectedGerman))
            }
            addSupport(explanation.title)
            addSupport(explanation.oneLine)
            addSupport(explanation.analogy)
            explanation.steps.forEach {
                addSupport($0.title)
                addSupport($0.detail)
            }
            addSupport(explanation.modelMeaning)
            addSupport(explanation.checkQuestion)
            addSupport(explanation.checkAnswer)
        }

        let grammarModels = grammar.map {
            GrammarTopic(
                id: $0.id,
                level: $0.level,
                order: $0.order,
                title: $0.title,
                explanation: $0.explanation,
                examples: $0.examples,
                commonMistakes: $0.commonMistakes,
                practice: $0.practice
            )
        }
        grammarModels.forEach {
            add(SimplifiedExplanationCatalog.grammar($0))
        }

        let vocabularyModels = vocabulary.map {
            VocabWord(
                id: $0.id,
                level: $0.level,
                theme: $0.theme,
                german: $0.german,
                article: $0.article,
                plural: $0.plural,
                english: $0.english,
                exampleSentence: $0.exampleSentence,
                exampleTranslation: $0.exampleTranslation,
                ttsText: $0.ttsText,
                difficultyTag: $0.difficultyTag
            )
        }
        vocabularyModels.forEach {
            add(SimplifiedExplanationCatalog.vocabularyWord($0))
        }
        for level in CEFRLevel.allCases {
            let levelWords = vocabularyModels.filter { $0.level == level.rawValue }
            for theme in Set(levelWords.map(\.theme)) {
                add(
                    SimplifiedExplanationCatalog.vocabularyTheme(
                        level: level,
                        theme: theme,
                        words: levelWords.filter { $0.theme == theme }
                    )
                )
            }
        }

        let encoded = try JSONEncoder.prettyPrinted.encode(
            sources.sorted {
                $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
            }
        )
        let output = encoded + Data([0x0A])
        if CommandLine.arguments.count == 3 {
            try output.write(
                to: URL(fileURLWithPath: CommandLine.arguments[2]),
                options: .atomic
            )
        } else {
            FileHandle.standardOutput.write(output)
        }
    }
}

private enum DumpError: Error {
    case missingResourceDirectory
}

private extension JSONEncoder {
    static var prettyPrinted: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return encoder
    }
}
