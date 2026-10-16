import Foundation

struct CurriculumModuleDescriptor: Identifiable, Hashable {
    let id: String
    let number: Int
    let title: String
    let subtitle: String
    let icon: String
    let itemIDs: [String]
}

enum CurriculumProgression {
    static let grammarSequences: [CEFRLevel: [String]] = [
        .a1: [
            "a1-alphabet-pronunciation",
            "a1-pronouns",
            "a1-formal-address",
            "a1-sein-haben",
            "a1-present-tense",
            "a1-word-order",
            "a1-questions",
            "a1-articles-nominative",
            "a1-plurals",
            "a1-adjectives-predicative",
            "a1-comparative-basics",
            "a1-accusative",
            "a1-accusative-pronouns",
            "a1-dative-pronouns",
            "a1-negation",
            "a1-possessives",
            "a1-modals",
            "a1-imperative",
            "a1-separable-verbs",
            "a1-coordination",
            "a1-preposition-contractions",
            "a1-time-expressions",
            "a1-prepositions",
            "a1-place-direction",
            "a1-perfect-basic",
            "a1-past-sein-haben"
        ],
        .a2: [
            "a2-perfect",
            "a2-participle-formation",
            "a2-preterite",
            "a2-werden-changes",
            "a2-modal-past",
            "a2-dative",
            "a2-object-pronouns",
            "a2-double-object-order",
            "a2-two-way-prepositions",
            "a2-n-declension-basic",
            "a2-verbs-prepositions",
            "a2-pronominal-adverbs",
            "a2-reflexive",
            "a2-reflexive-dative",
            "a2-indefinite-pronouns",
            "a2-adjective-endings",
            "a2-comparative",
            "a2-time-manner-place",
            "a2-infinitive-zu",
            "a2-purpose",
            "a2-subordinate",
            "a2-causal-connectors",
            "a2-temporal-clauses",
            "a2-indirect-questions",
            "a2-relative-basic"
        ],
        .b1: [
            "b1-past-narrative",
            "b1-plusquamperfekt",
            "b1-temporal-connectors",
            "b1-connectors",
            "b1-concessive-alternatives",
            "b1-concessive",
            "b1-relative",
            "b1-relative-wo-was",
            "b1-konjunktiv-ii",
            "b1-conditionals",
            "b1-passive",
            "b1-alternatives",
            "b1-passive-modal-verbs",
            "b1-genitive",
            "b1-adjective-endings",
            "b1-n-declension",
            "b1-participles-adjectives",
            "b1-nominalization",
            "b1-collocations",
            "b1-modal-particles",
            "b1-extended-infinitives",
            "b1-result-manner",
            "b1-indirect-speech",
            "b1-future",
            "b1-konjunktiv-past"
        ]
    ]

    static let vocabularySequences: [CEFRLevel: [String]] = [
        .a1: [
            "Menschen", "Familie", "Alltag", "Zeit", "Wohnen", "Essen", "Einkaufen",
            "Stadt", "Verkehr", "Gesundheit", "Arbeit", "Lernen", "Eigenschaften",
            "Gefühle", "Wetter", "Kommunikation", "Ämter"
        ],
        .a2: [
            "Alltag", "Wohnen", "Freizeit", "Reisen", "Gesundheit", "Arbeit",
            "Kommunikation", "Eigenschaften", "Konnektoren", "Umwelt", "Behörden", "Ämter"
        ],
        .b1: [
            "Alltag", "Kommunikation", "Eigenschaften", "Arbeit", "Bildung", "Medien",
            "Gesellschaft", "Gesundheit", "Umwelt", "Konflikte", "Konnektoren",
            "Argumentation", "Ämter", "Prüfung"
        ]
    ]

    static func grammarRank(topicID: String, level: CEFRLevel) -> Int {
        grammarSequences[level]?.firstIndex(of: topicID) ?? Int.max
    }

    static func grammarModules(level: CEFRLevel) -> [CurriculumModuleDescriptor] {
        let metadata: [(String, String, String)]
        switch level {
        case .a1:
            metadata = [
                ("Foundations", "People, verbs, and sentence shape", "building.columns.fill"),
                ("Everyday nouns", "Questions, articles, and objects", "basket.fill"),
                ("Clear interaction", "Negation, possession, and modal meaning", "bubble.left.and.bubble.right.fill"),
                ("Take action", "Requests, routines, and separable verbs", "bolt.fill"),
                ("Time and place", "Movement, position, and the spoken past", "clock.fill")
            ]
        case .a2:
            metadata = [
                ("Past and change", "Completed events, past states, and becoming", "point.3.connected.trianglepath.dotted"),
                ("Cases and objects", "Recipients, object order, place, and weak nouns", "arrow.left.and.right.circle.fill"),
                ("Reference and routine", "Verb patterns, reflexive actions, and pronouns", "arrow.triangle.2.circlepath"),
                ("Description and order", "Endings, comparisons, sentence order, and goals", "slider.horizontal.3"),
                ("Complex sentences", "Time, questions, and relative clauses", "link.circle.fill")
            ]
        case .b1:
            metadata = [
                ("Narrate and argue", "Sequence events and connect positions", "text.book.closed.fill"),
                ("Voice and possibility", "Relative detail, hypotheticals, and passive", "quote.bubble.fill"),
                ("Formal precision", "Alternatives, possession, and noun forms", "doc.text.fill"),
                ("Dense expression", "Participles, nominal style, and collocations", "text.book.closed.fill"),
                ("Advanced expression", "Formal links, reported speech, and assumptions", "sparkles")
            ]
        }
        return makeModules(
            level: level,
            kind: "grammar",
            items: grammarSequences[level] ?? [],
            sizes: level == .a1 ? [5, 5, 5, 5, 6] : [5, 5, 5, 5, 5],
            metadata: metadata
        )
    }

    static func vocabularyModules(level: CEFRLevel) -> [CurriculumModuleDescriptor] {
        let metadata: [(String, String, String)]
        let sizes: [Int]
        switch level {
        case .a1:
            metadata = [
                ("People and routines", "Identity, family, daily life, and time", "person.2.fill"),
                ("Daily essentials", "Home, food, shopping, and the city", "house.fill"),
                ("Independent life", "Transport, health, and work", "tram.fill"),
                ("Express yourself", "Learning, qualities, and feelings", "bubble.left.fill"),
                ("Practical help", "Weather, communication, and public offices", "checkmark.seal.fill")
            ]
            sizes = [4, 4, 3, 3, 3]
        case .a2:
            metadata = [
                ("Home and free time", "Routines, housing, and leisure", "house.fill"),
                ("Life on the move", "Travel, health, and work", "suitcase.rolling.fill"),
                ("Connected ideas", "Communication, qualities, and connectors", "link.circle.fill"),
                ("Public life", "Environment and administrative language", "building.2.fill")
            ]
            sizes = [3, 3, 3, 3]
        case .b1:
            metadata = [
                ("Confident expression", "Daily life, communication, and nuance", "bubble.left.and.bubble.right.fill"),
                ("Work and society", "Professional, educational, and media language", "briefcase.fill"),
                ("Real-world issues", "Society, health, and conflict", "person.3.fill"),
                ("Make your case", "Connectors, arguments, and public offices", "text.bubble.fill"),
                ("B1 readiness", "Exam language and final consolidation", "checkmark.seal.fill")
            ]
            sizes = [3, 3, 3, 3, 2]
        }
        return makeModules(
            level: level,
            kind: "vocabulary",
            items: vocabularySequences[level] ?? [],
            sizes: sizes,
            metadata: metadata
        )
    }

    static func orderedGrammarTopics(_ topics: [GrammarTopic], level: CEFRLevel) -> [GrammarTopic] {
        topics
            .filter { $0.level == level.rawValue }
            .sorted {
                let left = grammarRank(topicID: $0.id, level: level)
                let right = grammarRank(topicID: $1.id, level: level)
                return left == right ? $0.order < $1.order : left < right
            }
    }

    static func orderedVocabularyThemes(level: CEFRLevel, available: Set<String>) -> [String] {
        let syllabus = vocabularySequences[level] ?? []
        let sequenced = syllabus.filter(available.contains)
        let remaining = available.subtracting(syllabus).sorted()
        return sequenced + remaining
    }

    static func unlockedStageIndexes(completed: Set<Int>, count: Int) -> Set<Int> {
        guard count > 0 else { return [] }
        var unlocked: Set<Int> = [0]
        for index in 0..<count {
            if completed.contains(index) {
                unlocked.insert(index)
                if index + 1 < count { unlocked.insert(index + 1) }
            }
        }
        return unlocked
    }

    static func vocabularySourceID(level: CEFRLevel, theme: String, lessonID: String) -> String {
        "vocabulary-topic-\(level.rawValue)-\(theme)-\(lessonID)"
    }

    static func grammarSourceID(topicID: String, lessonID: String) -> String {
        "grammar-topic-\(topicID)-\(lessonID)"
    }

    static func isVocabularyThemeComplete(
        level: CEFRLevel,
        theme: String,
        lessonIDs: [String],
        completedSourceIDs: Set<String>
    ) -> Bool {
        lessonIDs.allSatisfy {
            completedSourceIDs.contains(vocabularySourceID(level: level, theme: theme, lessonID: $0))
        }
    }

    static func isGrammarTopicComplete(
        topicID: String,
        lessonIDs: [String],
        completedSourceIDs: Set<String>
    ) -> Bool {
        lessonIDs.allSatisfy {
            completedSourceIDs.contains(grammarSourceID(topicID: topicID, lessonID: $0))
        }
    }

    private static func makeModules(
        level: CEFRLevel,
        kind: String,
        items: [String],
        sizes: [Int],
        metadata: [(String, String, String)]
    ) -> [CurriculumModuleDescriptor] {
        var cursor = 0
        return sizes.enumerated().compactMap { index, size in
            guard cursor < items.count, metadata.indices.contains(index) else { return nil }
            let end = min(cursor + size, items.count)
            defer { cursor = end }
            return CurriculumModuleDescriptor(
                id: "\(level.rawValue)-\(kind)-module-\(index + 1)",
                number: index + 1,
                title: metadata[index].0,
                subtitle: metadata[index].1,
                icon: metadata[index].2,
                itemIDs: Array(items[cursor..<end])
            )
        }
    }
}
