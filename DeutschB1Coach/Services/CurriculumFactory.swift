import Foundation

enum CurriculumFactory {
    static func lessons(
        explicit: [CompleteLessonDTO],
        grammar: [GrammarTopicDTO],
        vocabulary: [VocabWordDTO]
    ) -> [CompleteLessonDTO] {
        let explicitByGrammarID = Dictionary(uniqueKeysWithValues: explicit.map { ($0.grammarTopicId, $0) })
        var lessons: [CompleteLessonDTO] = []

        for level in CEFRLevel.allCases {
            let levelGrammar = grammar
                .filter { $0.level == level }
                .sorted {
                    CurriculumProgression.grammarRank(topicID: $0.id, level: level)
                        < CurriculumProgression.grammarRank(topicID: $1.id, level: level)
                }
            let levelVocab = vocabulary.filter { $0.level == level }
            let orderedThemes = CurriculumProgression.orderedVocabularyThemes(
                level: level,
                available: Set(levelVocab.map(\.theme))
            )

            for (index, topic) in levelGrammar.enumerated() {
                let sequenceOrder = index + 1
                if let explicitLesson = explicitByGrammarID[topic.id] {
                    lessons.append(copy(explicitLesson, order: sequenceOrder, topic: topic))
                    continue
                }

                let words = coherentVocabulary(
                    levelVocab,
                    orderedThemes: orderedThemes,
                    lessonIndex: index,
                    lessonCount: levelGrammar.count,
                    count: 8
                )
                let theme = words.first?.theme ?? orderedThemes.first ?? "everyday life"
                let profile = IntegrationCourseCurriculum.profile(
                    level: level,
                    order: sequenceOrder,
                    grammarTitle: topic.title,
                    vocabularyThemes: [theme]
                )
                lessons.append(
                    CompleteLessonDTO(
                        id: "\(level.rawValue.lowercased())-lesson-\(String(format: "%02d", topic.order))",
                        level: level,
                        order: sequenceOrder,
                        title: topic.title,
                        scenario: "\(profile.context) \(profile.canDoStatements[0]) Use \(topic.title.lowercased()) as the language tool for the task.",
                        vocabularyIds: words.map(\.id),
                        grammarTopicId: topic.id,
                        guidedPractice: topic.practice
                            .prefix(practiceTarget(for: level))
                            .map(lessonExercise),
                        listening: ListeningTask(
                            script: listeningScript(topic: topic, index: index),
                            questions: listeningQuestions(topic: topic)
                        ),
                        speaking: SpeakingTask(
                            prompt: profile.speakingPrompt,
                            expectedAnswer: topic.examples.first?.german ?? "Ich lerne heute Deutsch.",
                            requiredPhrases: words.prefix(3).map(\.german),
                            grammarMarkers: markers(from: topic)
                        ),
                        writing: WritingTask(
                            prompt: profile.writingPrompt,
                            checklist: profile.writingChecklist
                        ),
                        recap: recap(topic: topic, words: words, profile: profile),
                        xp: level == .b1 ? 35 : (level == .a2 ? 30 : 25)
                    )
                )
            }
        }

        return lessons.sorted {
            if $0.level == $1.level { return $0.order < $1.order }
            return levelIndex($0.level) < levelIndex($1.level)
        }
    }

    static func quizzes(
        explicit: [QuizQuestionDTO],
        grammar: [GrammarTopicDTO],
        vocabulary: [VocabWordDTO]
    ) -> [QuizQuestionDTO] {
        var result = explicit

        for level in CEFRLevel.allCases {
            let words = vocabulary.filter { $0.level == level }
            for (index, word) in words.enumerated() {
                let distractors = [1, 5, 11]
                    .map { words[(index + $0) % words.count].english }
                    .filter { $0 != word.english }
                result.append(
                    QuizQuestionDTO(
                        id: "quiz-\(word.id)-meaning",
                        level: level,
                        unitId: word.theme,
                        type: .multipleChoice,
                        skill: .vocabulary,
                        prompt: "What does \"\(word.ttsText)\" mean?",
                        choices: uniqueShuffled([word.english] + distractors, seed: index),
                        correctAnswer: word.english,
                        explanation: word.exampleSentence
                    )
                )

                let germanDistractors = [1, 5, 11]
                    .map { words[(index + $0) % words.count].ttsText }
                    .filter { $0 != word.ttsText }
                result.append(
                    QuizQuestionDTO(
                        id: "quiz-\(word.id)-german",
                        level: level,
                        unitId: word.theme,
                        type: .multipleChoice,
                        skill: .vocabulary,
                        prompt: "Which German word means \"\(word.english)\"?",
                        choices: uniqueShuffled([word.ttsText] + germanDistractors, seed: index + 1),
                        correctAnswer: word.ttsText,
                        explanation: word.exampleSentence
                    )
                )

                if let article = word.article {
                    result.append(
                        QuizQuestionDTO(
                            id: "quiz-\(word.id)-article",
                            level: level,
                            unitId: word.theme,
                            type: .multipleChoice,
                            skill: .grammar,
                            prompt: "Choose the article for \(word.german.replacingOccurrences(of: "der ", with: "").replacingOccurrences(of: "die ", with: "").replacingOccurrences(of: "das ", with: ""))",
                            choices: rotated(["der", "die", "das"], by: index),
                            correctAnswer: article,
                            explanation: "Learn every noun as one unit: \(article) \(word.german.replacingOccurrences(of: "\(article) ", with: ""))."
                        )
                    )
                }
            }
        }

        for topic in grammar {
            for (index, practice) in topic.practice.enumerated() {
                result.append(
                    QuizQuestionDTO(
                        id: "quiz-\(topic.id)-\(index + 1)",
                        level: topic.level,
                        unitId: topic.id,
                        type: .fillBlank,
                        skill: .grammar,
                        prompt: practice.prompt,
                        choices: [],
                        correctAnswer: practice.answer,
                        explanation: practice.explanation
                    )
                )
            }
        }

        return result
    }

    private static func circularSlice<T>(_ values: [T], start: Int, count: Int) -> [T] {
        guard !values.isEmpty else { return [] }
        return (0..<count).map { values[(start + $0) % values.count] }
    }

    private static func copy(
        _ lesson: CompleteLessonDTO,
        order: Int,
        topic: GrammarTopicDTO
    ) -> CompleteLessonDTO {
        CompleteLessonDTO(
            id: lesson.id,
            level: lesson.level,
            order: order,
            title: lesson.title,
            scenario: lesson.scenario,
            vocabularyIds: lesson.vocabularyIds,
            grammarTopicId: lesson.grammarTopicId,
            guidedPractice: enrichedPractice(
                lesson.guidedPractice,
                topic: topic,
                targetCount: practiceTarget(for: lesson.level)
            ),
            listening: lesson.listening,
            speaking: lesson.speaking,
            writing: lesson.writing,
            recap: lesson.recap,
            xp: lesson.xp
        )
    }

    private static func listeningScript(topic: GrammarTopicDTO, index: Int) -> String {
        let examples = Array(topic.examples.prefix(2).map(\.german))
        let first = examples.first ?? "Ich lerne heute Deutsch."
        let second = examples.dropFirst().first ?? first
        let frames = [
            "Hören Sie zuerst den Modellsatz: „\(first)“ Jetzt vergleichen Sie: „\(second)“ Was bleibt gleich, und was verändert sich?",
            "Konzentrieren Sie sich zuerst auf die Bedeutung: „\(first)“ Hören Sie danach das gleiche Sprachmuster in: „\(second)“",
            "Achten Sie genau auf die Satzstruktur: „\(first)“ Hören Sie nun ein zweites Beispiel: „\(second)“ Sprechen Sie beide Sätze leise mit.",
            "Hören Sie in drei Schritten. Zuerst: „\(first)“ Dann: „\(second)“ Zum Schluss wiederholen Sie den Satz, der für Sie schwieriger war.",
            "Ein Satzmuster, zwei klare Beispiele. Beispiel eins: „\(first)“ Beispiel zwei: „\(second)“ Welche Position ist in beiden Sätzen besonders wichtig?"
        ]
        return frames[index % frames.count]
    }

    private static func listeningQuestions(topic: GrammarTopicDTO) -> [PracticeQuestion] {
        let first = topic.examples.first
        return [
            PracticeQuestion(
                prompt: "What does the first model sentence mean?",
                answer: first?.english ?? "Listen for the main idea before individual words.",
                explanation: "Use the main verb and key nouns to understand the message before translating details."
            ),
            PracticeQuestion(
                prompt: "What pattern should you notice in both examples?",
                answer: topic.title,
                explanation: topic.explanation
            )
        ]
    }

    private static func coherentVocabulary(
        _ vocabulary: [VocabWordDTO],
        orderedThemes: [String],
        lessonIndex: Int,
        lessonCount: Int,
        count: Int
    ) -> [VocabWordDTO] {
        guard !vocabulary.isEmpty, !orderedThemes.isEmpty else { return [] }
        let themeIndex = min(
            lessonIndex * orderedThemes.count / max(lessonCount, 1),
            orderedThemes.count - 1
        )
        let theme = orderedThemes[themeIndex]
        let themedWords = vocabulary.filter { $0.theme == theme }
        guard !themedWords.isEmpty else { return [] }

        let previousLessonsInTheme = (0..<lessonIndex).filter { earlierIndex in
            min(
                earlierIndex * orderedThemes.count / max(lessonCount, 1),
                orderedThemes.count - 1
            ) == themeIndex
        }.count
        let start = (previousLessonsInTheme * count) % themedWords.count
        return circularSlice(themedWords, start: start, count: min(count, themedWords.count))
    }

    private static func enrichedPractice(
        _ existing: [LessonExercise],
        topic: GrammarTopicDTO,
        targetCount: Int
    ) -> [LessonExercise] {
        var result = existing
        var prompts = Set(existing.map(\.prompt))
        for item in topic.practice where result.count < targetCount && !prompts.contains(item.prompt) {
            result.append(lessonExercise(item))
            prompts.insert(item.prompt)
        }
        return result
    }

    private static func lessonExercise(_ item: PracticeQuestion) -> LessonExercise {
        LessonExercise(
            type: .fillBlank,
            prompt: item.prompt,
            choices: [],
            answer: item.answer,
            explanation: item.explanation
        )
    }

    private static func practiceTarget(for level: CEFRLevel) -> Int {
        level == .b1 ? 8 : 7
    }

    private static func recap(
        topic: GrammarTopicDTO,
        words: [VocabWordDTO],
        profile: IntegrationLessonProfile
    ) -> [String] {
        let model = topic.examples.first?.german ?? "Ich lerne heute Deutsch."
        let themes = Array(Set(words.map(\.theme))).sorted().prefix(2).joined(separator: " and ")
        return [
            "With \(topic.title.lowercased()), you can now act in \(profile.actionField.title.lowercased()): \(profile.canDoStatements[0].dropFirst(6))",
            "You can recognize \(topic.title.lowercased()) in a sentence such as “\(model)”.",
            "Your \(topic.title.lowercased()) review deck gained \(words.count) useful words from \(themes.isEmpty ? "this situation" : themes).",
            "After practicing \(topic.title.lowercased()), complete this transfer mission: \(profile.transferTask)"
        ]
    }

    private static func markers(from topic: GrammarTopicDTO) -> [String] {
        let words = topic.examples
            .flatMap { $0.german.lowercased().split(separator: " ").map(String.init) }
            .filter { $0.count > 3 }
        return Array(words.prefix(4))
    }

    private static func uniqueShuffled(_ values: [String], seed: Int) -> [String] {
        let unique = Array(NSOrderedSet(array: values)) as? [String] ?? values
        return rotated(unique, by: seed)
    }

    private static func rotated<T>(_ values: [T], by offset: Int) -> [T] {
        guard !values.isEmpty else { return [] }
        let shift = offset % values.count
        return Array(values[shift...] + values[..<shift])
    }

    private static func levelIndex(_ level: CEFRLevel) -> Int {
        CEFRLevel.allCases.firstIndex(of: level) ?? 0
    }
}
