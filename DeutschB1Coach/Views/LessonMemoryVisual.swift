import SwiftUI
import UIKit

struct LessonMemoryVisual: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasSettled = false

    let lesson: CompleteLessonDTO
    var animates = false

    var body: some View {
        Group {
            if let image = LessonVisualCatalog.image(for: lesson) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    LinearGradient(
                        colors: [fallbackTint.opacity(0.34), CoachTheme.rewardGlow.opacity(0.24)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Circle()
                        .fill(CoachTheme.elevatedSurface.opacity(0.82))
                        .frame(width: 46, height: 46)
                    Image(systemName: fallbackIcon)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(fallbackTint)
                    Text(lesson.level.rawValue)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(fallbackTint)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(CoachTheme.elevatedSurface.opacity(0.88), in: Capsule())
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(6)
                }
            }
        }
        .scaleEffect(animates && !reduceMotion && !hasSettled ? 1.045 : 1)
        .clipped()
        .onAppear {
            guard animates, !reduceMotion, !hasSettled else { return }
            withAnimation(CoachMotion.standard) {
                hasSettled = true
            }
        }
        .accessibilityHidden(true)
    }

    private var fallbackTint: Color {
        switch lesson.level {
        case .a1: CoachTheme.primary
        case .a2: CoachTheme.listening
        case .b1: CoachTheme.speaking
        }
    }

    private var fallbackIcon: String {
        let topic = lesson.grammarTopicId
        if topic.contains("formal-address") { return "person.2.fill" }
        if topic.contains("question") { return "questionmark.bubble.fill" }
        if topic.contains("pronoun") { return "person.3.fill" }
        if topic.contains("plural") || topic.contains("article") { return "rectangle.stack.fill" }
        if topic.contains("preposition") || topic.contains("direction") || topic.contains("contraction") { return "map.fill" }
        if topic.contains("past") || topic.contains("perfect") || topic.contains("temporal") || topic.contains("time") { return "clock.arrow.circlepath" }
        if topic.contains("relative") || topic.contains("connect") || topic.contains("coordination") || topic.contains("causal") { return "link.circle.fill" }
        if topic.contains("passive") { return "arrow.triangle.2.circlepath" }
        if topic.contains("modal") || topic.contains("konjunktiv") || topic.contains("conditional") { return "text.bubble.fill" }
        if topic.contains("reflexive") { return "arrow.triangle.2.circlepath" }
        if topic.contains("object-order") || topic.contains("dative") { return "arrow.triangle.branch" }
        if topic.contains("declension") { return "textformat.abc.dottedunderline" }
        if topic.contains("werden-changes") { return "arrow.forward.circle.fill" }
        if topic.contains("imperative") { return "exclamationmark.bubble.fill" }
        if topic.contains("adjective") || topic.contains("comparative") { return "slider.horizontal.3" }
        if topic.contains("concessive") { return "arrow.left.arrow.right" }
        if topic.contains("collocation") { return "puzzlepiece.extension.fill" }
        if topic.contains("infinitive") || topic.contains("result") { return "arrow.triangle.branch" }
        return "character.book.closed.fill"
    }
}

enum LessonVisualCatalog {
    private static let tileCache = NSCache<NSString, UIImage>()

    private static let topicOrder: [CEFRLevel: [String]] = [
        .a1: [
            "a1-pronouns",
            "a1-accusative",
            "a1-sein-haben",
            "a1-present-tense",
            "a1-articles-nominative",
            "a1-negation",
            "a1-word-order",
            "a1-questions",
            "a1-modals",
            "a1-possessives",
            "a1-plurals",
            "a1-prepositions",
            "a1-separable-verbs",
            "a1-perfect-basic"
        ],
        .a2: [
            "a2-perfect",
            "a2-dative",
            "a2-two-way-prepositions",
            "a2-adjective-endings",
            "a2-comparative",
            "a2-reflexive",
            "a2-modal-past",
            "a2-relative-basic",
            "a2-infinitive-zu",
            "a2-indirect-questions",
            "a2-preterite",
            "a2-verbs-prepositions",
            "a2-purpose",
            "a2-subordinate"
        ],
        .b1: [
            "b1-past-narrative",
            "b1-relative",
            "b1-passive",
            "b1-genitive",
            "b1-adjective-endings",
            "b1-n-declension",
            "b1-participles-adjectives",
            "b1-nominalization",
            "b1-connectors",
            "b1-indirect-speech",
            "b1-future",
            "b1-concessive",
            "b1-alternatives",
            "b1-konjunktiv-ii"
        ]
    ]

    static func tileIndex(for lesson: CompleteLessonDTO) -> Int {
        topicOrder[lesson.level]?.firstIndex(of: lesson.grammarTopicId) ?? -1
    }

    static func image(for lesson: CompleteLessonDTO) -> UIImage? {
        let tileIndex = tileIndex(for: lesson)
        guard 0..<16 ~= tileIndex else { return nil }
        let cacheKey = "\(lesson.level.rawValue)-\(tileIndex)" as NSString
        if let cached = tileCache.object(forKey: cacheKey) {
            return cached
        }

        let assetName = "LessonScenes\(lesson.level.rawValue)"
        guard let source = UIImage(named: assetName)?.cgImage else { return nil }
        let tileWidth = source.width / 4
        let tileHeight = source.height / 4
        let column = tileIndex % 4
        let row = tileIndex / 4
        let crop = CGRect(
            x: column * tileWidth,
            y: row * tileHeight,
            width: tileWidth,
            height: tileHeight
        )
        guard let cropped = source.cropping(to: crop) else { return nil }

        let image = UIImage(cgImage: cropped, scale: 1, orientation: .up)
        tileCache.setObject(image, forKey: cacheKey)
        return image
    }
}

/// Supplies an image-backed memory scene for every vocabulary record.  The scene
/// is selected from the learner's level and topic, while the foreground cue in
/// `VocabularyMemoryPicture` identifies the individual word precisely.
enum VocabularySceneCatalog {
    private static let tileCache = NSCache<NSString, UIImage>()

    static func image(for word: VocabWord) -> UIImage? {
        let level = word.level.uppercased()
        let tileIndex = tileIndex(for: word.theme, identifier: word.id)
        let cacheKey = "vocabulary-scene-\(level)-\(tileIndex)" as NSString
        if let cached = tileCache.object(forKey: cacheKey) { return cached }
        guard let source = UIImage(named: "LessonScenes\(level)")?.cgImage else { return nil }

        let tileWidth = source.width / 4
        let tileHeight = source.height / 4
        let crop = CGRect(
            x: (tileIndex % 4) * tileWidth,
            y: (tileIndex / 4) * tileHeight,
            width: tileWidth,
            height: tileHeight
        )
        guard let cropped = source.cropping(to: crop) else { return nil }
        let image = UIImage(cgImage: cropped, scale: 1, orientation: .up)
        tileCache.setObject(image, forKey: cacheKey)
        return image
    }

    private static func tileIndex(for theme: String, identifier: String) -> Int {
        let candidates: [Int]
        switch theme {
        case "Alltag", "Zeit": candidates = [0, 12, 15]
        case "Familie", "Menschen", "Gesellschaft": candidates = [0, 9, 15]
        case "Wohnen": candidates = [2, 3, 12]
        case "Essen", "Einkaufen": candidates = [1, 5, 14]
        case "Arbeit": candidates = [1, 2, 3]
        case "Behörden", "Ämter": candidates = [3, 8, 12]
        case "Bildung", "Lernen", "Prüfung": candidates = [0, 8, 15]
        case "Reisen", "Verkehr", "Stadt": candidates = [4, 6, 11]
        case "Gesundheit": candidates = [5, 9, 13]
        case "Freizeit": candidates = [0, 10, 14]
        case "Gefühle": candidates = [5, 8, 13]
        case "Wetter", "Umwelt": candidates = [6, 10, 13]
        case "Kommunikation", "Argumentation", "Konnektoren", "Konflikte": candidates = [0, 5, 10]
        default: candidates = [0, 9, 15]
        }
        let offset = identifier.unicodeScalars.reduce(0) { $0 + Int($1.value) } % candidates.count
        return candidates[offset]
    }
}

/// Exact, reviewed object art for high-frequency concrete vocabulary. Every
/// mapping names both its source atlas and crop, preventing category-level
/// guesses such as showing a vegetable for a banana.
enum VocabularyObjectAtlas {
    private struct Tile {
        let assetName: String
        let index: Int
    }

    private static let tileCache = NSCache<NSString, UIImage>()
    private static let tiles: [String: Tile] = [
        "apple": Tile(assetName: "VocabularyFoodAtlas", index: 0),
        "banana": Tile(assetName: "VocabularyFoodAtlas", index: 1),
        "bread": Tile(assetName: "VocabularyFoodAtlas", index: 2),
        "coffee": Tile(assetName: "VocabularyFoodAtlas", index: 3),
        "water": Tile(assetName: "VocabularyFoodAtlas", index: 4),
        "milk": Tile(assetName: "VocabularyFoodAtlas", index: 5),
        "tea": Tile(assetName: "VocabularyFoodAtlas", index: 6),
        "potato": Tile(assetName: "VocabularyFoodAtlas", index: 7),
        "rice": Tile(assetName: "VocabularyFoodAtlas", index: 8),
        "cheese": Tile(assetName: "VocabularyFoodAtlas", index: 9),
        "meat": Tile(assetName: "VocabularyFoodAtlas", index: 10),
        "vegetables": Tile(assetName: "VocabularyFoodAtlas", index: 11),
        "egg": Tile(assetName: "VocabularyFoodAtlas", index: 12),
        "soup": Tile(assetName: "VocabularyFoodAtlas", index: 13),
        "salad": Tile(assetName: "VocabularyFoodAtlas", index: 14),
        "salt": Tile(assetName: "VocabularyFoodAtlas", index: 15),

        "apartment": Tile(assetName: "VocabularyHomeAtlas", index: 0),
        "room": Tile(assetName: "VocabularyHomeAtlas", index: 1),
        "door": Tile(assetName: "VocabularyHomeAtlas", index: 2),
        "window": Tile(assetName: "VocabularyHomeAtlas", index: 3),
        "table": Tile(assetName: "VocabularyHomeAtlas", index: 4),
        "chair": Tile(assetName: "VocabularyHomeAtlas", index: 5),
        "bed": Tile(assetName: "VocabularyHomeAtlas", index: 6),
        "kitchen": Tile(assetName: "VocabularyHomeAtlas", index: 7),
        "bathroom": Tile(assetName: "VocabularyHomeAtlas", index: 8),
        "garden": Tile(assetName: "VocabularyHomeAtlas", index: 9),
        "key": Tile(assetName: "VocabularyHomeAtlas", index: 10),
        "supermarket": Tile(assetName: "VocabularyHomeAtlas", index: 11),
        "market": Tile(assetName: "VocabularyHomeAtlas", index: 12),
        "bag": Tile(assetName: "VocabularyHomeAtlas", index: 13),
        "bottle": Tile(assetName: "VocabularyHomeAtlas", index: 14),
        "money": Tile(assetName: "VocabularyHomeAtlas", index: 15),
        "euro": Tile(assetName: "VocabularyHomeAtlas", index: 15),

        "bus": Tile(assetName: "VocabularyCityAtlas", index: 0),
        "train": Tile(assetName: "VocabularyCityAtlas", index: 1),
        "car": Tile(assetName: "VocabularyCityAtlas", index: 2),
        "bicycle": Tile(assetName: "VocabularyCityAtlas", index: 3),
        "airplane": Tile(assetName: "VocabularyCityAtlas", index: 4),
        "ticket": Tile(assetName: "VocabularyCityAtlas", index: 5),
        "traffic light": Tile(assetName: "VocabularyCityAtlas", index: 6),
        "clock": Tile(assetName: "VocabularyCityAtlas", index: 7),
        "book": Tile(assetName: "VocabularyCityAtlas", index: 8),
        "notebook": Tile(assetName: "VocabularyCityAtlas", index: 9),
        "pen": Tile(assetName: "VocabularyCityAtlas", index: 10),
        "computer": Tile(assetName: "VocabularyCityAtlas", index: 11),
        "medicine": Tile(assetName: "VocabularyCityAtlas", index: 12),
        "hospital": Tile(assetName: "VocabularyCityAtlas", index: 13),
        "doctor": Tile(assetName: "VocabularyCityAtlas", index: 14),
        "sun": Tile(assetName: "VocabularyCityAtlas", index: 15),

        "mother": Tile(assetName: "VocabularyPeopleAtlas", index: 0),
        "father": Tile(assetName: "VocabularyPeopleAtlas", index: 1),
        "child": Tile(assetName: "VocabularyPeopleAtlas", index: 2),
        "family": Tile(assetName: "VocabularyPeopleAtlas", index: 3),
        "man": Tile(assetName: "VocabularyPeopleAtlas", index: 4),
        "woman": Tile(assetName: "VocabularyPeopleAtlas", index: 5),
        "friend": Tile(assetName: "VocabularyPeopleAtlas", index: 6),
        "neighbor": Tile(assetName: "VocabularyPeopleAtlas", index: 7),
        "teacher": Tile(assetName: "VocabularyPeopleAtlas", index: 8),
        "student": Tile(assetName: "VocabularyPeopleAtlas", index: 9),
        "head": Tile(assetName: "VocabularyPeopleAtlas", index: 10),
        "hand": Tile(assetName: "VocabularyPeopleAtlas", index: 11),
        "eye": Tile(assetName: "VocabularyPeopleAtlas", index: 12),
        "ear": Tile(assetName: "VocabularyPeopleAtlas", index: 13),
        "mouth": Tile(assetName: "VocabularyPeopleAtlas", index: 14),
        "body": Tile(assetName: "VocabularyPeopleAtlas", index: 15),

        "brother": Tile(assetName: "VocabularyRolesAtlas", index: 0),
        "sister": Tile(assetName: "VocabularyRolesAtlas", index: 1),
        "son": Tile(assetName: "VocabularyRolesAtlas", index: 2),
        "daughter": Tile(assetName: "VocabularyRolesAtlas", index: 3),
        "husband": Tile(assetName: "VocabularyRolesAtlas", index: 4),
        "wife": Tile(assetName: "VocabularyRolesAtlas", index: 5),
        "grandmother": Tile(assetName: "VocabularyRolesAtlas", index: 6),
        "grandfather": Tile(assetName: "VocabularyRolesAtlas", index: 7),
        "aunt": Tile(assetName: "VocabularyRolesAtlas", index: 8),
        "uncle": Tile(assetName: "VocabularyRolesAtlas", index: 9),
        "cousin": Tile(assetName: "VocabularyRolesAtlas", index: 10),
        "female doctor": Tile(assetName: "VocabularyRolesAtlas", index: 11),
        "nurse": Tile(assetName: "VocabularyRolesAtlas", index: 12),
        "boss": Tile(assetName: "VocabularyRolesAtlas", index: 13),
        "colleague": Tile(assetName: "VocabularyRolesAtlas", index: 14),
        "driver": Tile(assetName: "VocabularyRolesAtlas", index: 15),

        "address": Tile(assetName: "VocabularyPlacesAtlas", index: 0),
        "country": Tile(assetName: "VocabularyPlacesAtlas", index: 1),
        "city": Tile(assetName: "VocabularyPlacesAtlas", index: 2),
        "street": Tile(assetName: "VocabularyPlacesAtlas", index: 3),
        "train station": Tile(assetName: "VocabularyPlacesAtlas", index: 4),
        "platform": Tile(assetName: "VocabularyPlacesAtlas", index: 5),
        "airport": Tile(assetName: "VocabularyPlacesAtlas", index: 6),
        "bank": Tile(assetName: "VocabularyPlacesAtlas", index: 7),
        "post office": Tile(assetName: "VocabularyPlacesAtlas", index: 8),
        "police": Tile(assetName: "VocabularyPlacesAtlas", index: 9),
        "town hall": Tile(assetName: "VocabularyPlacesAtlas", index: 10),
        "citizens' office": Tile(assetName: "VocabularyPlacesAtlas", index: 11),
        "pharmacy": Tile(assetName: "VocabularyPlacesAtlas", index: 12),
        "school": Tile(assetName: "VocabularyPlacesAtlas", index: 13),
        "restaurant": Tile(assetName: "VocabularyPlacesAtlas", index: 14),
        "park": Tile(assetName: "VocabularyPlacesAtlas", index: 15),

        "day": Tile(assetName: "VocabularyTimeWeatherAtlas", index: 0),
        "week": Tile(assetName: "VocabularyTimeWeatherAtlas", index: 1),
        "year": Tile(assetName: "VocabularyTimeWeatherAtlas", index: 2),
        "today": Tile(assetName: "VocabularyTimeWeatherAtlas", index: 3),
        "tomorrow": Tile(assetName: "VocabularyTimeWeatherAtlas", index: 4),
        "evening": Tile(assetName: "VocabularyTimeWeatherAtlas", index: 5),
        "night": Tile(assetName: "VocabularyTimeWeatherAtlas", index: 6),
        "monday": Tile(assetName: "VocabularyTimeWeatherAtlas", index: 7),
        "weekend": Tile(assetName: "VocabularyTimeWeatherAtlas", index: 8),
        "date": Tile(assetName: "VocabularyTimeWeatherAtlas", index: 9),
        "rain": Tile(assetName: "VocabularyTimeWeatherAtlas", index: 10),
        "snow": Tile(assetName: "VocabularyTimeWeatherAtlas", index: 11),
        "wind": Tile(assetName: "VocabularyTimeWeatherAtlas", index: 12),
        "cloud": Tile(assetName: "VocabularyTimeWeatherAtlas", index: 13),
        "temperature": Tile(assetName: "VocabularyTimeWeatherAtlas", index: 14),
        "weather": Tile(assetName: "VocabularyTimeWeatherAtlas", index: 15),

        "course": Tile(assetName: "VocabularyStudyAtlas", index: 0),
        "task": Tile(assetName: "VocabularyStudyAtlas", index: 1),
        "exercise": Tile(assetName: "VocabularyStudyAtlas", index: 2),
        "homework": Tile(assetName: "VocabularyStudyAtlas", index: 3),
        "exam": Tile(assetName: "VocabularyStudyAtlas", index: 4),
        "dictionary": Tile(assetName: "VocabularyStudyAtlas", index: 5),
        "board": Tile(assetName: "VocabularyStudyAtlas", index: 6),
        "paper": Tile(assetName: "VocabularyStudyAtlas", index: 7),
        "question": Tile(assetName: "VocabularyStudyAtlas", index: 8),
        "answer": Tile(assetName: "VocabularyStudyAtlas", index: 9),
        "form": Tile(assetName: "VocabularyStudyAtlas", index: 10),
        "document": Tile(assetName: "VocabularyStudyAtlas", index: 11),
        "copy": Tile(assetName: "VocabularyStudyAtlas", index: 12),
        "bill": Tile(assetName: "VocabularyStudyAtlas", index: 13),
        "receipt": Tile(assetName: "VocabularyStudyAtlas", index: 14),
        "phone number": Tile(assetName: "VocabularyStudyAtlas", index: 15),

        "breakfast": Tile(assetName: "VocabularyDailyLifeAtlas", index: 0),
        "lunch": Tile(assetName: "VocabularyDailyLifeAtlas", index: 1),
        "dinner": Tile(assetName: "VocabularyDailyLifeAtlas", index: 2),
        "sugar": Tile(assetName: "VocabularyDailyLifeAtlas", index: 3),
        "checkout": Tile(assetName: "VocabularyDailyLifeAtlas", index: 4),
        "shop": Tile(assetName: "VocabularyDailyLifeAtlas", index: 5),
        "price": Tile(assetName: "VocabularyDailyLifeAtlas", index: 6),
        "offer": Tile(assetName: "VocabularyDailyLifeAtlas", index: 7),
        "kilogram": Tile(assetName: "VocabularyDailyLifeAtlas", index: 8),
        "thirst": Tile(assetName: "VocabularyDailyLifeAtlas", index: 9),
        "hunger": Tile(assetName: "VocabularyDailyLifeAtlas", index: 10),
        "stomach": Tile(assetName: "VocabularyDailyLifeAtlas", index: 11),
        "back": Tile(assetName: "VocabularyDailyLifeAtlas", index: 12),
        "leg": Tile(assetName: "VocabularyDailyLifeAtlas", index: 13),
        "throat": Tile(assetName: "VocabularyDailyLifeAtlas", index: 14),
        "pain": Tile(assetName: "VocabularyDailyLifeAtlas", index: 15),

        "to speak": Tile(assetName: "VocabularyActionsAtlas", index: 0),
        "to ask": Tile(assetName: "VocabularyActionsAtlas", index: 1),
        "to pay": Tile(assetName: "VocabularyActionsAtlas", index: 2),
        "to read": Tile(assetName: "VocabularyActionsAtlas", index: 3),
        "to write": Tile(assetName: "VocabularyActionsAtlas", index: 4),
        "to hear": Tile(assetName: "VocabularyActionsAtlas", index: 5),
        "to see": Tile(assetName: "VocabularyActionsAtlas", index: 6),
        "to sleep": Tile(assetName: "VocabularyActionsAtlas", index: 7),
        "to cook": Tile(assetName: "VocabularyActionsAtlas", index: 8),
        "to shower": Tile(assetName: "VocabularyActionsAtlas", index: 9),
        "to open": Tile(assetName: "VocabularyActionsAtlas", index: 10),
        "to close": Tile(assetName: "VocabularyActionsAtlas", index: 11),
        "to look for": Tile(assetName: "VocabularyActionsAtlas", index: 12),
        "to find": Tile(assetName: "VocabularyActionsAtlas", index: 13),
        "to help": Tile(assetName: "VocabularyActionsAtlas", index: 14),
        "to need": Tile(assetName: "VocabularyActionsAtlas", index: 15),

        "to go": Tile(assetName: "VocabularyCoreActionsAtlas", index: 0),
        "to come": Tile(assetName: "VocabularyCoreActionsAtlas", index: 1),
        "to live": Tile(assetName: "VocabularyCoreActionsAtlas", index: 2),
        "to learn": Tile(assetName: "VocabularyCoreActionsAtlas", index: 3),
        "to work": Tile(assetName: "VocabularyCoreActionsAtlas", index: 4),
        "to do": Tile(assetName: "VocabularyCoreActionsAtlas", index: 5),
        "to buy": Tile(assetName: "VocabularyCoreActionsAtlas", index: 6),
        "to eat": Tile(assetName: "VocabularyCoreActionsAtlas", index: 7),
        "to drink": Tile(assetName: "VocabularyCoreActionsAtlas", index: 8),
        "to travel": Tile(assetName: "VocabularyCoreActionsAtlas", index: 9),
        "to stay": Tile(assetName: "VocabularyCoreActionsAtlas", index: 10),
        "to take": Tile(assetName: "VocabularyCoreActionsAtlas", index: 11),
        "to give": Tile(assetName: "VocabularyCoreActionsAtlas", index: 12),
        "to get up": Tile(assetName: "VocabularyCoreActionsAtlas", index: 13),
        "to begin": Tile(assetName: "VocabularyCoreActionsAtlas", index: 14),
        "to clean": Tile(assetName: "VocabularyCoreActionsAtlas", index: 15),

        "work": Tile(assetName: "VocabularyRemainingAtlas", index: 0),
        "profession": Tile(assetName: "VocabularyRemainingAtlas", index: 1),
        "sick": Tile(assetName: "VocabularyRemainingAtlas", index: 2),
        "tired": Tile(assetName: "VocabularyRemainingAtlas", index: 3),
        "appointment": Tile(assetName: "VocabularyRemainingAtlas", index: 4),
        "name": Tile(assetName: "VocabularyRemainingAtlas", index: 5),
        "parents": Tile(assetName: "VocabularyRemainingAtlas", index: 6),
        "house": Tile(assetName: "VocabularyRemainingAtlas", index: 7),
        "stop": Tile(assetName: "VocabularyRemainingAtlas", index: 8),
        "subway": Tile(assetName: "VocabularyRemainingAtlas", index: 9),
        "tram": Tile(assetName: "VocabularyRemainingAtlas", index: 10),
        "way": Tile(assetName: "VocabularyRemainingAtlas", index: 11),
        "trip": Tile(assetName: "VocabularyRemainingAtlas", index: 12),
        "minute": Tile(assetName: "VocabularyRemainingAtlas", index: 13),
        "hour": Tile(assetName: "VocabularyRemainingAtlas", index: 14),
        "time of day": Tile(assetName: "VocabularyRemainingAtlas", index: 15),

        "big": Tile(assetName: "VocabularyQualitiesAtlas", index: 0),
        "small": Tile(assetName: "VocabularyQualitiesAtlas", index: 1),
        "good": Tile(assetName: "VocabularyQualitiesAtlas", index: 2),
        "bad": Tile(assetName: "VocabularyQualitiesAtlas", index: 3),
        "new": Tile(assetName: "VocabularyQualitiesAtlas", index: 4),
        "old": Tile(assetName: "VocabularyQualitiesAtlas", index: 5),
        "young": Tile(assetName: "VocabularyQualitiesAtlas", index: 6),
        "beautiful": Tile(assetName: "VocabularyQualitiesAtlas", index: 7),
        "cold": Tile(assetName: "VocabularyQualitiesAtlas", index: 8),
        "warm": Tile(assetName: "VocabularyQualitiesAtlas", index: 9),
        "expensive": Tile(assetName: "VocabularyQualitiesAtlas", index: 10),
        "cheap": Tile(assetName: "VocabularyQualitiesAtlas", index: 11),
        "fast": Tile(assetName: "VocabularyQualitiesAtlas", index: 12),
        "slow": Tile(assetName: "VocabularyQualitiesAtlas", index: 13),
        "friendly": Tile(assetName: "VocabularyQualitiesAtlas", index: 14),
        "size": Tile(assetName: "VocabularyQualitiesAtlas", index: 15),

        "joy": Tile(assetName: "VocabularyFeelingsAtlas", index: 0),
        "fear": Tile(assetName: "VocabularyFeelingsAtlas", index: 1),
        "worry": Tile(assetName: "VocabularyFeelingsAtlas", index: 2),
        "happy": Tile(assetName: "VocabularyFeelingsAtlas", index: 3),
        "sad": Tile(assetName: "VocabularyFeelingsAtlas", index: 4),
        "nervous": Tile(assetName: "VocabularyFeelingsAtlas", index: 5),
        "relaxed": Tile(assetName: "VocabularyFeelingsAtlas", index: 6),
        "degree": Tile(assetName: "VocabularyFeelingsAtlas", index: 7),
        "sunny": Tile(assetName: "VocabularyFeelingsAtlas", index: 8),
        "rainy": Tile(assetName: "VocabularyFeelingsAtlas", index: 9),
        "windy": Tile(assetName: "VocabularyFeelingsAtlas", index: 10),
        "dry": Tile(assetName: "VocabularyFeelingsAtlas", index: 11),
        "office": Tile(assetName: "VocabularyFeelingsAtlas", index: 12),
        "break": Tile(assetName: "VocabularyFeelingsAtlas", index: 13),
        "waiting time": Tile(assetName: "VocabularyFeelingsAtlas", index: 14),
        "color": Tile(assetName: "VocabularyFeelingsAtlas", index: 15),

        "to be": Tile(assetName: "VocabularyLanguageAtlas", index: 0),
        "to have": Tile(assetName: "VocabularyLanguageAtlas", index: 1),
        "word": Tile(assetName: "VocabularyLanguageAtlas", index: 2),
        "sentence": Tile(assetName: "VocabularyLanguageAtlas", index: 3),
        "language": Tile(assetName: "VocabularyLanguageAtlas", index: 4),
        "email": Tile(assetName: "VocabularyLanguageAtlas", index: 5),
        "to answer": Tile(assetName: "VocabularyLanguageAtlas", index: 6),
        "to understand": Tile(assetName: "VocabularyLanguageAtlas", index: 7),
        "to spell": Tile(assetName: "VocabularyLanguageAtlas", index: 8),
        "to repeat": Tile(assetName: "VocabularyLanguageAtlas", index: 9),
        "number": Tile(assetName: "VocabularyLanguageAtlas", index: 10),
        "to register": Tile(assetName: "VocabularyLanguageAtlas", index: 11),
        "to wait": Tile(assetName: "VocabularyLanguageAtlas", index: 12),
        "to visit": Tile(assetName: "VocabularyLanguageAtlas", index: 13),
        "to say": Tile(assetName: "VocabularyLanguageAtlas", index: 14),
        "to play": Tile(assetName: "VocabularyLanguageAtlas", index: 15),

        "grandson": Tile(assetName: "VocabularyMixedAtlas", index: 0),
        "medical practice": Tile(assetName: "VocabularyMixedAtlas", index: 1),
        "lesson": Tile(assetName: "VocabularyMixedAtlas", index: 2),
        "class": Tile(assetName: "VocabularyMixedAtlas", index: 3),
        "to wash": Tile(assetName: "VocabularyMixedAtlas", index: 4),
        "to celebrate": Tile(assetName: "VocabularyMixedAtlas", index: 5),
        "example": Tile(assetName: "VocabularyMixedAtlas", index: 6),
        "dentist": Tile(assetName: "VocabularyMixedAtlas", index: 7),
        "to wear or carry": Tile(assetName: "VocabularyMixedAtlas", index: 8),
        "vaccination": Tile(assetName: "VocabularyMixedAtlas", index: 9),
        "passport": Tile(assetName: "VocabularyMixedAtlas", index: 10),
        "identity card": Tile(assetName: "VocabularyMixedAtlas", index: 11),
        "residence permit": Tile(assetName: "VocabularyMixedAtlas", index: 12),
        "contract": Tile(assetName: "VocabularyMixedAtlas", index: 13),
        "key handover": Tile(assetName: "VocabularyMixedAtlas", index: 14),
        "luggage": Tile(assetName: "VocabularyMixedAtlas", index: 15),

        "taxi": Tile(assetName: "VocabularyA2PlacesAtlas", index: 0),
        "accommodation": Tile(assetName: "VocabularyA2PlacesAtlas", index: 1),
        "admission ticket": Tile(assetName: "VocabularyA2PlacesAtlas", index: 2),
        "balcony": Tile(assetName: "VocabularyA2PlacesAtlas", index: 3),
        "basement": Tile(assetName: "VocabularyA2PlacesAtlas", index: 4),
        "electricity": Tile(assetName: "VocabularyA2PlacesAtlas", index: 5),
        "emergency": Tile(assetName: "VocabularyA2PlacesAtlas", index: 6),
        "furniture": Tile(assetName: "VocabularyA2PlacesAtlas", index: 7),
        "heating": Tile(assetName: "VocabularyA2PlacesAtlas", index: 8),
        "hostel": Tile(assetName: "VocabularyA2PlacesAtlas", index: 9),
        "library": Tile(assetName: "VocabularyA2PlacesAtlas", index: 10),
        "roof": Tile(assetName: "VocabularyA2PlacesAtlas", index: 11),
        "sports hall": Tile(assetName: "VocabularyA2PlacesAtlas", index: 12),
        "travel guide": Tile(assetName: "VocabularyA2PlacesAtlas", index: 13),
        "apartment viewing": Tile(assetName: "VocabularyA2PlacesAtlas", index: 14),
        "job interview": Tile(assetName: "VocabularyA2PlacesAtlas", index: 15),

        "registration": Tile(assetName: "VocabularyA2HomeWorkAtlas", index: 0),
        "insurance": Tile(assetName: "VocabularyA2HomeWorkAtlas", index: 1),
        "job application": Tile(assetName: "VocabularyA2HomeWorkAtlas", index: 2),
        "utility costs": Tile(assetName: "VocabularyA2HomeWorkAtlas", index: 3),
        "rent": Tile(assetName: "VocabularyA2HomeWorkAtlas", index: 4),
        "tenant": Tile(assetName: "VocabularyA2HomeWorkAtlas", index: 5),
        "landlord": Tile(assetName: "VocabularyA2HomeWorkAtlas", index: 6),
        "move": Tile(assetName: "VocabularyA2HomeWorkAtlas", index: 7),
        "repair": Tile(assetName: "VocabularyA2HomeWorkAtlas", index: 8),
        "neighborhood": Tile(assetName: "VocabularyA2HomeWorkAtlas", index: 9),
        "workplace": Tile(assetName: "VocabularyA2HomeWorkAtlas", index: 10),
        "working hours": Tile(assetName: "VocabularyA2HomeWorkAtlas", index: 11),
        "salary": Tile(assetName: "VocabularyA2HomeWorkAtlas", index: 12),
        "cv": Tile(assetName: "VocabularyA2HomeWorkAtlas", index: 13),
        "experience": Tile(assetName: "VocabularyA2HomeWorkAtlas", index: 14),
        "vocational training": Tile(assetName: "VocabularyA2HomeWorkAtlas", index: 15),

        "shift": Tile(assetName: "VocabularyA2HealthCivicAtlas", index: 0),
        "termination": Tile(assetName: "VocabularyA2HealthCivicAtlas", index: 1),
        "meeting": Tile(assetName: "VocabularyA2HealthCivicAtlas", index: 2),
        "examination": Tile(assetName: "VocabularyA2HealthCivicAtlas", index: 3),
        "treatment": Tile(assetName: "VocabularyA2HealthCivicAtlas", index: 4),
        "prescription": Tile(assetName: "VocabularyA2HealthCivicAtlas", index: 5),
        "health insurer": Tile(assetName: "VocabularyA2HealthCivicAtlas", index: 6),
        "consultation hours": Tile(assetName: "VocabularyA2HealthCivicAtlas", index: 7),
        "fever": Tile(assetName: "VocabularyA2HealthCivicAtlas", index: 8),
        "cough": Tile(assetName: "VocabularyA2HealthCivicAtlas", index: 9),
        "injury": Tile(assetName: "VocabularyA2HealthCivicAtlas", index: 10),
        "authority": Tile(assetName: "VocabularyA2HealthCivicAtlas", index: 11),
        "application": Tile(assetName: "VocabularyA2HealthCivicAtlas", index: 12),
        "certificate": Tile(assetName: "VocabularyA2HealthCivicAtlas", index: 13),
        "fee": Tile(assetName: "VocabularyA2HealthCivicAtlas", index: 14),
        "signature": Tile(assetName: "VocabularyA2HealthCivicAtlas", index: 15),

        "deadline": Tile(assetName: "VocabularyA2TravelTalkAtlas", index: 0),
        "registration certificate": Tile(assetName: "VocabularyA2TravelTalkAtlas", index: 1),
        "reservation": Tile(assetName: "VocabularyA2TravelTalkAtlas", index: 2),
        "departure": Tile(assetName: "VocabularyA2TravelTalkAtlas", index: 3),
        "arrival": Tile(assetName: "VocabularyA2TravelTalkAtlas", index: 4),
        "delay": Tile(assetName: "VocabularyA2TravelTalkAtlas", index: 5),
        "excursion": Tile(assetName: "VocabularyA2TravelTalkAtlas", index: 6),
        "sight": Tile(assetName: "VocabularyA2TravelTalkAtlas", index: 7),
        "timetable": Tile(assetName: "VocabularyA2TravelTalkAtlas", index: 8),
        "message": Tile(assetName: "VocabularyA2TravelTalkAtlas", index: 9),
        "invitation": Tile(assetName: "VocabularyA2TravelTalkAtlas", index: 10),
        "cancellation": Tile(assetName: "VocabularyA2TravelTalkAtlas", index: 11),
        "suggestion": Tile(assetName: "VocabularyA2TravelTalkAtlas", index: 12),
        "opinion": Tile(assetName: "VocabularyA2TravelTalkAtlas", index: 13),
        "conversation": Tile(assetName: "VocabularyA2TravelTalkAtlas", index: 14),
        "explanation": Tile(assetName: "VocabularyA2TravelTalkAtlas", index: 15),

        "information": Tile(assetName: "VocabularyA2CommunityAtlas", index: 0),
        "questionnaire": Tile(assetName: "VocabularyA2CommunityAtlas", index: 1),
        "club": Tile(assetName: "VocabularyA2CommunityAtlas", index: 2),
        "event": Tile(assetName: "VocabularyA2CommunityAtlas", index: 3),
        "exhibition": Tile(assetName: "VocabularyA2CommunityAtlas", index: 4),
        "concert": Tile(assetName: "VocabularyA2CommunityAtlas", index: 5),
        "team": Tile(assetName: "VocabularyA2CommunityAtlas", index: 6),
        "member": Tile(assetName: "VocabularyA2CommunityAtlas", index: 7),
        "hobby": Tile(assetName: "VocabularyA2CommunityAtlas", index: 8),
        "hike": Tile(assetName: "VocabularyA2CommunityAtlas", index: 9),
        "celebration": Tile(assetName: "VocabularyA2CommunityAtlas", index: 10),
        "culture": Tile(assetName: "VocabularyA2CommunityAtlas", index: 11),
        "waste": Tile(assetName: "VocabularyA2CommunityAtlas", index: 12),
        "energy": Tile(assetName: "VocabularyA2CommunityAtlas", index: 13),
        "means of transport": Tile(assetName: "VocabularyA2CommunityAtlas", index: 14),
        "nature": Tile(assetName: "VocabularyA2CommunityAtlas", index: 15),

        "noise": Tile(assetName: "VocabularyA2EnvironmentActionsAtlas", index: 0),
        "air": Tile(assetName: "VocabularyA2EnvironmentActionsAtlas", index: 1),
        "surroundings": Tile(assetName: "VocabularyA2EnvironmentActionsAtlas", index: 2),
        "deposit": Tile(assetName: "VocabularyA2EnvironmentActionsAtlas", index: 3),
        "recycling": Tile(assetName: "VocabularyA2EnvironmentActionsAtlas", index: 4),
        "to pick up": Tile(assetName: "VocabularyA2EnvironmentActionsAtlas", index: 5),
        "to call": Tile(assetName: "VocabularyA2EnvironmentActionsAtlas", index: 6),
        "to fill out": Tile(assetName: "VocabularyA2EnvironmentActionsAtlas", index: 7),
        "to order": Tile(assetName: "VocabularyA2EnvironmentActionsAtlas", index: 8),
        "to book": Tile(assetName: "VocabularyA2EnvironmentActionsAtlas", index: 9),
        "to explain": Tile(assetName: "VocabularyA2EnvironmentActionsAtlas", index: 10),
        "to permit": Tile(assetName: "VocabularyA2EnvironmentActionsAtlas", index: 11),
        "to tell": Tile(assetName: "VocabularyA2EnvironmentActionsAtlas", index: 12),
        "to be absent": Tile(assetName: "VocabularyA2EnvironmentActionsAtlas", index: 13),
        "to belong": Tile(assetName: "VocabularyA2EnvironmentActionsAtlas", index: 14),
        "to terminate": Tile(assetName: "VocabularyA2EnvironmentActionsAtlas", index: 15),

        "to deliver": Tile(assetName: "VocabularyA2PlanningActionsAtlas", index: 0),
        "to plan": Tile(assetName: "VocabularyA2PlanningActionsAtlas", index: 1),
        "to reserve": Tile(assetName: "VocabularyA2PlanningActionsAtlas", index: 2),
        "to send": Tile(assetName: "VocabularyA2PlanningActionsAtlas", index: 3),
        "to participate": Tile(assetName: "VocabularyA2PlanningActionsAtlas", index: 4),
        "to move home": Tile(assetName: "VocabularyA2PlanningActionsAtlas", index: 5),
        "to sign": Tile(assetName: "VocabularyA2PlanningActionsAtlas", index: 6),
        "to arrange": Tile(assetName: "VocabularyA2PlanningActionsAtlas", index: 7),
        "to extend": Tile(assetName: "VocabularyA2PlanningActionsAtlas", index: 8),
        "to miss": Tile(assetName: "VocabularyA2PlanningActionsAtlas", index: 9),
        "to prepare": Tile(assetName: "VocabularyA2PlanningActionsAtlas", index: 10),
        "to suggest": Tile(assetName: "VocabularyA2PlanningActionsAtlas", index: 11),
        "to return": Tile(assetName: "VocabularyA2PlanningActionsAtlas", index: 12),
        "comfortable": Tile(assetName: "VocabularyA2PlanningActionsAtlas", index: 13),
        "busy": Tile(assetName: "VocabularyA2PlanningActionsAtlas", index: 14),
        "urgent": Tile(assetName: "VocabularyA2PlanningActionsAtlas", index: 15),

        "reachable": Tile(assetName: "VocabularyA2QualitiesAtlas", index: 0),
        "together": Tile(assetName: "VocabularyA2QualitiesAtlas", index: 1),
        "healthy": Tile(assetName: "VocabularyA2QualitiesAtlas", index: 2),
        "polite": Tile(assetName: "VocabularyA2QualitiesAtlas", index: 3),
        "free of charge": Tile(assetName: "VocabularyA2QualitiesAtlas", index: 4),
        "necessary": Tile(assetName: "VocabularyA2QualitiesAtlas", index: 5),
        "punctual": Tile(assetName: "VocabularyA2QualitiesAtlas", index: 6),
        "quiet": Tile(assetName: "VocabularyA2QualitiesAtlas", index: 7),
        "in writing": Tile(assetName: "VocabularyA2QualitiesAtlas", index: 8),
        "available": Tile(assetName: "VocabularyA2QualitiesAtlas", index: 9),
        "satisfied": Tile(assetName: "VocabularyA2QualitiesAtlas", index: 10),
        "in addition": Tile(assetName: "VocabularyA2QualitiesAtlas", index: 11),
        "afterwards": Tile(assetName: "VocabularyA2QualitiesAtlas", index: 12),
        "first": Tile(assetName: "VocabularyA2QualitiesAtlas", index: 13),
        "while": Tile(assetName: "VocabularyA2QualitiesAtlas", index: 14),
        "house rules": Tile(assetName: "VocabularyA2QualitiesAtlas", index: 15),

        "caretaker": Tile(assetName: "VocabularyA2HousingCivicAtlas", index: 0),
        "apartment listing": Tile(assetName: "VocabularyA2HousingCivicAtlas", index: 1),
        "employer": Tile(assetName: "VocabularyA2HousingCivicAtlas", index: 2),
        "employee": Tile(assetName: "VocabularyA2HousingCivicAtlas", index: 3),
        "overtime hour": Tile(assetName: "VocabularyA2HousingCivicAtlas", index: 4),
        "unemployment": Tile(assetName: "VocabularyA2HousingCivicAtlas", index: 5),
        "allergy": Tile(assetName: "VocabularyA2HousingCivicAtlas", index: 6),
        "symptom": Tile(assetName: "VocabularyA2HousingCivicAtlas", index: 7),
        "health insurance card": Tile(assetName: "VocabularyA2HousingCivicAtlas", index: 8),
        "residents' registration office": Tile(assetName: "VocabularyA2HousingCivicAtlas", index: 9),
        "immigration office": Tile(assetName: "VocabularyA2HousingCivicAtlas", index: 10),
        "extension": Tile(assetName: "VocabularyA2HousingCivicAtlas", index: 11),
        "stay": Tile(assetName: "VocabularyA2HousingCivicAtlas", index: 12),
        "power of attorney": Tile(assetName: "VocabularyA2HousingCivicAtlas", index: 13),
        "original": Tile(assetName: "VocabularyA2HousingCivicAtlas", index: 14),
        "reference number": Tile(assetName: "VocabularyA2HousingCivicAtlas", index: 15),

        "follow-up question": Tile(assetName: "VocabularyA2CommunicationActionsAtlas", index: 0),
        "request": Tile(assetName: "VocabularyA2CommunicationActionsAtlas", index: 1),
        "rejection": Tile(assetName: "VocabularyA2CommunicationActionsAtlas", index: 2),
        "to confirm": Tile(assetName: "VocabularyA2CommunicationActionsAtlas", index: 3),
        "to inform": Tile(assetName: "VocabularyA2CommunicationActionsAtlas", index: 4),
        "to provide information": Tile(assetName: "VocabularyA2CommunicationActionsAtlas", index: 5),
        "to take care of": Tile(assetName: "VocabularyA2CommunicationActionsAtlas", index: 6),
        "to change": Tile(assetName: "VocabularyA2CommunicationActionsAtlas", index: 7),
        "to cancel": Tile(assetName: "VocabularyA2CommunicationActionsAtlas", index: 8),
        "to postpone": Tile(assetName: "VocabularyA2CommunicationActionsAtlas", index: 9),
        "to transfer money": Tile(assetName: "VocabularyA2CommunicationActionsAtlas", index: 10),
        "to save": Tile(assetName: "VocabularyA2CommunicationActionsAtlas", index: 11),
        "to lend or borrow": Tile(assetName: "VocabularyA2CommunicationActionsAtlas", index: 12),
        "to ask again": Tile(assetName: "VocabularyA2CommunicationActionsAtlas", index: 13),
        "to hand in": Tile(assetName: "VocabularyA2CommunicationActionsAtlas", index: 14),
        "reliable": Tile(assetName: "VocabularyA2CommunicationActionsAtlas", index: 15),

        "flexible": Tile(assetName: "VocabularyA2PracticalLifeAtlas", index: 0),
        "careful": Tile(assetName: "VocabularyA2PracticalLifeAtlas", index: 1),
        "practical": Tile(assetName: "VocabularyA2PracticalLifeAtlas", index: 2),
        "possible": Tile(assetName: "VocabularyA2PracticalLifeAtlas", index: 3),
        "impossible": Tile(assetName: "VocabularyA2PracticalLifeAtlas", index: 4),
        "similar": Tile(assetName: "VocabularyA2PracticalLifeAtlas", index: 5),
        "different": Tile(assetName: "VocabularyA2PracticalLifeAtlas", index: 6),
        "rental contract": Tile(assetName: "VocabularyA2PracticalLifeAtlas", index: 7),
        "defect": Tile(assetName: "VocabularyA2PracticalLifeAtlas", index: 8),
        "employment reference": Tile(assetName: "VocabularyA2PracticalLifeAtlas", index: 9),
        "day of leave": Tile(assetName: "VocabularyA2PracticalLifeAtlas", index: 10),
        "department": Tile(assetName: "VocabularyA2PracticalLifeAtlas", index: 11),
        "part-time position": Tile(assetName: "VocabularyA2PracticalLifeAtlas", index: 12),
        "referral": Tile(assetName: "VocabularyA2PracticalLifeAtlas", index: 13),
        "blood pressure": Tile(assetName: "VocabularyA2PracticalLifeAtlas", index: 14),
        "pharmacist": Tile(assetName: "VocabularyA2PracticalLifeAtlas", index: 15),

        "appointment confirmation": Tile(assetName: "VocabularyA2TravelCoordinationAtlas", index: 0),
        "processing time": Tile(assetName: "VocabularyA2TravelCoordinationAtlas", index: 1),
        "office hours": Tile(assetName: "VocabularyA2TravelCoordinationAtlas", index: 2),
        "caseworker": Tile(assetName: "VocabularyA2TravelCoordinationAtlas", index: 3),
        "platform track": Tile(assetName: "VocabularyA2TravelCoordinationAtlas", index: 4),
        "travel destination": Tile(assetName: "VocabularyA2TravelCoordinationAtlas", index: 5),
        "outward and return journey": Tile(assetName: "VocabularyA2TravelCoordinationAtlas", index: 6),
        "response": Tile(assetName: "VocabularyA2TravelCoordinationAtlas", index: 7),
        "announcement": Tile(assetName: "VocabularyA2TravelCoordinationAtlas", index: 8),
        "appointment change": Tile(assetName: "VocabularyA2TravelCoordinationAtlas", index: 9),
        "course instructor": Tile(assetName: "VocabularyA2TravelCoordinationAtlas", index: 10),
        "meeting point": Tile(assetName: "VocabularyA2TravelCoordinationAtlas", index: 11),
        "to apply": Tile(assetName: "VocabularyA2TravelCoordinationAtlas", index: 12),
        "to apologize": Tile(assetName: "VocabularyA2TravelCoordinationAtlas", index: 13),
        "to remember": Tile(assetName: "VocabularyA2TravelCoordinationAtlas", index: 14),
        "to improve": Tile(assetName: "VocabularyA2TravelCoordinationAtlas", index: 15),

        "to arrange to meet": Tile(assetName: "VocabularyA2MeetingAtlas", index: 0),

        "statement/opinion": Tile(assetName: "VocabularyB1WorkAtlas", index: 0),
        "requirement": Tile(assetName: "VocabularyB1WorkAtlas", index: 1),
        "integration": Tile(assetName: "VocabularyB1WorkAtlas", index: 2),
        "nevertheless": Tile(assetName: "VocabularyB1WorkAtlas", index: 3),
        "therefore": Tile(assetName: "VocabularyB1WorkAtlas", index: 4),
        "condition": Tile(assetName: "VocabularyB1WorkAtlas", index: 5),
        "professional training": Tile(assetName: "VocabularyB1WorkAtlas", index: 6),
        "part-time work": Tile(assetName: "VocabularyB1WorkAtlas", index: 7),
        "full-time work": Tile(assetName: "VocabularyB1WorkAtlas", index: 8),
        "responsibility": Tile(assetName: "VocabularyB1WorkAtlas", index: 9),
        "activity": Tile(assetName: "VocabularyB1WorkAtlas", index: 10),
        "qualification": Tile(assetName: "VocabularyB1WorkAtlas", index: 11),
        "probation period": Tile(assetName: "VocabularyB1WorkAtlas", index: 12),
        "employment contract": Tile(assetName: "VocabularyB1WorkAtlas", index: 13),
        "company": Tile(assetName: "VocabularyB1WorkAtlas", index: 14),
        "equal opportunity": Tile(assetName: "VocabularyB1WorkAtlas", index: 15),

        "community": Tile(assetName: "VocabularyB1LearningAtlas", index: 0),
        "habit": Tile(assetName: "VocabularyB1LearningAtlas", index: 1),
        "origin": Tile(assetName: "VocabularyB1LearningAtlas", index: 2),
        "majority": Tile(assetName: "VocabularyB1LearningAtlas", index: 3),
        "minority": Tile(assetName: "VocabularyB1LearningAtlas", index: 4),
        "consideration": Tile(assetName: "VocabularyB1LearningAtlas", index: 5),
        "support": Tile(assetName: "VocabularyB1LearningAtlas", index: 6),
        "behavior": Tile(assetName: "VocabularyB1LearningAtlas", index: 7),
        "coexistence": Tile(assetName: "VocabularyB1LearningAtlas", index: 8),
        "knowledge": Tile(assetName: "VocabularyB1LearningAtlas", index: 9),
        "ability": Tile(assetName: "VocabularyB1LearningAtlas", index: 10),
        "learning objective": Tile(assetName: "VocabularyB1LearningAtlas", index: 11),
        "exam preparation": Tile(assetName: "VocabularyB1LearningAtlas", index: 12),
        "evaluation": Tile(assetName: "VocabularyB1LearningAtlas", index: 13),
        "feedback": Tile(assetName: "VocabularyB1LearningAtlas", index: 14),
        "progress": Tile(assetName: "VocabularyB1LearningAtlas", index: 15),

        "summary": Tile(assetName: "VocabularyB1EnvironmentAtlas", index: 0),
        "connection": Tile(assetName: "VocabularyB1EnvironmentAtlas", index: 1),
        "climate change": Tile(assetName: "VocabularyB1EnvironmentAtlas", index: 2),
        "sustainability": Tile(assetName: "VocabularyB1EnvironmentAtlas", index: 3),
        "consumption": Tile(assetName: "VocabularyB1EnvironmentAtlas", index: 4),
        "wastefulness": Tile(assetName: "VocabularyB1EnvironmentAtlas", index: 5),
        "measure": Tile(assetName: "VocabularyB1EnvironmentAtlas", index: 6),
        "impact": Tile(assetName: "VocabularyB1EnvironmentAtlas", index: 7),
        "resource": Tile(assetName: "VocabularyB1EnvironmentAtlas", index: 8),
        "nutrition": Tile(assetName: "VocabularyB1EnvironmentAtlas", index: 9),
        "agriculture": Tile(assetName: "VocabularyB1EnvironmentAtlas", index: 10),
        "packaging": Tile(assetName: "VocabularyB1EnvironmentAtlas", index: 11),
        "data protection": Tile(assetName: "VocabularyB1EnvironmentAtlas", index: 12),
        "public": Tile(assetName: "VocabularyB1EnvironmentAtlas", index: 13),
        "report": Tile(assetName: "VocabularyB1EnvironmentAtlas", index: 14),
        "contribution": Tile(assetName: "VocabularyB1EnvironmentAtlas", index: 15),

        "survey": Tile(assetName: "VocabularyB1CivicAtlas", index: 0),
        "advertising": Tile(assetName: "VocabularyB1CivicAtlas", index: 1),
        "source": Tile(assetName: "VocabularyB1CivicAtlas", index: 2),
        "access": Tile(assetName: "VocabularyB1CivicAtlas", index: 3),
        "network": Tile(assetName: "VocabularyB1CivicAtlas", index: 4),
        "publication": Tile(assetName: "VocabularyB1CivicAtlas", index: 5),
        "approval": Tile(assetName: "VocabularyB1CivicAtlas", index: 6),
        "objection": Tile(assetName: "VocabularyB1CivicAtlas", index: 7),
        "procedure": Tile(assetName: "VocabularyB1CivicAtlas", index: 8),
        "entitlement": Tile(assetName: "VocabularyB1CivicAtlas", index: 9),
        "proof": Tile(assetName: "VocabularyB1CivicAtlas", index: 10),
        "consultation": Tile(assetName: "VocabularyB1CivicAtlas", index: 11),
        "regulation": Tile(assetName: "VocabularyB1CivicAtlas", index: 12),
        "rule": Tile(assetName: "VocabularyB1CivicAtlas", index: 13),
        "decision": Tile(assetName: "VocabularyB1CivicAtlas", index: 14),
        "misunderstanding": Tile(assetName: "VocabularyB1CivicAtlas", index: 15),

        "solution": Tile(assetName: "VocabularyB1ReasoningAtlas", index: 0),
        "compromise": Tile(assetName: "VocabularyB1ReasoningAtlas", index: 1),
        "complaint": Tile(assetName: "VocabularyB1ReasoningAtlas", index: 2),
        "consequence": Tile(assetName: "VocabularyB1ReasoningAtlas", index: 3),
        "cause": Tile(assetName: "VocabularyB1ReasoningAtlas", index: 4),
        "point of view": Tile(assetName: "VocabularyB1ReasoningAtlas", index: 5),
        "argument": Tile(assetName: "VocabularyB1ReasoningAtlas", index: 6),
        "agreement": Tile(assetName: "VocabularyB1ReasoningAtlas", index: 7),
        "apology": Tile(assetName: "VocabularyB1ReasoningAtlas", index: 8),
        "well-being": Tile(assetName: "VocabularyB1ReasoningAtlas", index: 9),
        "strain": Tile(assetName: "VocabularyB1ReasoningAtlas", index: 10),
        "recovery": Tile(assetName: "VocabularyB1ReasoningAtlas", index: 11),
        "preventive care": Tile(assetName: "VocabularyB1ReasoningAtlas", index: 12),
        "side effect": Tile(assetName: "VocabularyB1ReasoningAtlas", index: 13),
        "lack of sleep": Tile(assetName: "VocabularyB1ReasoningAtlas", index: 14),
        "balance": Tile(assetName: "VocabularyB1ReasoningAtlas", index: 15),

        "care provision": Tile(assetName: "VocabularyB1ActionAtlas", index: 0),
        "to justify": Tile(assetName: "VocabularyB1ActionAtlas", index: 1),
        "to claim": Tile(assetName: "VocabularyB1ActionAtlas", index: 2),
        "to describe": Tile(assetName: "VocabularyB1ActionAtlas", index: 3),
        "to emphasize": Tile(assetName: "VocabularyB1ActionAtlas", index: 4),
        "to discuss": Tile(assetName: "VocabularyB1ActionAtlas", index: 5),
        "to recommend": Tile(assetName: "VocabularyB1ActionAtlas", index: 6),
        "to mention": Tile(assetName: "VocabularyB1ActionAtlas", index: 7),
        "to determine": Tile(assetName: "VocabularyB1ActionAtlas", index: 8),
        "to convince": Tile(assetName: "VocabularyB1ActionAtlas", index: 9),
        "to compare": Tile(assetName: "VocabularyB1ActionAtlas", index: 10),
        "to recognize": Tile(assetName: "VocabularyB1ActionAtlas", index: 11),
        "to apply for": Tile(assetName: "VocabularyB1ActionAtlas", index: 12),
        "to consider": Tile(assetName: "VocabularyB1ActionAtlas", index: 13),
        "to cope with": Tile(assetName: "VocabularyB1ActionAtlas", index: 14),
        "to assess": Tile(assetName: "VocabularyB1ActionAtlas", index: 15),

        "to decide": Tile(assetName: "VocabularyB1DecisionAtlas", index: 0),
        "to enable": Tile(assetName: "VocabularyB1DecisionAtlas", index: 1),
        "to expect": Tile(assetName: "VocabularyB1DecisionAtlas", index: 2),
        "to promote": Tile(assetName: "VocabularyB1DecisionAtlas", index: 3),
        "to avoid": Tile(assetName: "VocabularyB1DecisionAtlas", index: 4),
        "to do without": Tile(assetName: "VocabularyB1DecisionAtlas", index: 5),
        "to perceive": Tile(assetName: "VocabularyB1DecisionAtlas", index: 6),
        "to disagree": Tile(assetName: "VocabularyB1DecisionAtlas", index: 7),
        "to agree": Tile(assetName: "VocabularyB1DecisionAtlas", index: 8),
        "to summarize": Tile(assetName: "VocabularyB1DecisionAtlas", index: 9),
        "appropriate": Tile(assetName: "VocabularyB1DecisionAtlas", index: 10),
        "detailed": Tile(assetName: "VocabularyB1DecisionAtlas", index: 11),
        "clear": Tile(assetName: "VocabularyB1DecisionAtlas", index: 12),
        "decisive": Tile(assetName: "VocabularyB1DecisionAtlas", index: 13),
        "required": Tile(assetName: "VocabularyB1DecisionAtlas", index: 14),
        "mutual": Tile(assetName: "VocabularyB1DecisionAtlas", index: 15),

        "credible": Tile(assetName: "VocabularyB1QualityAtlas", index: 0),
        "long-term": Tile(assetName: "VocabularyB1QualityAtlas", index: 1),
        "sustainable": Tile(assetName: "VocabularyB1QualityAtlas", index: 2),
        "in time": Tile(assetName: "VocabularyB1QualityAtlas", index: 3),
        "independent": Tile(assetName: "VocabularyB1QualityAtlas", index: 4),
        "responsible": Tile(assetName: "VocabularyB1QualityAtlas", index: 5),
        "advantageous": Tile(assetName: "VocabularyB1QualityAtlas", index: 6),
        "essential": Tile(assetName: "VocabularyB1QualityAtlas", index: 7),
        "however": Tile(assetName: "VocabularyB1QualityAtlas", index: 8),
        "on the one hand": Tile(assetName: "VocabularyB1QualityAtlas", index: 9),
        "on the other hand": Tile(assetName: "VocabularyB1QualityAtlas", index: 10),
        "as a result": Tile(assetName: "VocabularyB1QualityAtlas", index: 11),
        "task instructions": Tile(assetName: "VocabularyB1QualityAtlas", index: 12),
        "listening comprehension": Tile(assetName: "VocabularyB1QualityAtlas", index: 13),
        "reading comprehension": Tile(assetName: "VocabularyB1QualityAtlas", index: 14),
        "expression": Tile(assetName: "VocabularyB1QualityAtlas", index: 15),

        "useful phrase": Tile(assetName: "VocabularyB1ExamAtlas", index: 0),
        "time management": Tile(assetName: "VocabularyB1ExamAtlas", index: 1),
        "assessment criterion": Tile(assetName: "VocabularyB1ExamAtlas", index: 2),
        "proposed solution": Tile(assetName: "VocabularyB1ExamAtlas", index: 3),
        "introduction": Tile(assetName: "VocabularyB1ExamAtlas", index: 4),
        "conclusion": Tile(assetName: "VocabularyB1ExamAtlas", index: 5),
        "examiner": Tile(assetName: "VocabularyB1ExamAtlas", index: 6),
        "examination regulations": Tile(assetName: "VocabularyB1ExamAtlas", index: 7),
        "advantage": Tile(assetName: "VocabularyB1ExamAtlas", index: 8),
        "disadvantage": Tile(assetName: "VocabularyB1ExamAtlas", index: 9),
        "justification": Tile(assetName: "VocabularyB1ExamAtlas", index: 10),
        "counterargument": Tile(assetName: "VocabularyB1ExamAtlas", index: 11),
        "perspective": Tile(assetName: "VocabularyB1ExamAtlas", index: 12),
        "priority": Tile(assetName: "VocabularyB1ExamAtlas", index: 13),
        "evidence": Tile(assetName: "VocabularyB1ExamAtlas", index: 14),
        "summary conclusion": Tile(assetName: "VocabularyB1ExamAtlas", index: 15),

        "to explain in detail": Tile(assetName: "VocabularyB1CommunicationAtlas", index: 0),
        "to object": Tile(assetName: "VocabularyB1CommunicationAtlas", index: 1),
        "to clarify precisely": Tile(assetName: "VocabularyB1CommunicationAtlas", index: 2),
        "to misunderstand": Tile(assetName: "VocabularyB1CommunicationAtlas", index: 3),
        "to refer to": Tile(assetName: "VocabularyB1CommunicationAtlas", index: 4),
        "to state an opinion": Tile(assetName: "VocabularyB1CommunicationAtlas", index: 5),
        "to reflect": Tile(assetName: "VocabularyB1CommunicationAtlas", index: 6),
        "to clarify": Tile(assetName: "VocabularyB1CommunicationAtlas", index: 7),
        "workload": Tile(assetName: "VocabularyB1CommunicationAtlas", index: 8),
        "compatibility": Tile(assetName: "VocabularyB1CommunicationAtlas", index: 9),
        "promotion": Tile(assetName: "VocabularyB1CommunicationAtlas", index: 10),
        "recognition": Tile(assetName: "VocabularyB1CommunicationAtlas", index: 11),
        "working atmosphere": Tile(assetName: "VocabularyB1CommunicationAtlas", index: 12),
        "continuing education": Tile(assetName: "VocabularyB1CommunicationAtlas", index: 13),
        "learning strategy": Tile(assetName: "VocabularyB1CommunicationAtlas", index: 14),
        "independence": Tile(assetName: "VocabularyB1CommunicationAtlas", index: 15),

        "group work": Tile(assetName: "VocabularyB1SocietyAtlas", index: 0),
        "certificate of participation": Tile(assetName: "VocabularyB1SocietyAtlas", index: 1),
        "volunteering": Tile(assetName: "VocabularyB1SocietyAtlas", index: 2),
        "diversity": Tile(assetName: "VocabularyB1SocietyAtlas", index: 3),
        "participation": Tile(assetName: "VocabularyB1SocietyAtlas", index: 4),
        "credibility": Tile(assetName: "VocabularyB1SocietyAtlas", index: 5),
        "media coverage": Tile(assetName: "VocabularyB1SocietyAtlas", index: 6),
        "emission": Tile(assetName: "VocabularyB1SocietyAtlas", index: 7),
        "renewable energy": Tile(assetName: "VocabularyB1SocietyAtlas", index: 8),
        "provided that": Tile(assetName: "VocabularyB1SocietyAtlas", index: 9),
        "as soon as": Tile(assetName: "VocabularyB1SocietyAtlas", index: 10),
        "meanwhile": Tile(assetName: "VocabularyB1SocietyAtlas", index: 11),
        "consequently": Tile(assetName: "VocabularyB1SocietyAtlas", index: 12),
        "in contrast": Tile(assetName: "VocabularyB1SocietyAtlas", index: 13),
        "furthermore": Tile(assetName: "VocabularyB1SocietyAtlas", index: 14),
        "whereas": Tile(assetName: "VocabularyB1SocietyAtlas", index: 15),

        "employment law": Tile(assetName: "VocabularyB1IntegrationAtlas", index: 0),
        "manager": Tile(assetName: "VocabularyB1IntegrationAtlas", index: 1),
        "continuing education opportunity": Tile(assetName: "VocabularyB1IntegrationAtlas", index: 2),
        "performance pressure": Tile(assetName: "VocabularyB1IntegrationAtlas", index: 3),
        "ability to work in a team": Tile(assetName: "VocabularyB1IntegrationAtlas", index: 4),
        "sense of belonging": Tile(assetName: "VocabularyB1IntegrationAtlas", index: 5),
        "barrier": Tile(assetName: "VocabularyB1IntegrationAtlas", index: 6),
        "discrimination": Tile(assetName: "VocabularyB1IntegrationAtlas", index: 7),
        "solidarity": Tile(assetName: "VocabularyB1IntegrationAtlas", index: 8),
        "population": Tile(assetName: "VocabularyB1IntegrationAtlas", index: 9),
        "learning success": Tile(assetName: "VocabularyB1IntegrationAtlas", index: 10),
        "competence": Tile(assetName: "VocabularyB1IntegrationAtlas", index: 11),
        "teaching method": Tile(assetName: "VocabularyB1IntegrationAtlas", index: 12),
        "exam anxiety": Tile(assetName: "VocabularyB1IntegrationAtlas", index: 13),
        "language mediation": Tile(assetName: "VocabularyB1IntegrationAtlas", index: 14),
        "energy consumption": Tile(assetName: "VocabularyB1IntegrationAtlas", index: 15),

        "waste prevention": Tile(assetName: "VocabularyB1MediaLawAtlas", index: 0),
        "public transport": Tile(assetName: "VocabularyB1MediaLawAtlas", index: 1),
        "environmental awareness": Tile(assetName: "VocabularyB1MediaLawAtlas", index: 2),
        "heatwave": Tile(assetName: "VocabularyB1MediaLawAtlas", index: 3),
        "false report": Tile(assetName: "VocabularyB1MediaLawAtlas", index: 4),
        "freedom of expression": Tile(assetName: "VocabularyB1MediaLawAtlas", index: 5),
        "media literacy": Tile(assetName: "VocabularyB1MediaLawAtlas", index: 6),
        "user account": Tile(assetName: "VocabularyB1MediaLawAtlas", index: 7),
        "screen time": Tile(assetName: "VocabularyB1MediaLawAtlas", index: 8),
        "legal advice": Tile(assetName: "VocabularyB1MediaLawAtlas", index: 9),
        "processing status": Tile(assetName: "VocabularyB1MediaLawAtlas", index: 10),
        "data protection provision": Tile(assetName: "VocabularyB1MediaLawAtlas", index: 11),
        "appeal": Tile(assetName: "VocabularyB1MediaLawAtlas", index: 12),
        "legal remedy": Tile(assetName: "VocabularyB1MediaLawAtlas", index: 13),
        "weighing of options": Tile(assetName: "VocabularyB1MediaLawAtlas", index: 14),
        "claim": Tile(assetName: "VocabularyB1MediaLawAtlas", index: 15),

        "main argument": Tile(assetName: "VocabularyB1AdvancedAtlas", index: 0),
        "opposing position": Tile(assetName: "VocabularyB1AdvancedAtlas", index: 1),
        "proposed approach": Tile(assetName: "VocabularyB1AdvancedAtlas", index: 2),
        "to understand or follow": Tile(assetName: "VocabularyB1AdvancedAtlas", index: 3),
        "to require or presuppose": Tile(assetName: "VocabularyB1AdvancedAtlas", index: 4),
        "to influence": Tile(assetName: "VocabularyB1AdvancedAtlas", index: 5),
        "to prove": Tile(assetName: "VocabularyB1AdvancedAtlas", index: 6),
        "to engage critically with": Tile(assetName: "VocabularyB1AdvancedAtlas", index: 7),
        "to draw attention to": Tile(assetName: "VocabularyB1AdvancedAtlas", index: 8),
        "to be suitable": Tile(assetName: "VocabularyB1AdvancedAtlas", index: 9),
        "to implement": Tile(assetName: "VocabularyB1AdvancedAtlas", index: 10),
        "to ensure": Tile(assetName: "VocabularyB1AdvancedAtlas", index: 11)
    ]

    static func image(for word: VocabWord) -> UIImage? {
        image(forKey: normalizedKey(word.english))
    }

    static func hasExactImage(forEnglish english: String) -> Bool {
        tiles[normalizedKey(english)] != nil
    }

    static var exactImageKeyCount: Int { tiles.count }

    static func preload(englishWords: [String]) {
        let keys = englishWords.map(normalizedKey)
        DispatchQueue.global(qos: .userInitiated).async {
            for key in keys {
                _ = image(forKey: key)
            }
        }
    }

    private static func normalizedKey(_ english: String) -> String {
        english
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en"))
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func image(forKey key: String) -> UIImage? {
        guard let tile = tiles[key] else { return nil }
        let cacheKey = "\(tile.assetName)-\(tile.index)" as NSString
        if let cached = tileCache.object(forKey: cacheKey) { return cached }
        guard let sourceImage = UIImage(named: tile.assetName),
              let source = sourceImage.cgImage else { return nil }

        let tileWidth = source.width / 4
        let tileHeight = source.height / 4
        let crop = CGRect(
            x: (tile.index % 4) * tileWidth,
            y: (tile.index / 4) * tileHeight,
            width: tileWidth,
            height: tileHeight
        )
        guard let cropped = source.cropping(to: crop) else { return nil }
        let image = UIImage(cgImage: cropped, scale: sourceImage.scale, orientation: .up)
        tileCache.setObject(image, forKey: cacheKey)
        return image
    }
}

/// A reusable visual metaphor for grammar lessons. The illustrations reinforce the
/// pattern before the learner reads the rule or reaches for a translation.
struct GrammarMemoryScene: View {
    let topicID: String
    var compact = false

    var body: some View {
        Group {
            if let image = GrammarMemorySceneCatalog.image(for: topicID) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(height: compact ? 82 : 128)
        .clipShape(RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
        .accessibilityHidden(true)
    }
}

enum GrammarMemorySceneCatalog {
    private static let tileCache = NSCache<NSString, UIImage>()

    static func image(for topicID: String) -> UIImage? {
        let tileIndex = index(for: topicID)
        let cacheKey = "grammar-memory-\(tileIndex)" as NSString
        if let cached = tileCache.object(forKey: cacheKey) { return cached }
        guard let source = UIImage(named: "GrammarMemoryScenes")?.cgImage else { return nil }

        let tileWidth = source.width / 4
        let tileHeight = source.height / 4
        let crop = CGRect(
            x: (tileIndex % 4) * tileWidth,
            y: (tileIndex / 4) * tileHeight,
            width: tileWidth,
            height: tileHeight
        )
        guard let cropped = source.cropping(to: crop) else { return nil }
        let image = UIImage(cgImage: cropped, scale: 1, orientation: .up)
        tileCache.setObject(image, forKey: cacheKey)
        return image
    }

    private static func index(for topicID: String) -> Int {
        let topic = topicID.lowercased()
        if topic.contains("nominative") || topic.contains("pronoun") { return 0 }
        if topic.contains("accusative") { return 1 }
        if topic.contains("dative") { return 2 }
        if topic.contains("genitive") || topic.contains("possessive") { return 3 }
        if topic.contains("word-order") || topic.contains("subordinate") || topic.contains("indirect-question") { return 4 }
        if topic.contains("verb") || topic.contains("infinitive") || topic.contains("passive") { return 5 }
        if topic.contains("separable") { return 6 }
        if topic.contains("time") || topic.contains("temporal") || topic.contains("present") { return 7 }
        if topic.contains("past") || topic.contains("perfect") || topic.contains("preterite") { return 8 }
        if topic.contains("future") || topic.contains("purpose") { return 9 }
        if topic.contains("question") || topic.contains("speech") || topic.contains("formal") { return 10 }
        if topic.contains("relative") || topic.contains("connect") || topic.contains("causal") || topic.contains("concessive") || topic.contains("result") { return 14 }
        if topic.contains("preposition") || topic.contains("direction") { return 12 }
        if topic.contains("comparative") || topic.contains("adjective") { return 13 }
        return 15
    }
}
