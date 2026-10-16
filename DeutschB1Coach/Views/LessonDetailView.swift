import SwiftUI
import SwiftData

private enum GrammarLessonPanel: String, CaseIterable, Identifiable {
    case visual = "Visual"
    case build = "Build"
    case explanation = "Explain"
    case examples = "Examples"

    var id: String { rawValue }
}

private enum LessonListeningRound: Int, CaseIterable, Identifiable {
    case meaning
    case pattern
    case shadow

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .meaning: "Meaning"
        case .pattern: "Notice"
        case .shadow: "Shadow"
        }
    }

    var subtitle: String {
        switch self {
        case .meaning: "Understand the situation without reading"
        case .pattern: "Read once and locate the grammar pattern"
        case .shadow: "Speak with the model at a comfortable pace"
        }
    }

    var icon: String {
        switch self {
        case .meaning: "ear.fill"
        case .pattern: "text.magnifyingglass"
        case .shadow: "waveform.and.mic"
        }
    }

    var speechStyle: GermanSpeechStyle {
        switch self {
        case .meaning: .listening
        case .pattern: .sentence
        case .shadow: .model
        }
    }
}

struct LessonDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedTab") private var selectedTab = 1
    let lesson: CompleteLessonDTO
    @Query private var vocab: [VocabWord]
    @Query private var topics: [GrammarTopic]
    @Query private var lessonRecords: [LessonRecord]
    @State private var step = 0
    @State private var selectedAnswers: [String: String] = [:]
    @State private var typedAnswers: [String: String] = [:]
    @State private var checkedTypedAnswers: Set<String> = []
    @State private var vocabularyIndex = 0
    @State private var practiceIndex = 0
    @State private var grammarPanel = GrammarLessonPanel.visual
    @State private var listeningRound = LessonListeningRound.meaning
    @State private var completedListeningRounds: Set<LessonListeningRound> = []
    @State private var revealedListeningAnswers: Set<Int> = []
    @State private var showCompletion = false
    @State private var returnToLessonMenuAfterCompletion = false
    @State private var showsPremium = false
    @State private var premium = PremiumAccessService.shared
    @State private var recordedLessonStart = false
    @Namespace private var namespace

    init(lesson: CompleteLessonDTO, initialStep: Int = 0) {
        self.lesson = lesson
        _step = State(initialValue: min(max(initialStep, 0), 7))
    }

    private var lessonVocab: [VocabWord] {
        let wordsByID = Dictionary(uniqueKeysWithValues: vocab.map { ($0.id, $0) })
        return lesson.vocabularyIds.compactMap { wordsByID[$0] }
    }

    private var grammarTopic: GrammarTopic? {
        topics.first { $0.id == lesson.grammarTopicId }
    }

    private var integrationProfile: IntegrationLessonProfile {
        IntegrationCourseCurriculum.profile(
            for: lesson,
            vocabularyThemes: Array(Set(lessonVocab.map(\.theme))).sorted()
        )
    }

    private var phase: LessonTeachingPhase {
        LessonTeachingPhase(rawValue: step) ?? .context
    }

    private var continueTitle: String {
        phase.continueTitle
    }

    private var orderedLevelTopics: [GrammarTopic] {
        CurriculumProgression.orderedGrammarTopics(topics, level: lesson.level)
    }

    private var topicSequenceIndex: Int? {
        orderedLevelTopics.firstIndex { $0.id == lesson.grammarTopicId }
    }

    private var previousTopicTitle: String? {
        guard let topicSequenceIndex, topicSequenceIndex > 0 else { return nil }
        return orderedLevelTopics[topicSequenceIndex - 1].title
    }

    private var nextTopicTitle: String? {
        guard let topicSequenceIndex, topicSequenceIndex + 1 < orderedLevelTopics.count else { return nil }
        return orderedLevelTopics[topicSequenceIndex + 1].title
    }

    private var totalLevelLessons: Int {
        max(CurriculumProgression.grammarSequences[lesson.level]?.count ?? orderedLevelTopics.count, 1)
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                LessonProgressBar(progress: Double(step + 1) / Double(LessonTeachingPhase.allCases.count))
                LessonPhaseMap(phase: phase)
                HStack(spacing: 10) {
                    CoachIconTile(icon: phase.icon, tint: phase.tint, size: 38)
                    VStack(alignment: .leading, spacing: 2) {
                        TeachingText(english: phase.title)
                            .font(.callout.weight(.bold))
                        TeachingText(english: phase.prompt)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    Spacer()
                    Text("\(step + 1)/\(LessonTeachingPhase.allCases.count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(phase.tint)
                }
            }
            .padding()

            ScrollViewReader { proxy in
                ScrollView {
                    Color.clear
                        .frame(height: 1)
                        .id("lesson-step-top")
                    stepContent
                        .padding()
                        .id(step)
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                }
                .onChange(of: step) { _, _ in
                    proxy.scrollTo("lesson-step-top", anchor: .top)
                }
            }
            .coachBackground()

            HStack(spacing: 12) {
                Button {
                    withAnimation(CoachMotion.spring) {
                        step = max(0, step - 1)
                    }
                } label: {
                    Label {
                        TeachingText(english: "Back")
                    } icon: {
                        Image(systemName: "chevron.left")
                    }
                }
                .buttonStyle(SecondaryCoachButton(tint: CoachTheme.primary))
                .disabled(step == 0)

                Button {
                    withAnimation(CoachMotion.spring) {
                        if step + 1 < LessonTeachingPhase.allCases.count {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            step += 1
                            saveProgress(isComplete: false)
                        } else {
                            saveProgress(isComplete: true)
                            CoachFeedback.success()
                            showCompletion = true
                        }
                    }
                } label: {
                    Label {
                        TeachingText(english: continueTitle)
                            .lineLimit(2)
                            .minimumScaleFactor(0.78)
                    } icon: {
                        Image(systemName: step + 1 == LessonTeachingPhase.allCases.count ? "checkmark" : "chevron.right")
                    }
                }
                .buttonStyle(PrimaryCoachButton())
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .navigationTitle(lesson.title)
        .teachingLanguageSwitcher()
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCompletion, onDismiss: returnToLessonMenuIfNeeded) {
            completionView
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showsPremium) {
            PremiumView(entryPoint: .lessonCompleted)
        }
        .onAppear {
            if !recordedLessonStart {
                recordedLessonStart = true
                PrivateProductAnalytics.record(.lessonStarted)
            }
            if let record = lessonRecords.first(where: { $0.lessonId == lesson.id }), !record.isCompleted {
                step = min(record.highestCompletedStep, LessonTeachingPhase.allCases.count - 1)
            }
        }
    }

    @ViewBuilder private var stepContent: some View {
        switch step {
        case 0: introView
        case 1: vocabularyView
        case 2: grammarView
        case 3: guidedPracticeView
        case 4: listeningView
        case 5: speakingView
        case 6: writingView
        default: recapView
        }
    }

    private var introView: some View {
        CoachCard {
            VStack(alignment: .leading, spacing: 16) {
                ScenarioHeroView(lesson: lesson)
                Text(lesson.title)
                    .font(.largeTitle.bold())
                HStack(spacing: 8) {
                    SkillChip(title: lesson.level.rawValue, color: CoachTheme.primary)
                    SkillChip(title: "Lesson \(lesson.order) of \(totalLevelLessons)", color: CoachTheme.listening)
                }
                HStack(spacing: 8) {
                    SkillChip(title: integrationProfile.section.band, color: CoachTheme.reward)
                    SkillChip(title: integrationProfile.actionField.title, color: CoachTheme.speaking)
                }
                TeachingText(english: lesson.scenario)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                LessonSequenceRoadmap(
                    previous: previousTopicTitle,
                    current: lesson.title,
                    next: nextTopicTitle
                )
                Divider()
                VStack(alignment: .leading, spacing: 9) {
                    Label {
                        TeachingText(english: "By the end of this lesson")
                    } icon: {
                        Image(systemName: "target")
                    }
                    .font(.headline)
                    .foregroundStyle(CoachTheme.primary)

                    ForEach(Array(integrationProfile.canDoStatements.enumerated()), id: \.offset) { index, statement in
                        lessonObjective(
                            icon: index == 0 ? integrationProfile.actionField.icon : index == 1 ? "textformat" : "arrow.triangle.2.circlepath",
                            title: index == 0 ? "Act in German" : index == 1 ? "Use the language tool" : "Repair communication",
                            detail: statement,
                            tint: index == 0 ? CoachTheme.primary : index == 1 ? CoachTheme.reward : CoachTheme.speaking
                        )
                    }
                }

                VStack(alignment: .leading, spacing: 5) {
                    Label {
                        TeachingText(english: "Real-life transfer")
                    } icon: {
                        Image(systemName: "arrow.up.forward.circle.fill")
                    }
                    .font(.callout.weight(.bold))
                    .foregroundStyle(CoachTheme.correct)
                    TeachingText(english: integrationProfile.transferTask)
                        .font(.callout)
                }
                .padding(12)
                .background(CoachTheme.correct.opacity(0.08), in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))

                DisclosureGroup {
                    TeachingText(english: integrationProfile.participationNote)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding(.top, 7)
                } label: {
                    Label {
                        TeachingText(english: "Participation in Germany")
                    } icon: {
                        Image(systemName: "building.columns.fill")
                    }
                }
                .font(.callout.weight(.semibold))
            }
        }
    }

    private var vocabularyView: some View {
        VStack(alignment: .leading, spacing: 14) {
            if lessonVocab.indices.contains(vocabularyIndex) {
                let word = lessonVocab[vocabularyIndex]
                CoachSectionHeader(
                    title: "Word \(vocabularyIndex + 1) of \(lessonVocab.count)",
                    subtitle: "Say it, picture it, then read it in context"
                )
                LessonProgressBar(progress: Double(vocabularyIndex + 1) / Double(max(lessonVocab.count, 1)))

                CoachCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            SkillChip(title: word.theme, color: CoachTheme.listening, translatesTitle: false)
                            Spacer(minLength: 8)
                            GermanSpeechButton(text: word.ttsText, style: .word, label: "Play pronunciation for \(word.german)")
                            GermanSpeechButton(text: word.exampleSentence, label: "Play example sentence")
                        }
                        VocabularyVisualExplanation(word: word, compact: false, prefersVisualRecall: true)
                        SimplifiedExplanationButton(
                            explanation: SimplifiedExplanationCatalog.vocabularyWord(word),
                            tint: CoachTheme.accent
                        )
                    }
                }

                itemNavigation(
                    index: vocabularyIndex,
                    count: lessonVocab.count,
                    canAdvance: true,
                    previous: { vocabularyIndex = max(0, vocabularyIndex - 1) },
                    next: { vocabularyIndex = min(lessonVocab.count - 1, vocabularyIndex + 1) },
                    nextTitle: "Next word",
                    completionTitle: "All words seen"
                )
            } else {
                CoachEmptyState(
                    icon: "character.book.closed.fill",
                    title: "Vocabulary is ready in review",
                    message: "Continue to the grammar pattern for this lesson."
                )
            }
        }
    }

    @ViewBuilder private var grammarView: some View {
        if grammarTopic?.id == "a1-alphabet-pronunciation" {
            GermanAlphabetLessonView()
        } else {
            CoachCard(tint: CoachTheme.reward) {
                VStack(alignment: .leading, spacing: 14) {
                    TeachingText(english: grammarTopic?.title ?? "Grammar Focus")
                        .font(.title2.weight(.semibold))
                    if let grammarTopic {
                        Picker(selection: $grammarPanel) {
                            ForEach(GrammarLessonPanel.allCases) { panel in
                                TeachingText(english: panel.rawValue).tag(panel)
                            }
                        } label: {
                            TeachingText(english: "Grammar explanation")
                        }
                        .pickerStyle(.segmented)
                        .tint(CoachTheme.reward)

                        SimplifiedExplanationButton(
                            explanation: SimplifiedExplanationCatalog.grammar(grammarTopic),
                            tint: CoachTheme.reward
                        )

                        grammarPanelContent(grammarTopic)
                            .id(grammarPanel)
                            .transition(.opacity)
                            .animation(CoachMotion.quick, value: grammarPanel)

                        if !grammarTopic.commonMistakes.isEmpty {
                            DisclosureGroup {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(grammarTopic.commonMistakes, id: \.self) { mistake in
                                        Label {
                                            TeachingText(english: mistake)
                                        } icon: {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                        }
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.top, 8)
                            } label: {
                                TeachingText(english: "Common mistakes to avoid")
                            }
                            .font(.callout.weight(.semibold))
                        }
                    } else {
                        TeachingText(english: "The grammar topic could not be loaded. Continue to practice or reopen the lesson.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var guidedPracticeView: some View {
        VStack(alignment: .leading, spacing: 14) {
            if lesson.guidedPractice.indices.contains(practiceIndex) {
                let exercise = lesson.guidedPractice[practiceIndex]
                let isAnswered = exercise.choices.isEmpty
                    ? checkedTypedAnswers.contains(exercise.prompt)
                    : selectedAnswers[exercise.prompt] != nil

                CoachSectionHeader(
                    title: "Question \(practiceIndex + 1) of \(lesson.guidedPractice.count)",
                    subtitle: "Answer first, then study the explanation"
                )
                LessonProgressBar(
                    progress: Double(practiceIndex + (isAnswered ? 1 : 0))
                        / Double(max(lesson.guidedPractice.count, 1))
                )
                CoachCard(tint: CoachTheme.primary) {
                    LessonPracticeVisualPrimer(topic: grammarTopic)
                }
                practiceCard(exercise)
                itemNavigation(
                    index: practiceIndex,
                    count: lesson.guidedPractice.count,
                    canAdvance: isAnswered,
                    previous: { practiceIndex = max(0, practiceIndex - 1) },
                    next: { practiceIndex = min(lesson.guidedPractice.count - 1, practiceIndex + 1) },
                    nextTitle: "Next question",
                    completionTitle: "Practice complete"
                )
            } else {
                CoachEmptyState(
                    icon: "checklist",
                    title: "No guided questions",
                    message: "Continue to listening and use the model sentence aloud."
                )
            }
        }
    }

    private func practiceCard(_ exercise: LessonExercise) -> some View {
        CoachCard {
            VStack(alignment: .leading, spacing: 12) {
                TeachingText(
                    english: exercise.prompt,
                    protectedGerman: GermanContentProtection.exercisePrompt(
                        exercise.prompt,
                        answer: exercise.answer
                    )
                )
                    .font(.headline)
                if exercise.choices.isEmpty {
                    let answerBinding = Binding(
                        get: { typedAnswers[exercise.prompt, default: ""] },
                        set: { typedAnswers[exercise.prompt] = $0 }
                    )
                    TeachingTextField(prompt: "Type your answer", text: answerBinding, axis: .vertical)
                    .textFieldStyle(CoachTextFieldStyle(tint: CoachTheme.primary))
                    .germanKeyboardAccessory(text: answerBinding)
                    TeachingButton("Check answer") {
                        checkedTypedAnswers.insert(exercise.prompt)
                    }
                    .buttonStyle(PrimaryCoachButton())
                    .disabled(typedAnswers[exercise.prompt, default: ""].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    if checkedTypedAnswers.contains(exercise.prompt) {
                        let isCorrect = normalized(typedAnswers[exercise.prompt, default: ""]) == normalized(exercise.answer)
                        VStack(alignment: .trailing, spacing: 8) {
                            CoachFeedbackPanel(
                                isCorrect: isCorrect,
                                title: isCorrect ? "Correct" : "Answer: \(exercise.answer)",
                                message: exercise.explanation,
                                protectedGerman: [exercise.answer]
                            )
                            GermanSpeechButton(text: exercise.answer, label: "Play correct answer")
                        }
                    }
                } else {
                    ForEach(exercise.choices, id: \.self) { choice in
                        Button {
                            UIImpactFeedbackGenerator(style: choice == exercise.answer ? .light : .rigid).impactOccurred()
                            withAnimation(CoachMotion.spring) {
                                selectedAnswers[exercise.prompt] = choice
                            }
                        } label: {
                            HStack {
                                Text(choice)
                                Spacer()
                                if selectedAnswers[exercise.prompt] == choice {
                                    Image(systemName: choice == exercise.answer ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundStyle(choice == exercise.answer ? CoachTheme.correct : CoachTheme.incorrect)
                                }
                            }
                        }
                        .buttonStyle(SecondaryCoachButton(tint: CoachTheme.primary))
                    }
                    if let selected = selectedAnswers[exercise.prompt] {
                        VStack(alignment: .trailing, spacing: 8) {
                            CoachFeedbackPanel(
                                isCorrect: selected == exercise.answer,
                                title: selected == exercise.answer ? "Correct" : "Answer: \(exercise.answer)",
                                message: exercise.explanation,
                                protectedGerman: [exercise.answer]
                            )
                            GermanSpeechButton(text: exercise.answer, label: "Play correct answer")
                        }
                    }
                }
            }
        }
    }

    private var listeningView: some View {
        CoachCard(tint: CoachTheme.listening) {
            VStack(alignment: .leading, spacing: 16) {
                LessonListeningVisual(lesson: lesson, words: lessonVocab)
                ListeningRoundSelector(
                    selected: listeningRound,
                    completed: completedListeningRounds,
                    select: selectListeningRound
                )
                Divider()
                listeningRoundContent

                if let nextRound = nextListeningRound {
                    Button {
                        CoachFeedback.selection()
                        withAnimation(CoachMotion.spring) {
                            listeningRound = nextRound
                        }
                    } label: {
                        TeachingLabel(english: "Next: \(nextRound.title)", systemImage: "chevron.right")
                    }
                    .buttonStyle(SecondaryCoachButton(tint: CoachTheme.listening))
                    .disabled(!completedListeningRounds.contains(listeningRound))
                } else if completedListeningRounds.contains(.shadow) {
                    TeachingLabel(english: "Listening cycle complete", systemImage: "checkmark.seal.fill")
                        .font(.callout.weight(.bold))
                        .foregroundStyle(CoachTheme.correct)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }

    private var speakingView: some View {
        CoachCard(tint: CoachTheme.speaking) {
            VStack(alignment: .leading, spacing: 12) {
                LessonSpeakingVisual(
                    sentence: lesson.speaking.expectedAnswer,
                    phrases: lesson.speaking.requiredPhrases
                )
                Divider()
                TeachingText(english: lesson.speaking.prompt)
                VStack(alignment: .leading, spacing: 3) {
                    TeachingText(english: "Safe German model")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(lesson.speaking.expectedAnswer)
                        .font(.callout)
                        .environment(\.layoutDirection, .leftToRight)
                }
                NavigationLink {
                    SpeakingPracticeView(
                        prompt: SpeechPrompt(
                            expectedAnswer: lesson.speaking.expectedAnswer,
                            requiredPhrases: lesson.speaking.requiredPhrases,
                            grammarMarkers: lesson.speaking.grammarMarkers,
                            targetDuration: 5...18
                        ),
                        taskTitle: lesson.speaking.prompt,
                        level: lesson.level
                    )
                } label: {
                    TeachingLabel(english: "Open Speaking Coach", systemImage: "mic.fill")
                }
                .buttonStyle(PrimaryCoachButton())
            }
        }
    }

    private var writingView: some View {
        CoachCard(tint: CoachTheme.writing) {
            VStack(alignment: .leading, spacing: 12) {
                LessonWritingVisual(checklist: lesson.writing.checklist)
                Divider()
                TeachingText(english: lesson.writing.prompt)
                NavigationLink {
                    WritingPracticeView(prompt: lesson.writing.prompt, checklist: lesson.writing.checklist, level: lesson.level)
                } label: {
                    TeachingLabel(english: "Open Writing Lab", systemImage: "square.and.pencil")
                }
                .buttonStyle(PrimaryCoachButton())
            }
        }
    }

    private var recapView: some View {
        CoachCard(tint: CoachTheme.correct) {
            VStack(alignment: .leading, spacing: 12) {
                LessonRecapVisual(
                    lesson: lesson,
                    wordCount: lessonVocab.count,
                    grammarTitle: grammarTopic?.title ?? "Grammar pattern"
                )
                Divider()
                ForEach(lesson.recap, id: \.self) { item in
                    Label {
                        TeachingText(english: item)
                    } icon: {
                        Image(systemName: "checkmark.seal.fill")
                    }
                        .foregroundStyle(CoachTheme.primary)
                }
                Divider()
                VStack(alignment: .leading, spacing: 6) {
                    Label {
                        TeachingText(english: "Do it outside the lesson")
                    } icon: {
                        Image(systemName: "arrow.up.forward.circle.fill")
                    }
                    .font(.headline)
                    .foregroundStyle(CoachTheme.correct)
                    TeachingText(english: integrationProfile.transferTask)
                        .font(.callout)
                    TeachingText(english: "Text type: \(integrationProfile.textType)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(CoachTheme.correct.opacity(0.08), in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
            }
        }
    }

    @ViewBuilder private func grammarPanelContent(_ topic: GrammarTopic) -> some View {
        switch grammarPanel {
        case .visual:
            GrammarVisualExplanation(topic: topic)
        case .build:
            SentenceBuilderGameLink(topic: topic)
        case .explanation:
            GrammarPlainLanguageGuide(topic: topic)
        case .examples:
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(topic.examples.enumerated()), id: \.offset) { index, example in
                    HStack(alignment: .top, spacing: 9) {
                        Text("\(index + 1)")
                            .font(.caption.weight(.bold).monospacedDigit())
                            .foregroundStyle(.white)
                            .frame(width: 26, height: 26)
                            .background(CoachTheme.listening, in: Circle())
                        VStack(alignment: .leading, spacing: 3) {
                            Text(example.german)
                                .font(.headline)
                                .environment(\.layoutDirection, .leftToRight)
                            TeachingText(english: example.english)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 8)
                        GermanSpeechButton(text: example.german, label: "Play grammar example")
                        GrammarXRayButton(sentence: example.german, topic: topic)
                    }
                }
            }
        }
    }

    private var completionView: some View {
        ScrollView {
            VStack(spacing: 18) {
                CoachCelebrationMark()
                VStack(spacing: 5) {
                    TeachingText(english: "Lesson Complete")
                        .font(.largeTitle.bold())
                    TeachingText(english: "You moved your \(lesson.level.rawValue) journey forward.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                LessonAccomplishmentProgress(
                    level: lesson.level,
                    completedLesson: lesson.order,
                    totalLessons: totalLevelLessons,
                    xp: lesson.xp,
                    wordCount: lessonVocab.count,
                    practiceCount: lesson.guidedPractice.count
                )

                if integrationProfile.isCheckpoint {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(CoachTheme.reward)
                            .frame(width: 36, height: 36)
                            .background(CoachTheme.reward.opacity(0.12), in: Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(integrationProfile.section.band) checkpoint")
                                .font(.headline)
                            TeachingText(english: integrationProfile.section.goal)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    .background(CoachTheme.reward.opacity(0.08), in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
                }

                if let nextTopicTitle {
                    HStack(spacing: 10) {
                        Image(systemName: "lock.open.fill")
                            .foregroundStyle(CoachTheme.correct)
                            .frame(width: 34, height: 34)
                            .background(CoachTheme.correct.opacity(0.12), in: Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            TeachingText(english: "Next lesson unlocked")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            TeachingText(english: nextTopicTitle)
                                .font(.headline)
                                .lineLimit(2)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    .background(CoachTheme.correct.opacity(0.08), in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
                }

                if shouldOfferFullJourney {
                    CoachCard(tint: CoachTheme.accent) {
                        VStack(alignment: .leading, spacing: 10) {
                            TeachingLabel(english: "Your next step", systemImage: "arrow.up.right.circle.fill")
                                .font(.headline)
                                .foregroundStyle(CoachTheme.accent)
                            TeachingText(
                                english: lesson.level == .a1
                                    ? "You completed the free A1 starter. Continue the complete chronological course when you are ready."
                                    : "You experienced a lesson at your placed level. Continue this (lesson.level.rawValue) course in order with the full coach."
                            )
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            TeachingButton("Continue the full journey") {
                                showCompletion = false
                                Task { @MainActor in
                                    try? await Task.sleep(for: .milliseconds(220))
                                    showsPremium = true
                                }
                            }
                            .buttonStyle(PrimaryCoachButton(tint: CoachTheme.accent))
                        }
                    }
                }

                Button {
                    returnToLessonMenuAfterCompletion = true
                    showCompletion = false
                } label: {
                    Label {
                        TeachingText(english: "Choose next lesson")
                    } icon: {
                        Image(systemName: "list.bullet.rectangle")
                    }
                }
                .buttonStyle(PrimaryCoachButton())
            }
            .padding()
        }
    }

    @ViewBuilder private var listeningRoundContent: some View {
        switch listeningRound {
        case .meaning:
            VStack(alignment: .leading, spacing: 13) {
                listeningInstruction(
                    title: "Listen without reading",
                    message: "Play the audio once. Notice who is speaking, the main action, and the overall meaning. Missing a few words is normal."
                )
                listeningPlayButton(title: "Play for meaning", round: .meaning)
                listeningQuestions
            }
        case .pattern:
            VStack(alignment: .leading, spacing: 13) {
                listeningInstruction(
                    title: "Connect sound and structure",
                    message: "Read while you listen again. Find the target pattern and compare the two model sentences."
                )
                HStack(alignment: .top, spacing: 8) {
                    Text(lesson.listening.script)
                        .font(.body)
                        .environment(\.layoutDirection, .leftToRight)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    GrammarXRayButton(sentence: lesson.listening.script, topic: grammarTopic)
                }
                .padding(12)
                .background(CoachTheme.listening.opacity(0.08), in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
                HStack {
                    SkillChip(title: lesson.title, color: CoachTheme.reward, translatesTitle: false)
                    Spacer()
                    listeningPlayButton(title: "Listen with text", round: .pattern)
                }
            }
        case .shadow:
            VStack(alignment: .leading, spacing: 13) {
                listeningInstruction(
                    title: "Shadow the speaker",
                    message: "Play the slower model. Speak just after the voice, copy the rhythm, then repeat the full audio at natural speed."
                )
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(listeningChunks.enumerated()), id: \.offset) { index, chunk in
                        HStack(alignment: .top, spacing: 9) {
                            Text("\(index + 1)")
                                .font(.caption.weight(.heavy).monospacedDigit())
                                .foregroundStyle(.white)
                                .frame(width: 26, height: 26)
                                .background(CoachTheme.speaking, in: Circle())
                            Text(chunk)
                                .font(.callout.weight(.medium))
                                .environment(\.layoutDirection, .leftToRight)
                            Spacer(minLength: 0)
                            GrammarXRayButton(sentence: chunk, topic: grammarTopic)
                        }
                    }
                }
                HStack(spacing: 10) {
                    listeningPlayButton(title: "Play slowly", round: .shadow)
                    Button {
                        completedListeningRounds.insert(.shadow)
                        GermanSpeechService.shared.speak(lesson.listening.script, style: .listening)
                    } label: {
                        TeachingLabel(english: "Natural", systemImage: "speaker.wave.2.fill")
                    }
                    .buttonStyle(SecondaryCoachButton(tint: CoachTheme.listening))
                }
            }
        }
    }

    private var listeningQuestions: some View {
        VStack(alignment: .leading, spacing: 9) {
            ForEach(Array(lesson.listening.questions.enumerated()), id: \.offset) { index, question in
                VStack(alignment: .leading, spacing: 8) {
                    Button {
                        CoachFeedback.selection()
                        withAnimation(CoachMotion.quick) {
                            if revealedListeningAnswers.contains(index) {
                                revealedListeningAnswers.remove(index)
                            } else {
                                revealedListeningAnswers.insert(index)
                            }
                        }
                    } label: {
                        HStack(alignment: .top) {
                            TeachingText(english: question.prompt)
                                .font(.callout.weight(.semibold))
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 8)
                            Image(systemName: revealedListeningAnswers.contains(index) ? "chevron.up" : "eye.fill")
                                .foregroundStyle(CoachTheme.listening)
                        }
                    }
                    .buttonStyle(.plain)

                    if revealedListeningAnswers.contains(index) {
                        HStack(alignment: .top, spacing: 8) {
                            TeachingText(english: question.answer)
                                .font(.callout.weight(.semibold))
                            Spacer(minLength: 4)
                            GrammarXRayButton(sentence: question.answer, topic: grammarTopic)
                        }
                        TeachingText(english: question.explanation)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(11)
                .background(CoachTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
                .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(CoachTheme.listening.opacity(0.16)))
            }
        }
    }

    private func listeningInstruction(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            TeachingText(english: title)
                .font(.headline)
            TeachingText(english: message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func listeningPlayButton(title: String, round: LessonListeningRound) -> some View {
        Button {
            completedListeningRounds.insert(round)
            CoachFeedback.selection()
            GermanSpeechService.shared.speak(lesson.listening.script, style: round.speechStyle)
        } label: {
            TeachingLabel(english: title, systemImage: "speaker.wave.2.fill")
        }
        .buttonStyle(PrimaryCoachButton(tint: CoachTheme.listening))
    }

    private var nextListeningRound: LessonListeningRound? {
        LessonListeningRound(rawValue: listeningRound.rawValue + 1)
    }

    private var listeningChunks: [String] {
        var result: [String] = []
        lesson.listening.script.enumerateSubstrings(
            in: lesson.listening.script.startIndex..<lesson.listening.script.endIndex,
            options: .bySentences
        ) { substring, _, _, _ in
            if let substring {
                result.append(substring.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        return result.isEmpty ? [lesson.listening.script] : result
    }

    private func selectListeningRound(_ round: LessonListeningRound) {
        let isUnlocked = round == .meaning
            || LessonListeningRound(rawValue: round.rawValue - 1).map(completedListeningRounds.contains) == true
        guard isUnlocked else {
            CoachFeedback.warning()
            return
        }
        CoachFeedback.selection()
        withAnimation(CoachMotion.spring) {
            listeningRound = round
        }
    }

    private func lessonObjective(
        icon: String,
        title: String,
        detail: String,
        tint: Color
    ) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                TeachingText(english: title)
                    .font(.callout.weight(.bold))
                TeachingText(english: detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func returnToLessonMenuIfNeeded() {
        guard returnToLessonMenuAfterCompletion else { return }
        returnToLessonMenuAfterCompletion = false
        dismiss()
        selectedTab = 1
    }

    @ViewBuilder private func itemNavigation(
        index: Int,
        count: Int,
        canAdvance: Bool,
        previous: @escaping () -> Void,
        next: @escaping () -> Void,
        nextTitle: String,
        completionTitle: String
    ) -> some View {
        HStack(spacing: 10) {
            Button {
                CoachFeedback.selection()
                withAnimation(CoachMotion.quick) { previous() }
            } label: {
                TeachingLabel(english: "Previous", systemImage: "chevron.left")
            }
            .buttonStyle(SecondaryCoachButton(tint: CoachTheme.primary))
            .disabled(index == 0)

            Spacer(minLength: 4)

            if index + 1 < count {
                Button {
                    CoachFeedback.selection()
                    withAnimation(CoachMotion.quick) { next() }
                } label: {
                    TeachingLabel(english: nextTitle, systemImage: "chevron.right")
                }
                .buttonStyle(PrimaryCoachButton())
                .disabled(!canAdvance)
            } else {
                TeachingLabel(
                    english: canAdvance ? completionTitle : "Finish this item",
                    systemImage: canAdvance ? "checkmark.circle.fill" : "circle"
                )
                .font(.callout.weight(.semibold))
                .foregroundStyle(canAdvance ? CoachTheme.correct : Color.secondary)
            }
        }
    }

    private func saveProgress(isComplete: Bool) {
        let wasComplete = lessonRecords.first(where: { $0.lessonId == lesson.id })?.isCompleted == true
        try? ProgressService().recordLesson(
            lesson,
            completedStep: step,
            isComplete: isComplete,
            modelContext: modelContext
        )
        if isComplete && !wasComplete {
            PrivateProductAnalytics.record(.lessonCompleted)
        }
    }

    private var shouldOfferFullJourney: Bool {
        !premium.isPremium
            && (lesson.level != .a1 || lesson.order == PremiumAccessPolicy.freeA1LessonCount)
    }

    private func normalized(_ value: String) -> String {
        value.lowercased().trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))
    }
}

private struct LessonSequenceRoadmap: View {
    let previous: String?
    let current: String
    let next: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            TeachingText(english: "Your learning sequence")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack(alignment: .top, spacing: 5) {
                sequenceNode(
                    label: "BEFORE",
                    title: previous ?? "Level starting point",
                    translatesTitle: true,
                    icon: previous == nil ? "flag.fill" : "checkmark",
                    tint: previous == nil ? CoachTheme.listening : CoachTheme.correct,
                    isCurrent: false
                )
                sequenceArrow
                sequenceNode(
                    label: "TODAY",
                    title: current,
                    translatesTitle: false,
                    icon: "play.fill",
                    tint: CoachTheme.primary,
                    isCurrent: true
                )
                sequenceArrow
                sequenceNode(
                    label: "NEXT",
                    title: next ?? "Level consolidation",
                    translatesTitle: true,
                    icon: next == nil ? "checkmark.seal.fill" : "lock.open.fill",
                    tint: next == nil ? CoachTheme.correct : CoachTheme.accent,
                    isCurrent: false
                )
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func sequenceNode(
        label: String,
        title: String,
        translatesTitle: Bool,
        icon: String,
        tint: Color,
        isCurrent: Bool
    ) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(isCurrent ? .white : tint)
                .frame(width: 30, height: 30)
                .background(isCurrent ? tint : tint.opacity(0.12), in: Circle())
            TeachingText(english: label)
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .foregroundStyle(tint)
            Group {
                if translatesTitle {
                    TeachingText(english: title)
                } else {
                    Text(title)
                }
            }
            .font(.caption2.weight(isCurrent ? .bold : .medium))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.72)
            .frame(maxWidth: .infinity, minHeight: 30, alignment: .top)
        }
        .frame(maxWidth: .infinity)
    }

    private var sequenceArrow: some View {
        Image(systemName: "chevron.right")
            .font(.caption2.weight(.bold))
            .foregroundStyle(.tertiary)
            .padding(.top, 10)
            .accessibilityHidden(true)
    }
}

private struct ListeningRoundSelector: View {
    let selected: LessonListeningRound
    let completed: Set<LessonListeningRound>
    let select: (LessonListeningRound) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 5) {
                ForEach(Array(LessonListeningRound.allCases.enumerated()), id: \.element.id) { index, round in
                    if index > 0 {
                        Capsule()
                            .fill(completed.contains(LessonListeningRound.allCases[index - 1]) ? CoachTheme.correct : CoachTheme.stroke)
                            .frame(maxWidth: .infinity)
                            .frame(height: 3)
                            .accessibilityHidden(true)
                    }
                    let isUnlocked = round == .meaning
                        || completed.contains(LessonListeningRound.allCases[index - 1])
                    Button { select(round) } label: {
                        VStack(spacing: 5) {
                            ZStack(alignment: .bottomTrailing) {
                                Circle()
                                    .fill(selected == round ? CoachTheme.listening.opacity(0.18) : CoachTheme.elevatedSurface)
                                    .overlay(
                                        Circle().stroke(
                                            selected == round ? CoachTheme.listening : CoachTheme.stroke,
                                            lineWidth: selected == round ? 2 : 1
                                        )
                                    )
                                Image(systemName: isUnlocked ? round.icon : "lock.fill")
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(isUnlocked ? CoachTheme.listening : Color.secondary)
                                if completed.contains(round) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 8, weight: .heavy))
                                        .foregroundStyle(.white)
                                        .frame(width: 17, height: 17)
                                        .background(CoachTheme.correct, in: Circle())
                                }
                            }
                            .frame(width: 44, height: 44)
                            TeachingText(english: round.title)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(isUnlocked ? Color.primary : Color.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(!isUnlocked)
                    .teachingAccessibilityLabel("Listening step \(index + 1), \(round.title)")
                    .teachingAccessibilityValue(completed.contains(round) ? "Complete" : isUnlocked ? "Available" : "Locked")
                }
            }
            TeachingText(english: selected.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

private struct LessonAccomplishmentProgress: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var displayedProgress = 0.0
    @State private var revealsRewards = false

    let level: CEFRLevel
    let completedLesson: Int
    let totalLessons: Int
    let xp: Int
    let wordCount: Int
    let practiceCount: Int

    private var targetProgress: Double {
        min(max(Double(completedLesson) / Double(max(totalLessons, 1)), 0), 1)
    }

    private var previousProgress: Double {
        min(max(Double(max(completedLesson - 1, 0)) / Double(max(totalLessons, 1)), 0), 1)
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .stroke(.primary.opacity(0.10), lineWidth: 11)
                    Circle()
                        .trim(from: 0, to: displayedProgress)
                        .stroke(CoachTheme.progressGradient(), style: StrokeStyle(lineWidth: 11, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 1) {
                        Text("\(Int(displayedProgress * 100))%")
                            .font(.system(.title2, design: .rounded, weight: .bold).monospacedDigit())
                        Text(level.rawValue)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(CoachTheme.primary)
                    }
                }
                .frame(width: 108, height: 108)
                .scaleEffect(revealsRewards || reduceMotion ? 1 : 0.88)

                VStack(alignment: .leading, spacing: 7) {
                    TeachingText(english: "\(level.rawValue) COURSE")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(CoachTheme.primary)
                    TeachingText(english: "Lesson \(completedLesson) of \(totalLessons)")
                        .font(.title3.weight(.bold))
                    LessonProgressBar(progress: targetProgress)
                    TeachingText(
                        english: completedLesson == totalLessons
                            ? "Level path complete"
                            : "\(totalLessons - completedLesson) lessons remain"
                    )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 8) {
                accomplishmentMetric(value: "+\(xp)", label: "XP", icon: "sparkles", tint: CoachTheme.accent)
                accomplishmentMetric(value: "\(wordCount)", label: "words", icon: "character.book.closed.fill", tint: CoachTheme.listening)
                accomplishmentMetric(value: "\(practiceCount)", label: "questions", icon: "checkmark.circle.fill", tint: CoachTheme.correct)
            }
            .opacity(revealsRewards || reduceMotion ? 1 : 0)
            .offset(y: revealsRewards || reduceMotion ? 0 : 8)
        }
        .onAppear {
            displayedProgress = reduceMotion ? targetProgress : previousProgress
            revealsRewards = reduceMotion
            guard !reduceMotion else { return }
            withAnimation(CoachMotion.standard.delay(0.06)) {
                displayedProgress = targetProgress
            }
            withAnimation(CoachMotion.celebration.delay(0.12)) {
                revealsRewards = true
            }
        }
    }

    private func accomplishmentMetric(
        value: String,
        label: String,
        icon: String,
        tint: Color
    ) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
            Text(value)
                .font(.headline.monospacedDigit())
            TeachingText(english: label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 72)
        .background(tint.opacity(0.08), in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(tint.opacity(0.14)))
        .accessibilityElement(children: .combine)
    }
}
