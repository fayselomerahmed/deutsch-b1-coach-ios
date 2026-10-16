import Foundation
import SwiftData

enum CEFRLevel: String, Codable, CaseIterable, Identifiable {
    case a1 = "A1"
    case a2 = "A2"
    case b1 = "B1"

    var id: String { rawValue }
}

enum SkillArea: String, Codable, CaseIterable, Identifiable {
    case grammar
    case vocabulary
    case listening
    case reading
    case writing
    case speaking

    var id: String { rawValue }
}

enum QuizQuestionType: String, Codable, CaseIterable {
    case multipleChoice
    case fillBlank
    case matching
    case listeningComprehension
    case sentenceReorder
}

struct ExampleSentence: Codable, Hashable {
    let german: String
    let english: String
}

struct PracticeQuestion: Codable, Hashable {
    let prompt: String
    let answer: String
    let explanation: String
}

@Model
final class GrammarTopic {
    @Attribute(.unique) var id: String
    var level: String
    var order: Int
    var title: String
    var explanation: String
    var examplesData: Data
    var commonMistakes: [String]
    var practiceData: Data

    init(
        id: String,
        level: CEFRLevel,
        order: Int,
        title: String,
        explanation: String,
        examples: [ExampleSentence],
        commonMistakes: [String],
        practice: [PracticeQuestion]
    ) {
        self.id = id
        self.level = level.rawValue
        self.order = order
        self.title = title
        self.explanation = explanation
        self.examplesData = (try? JSONEncoder().encode(examples)) ?? Data()
        self.commonMistakes = commonMistakes
        self.practiceData = (try? JSONEncoder().encode(practice)) ?? Data()
    }

    var cefrLevel: CEFRLevel { CEFRLevel(rawValue: level) ?? .a1 }
    var examples: [ExampleSentence] { (try? JSONDecoder().decode([ExampleSentence].self, from: examplesData)) ?? [] }
    var practice: [PracticeQuestion] { (try? JSONDecoder().decode([PracticeQuestion].self, from: practiceData)) ?? [] }
}

@Model
final class VocabWord {
    @Attribute(.unique) var id: String
    var level: String
    var theme: String
    var german: String
    var article: String?
    var plural: String?
    var english: String
    var exampleSentence: String
    var exampleTranslation: String?
    var ttsText: String
    var difficultyTag: String

    init(
        id: String,
        level: CEFRLevel,
        theme: String,
        german: String,
        article: String?,
        plural: String?,
        english: String,
        exampleSentence: String,
        exampleTranslation: String? = nil,
        ttsText: String,
        difficultyTag: String
    ) {
        self.id = id
        self.level = level.rawValue
        self.theme = theme
        self.german = german
        self.article = article
        self.plural = plural
        self.english = english
        self.exampleSentence = exampleSentence
        self.exampleTranslation = exampleTranslation
        self.ttsText = ttsText
        self.difficultyTag = difficultyTag
    }

    var exampleMeaning: String {
        let translation = exampleTranslation?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return translation.isEmpty ? english : translation
    }
}

@Model
final class QuizQuestion {
    @Attribute(.unique) var id: String
    var level: String
    var unitId: String
    var type: String
    var skill: String
    var prompt: String
    var choices: [String]
    var correctAnswer: String
    var explanation: String

    init(
        id: String,
        level: CEFRLevel,
        unitId: String,
        type: QuizQuestionType,
        skill: SkillArea,
        prompt: String,
        choices: [String],
        correctAnswer: String,
        explanation: String
    ) {
        self.id = id
        self.level = level.rawValue
        self.unitId = unitId
        self.type = type.rawValue
        self.skill = skill.rawValue
        self.prompt = prompt
        self.choices = choices
        self.correctAnswer = correctAnswer
        self.explanation = explanation
    }
}

struct GrammarTopicDTO: Codable {
    let id: String
    let level: CEFRLevel
    let order: Int
    let title: String
    let explanation: String
    let examples: [ExampleSentence]
    let commonMistakes: [String]
    let practice: [PracticeQuestion]
}

struct VocabWordDTO: Codable {
    let id: String
    let level: CEFRLevel
    let theme: String
    let german: String
    let article: String?
    let plural: String?
    let english: String
    let exampleSentence: String
    let exampleTranslation: String
    let ttsText: String
    let difficultyTag: String
}

struct QuizQuestionDTO: Codable {
    let id: String
    let level: CEFRLevel
    let unitId: String
    let type: QuizQuestionType
    let skill: SkillArea
    let prompt: String
    let choices: [String]
    let correctAnswer: String
    let explanation: String
}

enum LessonStepKind: String, Codable, CaseIterable {
    case intro
    case vocabulary
    case grammar
    case guidedPractice
    case listening
    case speaking
    case writing
    case recap
}

struct LessonExercise: Codable, Hashable {
    let type: QuizQuestionType
    let prompt: String
    let choices: [String]
    let answer: String
    let explanation: String
}

struct ListeningTask: Codable, Hashable {
    let script: String
    let questions: [PracticeQuestion]
}

struct SpeakingTask: Codable, Hashable {
    let prompt: String
    let expectedAnswer: String
    let requiredPhrases: [String]
    let grammarMarkers: [String]
}

struct WritingTask: Codable, Hashable {
    let prompt: String
    let checklist: [String]
}

struct CompleteLessonDTO: Codable, Identifiable, Hashable {
    let id: String
    let level: CEFRLevel
    let order: Int
    let title: String
    let scenario: String
    let vocabularyIds: [String]
    let grammarTopicId: String
    let guidedPractice: [LessonExercise]
    let listening: ListeningTask
    let speaking: SpeakingTask
    let writing: WritingTask
    let recap: [String]
    let xp: Int
}

struct PracticalPhraseDTO: Codable, Hashable {
    let german: String
    let english: String
}

struct EverydayPhraseDTO: Codable, Identifiable, Hashable {
    let id: String
    let level: CEFRLevel
    let german: String
    let english: String
}

struct EverydayPhraseCategoryDTO: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let phrases: [EverydayPhraseDTO]
}

struct PracticalTurnDTO: Codable, Hashable {
    let partnerCue: String
    let cueTranslation: String
    let modelResponse: String
    let responseTranslation: String
    let requiredPhrases: [String]
    let grammarMarkers: [String]
}

struct PracticalMissionDTO: Codable, Identifiable, Hashable {
    let id: String
    let level: CEFRLevel
    let order: Int
    let title: String
    let setting: String
    let goal: String
    let partnerRole: String
    let icon: String
    let canDo: [String]
    let phrases: [PracticalPhraseDTO]
    let turns: [PracticalTurnDTO]
    let writingPrompt: String
    let writingChecklist: [String]

    var activitySourceID: String { "practical-mission-\(id)" }
}
