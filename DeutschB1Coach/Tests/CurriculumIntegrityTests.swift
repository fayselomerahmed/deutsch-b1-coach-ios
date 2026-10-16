import XCTest
import UIKit
@testable import DeutschB1Coach

final class CurriculumIntegrityTests: XCTestCase {
    @MainActor
    func testFreeVersionAccessBoundaryMatchesProductOffer() throws {
        XCTAssertEqual(PremiumAccessPolicy.freeA1LessonCount, 5)
        XCTAssertTrue(PremiumAccessPolicy.canOpenLevel(.a1, isPremium: false))
        XCTAssertFalse(PremiumAccessPolicy.canOpenLevel(.a2, isPremium: false))
        XCTAssertFalse(PremiumAccessPolicy.canOpenLevel(.b1, isPremium: false))

        let lessons = try ContentLoader.shared.loadLessons()
        for lesson in lessons {
            let expectedFreeAccess = lesson.level == .a1 && lesson.order <= 5
            XCTAssertEqual(
                PremiumAccessPolicy.canOpenLesson(lesson, isPremium: false),
                expectedFreeAccess,
                "Unexpected free access for \(lesson.id)"
            )
            XCTAssertTrue(PremiumAccessPolicy.canOpenLesson(lesson, isPremium: true))

            let b1PreviewAccess = expectedFreeAccess || (lesson.level == .b1 && lesson.order == 1)
            XCTAssertEqual(
                PremiumAccessPolicy.canOpenLesson(
                    lesson,
                    preferredLevel: .b1,
                    isPremium: false
                ),
                b1PreviewAccess,
                "The free B1 preview boundary changed for \(lesson.id)"
            )
        }

        XCTAssertTrue(PremiumAccessPolicy.canOpenCourseBook(.b1, preferredLevel: .b1, isPremium: false))
        XCTAssertFalse(PremiumAccessPolicy.canOpenCourseBook(.a2, preferredLevel: .b1, isPremium: false))
        XCTAssertTrue(PremiumAccessPolicy.canOpenCourseBook(.a1, preferredLevel: .b1, isPremium: false))
    }

    func testDynamicCorrectionsUseBundledNaturalVoiceModel() throws {
        let text = "Ich habe sechs Jahre Erfahrung in der Softwareentwicklung."
        XCTAssertTrue(OnDeviceGermanVoiceRenderer.shared.hasBundledModel)

        let rendered = expectation(description: "Neural correction audio rendered")
        OnDeviceGermanVoiceRenderer.shared.render(text) { url in
            defer { rendered.fulfill() }
            guard let url,
                  let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize
            else {
                return XCTFail("The offline natural voice did not create an audio file.")
            }
            XCTAssertEqual(url.pathExtension, "wav")
            XCTAssertGreaterThan(size, 44)
        }

        wait(for: [rendered], timeout: 45)
    }

    func testMotionDurationsStayFastAndProfessional() {
        let durations = [
            CoachMotion.quickDuration,
            CoachMotion.standardDuration,
            CoachMotion.springDuration,
            CoachMotion.celebrationDuration
        ]

        XCTAssertTrue(durations.allSatisfy { 0.15...0.30 ~= $0 })
        XCTAssertEqual(durations, durations.sorted())
    }

    func testCoachAvatarMotionProfilesStaySubtleAndAccessible() {
        XCTAssertEqual(Set(CoachMascotMood.allCases.map(\.accessibilityDescription)).count, CoachMascotMood.allCases.count)

        for mood in CoachMascotMood.allCases {
            let profile = CoachAvatarMotionProfile.profile(for: mood)
            XCTAssertGreaterThan(profile.period, 0)
            XCTAssertLessThanOrEqual(profile.verticalAmplitude, 2)
            XCTAssertLessThanOrEqual(profile.rotationAmplitude, 1.4)
            XCTAssertLessThanOrEqual(profile.scaleAmplitude, 0.01)

            for sample in stride(from: 0.0, through: profile.period, by: profile.period / 8) {
                let values = profile.values(at: sample)
                XCTAssertLessThanOrEqual(abs(values.verticalOffset), profile.verticalAmplitude + 0.001)
                XCTAssertLessThanOrEqual(abs(values.rotation), profile.rotationAmplitude + 0.001)
                XCTAssertTrue(0.98...1.02 ~= values.scale)
            }
        }
    }

    func testCoursePreparationMilestonesAreRealAndOrdered() {
        let phases = ContentPreparationPhase.allCases

        XCTAssertEqual(phases.map(\.rawValue), Array(0..<phases.count))
        XCTAssertTrue(phases.allSatisfy { !$0.title.isEmpty && !$0.message.isEmpty && !$0.icon.isEmpty })
        XCTAssertEqual(phases.map(\.progress), phases.map(\.progress).sorted())
        XCTAssertEqual(phases.last?.progress, 1)
        XCTAssertFalse(ContentPreparationPhase.grammar.includes(.a1))
        XCTAssertTrue(ContentPreparationPhase.vocabularyA1.includes(.a1))
        XCTAssertFalse(ContentPreparationPhase.vocabularyA1.includes(.a2))
        XCTAssertTrue(ContentPreparationPhase.vocabularyA2.includes(.a2))
        XCTAssertTrue(ContentPreparationPhase.vocabularyB1.includes(.b1))
    }

    func testFlashcardSwipeDirectionsNavigatePredictably() {
        XCTAssertEqual(FlashcardSwipeNavigation.indexOffset(for: -90), 1)
        XCTAssertEqual(FlashcardSwipeNavigation.indexOffset(for: 90), -1)
        XCTAssertNil(FlashcardSwipeNavigation.indexOffset(for: 40))
        XCTAssertEqual(FlashcardSwipeNavigation.indexOffset(for: -56), 1)
    }

    func testGrammarBuilderExplainsSubordinateVerbPosition() {
        let words = ["Ich", "bleibe", "zu", "Hause,", "weil", "ich", "krank", "bin."]
            .enumerated()
            .map { GrammarBuilderToken(id: "\($0.offset)", text: $0.element) }

        XCTAssertEqual(
            GrammarStructureReasoner.cue(
                at: 4,
                tokens: words,
                topicID: "a2-causal-connectors"
            ).shortTitle,
            "Connector"
        )
        XCTAssertEqual(
            GrammarStructureReasoner.cue(
                at: 7,
                tokens: words,
                topicID: "a2-causal-connectors"
            ).shortTitle,
            "Verb at end"
        )
    }

    func testGrammarBuilderExplainsQuestionVerbFirst() {
        let words = ["Kommst", "du", "aus", "Berlin?"]
            .enumerated()
            .map { GrammarBuilderToken(id: "\($0.offset)", text: $0.element) }

        XCTAssertEqual(
            GrammarStructureReasoner.cue(
                at: 0,
                tokens: words,
                topicID: "a1-questions"
            ).shortTitle,
            "Verb first"
        )
        XCTAssertEqual(
            GrammarStructureReasoner.cue(
                at: 1,
                tokens: words,
                topicID: "a1-questions"
            ).shortTitle,
            "Subject"
        )
    }

    func testGrammarBuilderDoesNotMislabelComparativeAlsAsClauseConnector() {
        let words = ["Berlin", "ist", "größer", "als", "Bonn."]
            .enumerated()
            .map { GrammarBuilderToken(id: "\($0.offset)", text: $0.element) }

        XCTAssertNotEqual(
            GrammarStructureReasoner.cue(
                at: 3,
                tokens: words,
                topicID: "a2-comparative"
            ).shortTitle,
            "Connector"
        )
    }

    func testGrammarBuilderComparesWordsWithoutPunctuationOrCaseNoise() {
        XCTAssertEqual(GrammarStructureReasoner.normalized("Hause,"), "hause")
        XCTAssertEqual(GrammarStructureReasoner.normalized("ÖFFNEN!"), "öffnen")
    }

    func testGrammarBuilderProvidesHowAndWhyForEverySentencePattern() {
        let patterns: [(topicID: String, words: [String], expectedReason: String)] = [
            (
                "a1-questions",
                ["Wo", "wohnst", "du?"],
                "question word"
            ),
            (
                "a2-causal-connectors",
                ["Ich", "bleibe", "zu", "Hause,", "weil", "ich", "krank", "bin."],
                "dependent clause"
            ),
            (
                "a2-perfect",
                ["Ich", "habe", "die", "Aufgabe", "gemacht."],
                "sentence bracket"
            ),
            (
                "a2-dative-accusative",
                ["Ich", "gebe", "dem", "Kind", "den", "Ball."],
                "receiver"
            ),
            (
                "a1-main-clause",
                ["Heute", "lerne", "ich", "Deutsch."],
                "main statement"
            )
        ]

        for pattern in patterns {
            let tokens = pattern.words.enumerated().map {
                GrammarBuilderToken(id: "\($0.offset)", text: $0.element)
            }
            let reason = GrammarStructureReasoner.sentenceReason(
                topicID: pattern.topicID,
                tokens: tokens
            )

            XCTAssertFalse(reason.isEmpty, "Missing sentence reason for \(pattern.topicID)")
            XCTAssertTrue(
                reason.localizedCaseInsensitiveContains(pattern.expectedReason),
                "The reason for \(pattern.topicID) does not explain its defining structure."
            )
            XCTAssertTrue(
                tokens.indices.allSatisfy {
                    !GrammarStructureReasoner.cue(
                        at: $0,
                        tokens: tokens,
                        topicID: pattern.topicID
                    ).reason.isEmpty
                },
                "Every word position must have its own explanation."
            )
        }
    }

    func testSentenceBuilderGameStartsWithTheRequestedTopicAndAvoidsDuplicates() {
        let focusedTopic = GrammarTopic(
            id: "a1-focused",
            level: .a1,
            order: 2,
            title: "Focused topic",
            explanation: "A focused explanation.",
            examples: [
                ExampleSentence(german: "Ich lerne Deutsch.", english: "I learn German."),
                ExampleSentence(german: "Heute lerne ich Deutsch.", english: "Today I learn German.")
            ],
            commonMistakes: [],
            practice: []
        )
        let nextTopic = GrammarTopic(
            id: "a1-next",
            level: .a1,
            order: 1,
            title: "Next topic",
            explanation: "A second explanation.",
            examples: [
                ExampleSentence(german: "Ich lerne Deutsch.", english: "I learn German."),
                ExampleSentence(german: "Morgen arbeite ich.", english: "Tomorrow I work.")
            ],
            commonMistakes: [],
            practice: []
        )

        let rounds = SentenceBuilderGameFactory.makeRounds(
            topics: [nextTopic, focusedTopic],
            level: .a1,
            startingTopicID: focusedTopic.id,
            count: 8
        )

        XCTAssertEqual(rounds.first?.topicID, focusedTopic.id)
        XCTAssertEqual(rounds.count, 3)
        XCTAssertEqual(Set(rounds.map { GrammarStructureReasoner.normalized($0.example.german) }).count, rounds.count)
    }

    func testVocabularyMatchRoundCreatesFourUnambiguousPairs() throws {
        let terms = (1...6).map {
            VocabularyMatchTerm(
                id: "term-\($0)",
                german: "Wort \($0)",
                article: nil,
                meaning: "meaning \($0)",
                theme: "Alltag",
                symbol: "star.fill"
            )
        }

        let round = try XCTUnwrap(VocabularyMatchDeckFactory.makeRound(from: terms))

        XCTAssertEqual(round.terms.count, 4)
        XCTAssertEqual(round.cards.count, 8)
        XCTAssertEqual(Set(round.cards.map(\.id)).count, 8)
        for term in round.terms {
            let pair = round.cards.filter { $0.pairID == term.id }
            XCTAssertEqual(Set(pair.map(\.side)), [.german, .meaning])
        }
    }

    func testVocabularyMatchGameTracksMissesCombosAndCompletion() throws {
        let terms = (1...2).map {
            VocabularyMatchTerm(
                id: "term-\($0)",
                german: "Wort \($0)",
                article: nil,
                meaning: "meaning \($0)",
                theme: "Alltag",
                symbol: "star.fill"
            )
        }
        let round = try XCTUnwrap(VocabularyMatchDeckFactory.makeRound(from: terms, pairCount: 2))
        var game = VocabularyMatchGameState(round: round)
        let firstGerman = try XCTUnwrap(round.cards.first { $0.pairID == terms[0].id && $0.side == .german })
        let firstMeaning = try XCTUnwrap(round.cards.first { $0.pairID == terms[0].id && $0.side == .meaning })
        let secondGerman = try XCTUnwrap(round.cards.first { $0.pairID == terms[1].id && $0.side == .german })
        let secondMeaning = try XCTUnwrap(round.cards.first { $0.pairID == terms[1].id && $0.side == .meaning })

        XCTAssertEqual(game.select(firstGerman, isResolving: false), .firstSelection)
        XCTAssertEqual(game.select(secondMeaning, isResolving: false), .miss)
        XCTAssertEqual(game.moves, 1)
        XCTAssertEqual(game.combo, 0)
        game.resolveMiss()

        XCTAssertEqual(game.select(firstGerman, isResolving: false), .firstSelection)
        XCTAssertEqual(game.select(firstMeaning, isResolving: false), .match(terms[0]))
        XCTAssertEqual(game.score, 100)
        XCTAssertEqual(game.combo, 1)
        XCTAssertFalse(game.isComplete)

        XCTAssertEqual(game.select(secondGerman, isResolving: false), .firstSelection)
        XCTAssertEqual(game.select(secondMeaning, isResolving: false), .match(terms[1]))
        XCTAssertEqual(game.score, 225)
        XCTAssertEqual(game.bestCombo, 2)
        XCTAssertTrue(game.isComplete)
    }

    func testVocabularyMatchRemovesDuplicateMeanings() {
        let terms = [
            VocabularyMatchTerm(id: "one", german: "der Termin", article: "der", meaning: "appointment", theme: "Alltag", symbol: "calendar"),
            VocabularyMatchTerm(id: "two", german: "die Verabredung", article: "die", meaning: "appointment", theme: "Alltag", symbol: "calendar")
        ]

        XCTAssertEqual(VocabularyMatchDeckFactory.uniqueTerms(from: terms).map(\.id), ["one"])
    }

    func testTeachingLanguagesAreCompleteAndSafe() {
        let languages = TeachingLanguage.allCases

        XCTAssertEqual(languages.count, 20)
        XCTAssertEqual(Set(languages.map(\.rawValue)).count, languages.count)
        XCTAssertEqual(TeachingLanguage.defaultLanguage, .english)
        XCTAssertEqual(TeachingLanguage.resolve("not-a-language"), .english)
        XCTAssertEqual(languages.filter(\.isRightToLeft), [.arabic])
        XCTAssertTrue(languages.allSatisfy { !$0.nativeName.isEmpty && !$0.englishName.isEmpty })
        XCTAssertTrue(languages.allSatisfy { !$0.flag.isEmpty })
        XCTAssertEqual(Set(languages.map(\.flag)).count, languages.count)
        XCTAssertTrue(languages.allSatisfy { language in
            TeachingInterfaceKey.allCases.allSatisfy {
                !language.interfaceText($0).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
        })
        XCTAssertFalse(TeachingLanguage.english.usesBundledExplanations)
        XCTAssertTrue(
            languages
                .filter { $0 != .english }
                .allSatisfy(\.usesBundledExplanations)
        )
        for language in languages where language != .english {
            XCTAssertGreaterThanOrEqual(
                BundledTeachingTranslationCatalog.translationCount(for: language),
                9_800,
                "Incomplete offline catalog for \(language.rawValue)"
            )
            for source in [
                "Explain more simply",
                "Opens a shorter explanation with one example and a self-check",
                "ONE IDEA",
                "Three tiny steps",
                "Do only one step at a time",
                "One safe model",
                "Play simple model",
                "Show the simple answer",
                "Close simple explanation",
                "Simple explanation",
            ] {
                XCTAssertNotEqual(
                    BundledTeachingTranslationCatalog.translation(
                        for: source,
                        language: language
                    ),
                    source,
                    "Missing translated microcopy for \(language.rawValue): \(source)"
                )
            }
            for source in [
                "Vocabulary",
                "Listening",
                "Reading",
                "Writing",
                "Speaking",
                "Where do you need the most help?",
                "Choose one focus. Your practice will adapt, and you can change it later.",
                "Learning focus",
                "Your focused path",
                "More improvements for you",
                "Practice the skill that needs the most attention",
                "My focus",
                "Change focus",
                "Start focused practice",
                "Playback speed",
                "Cancel German audio",
                "Pause German audio",
                "Resume German audio",
                "Stop German audio",
                "Skip tutorial",
                "Previous tutorial page",
                "Tutorial progress",
                "Welcome to your German journey",
                "Learn, practice, review, and track progress from one clear home.",
                "Learn with a clear path",
                "Follow A1, A2, and B1 course books in order. Lessons unlock as you make progress.",
                "Build memory with pictures and sound",
                "Every word includes a visual, singular and plural forms, examples, and natural German audio.",
                "Practice real conversations",
                "Listen, speak, and repeat in everyday situations. The coach corrects your answer and helps you try again.",
                "Improve what needs attention",
                "Choose your weakest skill and receive focused practice plus supporting recommendations.",
                "Your daily learning home",
                "Continue your next lesson, see today's practice, and reach the most useful action without searching.",
                "Understand grammar visually",
                "See word order, cases, articles, and sentence structure before practicing them.",
                "Review and play",
                "Use flashcards, matching games, and sentence challenges to bring difficult material back at the right time.",
                "See your progress",
                "Follow your course journey, streak, mastered words, and B1 readiness as you improve.",
                "Prepare for the B1 exam",
                "Practice reading, listening, writing, and speaking with guided tasks and realistic mock exams.",
                "Prepare for life in Germany",
                "Study the official 300 questions plus 10 questions for your federal state, then take randomized mock tests.",
                "Open feature tutorial",
                "Close feature tutorial",
            ] {
                XCTAssertNotEqual(
                    BundledTeachingTranslationCatalog.translation(
                        for: source,
                        language: language
                    ),
                    source,
                    "Missing translated focus/audio copy for \(language.rawValue): \(source)"
                )
            }
        }
        XCTAssertNotEqual(
            BundledTeachingTranslationCatalog.translation(for: "Continue lesson", language: .amharic),
            "Continue lesson"
        )
        XCTAssertNotEqual(
            BundledTeachingTranslationCatalog.translation(for: "Continue lesson", language: .tigrinya),
            "Continue lesson"
        )
        for language in languages where language != .english {
            XCTAssertNotEqual(
                BundledTeachingTranslationCatalog.translation(
                    for: "Beginner German",
                    language: language
                ),
                "Beginner German",
                "Missing bundled course title for \(language.rawValue)"
            )
            XCTAssertNotEqual(
                BundledTeachingTranslationCatalog.translation(
                    for: "A1 COURSE BOOK",
                    language: language
                ),
                "A1 COURSE BOOK",
                "Missing bundled course label for \(language.rawValue)"
            )
        }
    }

    @MainActor
    func testOwnerContentStudioSupportsOnlyKnownCurriculumFiles() {
        let files = AdminContentManager.supportedFiles
        let names = files.map(\.fileName)

        XCTAssertEqual(files.count, 8)
        XCTAssertEqual(Set(names).count, files.count)
        XCTAssertEqual(
            Set(names),
            Set([
                "grammar", "vocab_a1", "vocab_a2", "vocab_b1",
                "lessons", "quizzes", "practical_missions", "everyday_phrases"
            ])
        )
        XCTAssertTrue(files.allSatisfy { !$0.title.isEmpty && !$0.detail.isEmpty })
    }

    @MainActor
    func testAmharicCatalogCoversTheCompleteA1ToB1Curriculum() throws {
        XCTAssertGreaterThanOrEqual(
            BundledTeachingTranslationCatalog.amharicTranslationCount,
            5_800
        )

        let grammar = try ContentLoader.shared.loadGrammar()
        for topic in grammar {
            assertAmharicTranslation(topic.title, context: "\(topic.id) title")
            assertAmharicTranslation(topic.explanation, context: "\(topic.id) explanation")
            topic.examples.forEach {
                assertAmharicTranslation($0.english, context: "\(topic.id) example")
            }
            topic.commonMistakes.forEach {
                assertAmharicTranslation($0, context: "\(topic.id) common mistake")
            }
            for exercise in topic.practice {
                let payload = TeachingTranslationPayload(
                    source: exercise.prompt,
                    protectedGerman: GermanContentProtection.exercisePrompt(
                        exercise.prompt,
                        answer: exercise.answer
                    )
                )
                assertAmharicTranslation(
                    payload.translationSource,
                    context: "\(topic.id) exercise prompt"
                )
                assertAmharicTranslation(
                    exercise.explanation,
                    context: "\(topic.id) exercise explanation"
                )
            }
        }

        for word in try ContentLoader.shared.allVocabulary() {
            assertAmharicTranslation(word.english, context: "\(word.id) meaning")
            assertAmharicTranslation(
                word.exampleTranslation,
                context: "\(word.id) example translation"
            )
        }

        for lesson in try ContentLoader.shared.loadLessons() {
            assertAmharicTranslation(lesson.scenario, context: "\(lesson.id) scenario")
            for exercise in lesson.guidedPractice {
                let payload = TeachingTranslationPayload(
                    source: exercise.prompt,
                    protectedGerman: GermanContentProtection.exercisePrompt(
                        exercise.prompt,
                        answer: exercise.answer
                    )
                )
                assertAmharicTranslation(
                    payload.translationSource,
                    context: "\(lesson.id) guided prompt"
                )
                assertAmharicTranslation(
                    exercise.explanation,
                    context: "\(lesson.id) guided explanation"
                )
            }
            lesson.listening.questions.forEach {
                assertAmharicTranslation($0.prompt, context: "\(lesson.id) listening prompt")
                assertAmharicTranslation($0.answer, context: "\(lesson.id) listening answer")
                assertAmharicTranslation(
                    $0.explanation,
                    context: "\(lesson.id) listening explanation"
                )
            }
            assertAmharicTranslation(
                lesson.speaking.prompt,
                context: "\(lesson.id) speaking prompt"
            )
            assertAmharicTranslation(
                lesson.writing.prompt,
                context: "\(lesson.id) writing prompt"
            )
            lesson.writing.checklist.forEach {
                assertAmharicTranslation($0, context: "\(lesson.id) writing checklist")
            }
            lesson.recap.forEach {
                assertAmharicTranslation($0, context: "\(lesson.id) recap")
            }
        }

        for level in CEFRLevel.allCases {
            for module in IntegrationCourseCurriculum.languageCourseModules(level: level) {
                assertAmharicTranslation(module.title, context: "\(module.id) title")
                assertAmharicTranslation(module.subtitle, context: "\(module.id) subtitle")
            }
        }

        XCTAssertEqual(
            BundledTeachingTranslationCatalog.translation(
                for: "Nominative Articles",
                language: .amharic
            ),
            "የNominativ አርቲክሎች"
        )
        XCTAssertEqual(
            BundledTeachingTranslationCatalog.translation(
                for: "Reflexive Dative",
                language: .amharic
            ),
            "ተመላሽ Dativ"
        )
    }

    func testGermanExerciseContentStaysOutOfSupportTranslation() {
        XCTAssertEqual(
            GermanContentProtection.exercisePrompt(
                "Fill in: Wo ___ du?",
                answer: "wohnst"
            ),
            ["Wo ___ du?"]
        )
        XCTAssertEqual(
            GermanContentProtection.exercisePrompt(
                "Translate: I live in Berlin.",
                answer: "Ich wohne in Berlin."
            ),
            []
        )
        XCTAssertEqual(
            GermanContentProtection.exercisePrompt(
                "Ich ___ müde.",
                answer: "bin"
            ),
            ["Ich ___ müde."]
        )
    }

    func testGermanProtectionUsesWholeWordsAndRestoresExactContent() {
        let ordinaryEnglish = TeachingTranslationPayload(
            source: "Articles are useful in longer explanations.",
            protectedGerman: ["er", "es"]
        )
        XCTAssertEqual(
            ordinaryEnglish.translationSource,
            "Articles are useful in longer explanations."
        )

        let mixedSupport = TeachingTranslationPayload(
            source: "Use er and es before the changed verb.",
            protectedGerman: []
        )
        XCTAssertFalse(mixedSupport.translationSource.contains(" er "))
        XCTAssertFalse(mixedSupport.translationSource.contains(" es "))
        XCTAssertEqual(
            mixedSupport.restoringGerman(in: mixedSupport.translationSource),
            "Use er and es before the changed verb."
        )

        let caseSensitivePronouns = TeachingTranslationPayload(
            source: "Sie sagt, dass sie heute arbeitet.",
            protectedGerman: []
        )
        XCTAssertEqual(
            caseSensitivePronouns.restoringGerman(
                in: caseSensitivePronouns.translationSource
            ),
            "Sie sagt, dass sie heute arbeitet."
        )

        let germanModel = TeachingTranslationPayload(
            source: "Use the model “das ausgefüllte Formular” for “the completed form”.",
            protectedGerman: []
        )
        XCTAssertFalse(germanModel.translationSource.contains("ausgefüllte Formular"))
        XCTAssertTrue(germanModel.translationSource.contains("the completed form"))
        XCTAssertEqual(
            germanModel.restoringGerman(in: germanModel.translationSource),
            "Use the model “das ausgefüllte Formular” for “the completed form”."
        )
    }

    func testGermanProtectionKeepsFormalAndLowercasePronounsDistinct() {
        let source = "Use sie for they and Sie for formal you."
        let payload = TeachingTranslationPayload(source: source, protectedGerman: [])

        XCTAssertEqual(payload.replacements.count, 2)
        XCTAssertTrue(payload.replacements.contains { $0.german == "sie" })
        XCTAssertTrue(payload.replacements.contains { $0.german == "Sie" })
        XCTAssertEqual(payload.restoringGerman(in: payload.translationSource), source)
    }

    func testSimplifiedVocabularyExplanationProtectsGermanForms() {
        let word = VocabWord(
            id: "protection-test",
            level: .a1,
            theme: "Essen",
            german: "Apfel",
            article: "der",
            plural: "Äpfel",
            english: "apple",
            exampleSentence: "Der Apfel ist rot.",
            exampleTranslation: "The apple is red.",
            ttsText: "der Apfel, die Äpfel",
            difficultyTag: "core"
        )
        let explanation = SimplifiedExplanationCatalog.vocabularyWord(word)
        let titlePayload = TeachingTranslationPayload(
            source: explanation.title,
            protectedGerman: explanation.protectedGerman
        )
        let formPayload = TeachingTranslationPayload(
            source: explanation.steps[1].detail,
            protectedGerman: explanation.protectedGerman
        )

        XCTAssertFalse(titlePayload.translationSource.contains("der Apfel"))
        XCTAssertEqual(
            titlePayload.restoringGerman(in: titlePayload.translationSource),
            "der Apfel, made simple"
        )
        XCTAssertFalse(formPayload.translationSource.contains("Äpfel"))
        XCTAssertEqual(
            formPayload.restoringGerman(in: formPayload.translationSource),
            "Treat der + the noun as one word-picture. The plural is Äpfel."
        )
    }

    private func assertAmharicTranslation(
        _ source: String,
        context: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let payload = TeachingTranslationPayload(source: source, protectedGerman: [])
        guard payload.hasSupportLanguageText else { return }
        let translation = BundledTeachingTranslationCatalog.translation(
            for: payload.translationSource,
            language: .amharic
        )
        XCTAssertNotNil(
            translation,
            "Missing Amharic: \(context). Source: \(payload.translationSource)",
            file: file,
            line: line
        )
        XCTAssertNotEqual(
            translation?.trimmingCharacters(in: .whitespacesAndNewlines),
            payload.translationSource.trimmingCharacters(in: .whitespacesAndNewlines),
            "Untranslated Amharic: \(context)",
            file: file,
            line: line
        )
    }

    func testGrammarVisualsSeparateGermanFormsFromSupportLabels() {
        let germanTitle = GrammarVisualNode("ich", "subject", .primary)
        XCTAssertFalse(germanTitle.translatesTitle)
        XCTAssertTrue(germanTitle.translatesDetail)

        let supportTitle = GrammarVisualNode("past action", "completed", .listening)
        XCTAssertTrue(supportTitle.translatesTitle)
        XCTAssertTrue(supportTitle.translatesDetail)

        let germanDetail = GrammarVisualNode("ich", "bin / habe", .primary)
        XCTAssertFalse(germanDetail.translatesTitle)
        XCTAssertFalse(germanDetail.translatesDetail)
    }

    func testA1StartsWithTheCompleteGermanAlphabetAndSoundLesson() throws {
        let grammar: [GrammarTopicDTO] = try decode("grammar")
        let lessons: [CompleteLessonDTO] = try decode("lessons")
        let expectedCharacters = Set(
            ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
             "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
             "Ä", "Ö", "Ü", "ß"]
        )

        XCTAssertEqual(
            CurriculumProgression.grammarSequences[.a1]?.first,
            "a1-alphabet-pronunciation"
        )

        let alphabetTopic = try XCTUnwrap(
            grammar.first { $0.id == "a1-alphabet-pronunciation" }
        )
        XCTAssertEqual(alphabetTopic.level, .a1)
        XCTAssertEqual(alphabetTopic.order, 0)
        XCTAssertGreaterThanOrEqual(alphabetTopic.examples.count, 5)
        XCTAssertGreaterThanOrEqual(alphabetTopic.practice.count, 10)

        let alphabetLesson = try XCTUnwrap(
            lessons.first { $0.id == "a1-l00-alphabet" }
        )
        XCTAssertEqual(alphabetLesson.level, .a1)
        XCTAssertEqual(alphabetLesson.order, 0)
        XCTAssertEqual(alphabetLesson.grammarTopicId, alphabetTopic.id)
        XCTAssertGreaterThanOrEqual(alphabetLesson.guidedPractice.count, 6)

        XCTAssertEqual(GermanAlphabetCatalog.entries.count, 30)
        XCTAssertEqual(Set(GermanAlphabetCatalog.entries.map(\.id)), expectedCharacters)
        XCTAssertEqual(Set(GermanAlphabetCatalog.entries.map(\.id)).count, 30)
        XCTAssertTrue(GermanAlphabetCatalog.entries.allSatisfy {
            !$0.spokenLetterName.isEmpty
                && !$0.letterNameIPA.isEmpty
                && !$0.example.isEmpty
                && !$0.exampleIPA.isEmpty
                && !$0.soundTip.isEmpty
        })
    }

    func testFirstInstallRequiresAnExplicitLanguageChoice() {
        XCTAssertTrue(
            FirstLaunchFlow.requiresLanguageSelection(
                didChooseLanguage: false,
                didCompleteOnboarding: false
            )
        )
        XCTAssertFalse(
            FirstLaunchFlow.requiresLanguageSelection(
                didChooseLanguage: true,
                didCompleteOnboarding: false
            )
        )
        XCTAssertFalse(
            FirstLaunchFlow.requiresLanguageSelection(
                didChooseLanguage: false,
                didCompleteOnboarding: true
            )
        )
        XCTAssertTrue(
            FirstLaunchFlow.requiresTutorial(
                didChooseLanguage: true,
                didCompleteTutorial: false,
                didCompleteOnboarding: false
            )
        )
        XCTAssertFalse(
            FirstLaunchFlow.requiresTutorial(
                didChooseLanguage: false,
                didCompleteTutorial: false,
                didCompleteOnboarding: false
            )
        )
        XCTAssertFalse(
            FirstLaunchFlow.requiresTutorial(
                didChooseLanguage: true,
                didCompleteTutorial: true,
                didCompleteOnboarding: false
            )
        )
        XCTAssertFalse(
            FirstLaunchFlow.requiresTutorial(
                didChooseLanguage: true,
                didCompleteTutorial: false,
                didCompleteOnboarding: true
            )
        )
    }

    func testEveryCEFRCourseBookHasTwoOrderedChapters() {
        for level in CEFRLevel.allCases {
            let chapters = IntegrationCourseCurriculum.languageCourseModules(level: level)
            XCTAssertEqual(chapters.count, 2, level.rawValue)
            XCTAssertEqual(chapters.flatMap(\.itemIDs), CurriculumProgression.grammarSequences[level])
            XCTAssertTrue(chapters.allSatisfy { !$0.title.isEmpty && !$0.subtitle.isEmpty })
        }
    }

    func testVisualLessonFlowCoversEveryTeachingPhase() {
        let phases = LessonTeachingPhase.allCases

        XCTAssertEqual(phases.count, 8)
        XCTAssertEqual(phases.map(\.rawValue), Array(0..<8))
        XCTAssertEqual(Set(phases.map(\.title)).count, phases.count)
        XCTAssertTrue(phases.allSatisfy {
            !$0.prompt.isEmpty && !$0.continueTitle.isEmpty && !$0.icon.isEmpty
        })
    }

    func testVocabularyAndGrammarCoverage() throws {
        let vocabulary = try loadVocabulary()
        let grammar: [GrammarTopicDTO] = try decode("grammar")

        for level in CEFRLevel.allCases {
            XCTAssertGreaterThanOrEqual(vocabulary.filter { $0.level == level }.count, 220)
            XCTAssertGreaterThanOrEqual(grammar.filter { $0.level == level }.count, 25)
        }

        XCTAssertEqual(Set(vocabulary.map(\.id)).count, vocabulary.count)
        XCTAssertEqual(Set(grammar.map(\.id)).count, grammar.count)
        XCTAssertTrue(vocabulary.allSatisfy {
            !$0.german.isEmpty
                && !$0.english.isEmpty
                && !$0.exampleSentence.isEmpty
                && !$0.exampleTranslation.isEmpty
        })
        XCTAssertTrue(vocabulary.allSatisfy { !isWeakTemplate($0.exampleSentence) })
        XCTAssertTrue(vocabulary.filter { $0.level == .a1 }.allSatisfy {
            !isRepeatedTopicFrame($0.exampleSentence)
        })
        let a1SentenceOpenings = vocabulary
            .filter { $0.level == .a1 }
            .map { $0.exampleSentence.split(separator: " ").prefix(3).joined(separator: " ") }
        let repeatedOpenings = Dictionary(grouping: a1SentenceOpenings, by: { $0 })
            .filter { $0.value.count > 2 }
        XCTAssertTrue(repeatedOpenings.isEmpty, "Repeated A1 sentence openings: \(repeatedOpenings.keys.sorted())")
        XCTAssertEqual(Set(vocabulary.map(\.exampleSentence)).count, vocabulary.count)
        XCTAssertTrue(vocabulary.allSatisfy {
            $0.exampleSentence.localizedCaseInsensitiveCompare($0.exampleTranslation) != .orderedSame
        })
        XCTAssertTrue(grammar.allSatisfy { $0.examples.count >= 2 && $0.practice.count >= 9 })
        XCTAssertGreaterThanOrEqual(grammar.flatMap(\.practice).count, 900)
        let practicePrompts = grammar.flatMap(\.practice).map(\.prompt)
        let practiceExplanations = grammar.flatMap(\.practice).map(\.explanation)
        XCTAssertEqual(Set(practicePrompts).count, practicePrompts.count)
        XCTAssertEqual(Set(practiceExplanations).count, practiceExplanations.count)
    }

    func testGeneratedLessonsCoverEveryGrammarTopicAndUseValidVocabulary() throws {
        let vocabulary = try loadVocabulary()
        let grammar: [GrammarTopicDTO] = try decode("grammar")
        let explicit: [CompleteLessonDTO] = try decode("lessons")
        let lessons = CurriculumFactory.lessons(explicit: explicit, grammar: grammar, vocabulary: vocabulary)
        let vocabularyIds = Set(vocabulary.map(\.id))
        let grammarIds = Set(grammar.map(\.id))

        XCTAssertEqual(lessons.count, grammar.count)
        XCTAssertEqual(Set(lessons.map(\.grammarTopicId)), grammarIds)
        XCTAssertTrue(lessons.allSatisfy { !$0.vocabularyIds.isEmpty })
        XCTAssertTrue(lessons.flatMap(\.vocabularyIds).allSatisfy(vocabularyIds.contains))
        XCTAssertTrue(lessons.filter { $0.level != .b1 }.allSatisfy { $0.guidedPractice.count >= 7 })
        XCTAssertTrue(lessons.filter { $0.level == .b1 }.allSatisfy { $0.guidedPractice.count >= 8 })
        XCTAssertTrue(lessons.allSatisfy { $0.listening.questions.count >= 2 })
        XCTAssertEqual(Set(lessons.map(\.scenario)).count, lessons.count)
        XCTAssertEqual(Set(lessons.map(\.listening.script)).count, lessons.count)
        let recapLines = lessons.flatMap(\.recap)
        XCTAssertEqual(Set(recapLines).count, recapLines.count)
        XCTAssertFalse(lessons.contains {
            $0.listening.script.hasPrefix("Heute üben wir Grammatik mit Alltagssätzen.")
        })

        for level in CEFRLevel.allCases {
            let levelLessons = lessons.filter { $0.level == level }.sorted { $0.order < $1.order }
            XCTAssertEqual(levelLessons.map(\.grammarTopicId), CurriculumProgression.grammarSequences[level])
            XCTAssertEqual(levelLessons.map(\.order), Array(1...levelLessons.count))
        }

        let explicitLessonIDs = Set(explicit.map(\.id))
        let vocabularyByID = Dictionary(uniqueKeysWithValues: vocabulary.map { ($0.id, $0) })
        for lesson in lessons where !explicitLessonIDs.contains(lesson.id) {
            let lessonThemes = Set(lesson.vocabularyIds.compactMap { vocabularyByID[$0]?.theme })
            XCTAssertEqual(lessonThemes.count, 1, "Mixed vocabulary themes in \(lesson.id): \(lessonThemes)")
        }
    }

    func testIntegrationCourseHasSixProgressiveLanguageSections() {
        let sections = IntegrationCourseCurriculum.languageSections

        XCTAssertEqual(sections.count, 6)
        XCTAssertEqual(sections.map(\.number), Array(1...6))
        XCTAssertEqual(sections.filter { $0.level == .a1 }.count, 2)
        XCTAssertEqual(sections.filter { $0.level == .a2 }.count, 2)
        XCTAssertEqual(sections.filter { $0.level == .b1 }.count, 2)
        XCTAssertEqual(sections.map { $0.lessonRange.count }.reduce(0, +), 76)
        XCTAssertTrue(sections.allSatisfy { !$0.band.isEmpty && !$0.goal.isEmpty })

        for level in CEFRLevel.allCases {
            let modules = IntegrationCourseCurriculum.languageCourseModules(level: level)
            XCTAssertEqual(modules.count, 2)
            XCTAssertEqual(
                modules.flatMap(\.itemIDs),
                CurriculumProgression.grammarSequences[level] ?? []
            )
        }
    }

    func testEveryLanguageLessonHasAnIntegrationOutcomeAndTransferTask() throws {
        let vocabulary = try loadVocabulary()
        let grammar: [GrammarTopicDTO] = try decode("grammar")
        let explicit: [CompleteLessonDTO] = try decode("lessons")
        let lessons = CurriculumFactory.lessons(explicit: explicit, grammar: grammar, vocabulary: vocabulary)
        let vocabularyByID = Dictionary(uniqueKeysWithValues: vocabulary.map { ($0.id, $0) })
        var coveredFields: Set<IntegrationActionField> = []

        for lesson in lessons {
            let themes = Array(Set(lesson.vocabularyIds.compactMap { vocabularyByID[$0]?.theme }))
            let profile = IntegrationCourseCurriculum.profile(for: lesson, vocabularyThemes: themes)
            coveredFields.insert(profile.actionField)

            XCTAssertEqual(profile.canDoStatements.count, 3, lesson.id)
            XCTAssertTrue(profile.canDoStatements.allSatisfy { $0.hasPrefix("I can ") }, lesson.id)
            XCTAssertFalse(profile.context.isEmpty, lesson.id)
            XCTAssertFalse(profile.transferTask.isEmpty, lesson.id)
            XCTAssertFalse(profile.speakingPrompt.isEmpty, lesson.id)
            XCTAssertFalse(profile.writingPrompt.isEmpty, lesson.id)
            XCTAssertGreaterThanOrEqual(profile.writingChecklist.count, 5, lesson.id)
            XCTAssertFalse(profile.textType.isEmpty, lesson.id)
            XCTAssertFalse(profile.participationNote.isEmpty, lesson.id)
        }

        XCTAssertEqual(coveredFields, Set(IntegrationActionField.allCases))
    }

    func testOfficialOrientationCatalogueHasEveryRequiredQuestion() throws {
        XCTAssertEqual(IntegrationCourseCurriculum.orientationCourseLanguageCode, "de")
        XCTAssertNil(OrientationQuestionRepository.loadErrorDescription)
        XCTAssertEqual(OrientationQuestionRepository.source.publisher, "Bundesamt für Migration und Flüchtlinge")
        XCTAssertEqual(OrientationQuestionRepository.source.date, "07.05.2025")
        XCTAssertEqual(OrientationQuestionRepository.generalQuestions.count, 300)
        XCTAssertEqual(GermanFederalState.allCases.count, 16)
        XCTAssertEqual(Set(GermanFederalState.allCases.map(\.rawValue)).count, 16)
        XCTAssertEqual(Set(GermanFederalState.allCases.map(\.name)).count, 16)

        let allQuestions = IntegrationCourseCurriculum.allOrientationQuestions
        XCTAssertEqual(allQuestions.count, 460)
        XCTAssertEqual(Set(allQuestions.map(\.id)).count, 460)

        for state in GermanFederalState.allCases {
            let stateQuestions = OrientationQuestionRepository.questions(for: state)
            let catalogs = IntegrationCourseCurriculum.orientationQuestionCatalogs(for: state)
            let learnerQuestions = catalogs.flatMap(\.questions)

            XCTAssertEqual(stateQuestions.count, 10, state.name)
            XCTAssertEqual(stateQuestions.map(\.number), Array(1...10), state.name)
            XCTAssertTrue(stateQuestions.allSatisfy { $0.stateCode == state.rawValue }, state.name)
            XCTAssertEqual(catalogs.count, 4, state.name)
            XCTAssertEqual(catalogs.map { $0.questions.count }, [100, 100, 100, 10], state.name)
            XCTAssertEqual(learnerQuestions.count, 310, state.name)
            XCTAssertEqual(Set(learnerQuestions.map(\.id)).count, 310, state.name)
        }

        for question in allQuestions {
            XCTAssertFalse(question.question.isEmpty, question.id)
            XCTAssertEqual(question.choices.count, OrientationQuestion.requiredChoiceCount, question.id)
            XCTAssertTrue(question.hasStandardChoiceFormat, question.id)
            XCTAssertEqual(
                question.choices.filter {
                    !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }.count,
                4,
                question.id
            )
            XCTAssertTrue(question.choices.indices.contains(question.answerIndex), question.id)
            XCTAssertFalse(question.answer.isEmpty, question.id)
            if let imageName = question.imageName {
                XCTAssertNoThrow(
                    try resourceURL(
                        imageName,
                        withExtension: "png",
                        subdirectory: "OrientationImages"
                    ),
                    question.id
                )
            }
        }

        XCTAssertEqual(allQuestions.filter { $0.imageName != nil }.count, 43)
    }

    func testOrientationQuestionProgressPersistsStableOfficialIDs() {
        let questions = IntegrationCourseCurriculum.orientationQuestions(for: .berlin)
        let mastered = Set(questions.prefix(3).map(\.id))
        let encoded = OrientationQuestionProgress.encoded(mastered)
        XCTAssertEqual(OrientationQuestionProgress.masteredIDs(from: encoded), mastered)
        XCTAssertTrue(mastered.allSatisfy { $0.hasPrefix("general-") })
    }

    func testOrientationQuestionsCanBeOpenedDirectlyByNumber() throws {
        let state = GermanFederalState.berlin

        for number in [1, 150, 300] {
            let question = try XCTUnwrap(
                IntegrationCourseCurriculum.orientationQuestion(
                    number: number,
                    scope: .general,
                    for: state
                )
            )
            XCTAssertEqual(question.number, number)
            XCTAssertEqual(question.scope, .general)
        }

        for number in [1, 5, 10] {
            let question = try XCTUnwrap(
                IntegrationCourseCurriculum.orientationQuestion(
                    number: number,
                    scope: .state,
                    for: state
                )
            )
            XCTAssertEqual(question.number, number)
            XCTAssertEqual(question.scope, .state)
            XCTAssertEqual(question.stateCode, state.rawValue)
        }

        XCTAssertNil(
            IntegrationCourseCurriculum.orientationQuestion(
                number: 0,
                scope: .general,
                for: state
            )
        )
        XCTAssertNil(
            IntegrationCourseCurriculum.orientationQuestion(
                number: 301,
                scope: .general,
                for: state
            )
        )
        XCTAssertNil(
            IntegrationCourseCurriculum.orientationQuestion(
                number: 11,
                scope: .state,
                for: state
            )
        )
    }

    func testRandomizedOrientationMockExamMatchesOfficialFormat() throws {
        XCTAssertEqual(OrientationMockExamFactory.generalQuestionCount, 30)
        XCTAssertEqual(OrientationMockExamFactory.stateQuestionCount, 3)
        XCTAssertEqual(OrientationMockExamFactory.totalQuestionCount, 33)
        XCTAssertEqual(OrientationMockExamFactory.durationSeconds, 3_600)
        XCTAssertEqual(OrientationMockExamFactory.lifeInGermanyPassScore, 15)
        XCTAssertEqual(OrientationMockExamFactory.citizenshipPassScore, 17)

        let officialByID = Dictionary(
            uniqueKeysWithValues: IntegrationCourseCurriculum.allOrientationQuestions.map { ($0.id, $0) }
        )

        for (index, state) in GermanFederalState.allCases.enumerated() {
            var generator = SeededRandomNumberGenerator(seed: UInt64(index + 1))
            let attempt = try XCTUnwrap(
                OrientationMockExamFactory.make(for: state, using: &generator),
                state.name
            )

            XCTAssertEqual(attempt.questions.count, 33, state.name)
            XCTAssertEqual(Set(attempt.questions.map(\.id)).count, 33, state.name)
            XCTAssertTrue(attempt.questions.prefix(30).allSatisfy { $0.scope == .general }, state.name)
            XCTAssertTrue(attempt.questions.suffix(3).allSatisfy {
                $0.scope == .state && $0.stateCode == state.rawValue
            }, state.name)
            XCTAssertTrue(attempt.questions.allSatisfy(\.hasStandardChoiceFormat), state.name)
            XCTAssertTrue(attempt.questions.allSatisfy { question in
                officialByID[question.id]?.choices == question.choices
            }, "Answer order changed for \(state.name)")
        }

        var firstGenerator = SeededRandomNumberGenerator(seed: 101)
        var secondGenerator = SeededRandomNumberGenerator(seed: 202)
        let first = try XCTUnwrap(OrientationMockExamFactory.make(for: .berlin, using: &firstGenerator))
        let second = try XCTUnwrap(OrientationMockExamFactory.make(for: .berlin, using: &secondGenerator))
        XCTAssertNotEqual(first.questions.map(\.id), second.questions.map(\.id))
    }

    func testOrientationMockExamScoringUsesOfficialThresholds() throws {
        var generator = SeededRandomNumberGenerator(seed: 42)
        let attempt = try XCTUnwrap(
            OrientationMockExamFactory.make(for: .northRhineWestphalia, using: &generator)
        )

        let fifteenAnswers = Dictionary(
            uniqueKeysWithValues: attempt.questions.prefix(15).map { ($0.id, $0.answerIndex) }
        )
        let lifeInGermanyResult = OrientationMockExamFactory.result(
            for: attempt,
            answers: fifteenAnswers
        )
        XCTAssertEqual(lifeInGermanyResult.correctCount, 15)
        XCTAssertTrue(lifeInGermanyResult.passedLifeInGermany)
        XCTAssertFalse(lifeInGermanyResult.reachedCitizenshipThreshold)
        XCTAssertEqual(lifeInGermanyResult.unansweredCount, 18)

        let seventeenAnswers = Dictionary(
            uniqueKeysWithValues: attempt.questions.prefix(17).map { ($0.id, $0.answerIndex) }
        )
        let citizenshipResult = OrientationMockExamFactory.result(
            for: attempt,
            answers: seventeenAnswers
        )
        XCTAssertEqual(citizenshipResult.correctCount, 17)
        XCTAssertTrue(citizenshipResult.passedLifeInGermany)
        XCTAssertTrue(citizenshipResult.reachedCitizenshipThreshold)
        XCTAssertEqual(citizenshipResult.unansweredCount, 16)
    }

    func testEveryTopicHasACompleteExtraSimpleExplanation() throws {
        let grammarDTOs: [GrammarTopicDTO] = try decode("grammar")
        let vocabularyDTOs = try loadVocabulary()
        XCTAssertEqual(
            SimplifiedExplanationCatalog.supportedGrammarTopicIDs,
            Set(grammarDTOs.map(\.id))
        )
        XCTAssertEqual(
            SimplifiedExplanationCatalog.supportedVocabularyThemes,
            Set(vocabularyDTOs.map(\.theme))
        )
        let grammarExplanations = grammarDTOs.map { dto in
            SimplifiedExplanationCatalog.grammar(
                GrammarTopic(
                    id: dto.id,
                    level: dto.level,
                    order: dto.order,
                    title: dto.title,
                    explanation: dto.explanation,
                    examples: dto.examples,
                    commonMistakes: dto.commonMistakes,
                    practice: dto.practice
                )
            )
        }
        let wordExplanations = vocabularyDTOs.map { dto in
            SimplifiedExplanationCatalog.vocabularyWord(
                VocabWord(
                    id: dto.id,
                    level: dto.level,
                    theme: dto.theme,
                    german: dto.german,
                    article: dto.article,
                    plural: dto.plural,
                    english: dto.english,
                    exampleSentence: dto.exampleSentence,
                    exampleTranslation: dto.exampleTranslation,
                    ttsText: dto.ttsText,
                    difficultyTag: dto.difficultyTag
                )
            )
        }
        for explanation in grammarExplanations + wordExplanations {
            XCTAssertFalse(explanation.title.isEmpty)
            XCTAssertFalse(explanation.oneLine.isEmpty)
            XCTAssertFalse(explanation.analogy.isEmpty)
            XCTAssertEqual(explanation.steps.count, 3)
            XCTAssertTrue(explanation.steps.allSatisfy { !$0.title.isEmpty && !$0.detail.isEmpty })
            XCTAssertFalse(explanation.checkQuestion.isEmpty)
            XCTAssertFalse(explanation.checkAnswer.isEmpty)
            XCTAssertFalse(explanation.icon.isEmpty)
        }
        XCTAssertEqual(Set(grammarExplanations.map(\.oneLine)).count, grammarDTOs.count)
    }

    func testEveryLessonHasMemoryVisualCoverage() throws {
        let vocabulary = try loadVocabulary()
        let grammar: [GrammarTopicDTO] = try decode("grammar")
        let explicit: [CompleteLessonDTO] = try decode("lessons")
        let lessons = CurriculumFactory.lessons(explicit: explicit, grammar: grammar, vocabulary: vocabulary)

        for level in CEFRLevel.allCases {
            let levelLessons = lessons.filter { $0.level == level }
            let atlasTileIndices = levelLessons.map(LessonVisualCatalog.tileIndex).filter { $0 >= 0 }
            XCTAssertEqual(levelLessons.count, CurriculumProgression.grammarSequences[level]?.count)
            XCTAssertEqual(atlasTileIndices.count, 14)
            XCTAssertTrue(atlasTileIndices.allSatisfy { 0..<16 ~= $0 })
            XCTAssertEqual(Set(atlasTileIndices).count, atlasTileIndices.count)
            XCTAssertGreaterThanOrEqual(levelLessons.count - atlasTileIndices.count, 11)
        }
    }

    func testEveryGrammarAndVocabularyItemHasAVisualExplanation() throws {
        let vocabulary = try loadVocabulary()
        let grammar: [GrammarTopicDTO] = try decode("grammar")

        XCTAssertEqual(Set(grammar.map(\.id)), GrammarVisualCatalog.supportedTopicIDs)
        XCTAssertTrue(vocabulary.allSatisfy {
            VocabularyVisualCatalog.supportedThemes.contains($0.theme)
        })
        XCTAssertTrue(vocabulary.allSatisfy {
            !VocabularyVisualCatalog.symbol(theme: $0.theme, german: $0.german, english: $0.english).isEmpty
        })
        for word in vocabulary {
            let descriptor = VocabularyVisualCatalog.descriptor(
                theme: word.theme,
                german: word.german,
                english: word.english
            )
            XCTAssertNotNil(
                UIImage(systemName: descriptor.primarySymbol),
                "Missing primary picture for \(word.german): \(descriptor.primarySymbol)"
            )
            XCTAssertNotNil(
                UIImage(systemName: descriptor.contextSymbol),
                "Missing context picture for \(word.german): \(descriptor.contextSymbol)"
            )
        }
        XCTAssertTrue(vocabulary.allSatisfy {
            VocabularyVisualCatalog.kind(
                article: $0.article,
                plural: $0.plural,
                english: $0.english,
                theme: $0.theme
            ).rawValue.isEmpty == false
        })
        let distinctPictures = Set(vocabulary.map {
            VocabularyVisualCatalog.symbol(theme: $0.theme, german: $0.german, english: $0.english)
        })
        XCTAssertGreaterThanOrEqual(distinctPictures.count, 75)
    }

    func testEveryVocabularyEntryHasAnExactReviewedImage() throws {
        let vocabulary = try loadVocabulary()

        XCTAssertGreaterThanOrEqual(VocabularyObjectAtlas.exactImageKeyCount, 670)
        XCTAssertTrue(vocabulary.allSatisfy {
            VocabularyObjectAtlas.hasExactImage(forEnglish: $0.english)
        })
        XCTAssertTrue(VocabularyObjectAtlas.hasExactImage(forEnglish: "banana"))
    }

    func testGeneratedQuizBankIsLargeAndAnswerable() throws {
        let vocabulary = try loadVocabulary()
        let grammar: [GrammarTopicDTO] = try decode("grammar")
        let explicit: [QuizQuestionDTO] = try decode("quizzes")
        let quizzes = CurriculumFactory.quizzes(explicit: explicit, grammar: grammar, vocabulary: vocabulary)

        XCTAssertGreaterThanOrEqual(quizzes.count, 2_100)
        XCTAssertEqual(Set(quizzes.map(\.id)).count, quizzes.count)
        XCTAssertTrue(quizzes.allSatisfy { !$0.prompt.isEmpty && !$0.correctAnswer.isEmpty && !$0.explanation.isEmpty })
        XCTAssertTrue(quizzes.allSatisfy { $0.choices.isEmpty || $0.choices.contains($0.correctAnswer) })
    }

    func testPracticalMissionsCoverEssentialSituationsAtEveryLevel() throws {
        let missions: [PracticalMissionDTO] = try decode("practical_missions")

        XCTAssertEqual(missions.count, 25)
        XCTAssertEqual(Set(missions.map(\.id)).count, missions.count)
        for level in CEFRLevel.allCases {
            let levelMissions = missions.filter { $0.level == level }.sorted { $0.order < $1.order }
            let expectedCount = level == .b1 ? 13 : 6
            XCTAssertEqual(levelMissions.count, expectedCount)
            XCTAssertEqual(levelMissions.map(\.order), Array(1...expectedCount))
        }
        XCTAssertTrue(missions.allSatisfy { !$0.goal.isEmpty && !$0.setting.isEmpty && !$0.partnerRole.isEmpty })
        XCTAssertTrue(missions.allSatisfy { $0.canDo.count >= 3 && $0.phrases.count >= 4 && $0.turns.count >= 4 })
        XCTAssertTrue(missions.flatMap(\.turns).allSatisfy {
            !$0.partnerCue.isEmpty
                && !$0.modelResponse.isEmpty
                && !$0.requiredPhrases.isEmpty
                && !$0.grammarMarkers.isEmpty
        })
        XCTAssertTrue(missions.allSatisfy { !$0.writingPrompt.isEmpty && $0.writingChecklist.count >= 4 })
        XCTAssertTrue(
            Set([
                "a1-shopping", "a1-supermarket", "a2-customer-sale",
                "b1-interview", "b1-first-day", "b1-sick-leave",
                "b1-school-meeting", "b1-health-insurance", "b1-bank-security",
                "b1-neighbor", "b1-qualification", "b1-community-club"
            ])
                .isSubset(of: Set(missions.map(\.id)))
        )
    }

    func testEverydayPhrasebookContainsTwoHundredFortyUsefulUniquePhrases() throws {
        let categories: [EverydayPhraseCategoryDTO] = try decode("everyday_phrases")
        let phrases = categories.flatMap(\.phrases)

        XCTAssertEqual(categories.count, 12)
        XCTAssertTrue(categories.allSatisfy {
            !$0.title.isEmpty && !$0.subtitle.isEmpty && !$0.icon.isEmpty && $0.phrases.count == 20
        })
        XCTAssertEqual(phrases.count, 240)
        XCTAssertEqual(Set(phrases.map(\.id)).count, phrases.count)
        XCTAssertEqual(Set(phrases.map(\.german)).count, phrases.count)
        XCTAssertTrue(phrases.allSatisfy {
            !$0.german.isEmpty && !$0.english.isEmpty
                && $0.german.localizedCaseInsensitiveCompare($0.english) != .orderedSame
        })
        XCTAssertEqual(phrases.filter { $0.level == .a1 }.count, 84)
        XCTAssertEqual(phrases.filter { $0.level == .a2 }.count, 84)
        XCTAssertEqual(phrases.filter { $0.level == .b1 }.count, 72)
        XCTAssertTrue(
            Set([
                "polite-essentials", "understand-clarify", "meeting-people", "time-plans",
                "shopping-paying", "food-cafes", "getting-around", "home-neighbors",
                "health-pharmacy", "work-colleagues", "appointments-services", "phone-urgent-help"
            ]).isSubset(of: Set(categories.map(\.id)))
        )
    }

    func testEveryCurriculumTopicHasACompleteMiniLessonPath() throws {
        let vocabulary = try loadVocabulary()
        let grammar: [GrammarTopicDTO] = try decode("grammar")
        let vocabularyTopics = Set(vocabulary.map { "\($0.level.rawValue)|\($0.theme)" })

        XCTAssertEqual(VocabularyTopicLesson.allCases.count, 4)
        XCTAssertEqual(GrammarTopicLesson.allCases.count, 5)
        XCTAssertGreaterThanOrEqual(vocabularyTopics.count, 40)
        XCTAssertEqual(vocabularyTopics.count * VocabularyTopicLesson.allCases.count, 172)
        XCTAssertEqual(grammar.count * GrammarTopicLesson.allCases.count, 380)
        XCTAssertTrue(vocabularyTopics.allSatisfy { topic in
            vocabulary.contains { "\($0.level.rawValue)|\($0.theme)" == topic }
        })

        for level in CEFRLevel.allCases {
            let grammarIDs = Set(grammar.filter { $0.level == level }.map(\.id))
            let vocabularyThemes = Set(vocabulary.filter { $0.level == level }.map(\.theme))
            XCTAssertEqual(Set(CurriculumProgression.grammarSequences[level] ?? []), grammarIDs)
            XCTAssertEqual(Set(CurriculumProgression.vocabularySequences[level] ?? []), vocabularyThemes)
        }
    }

    func testMiniLessonsUnlockStrictlyInOrder() {
        XCTAssertEqual(CurriculumProgression.unlockedStageIndexes(completed: [], count: 5), [0])
        XCTAssertEqual(CurriculumProgression.unlockedStageIndexes(completed: [0], count: 5), [0, 1])
        XCTAssertEqual(CurriculumProgression.unlockedStageIndexes(completed: [0, 1], count: 5), [0, 1, 2])
        XCTAssertEqual(CurriculumProgression.unlockedStageIndexes(completed: [0, 1, 2, 3, 4], count: 5), [0, 1, 2, 3, 4])
    }

    func testModulesCategorizeEveryTopicWithoutLongLists() {
        for level in CEFRLevel.allCases {
            let grammarModules = CurriculumProgression.grammarModules(level: level)
            let vocabularyModules = CurriculumProgression.vocabularyModules(level: level)

            XCTAssertEqual(grammarModules.flatMap(\.itemIDs), CurriculumProgression.grammarSequences[level] ?? [])
            XCTAssertEqual(vocabularyModules.flatMap(\.itemIDs), CurriculumProgression.vocabularySequences[level] ?? [])
            XCTAssertEqual(grammarModules.count, 5)
            XCTAssertTrue(grammarModules.allSatisfy { 5...6 ~= $0.itemIDs.count })
            XCTAssertTrue(vocabularyModules.allSatisfy { 2...4 ~= $0.itemIDs.count })
        }
    }

    func testVocabularyReviewStatusStartsInLearningDeck() {
        let item = ReviewItem(id: "review-test", contentId: "test", kind: .vocabulary)
        XCTAssertFalse(item.isMemorized)
        XCTAssertFalse(item.isMarked)
    }

    func testDailyFocusPlanScalesAndPrioritizesDueReview() {
        XCTAssertEqual(DailyFocusPlan.steps(minutes: 5, prioritizesReview: false).count, 2)
        XCTAssertEqual(DailyFocusPlan.steps(minutes: 10, prioritizesReview: false).count, 3)
        XCTAssertEqual(DailyFocusPlan.steps(minutes: 15, prioritizesReview: false).count, 4)
        XCTAssertEqual(DailyFocusPlan.steps(minutes: 10, prioritizesReview: true).first, .recall)

        for minutes in [5, 10, 15] {
            let steps = DailyFocusPlan.steps(minutes: minutes, prioritizesReview: true)
            XCTAssertEqual(Set(steps.map(\.id)).count, steps.count)
        }
    }

    func testExamReadinessStartsWithListeningAndNoFalseReadiness() {
        let readiness = ExamReadinessSnapshot(activities: [])

        XCTAssertEqual(readiness.progress, 0)
        XCTAssertEqual(readiness.passedSectionCount, 0)
        XCTAssertEqual(readiness.totalAttemptCount, 0)
        XCTAssertEqual(readiness.nextSection, .listening)
        XCTAssertFalse(readiness.isPracticeReady)
    }

    func testExamReadinessUsesLatestScoreAndPreservesPersonalBest() {
        let earlier = Date(timeIntervalSince1970: 1_000)
        let later = Date(timeIntervalSince1970: 2_000)
        let activities = [
            LearningActivity(level: .b1, skill: .listening, score: 0.85, xp: 25, sourceId: B1ExamSection.listening.activitySourceID, createdAt: earlier),
            LearningActivity(level: .b1, skill: .listening, score: 0.45, xp: 12, sourceId: B1ExamSection.listening.activitySourceID, createdAt: later),
            LearningActivity(level: .b1, skill: .reading, score: 0.70, xp: 25, sourceId: B1ExamSection.reading.activitySourceID, createdAt: later)
        ]

        let readiness = ExamReadinessSnapshot(activities: activities)
        let listening = readiness.readiness(for: .listening)

        XCTAssertEqual(listening.latestScore, 0.45)
        XCTAssertEqual(listening.bestScore, 0.85)
        XCTAssertEqual(listening.attemptCount, 2)
        XCTAssertFalse(listening.isAtPracticeLevel)
        XCTAssertEqual(readiness.nextSection, .writing)
        XCTAssertFalse(readiness.isPracticeReady)
    }

    func testExamReadinessRequiresAllFourLatestScoresAtTarget() {
        let activities = B1ExamSection.allCases.enumerated().map { index, section in
            LearningActivity(
                level: .b1,
                skill: section.skillArea,
                score: 0.60 + (Double(index) * 0.05),
                xp: 25,
                sourceId: section.activitySourceID
            )
        }
        let readiness = ExamReadinessSnapshot(activities: activities)

        XCTAssertEqual(readiness.passedSectionCount, 4)
        XCTAssertEqual(readiness.totalAttemptCount, 4)
        XCTAssertTrue(readiness.isPracticeReady)
        XCTAssertEqual(readiness.progress, 0.675, accuracy: 0.0001)
    }

    func testPrivacyManifestDeclaresAppOnlyDefaultsAndNoTracking() throws {
        let manifestURL = try resourceURL("PrivacyInfo", withExtension: "xcprivacy")
        let data = try Data(contentsOf: manifestURL)
        let manifest = try XCTUnwrap(
            PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        )

        XCTAssertEqual(manifest["NSPrivacyTracking"] as? Bool, false)
        XCTAssertEqual((manifest["NSPrivacyTrackingDomains"] as? [String])?.count, 0)
        let collectedData = try XCTUnwrap(manifest["NSPrivacyCollectedDataTypes"] as? [[String: Any]])
        let productInteraction = try XCTUnwrap(collectedData.first)
        XCTAssertEqual(collectedData.count, 1)
        XCTAssertEqual(productInteraction["NSPrivacyCollectedDataType"] as? String, "NSPrivacyCollectedDataTypeProductInteraction")
        XCTAssertEqual(productInteraction["NSPrivacyCollectedDataTypeLinked"] as? Bool, false)
        XCTAssertEqual(productInteraction["NSPrivacyCollectedDataTypeTracking"] as? Bool, false)
        XCTAssertEqual(productInteraction["NSPrivacyCollectedDataTypePurposes"] as? [String], ["NSPrivacyCollectedDataTypePurposeAnalytics"])

        let APIs = try XCTUnwrap(manifest["NSPrivacyAccessedAPITypes"] as? [[String: Any]])
        let defaults = try XCTUnwrap(APIs.first)
        XCTAssertEqual(defaults["NSPrivacyAccessedAPIType"] as? String, "NSPrivacyAccessedAPICategoryUserDefaults")
        XCTAssertEqual(defaults["NSPrivacyAccessedAPITypeReasons"] as? [String], ["CA92.1"])
    }

    func testProductionLiveServicesRemainConfigured() throws {
        let configuration = try XCTUnwrap(LiveContentConfiguration.current())
        XCTAssertEqual(configuration.baseURL, LiveContentConfiguration.productionBaseURL)
        XCTAssertEqual(configuration.baseURL.scheme, "https")
        XCTAssertEqual(configuration.baseURL.host, "example.invalid")
    }

    func testNeuralAudioResourceNamesAreStable() {
        XCTAssertEqual(
            GermanSpeechService.neuralResourceName(for: "  Guten\nTag!  "),
            GermanSpeechService.neuralResourceName(for: "Guten Tag!")
        )
        XCTAssertEqual(GermanSpeechService.neuralResourceName(for: "Guten Tag!"), "neural_59800e41c4aaabfb")
        XCTAssertLessThan(GermanSpeechStyle.model.neuralPlaybackRate, GermanSpeechStyle.listening.neuralPlaybackRate)
    }

    @MainActor
    func testFocusedListeningUsesEveryMissionAndTurnInOrder() throws {
        let lessons = try ContentLoader.shared.loadLessons()
        let missions = try ContentLoader.shared.loadPracticalMissions()
        let dialogues = ListeningCoachDialogue.curriculum(lessons: lessons, missions: missions)

        XCTAssertEqual(dialogues.count, lessons.count + missions.count)
        XCTAssertEqual(
            dialogues.reduce(0) { $0 + $1.questions.count },
            lessons.reduce(0) { $0 + $1.listening.questions.count }
                + missions.reduce(0) { $0 + $1.turns.count }
        )

        for level in CEFRLevel.allCases {
            let levelDialogues = dialogues.filter { $0.level == level }
            XCTAssertFalse(levelDialogues.isEmpty, "Missing focused listening for \(level.rawValue)")
            XCTAssertEqual(levelDialogues.map(\.order), levelDialogues.map(\.order).sorted())
            XCTAssertTrue(levelDialogues.allSatisfy { !$0.script.isEmpty && !$0.questions.isEmpty })
        }
    }

    func testLearningFocusAndSpeechSpeedOptionsAreComplete() {
        XCTAssertEqual(SkillArea.allCases.count, 6)
        XCTAssertTrue(SkillArea.allCases.allSatisfy {
            !$0.learningFocusTitle.isEmpty
                && !$0.learningFocusDetail.isEmpty
                && !$0.learningFocusOutcome.isEmpty
        })
        for skill in SkillArea.allCases {
            let improvements = skill.supportingImprovementSkills
            XCTAssertEqual(improvements.count, 3)
            XCTAssertEqual(Set(improvements).count, improvements.count)
            XCTAssertFalse(improvements.contains(skill))
        }
        XCTAssertEqual(GermanSpeechSpeed.allCases.map(\.rawValue), [0.75, 1, 1.25])
        XCTAssertEqual(GermanSpeechSpeed.resolve(0.8), .slow)
        XCTAssertEqual(GermanSpeechSpeed.resolve(1.1), .normal)
        XCTAssertEqual(GermanSpeechSpeed.resolve(1.3), .fast)
    }

    func testEveryMainFeatureHasAContextualTutorial() {
        XCTAssertEqual(MainFeatureTutorial.allCases.count, 5)
        XCTAssertEqual(Set(MainFeatureTutorial.allCases.map(\.id)).count, 5)
        XCTAssertTrue(MainFeatureTutorial.allCases.allSatisfy {
            !$0.title.isEmpty && !$0.message.isEmpty && !$0.icon.isEmpty
        })
    }

    func testEveryFixedPlaybackPromptHasBundledNeuralAudio() throws {
        let vocabulary = try loadVocabulary()
        let grammar: [GrammarTopicDTO] = try decode("grammar")
        let explicit: [CompleteLessonDTO] = try decode("lessons")
        let lessons = CurriculumFactory.lessons(explicit: explicit, grammar: grammar, vocabulary: vocabulary)
        let missions: [PracticalMissionDTO] = try decode("practical_missions")
        let phrasebook: [EverydayPhraseCategoryDTO] = try decode("everyday_phrases")
        let exam: MockExam = try decode("mock_exam_b1")

        var prompts = [GermanSpeechService.previewText]
        prompts += vocabulary.flatMap { [$0.ttsText, $0.exampleSentence] }
        prompts += grammar.flatMap { topic in
            topic.examples.map(\.german) + topic.practice.map(\.answer)
        }
        prompts += lessons.flatMap { [$0.listening.script, $0.speaking.expectedAnswer] }
        prompts += missions.flatMap { mission in
            mission.phrases.map(\.german)
                + mission.turns.flatMap { [$0.partnerCue, $0.modelResponse] }
        }
        prompts += phrasebook.flatMap(\.phrases).map(\.german)
        prompts += exam.sections.flatMap { section in
            section.tasks.compactMap(\.audioScript)
        }
        prompts += CEFRLevel.allCases.map {
            FluencyTaskCatalog.speaking(level: $0).speechPrompt.expectedAnswer
        }

        let missing = Set(prompts).filter {
            !GermanSpeechService.shared.hasBundledNeuralAudio(for: $0)
        }
        XCTAssertTrue(
            missing.isEmpty,
            "Fixed playback prompts missing neural audio: \(missing.sorted())"
        )
    }

    func testNeuralAudioPackIsCompleteAndValid() throws {
        let manifestURL = try resourceURL(
            "neural_audio_manifest",
            withExtension: "json",
            subdirectory: "NeuralAudio"
        )
        let resources = manifestURL.deletingLastPathComponent()
        let manifest = try JSONDecoder().decode(
            NeuralAudioManifest.self,
            from: Data(contentsOf: manifestURL)
        )

        XCTAssertGreaterThanOrEqual(manifest.clipCount, 2_150)
        XCTAssertEqual(manifest.clipCount, manifest.clips.count)
        XCTAssertEqual(Set(manifest.clips.map(\.id)).count, manifest.clips.count)
        XCTAssertTrue(manifest.clips.allSatisfy {
            $0.id == GermanSpeechService.neuralResourceName(for: $0.text)
        })
        for clip in manifest.clips {
            let attributes = try FileManager.default.attributesOfItem(
                atPath: resources.appendingPathComponent(clip.file).path
            )
            let fileSize = (attributes[.size] as? NSNumber)?.intValue ?? 0
            XCTAssertGreaterThan(fileSize, 1_024, clip.file)
        }

        let availableText = Set(manifest.clips.map(\.text))
        let vocabulary = try loadVocabulary()
        let grammar: [GrammarTopicDTO] = try decode("grammar")
        let missions: [PracticalMissionDTO] = try decode("practical_missions")
        let phrasebook: [EverydayPhraseCategoryDTO] = try decode("everyday_phrases")
        XCTAssertTrue(vocabulary.allSatisfy { availableText.contains($0.ttsText) })
        XCTAssertTrue(vocabulary.allSatisfy { availableText.contains($0.exampleSentence) })
        XCTAssertTrue(grammar.flatMap(\.examples).allSatisfy { availableText.contains($0.german) })
        XCTAssertTrue(grammar.flatMap(\.practice).allSatisfy { availableText.contains($0.answer) })
        XCTAssertTrue(missions.flatMap(\.phrases).allSatisfy { availableText.contains($0.german) })
        XCTAssertTrue(missions.flatMap(\.turns).allSatisfy {
            availableText.contains($0.partnerCue) && availableText.contains($0.modelResponse)
        })
        XCTAssertTrue(phrasebook.flatMap(\.phrases).allSatisfy {
            availableText.contains($0.german)
        })
    }

    private func loadVocabulary() throws -> [VocabWordDTO] {
        try ["vocab_a1", "vocab_a2", "vocab_b1"].flatMap { try decode($0) as [VocabWordDTO] }
    }

    private func decode<T: Decodable>(_ name: String) throws -> T {
        let url = try resourceURL(name, withExtension: "json")
        return try JSONDecoder().decode(T.self, from: Data(contentsOf: url))
    }

    func testNativeGrammarColorSemanticsResolveCaseTopics() {
        XCTAssertEqual(GermanGrammarCase.inferred(from: "NOM subject"), .nominative)
        XCTAssertEqual(GermanGrammarCase.inferred(from: "a1-accusative"), .accusative)
        XCTAssertEqual(GermanGrammarCase.inferred(from: "Dative receiver"), .dative)
        XCTAssertEqual(GermanGrammarCase.inferred(from: "b1-genitive"), .genitive)
    }

    func testCompoundAnalyzerPreservesFugenSAsItsOwnVisualPart() {
        let parts = GermanCompoundAnalyzer.parts(for: "Aufenthaltserlaubnis")

        XCTAssertEqual(parts.map(\.text), ["Aufenthalt", "s", "erlaubnis"])
        XCTAssertEqual(parts.map(\.isConnector), [false, true, false])
    }

    func testScenarioStylesResolveExistingRealLifeSettings() {
        XCTAssertEqual(LessonScenarioStyle.resolve(scenario: "In der Bäckerei"), .bakery)
        XCTAssertEqual(LessonScenarioStyle.resolve(scenario: "Beim Bürgeramt"), .bureaucracy)
        XCTAssertEqual(LessonScenarioStyle.resolve(scenario: "Eine Wohnung mieten"), .apartment)
    }

    private func resourceURL(
        _ name: String,
        withExtension fileExtension: String,
        subdirectory: String? = nil
    ) throws -> URL {
        let bundles = [Bundle.main, Bundle(for: CurriculumIntegrityTests.self)]
        for bundle in bundles {
            if let url = bundle.url(
                forResource: name,
                withExtension: fileExtension,
                subdirectory: subdirectory
            ) {
                return url
            }
            if subdirectory != nil,
               let url = bundle.url(forResource: name, withExtension: fileExtension) {
                return url
            }
        }

        let sourceResources = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Resources")
        let directory = subdirectory.map { sourceResources.appendingPathComponent($0) } ?? sourceResources
        let sourceURL = directory.appendingPathComponent("\(name).\(fileExtension)")
        guard FileManager.default.fileExists(atPath: sourceURL.path) else {
            throw NSError(
                domain: "CurriculumIntegrityTests.Resource",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Missing test resource \(sourceURL.lastPathComponent)"]
            )
        }
        return sourceURL
    }

    private func isWeakTemplate(_ value: String) -> Bool {
        ["Hier ist", "Kannst du heute", "Die Situation ist", "Wir verwenden heute"]
            .contains { value.hasPrefix($0) }
    }

    private func isRepeatedTopicFrame(_ value: String) -> Bool {
        let repeatedFrames = [
            "Deutschkurs",
            "Sprachkurs",
            "Im Unterricht",
            "Kannst du etwas über",
            "sprechen wir über",
            "geht es heute um",
            "möchte ich mehr über"
        ]
        return repeatedFrames.contains { value.localizedCaseInsensitiveContains($0) }
    }
}

private struct NeuralAudioManifest: Decodable {
    let clipCount: Int
    let clips: [NeuralAudioClip]
}

private struct NeuralAudioClip: Decodable {
    let id: String
    let file: String
    let text: String
}

private struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state
    }
}
