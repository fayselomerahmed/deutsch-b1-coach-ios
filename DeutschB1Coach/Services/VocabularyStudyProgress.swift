import Foundation

enum VocabularyStudyCategory: String, CaseIterable, Identifiable {
    case learning
    case marked
    case memorized

    var id: String { rawValue }

    var title: String {
        switch self {
        case .learning: "Learning"
        case .marked: "Marked"
        case .memorized: "Memorized"
        }
    }

    var icon: String {
        switch self {
        case .learning: "rectangle.stack.fill"
        case .marked: "bookmark.fill"
        case .memorized: "checkmark.square.fill"
        }
    }
}

enum VocabularyDeckProgressStore {
    private static let positionsKey = "vocabularyDeckPositions"
    private static let levelKey = "vocabularyDeckLastLevel"
    private static let themeKey = "vocabularyDeckLastTheme"
    private static let categoryKey = "vocabularyDeckLastCategory"

    static func lastSelection() -> (level: CEFRLevel, theme: String, category: VocabularyStudyCategory) {
        let defaults = UserDefaults.standard
        return (
            CEFRLevel(rawValue: defaults.string(forKey: levelKey) ?? "") ?? .a1,
            defaults.string(forKey: themeKey) ?? "All",
            VocabularyStudyCategory(rawValue: defaults.string(forKey: categoryKey) ?? "") ?? .learning
        )
    }

    static func saveSelection(level: CEFRLevel, theme: String, category: VocabularyStudyCategory) {
        let defaults = UserDefaults.standard
        defaults.set(level.rawValue, forKey: levelKey)
        defaults.set(theme, forKey: themeKey)
        defaults.set(category.rawValue, forKey: categoryKey)
    }

    static func lastWordID(level: CEFRLevel, theme: String, category: VocabularyStudyCategory) -> String? {
        positions[deckKey(level: level, theme: theme, category: category)]
    }

    static func save(wordID: String, level: CEFRLevel, theme: String, category: VocabularyStudyCategory) {
        var values = positions
        values[deckKey(level: level, theme: theme, category: category)] = wordID
        UserDefaults.standard.set(values, forKey: positionsKey)
        saveSelection(level: level, theme: theme, category: category)
    }

    static func clear() {
        let defaults = UserDefaults.standard
        [positionsKey, levelKey, themeKey, categoryKey].forEach(defaults.removeObject(forKey:))
    }

    private static var positions: [String: String] {
        UserDefaults.standard.dictionary(forKey: positionsKey) as? [String: String] ?? [:]
    }

    private static func deckKey(level: CEFRLevel, theme: String, category: VocabularyStudyCategory) -> String {
        "\(level.rawValue)|\(theme)|\(category.rawValue)"
    }
}
