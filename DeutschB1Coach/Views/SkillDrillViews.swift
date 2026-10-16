import SwiftData
import SwiftUI

struct ListeningDrillView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var dialogues: [ListeningCoachDialogue] = []
    @State private var level: CEFRLevel
    @State private var index = 0
    @State private var questionIndex = 0
    @State private var answer = ""
    @State private var showsAnswer = false
    @State private var showsTranscript = false
    @State private var evaluation: FreeResponseEvaluation?
    @State private var correctAnswers = 0
    @State private var premium = PremiumAccessService.shared
    @State private var showsPremium = false

    init(level: CEFRLevel = .a1) {
        _level = State(initialValue: level)
    }

    private var levelDialogues: [ListeningCoachDialogue] {
        dialogues.filter { $0.level == level }
    }

    private var dialogue: ListeningCoachDialogue? {
        levelDialogues.indices.contains(index) ? levelDialogues[index] : levelDialogues.first
    }

    private var question: ListeningCoachQuestion? {
        guard let dialogue else { return nil }
        return dialogue.questions.indices.contains(questionIndex)
            ? dialogue.questions[questionIndex]
            : dialogue.questions.first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker(selection: $level) {
                    ForEach(CEFRLevel.allCases) { Text($0.rawValue).tag($0) }
                } label: {
                    TeachingText(english: "Level")
                }
                .pickerStyle(.segmented)

                if let dialogue {
                    dialogueHeader(dialogue)
                    listenStep(dialogue)
                    transcriptStep(dialogue)
                    if let question {
                        answerStep(question, dialogue: dialogue)
                    }
                } else {
                    CoachCard {
                        CoachEmptyState(
                            icon: "headphones",
                            title: "Listening content unavailable",
                            message: "Choose another level while this audio lesson becomes available."
                        )
                    }
                }
            }
            .padding()
        }
        .teachingNavigationTitle("Listening")
        .coachBackground()
        .sheet(isPresented: $showsPremium) { PremiumView() }
        .task {
            if !PremiumAccessPolicy.canOpenLevel(level, isPremium: premium.isPremium) {
                level = .a1
            }
            let lessons = (try? ContentLoader.shared.loadLessons()) ?? []
            let missions = (try? ContentLoader.shared.loadPracticalMissions()) ?? []
            dialogues = ListeningCoachDialogue.curriculum(lessons: lessons, missions: missions)
            restoreProgress()
        }
        .onChange(of: level) { _, newLevel in
            guard PremiumAccessPolicy.canOpenLevel(newLevel, isPremium: premium.isPremium) else {
                level = .a1
                showsPremium = true
                return
            }
            restoreProgress()
        }
    }

    private func dialogueHeader(_ dialogue: ListeningCoachDialogue) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                SkillChip(title: dialogue.level.rawValue, color: CoachTheme.listening, translatesTitle: false)
                Text("\(index + 1)/\(levelDialogues.count)")
                    .font(.caption.monospacedDigit().weight(.bold))
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }
            TeachingText(english: dialogue.title)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .fixedSize(horizontal: false, vertical: true)
            TeachingText(english: dialogue.scenario)
                .font(.callout.weight(.semibold))
                .foregroundStyle(CoachTheme.listening)
            LessonProgressBar(
                progress: levelDialogues.isEmpty ? 0 : Double(index + 1) / Double(levelDialogues.count)
            )
        }
    }

    private func listenStep(_ dialogue: ListeningCoachDialogue) -> some View {
        CoachCard(tint: CoachTheme.listening) {
            HStack(alignment: .center, spacing: 13) {
                GermanSpeechButton(
                    text: dialogue.script,
                    style: .listening,
                    label: "Play German audio"
                )
                VStack(alignment: .leading, spacing: 4) {
                    TeachingText(english: "Listen without reading first. Replay once, then answer the comprehension question.")
                        .font(.headline)
                    TeachingText(english: "Play the audio once. Notice who is speaking, the main action, and the overall meaning. Missing a few words is normal.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func transcriptStep(_ dialogue: ListeningCoachDialogue) -> some View {
        CoachCard(tint: CoachTheme.reading) {
            DisclosureGroup(isExpanded: $showsTranscript) {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(dialogue.lines) { line in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .top, spacing: 8) {
                                SkillChip(title: line.role, color: line.isLearner ? CoachTheme.speaking : CoachTheme.listening)
                                Text(line.german)
                                    .font(.body.weight(.semibold))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                GermanSpeechButton(text: line.german, style: line.isLearner ? .model : .listening)
                            }
                            if let translation = line.translation, !translation.isEmpty {
                                TeachingText(english: translation, protectedGerman: [line.german])
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .padding(.leading, 4)
                            }
                        }
                        if line.id != dialogue.lines.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(.top, 12)
            } label: {
                VStack(alignment: .leading, spacing: 3) {
                    TeachingText(english: "Listen, compare the translation, and mark the pattern you noticed.")
                        .font(.headline)
                }
            }
            .tint(CoachTheme.reading)
        }
    }

    private func answerStep(
        _ question: ListeningCoachQuestion,
        dialogue: ListeningCoachDialogue
    ) -> some View {
        CoachCard(tint: CoachTheme.speaking) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        TeachingText(english: "Answer first, then study the explanation")
                            .font(.headline)
                        Text("\(questionIndex + 1)/\(dialogue.questions.count)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if let cue = question.germanCue {
                        GermanSpeechButton(text: cue, style: .listening, label: "Replay the speaker")
                    }
                }

                TeachingText(english: question.instruction, protectedGerman: question.protectedGerman)
                    .font(.title3.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)

                if let cue = question.germanCue {
                    Text(cue)
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(CoachTheme.listening.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                }

                TeachingTextField(prompt: question.answerPrompt, text: $answer, axis: .vertical)
                    .textFieldStyle(CoachTextFieldStyle(tint: CoachTheme.listening))
                    .germanKeyboardAccessory(text: $answer)

                if showsAnswer {
                    CoachFeedbackPanel(
                        isCorrect: evaluation?.isCorrect == true,
                        title: evaluation?.isCorrect == true ? "Correct" : "Hear the correct answer",
                        message: question.explanation,
                        protectedGerman: question.protectedGerman
                    )

                    if !question.usefulPhrases.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            TeachingText(english: "Add this phrase to your answer")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(CoachTheme.primary)
                            Text(question.usefulPhrases.joined(separator: ", "))
                                .font(.body.weight(.semibold))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    HStack(alignment: .center, spacing: 10) {
                        Text(question.answer)
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                        GermanSpeechButton(
                            text: question.answer,
                            style: .model,
                            label: "Play correct answer"
                        )
                    }
                    .padding(12)
                    .background(CoachTheme.correct.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

                    TeachingText(english: "Say the complete answer once before continuing.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TeachingButton(nextButtonTitle(for: dialogue)) {
                        advance(from: dialogue)
                    }
                    .buttonStyle(PrimaryCoachButton(tint: CoachTheme.listening))
                } else {
                    TeachingButton("Check answer") {
                        check(question)
                    }
                    .buttonStyle(PrimaryCoachButton(tint: CoachTheme.listening))
                    .disabled(answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func check(_ question: ListeningCoachQuestion) {
        evaluation = FreeResponseEvaluator().evaluate(answer, expected: question.answer)
        showsAnswer = true
        if evaluation?.isCorrect == true {
            correctAnswers += 1
            CoachFeedback.success()
        } else {
            CoachFeedback.warning()
        }
    }

    private func nextButtonTitle(for dialogue: ListeningCoachDialogue) -> String {
        questionIndex + 1 < dialogue.questions.count ? "Next question" : "Next listening"
    }

    private func advance(from dialogue: ListeningCoachDialogue) {
        if questionIndex + 1 < dialogue.questions.count {
            questionIndex += 1
            answer = ""
            showsAnswer = false
            evaluation = nil
            return
        }

        let score = dialogue.questions.isEmpty
            ? 0
            : Double(correctAnswers) / Double(dialogue.questions.count)
        try? ProgressService().recordPractice(
            level: level,
            skill: .listening,
            score: score,
            xp: 8,
            sourceId: "listening-\(dialogue.id)",
            modelContext: modelContext
        )
        index = levelDialogues.isEmpty ? 0 : (index + 1) % levelDialogues.count
        UserDefaults.standard.set(index, forKey: progressKey)
        resetQuestion()
        showsTranscript = false
        GermanSpeechService.shared.stop()
    }

    private var progressKey: String {
        "listeningCoach.index.\(level.rawValue)"
    }

    private func restoreProgress() {
        let savedIndex = UserDefaults.standard.integer(forKey: progressKey)
        index = levelDialogues.indices.contains(savedIndex) ? savedIndex : 0
        resetQuestion()
        showsTranscript = false
        GermanSpeechService.shared.stop()
    }

    private func resetQuestion() {
        questionIndex = 0
        answer = ""
        showsAnswer = false
        evaluation = nil
        correctAnswers = 0
    }
}

struct ListeningCoachDialogue: Identifiable {
    let id: String
    let level: CEFRLevel
    let order: Int
    let title: String
    let scenario: String
    let lines: [ListeningCoachLine]
    let questions: [ListeningCoachQuestion]

    var script: String {
        lines.map(\.german).joined(separator: "\n")
    }

    static func curriculum(
        lessons: [CompleteLessonDTO],
        missions: [PracticalMissionDTO]
    ) -> [ListeningCoachDialogue] {
        let foundation = lessons.map { lesson in
            ListeningCoachDialogue(
                id: "foundation-\(lesson.id)",
                level: lesson.level,
                order: lesson.order,
                title: lesson.title,
                scenario: lesson.scenario,
                lines: [
                    ListeningCoachLine(
                        id: "\(lesson.id)-script",
                        role: "Dialogue",
                        german: lesson.listening.script,
                        translation: nil,
                        isLearner: false
                    )
                ],
                questions: lesson.listening.questions.enumerated().map { offset, question in
                    ListeningCoachQuestion(
                        id: "\(lesson.id)-question-\(offset)",
                        instruction: question.prompt,
                        germanCue: nil,
                        answer: question.answer,
                        explanation: question.explanation,
                        answerPrompt: "Your answer",
                        protectedGerman: [],
                        usefulPhrases: []
                    )
                }
            )
        }

        let realLife = missions.map { mission in
            let lines = mission.turns.enumerated().flatMap { offset, turn in
                [
                    ListeningCoachLine(
                        id: "\(mission.id)-\(offset)-partner",
                        role: mission.partnerRole,
                        german: turn.partnerCue,
                        translation: turn.cueTranslation,
                        isLearner: false
                    ),
                    ListeningCoachLine(
                        id: "\(mission.id)-\(offset)-learner",
                        role: "You",
                        german: turn.modelResponse,
                        translation: turn.responseTranslation,
                        isLearner: true
                    )
                ]
            }
            let questions = mission.turns.enumerated().map { offset, turn in
                return ListeningCoachQuestion(
                    id: "\(mission.id)-response-\(offset)",
                    instruction: "Answer the prompt",
                    germanCue: turn.partnerCue,
                    answer: turn.modelResponse,
                    explanation: turn.responseTranslation,
                    answerPrompt: "Your answer",
                    protectedGerman: [turn.partnerCue, turn.modelResponse] + turn.requiredPhrases,
                    usefulPhrases: turn.requiredPhrases
                )
            }

            return ListeningCoachDialogue(
                id: "mission-\(mission.id)",
                level: mission.level,
                order: 100 + mission.order,
                title: mission.title,
                scenario: mission.setting,
                lines: lines,
                questions: questions
            )
        }

        return (foundation + realLife).sorted {
            if $0.level.rawValue != $1.level.rawValue {
                return $0.level.rawValue < $1.level.rawValue
            }
            return $0.order < $1.order
        }
    }
}

struct ListeningCoachLine: Identifiable {
    let id: String
    let role: String
    let german: String
    let translation: String?
    let isLearner: Bool
}

struct ListeningCoachQuestion: Identifiable {
    let id: String
    let instruction: String
    let germanCue: String?
    let answer: String
    let explanation: String
    let answerPrompt: String
    let protectedGerman: [String]
    let usefulPhrases: [String]
}

struct ReadingDrillView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var level: CEFRLevel
    @State private var index = 0
    @State private var selected = ""
    @State private var showsFeedback = false
    @State private var premium = PremiumAccessService.shared
    @State private var showsPremium = false

    init(level: CEFRLevel = .a1) {
        _level = State(initialValue: level)
    }

    private var tasks: [ReadingTask] { ReadingTask.catalog.filter { $0.level == level } }
    private var task: ReadingTask? { tasks.indices.contains(index) ? tasks[index] : tasks.first }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker(selection: $level) {
                    ForEach(CEFRLevel.allCases) { Text($0.rawValue).tag($0) }
                } label: {
                    TeachingText(english: "Level")
                }
                .pickerStyle(.segmented)

                if let task {
                    Text(task.title)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text(task.text)
                        .font(.title3)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(CoachTheme.surface, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
                    Text(task.question).font(.title3.weight(.semibold))
                    ForEach(task.choices, id: \.self) { choice in
                        readingChoiceButton(choice)
                    }
                    if showsFeedback {
                        CoachFeedbackPanel(
                            isCorrect: selected == task.answer,
                            title: selected == task.answer ? "Correct" : "Answer: \(task.answer)",
                            message: task.explanation
                        )
                        TeachingButton("Next text") { complete(task) }.buttonStyle(PrimaryCoachButton())
                    } else {
                        TeachingButton("Check answer") { showsFeedback = true }.buttonStyle(PrimaryCoachButton()).disabled(selected.isEmpty)
                    }
                }
            }
            .padding()
        }
        .teachingNavigationTitle("Reading Lab")
        .coachBackground()
        .sheet(isPresented: $showsPremium) { PremiumView() }
        .onAppear {
            if !PremiumAccessPolicy.canOpenLevel(level, isPremium: premium.isPremium) {
                level = .a1
            }
        }
        .onChange(of: level) { _, newLevel in
            guard PremiumAccessPolicy.canOpenLevel(newLevel, isPremium: premium.isPremium) else {
                level = .a1
                showsPremium = true
                return
            }
            reset()
        }
    }

    private func readingChoiceButton(_ choice: String) -> some View {
        let isSelected = selected == choice
        let borderColor = isSelected ? CoachTheme.primary : CoachTheme.stroke
        let borderWidth: CGFloat = isSelected ? 2 : 1

        return Button {
            selected = choice
        } label: {
            HStack {
                Text(choice)
                    .font(.body.weight(.medium))
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(CoachTheme.primary)
                }
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 48)
            .frame(maxWidth: .infinity)
            .background(isSelected ? CoachTheme.softMint : CoachTheme.surface, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
            .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(borderColor, lineWidth: borderWidth))
        }
        .buttonStyle(.plain)
        .disabled(showsFeedback)
    }

    private func complete(_ task: ReadingTask) {
        try? ProgressService().recordPractice(
            level: level,
            skill: .reading,
            score: selected == task.answer ? 1 : 0,
            xp: selected == task.answer ? 8 : 3,
            sourceId: task.id,
            modelContext: modelContext
        )
        index = tasks.isEmpty ? 0 : (index + 1) % tasks.count
        selected = ""
        showsFeedback = false
    }

    private func reset() {
        index = 0
        selected = ""
        showsFeedback = false
    }
}

private struct ReadingTask: Identifiable {
    let id: String
    let level: CEFRLevel
    let title: String
    let text: String
    let question: String
    let choices: [String]
    let answer: String
    let explanation: String

    static let catalog: [ReadingTask] = [
        .init(id: "read-a1-1", level: .a1, title: "Öffnungszeiten", text: "Die Bäckerei ist von Montag bis Samstag von 7 bis 18 Uhr geöffnet. Am Sonntag ist sie geschlossen.", question: "Wann ist die Bäckerei geschlossen?", choices: ["Am Montag", "Am Samstag", "Am Sonntag"], answer: "Am Sonntag", explanation: "The final sentence states that it is closed on Sunday."),
        .init(id: "read-a1-2", level: .a1, title: "Eine Nachricht", text: "Hallo Mia, ich komme heute um 18 Uhr. Wir treffen uns vor dem Kino. Bis später! Tom", question: "Wo treffen sich Mia und Tom?", choices: ["Im Café", "Vor dem Kino", "Am Bahnhof"], answer: "Vor dem Kino", explanation: "Wir treffen uns vor dem Kino gives the location."),
        .init(id: "read-a1-3", level: .a1, title: "Wohnung", text: "Die Wohnung hat zwei Zimmer, eine Küche und einen Balkon. Sie kostet 780 Euro im Monat.", question: "Wie viele Zimmer hat die Wohnung?", choices: ["Zwei", "Drei", "Vier"], answer: "Zwei", explanation: "The listing says zwei Zimmer."),
        .init(id: "read-a2-1", level: .a2, title: "Kursänderung", text: "Wegen der Krankheit der Lehrerin beginnt der Deutschkurs diese Woche erst am Donnerstag. Der Unterricht findet wie immer in Raum 12 statt.", question: "Warum beginnt der Kurs später?", choices: ["Der Raum ist besetzt.", "Die Lehrerin ist krank.", "Es sind Ferien."], answer: "Die Lehrerin ist krank.", explanation: "Wegen der Krankheit der Lehrerin gives the reason."),
        .init(id: "read-a2-2", level: .a2, title: "Fahrrad zu verkaufen", text: "Verkaufe mein drei Jahre altes Cityrad. Es funktioniert gut, braucht aber ein neues Licht. Preis: 120 Euro.", question: "Was muss repariert werden?", choices: ["Das Licht", "Die Bremsen", "Der Sitz"], answer: "Das Licht", explanation: "The bicycle needs a new light."),
        .init(id: "read-a2-3", level: .a2, title: "Einladung", text: "Ich feiere am Samstag meinen Geburtstag. Wenn das Wetter schön ist, grillen wir im Garten. Bitte bring eine Jacke mit, weil es abends kühl wird.", question: "Was soll der Gast mitbringen?", choices: ["Einen Salat", "Eine Jacke", "Ein Geschenk"], answer: "Eine Jacke", explanation: "Bitte bring eine Jacke mit is the request."),
        .init(id: "read-b1-1", level: .b1, title: "Flexible Arbeitszeit", text: "Unsere Firma führt ab August flexible Arbeitszeiten ein. Beschäftigte können zwischen 7 und 10 Uhr anfangen, müssen aber während der Kernzeit von 10 bis 15 Uhr erreichbar sein.", question: "Was ist während der Kernzeit erforderlich?", choices: ["Alle müssen im Büro sein.", "Beschäftigte müssen erreichbar sein.", "Niemand darf Pause machen."], answer: "Beschäftigte müssen erreichbar sein.", explanation: "The text requires availability, not necessarily office attendance."),
        .init(id: "read-b1-2", level: .b1, title: "Stadtbibliothek", text: "Die Bibliothek erweitert ihr digitales Angebot. Mitglieder können nun nicht nur E-Books, sondern auch Sprachkurse kostenlos nutzen. Für die Anmeldung ist ein gültiger Bibliotheksausweis nötig.", question: "Welche Voraussetzung gibt es?", choices: ["Man muss einen Kurs bezahlen.", "Man braucht einen gültigen Ausweis.", "Man muss in der Bibliothek lernen."], answer: "Man braucht einen gültigen Ausweis.", explanation: "A valid library card is required for registration."),
        .init(id: "read-b1-3", level: .b1, title: "Nachbarschaftsprojekt", text: "Im Innenhof soll ein gemeinsamer Garten entstehen. Einige Nachbarn sorgen sich wegen möglicher Kosten, während andere vor allem einen Treffpunkt für Familien wünschen. Eine Versammlung soll offene Fragen klären.", question: "Warum findet eine Versammlung statt?", choices: ["Um Pflanzen zu verkaufen", "Um offene Fragen zu klären", "Um den Garten zu schließen"], answer: "Um offene Fragen zu klären", explanation: "The final sentence states the purpose directly.")
    ]
}
