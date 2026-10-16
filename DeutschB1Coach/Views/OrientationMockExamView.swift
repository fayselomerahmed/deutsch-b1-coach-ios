import SwiftUI

struct OrientationMockExamEntryCard: View {
    @AppStorage(OrientationMockExamProgress.bestScoresStorageKey) private var bestScoresRaw = "{}"

    let state: GermanFederalState

    private var bestScore: Int? {
        OrientationMockExamProgress.bestScore(for: state, from: bestScoresRaw)
    }

    var body: some View {
        CoachCard(tint: CoachTheme.accent) {
            HStack(alignment: .top, spacing: 13) {
                CoachIconTile(icon: "timer", tint: CoachTheme.accent, size: 52)
                VStack(alignment: .leading, spacing: 7) {
                    Text("Zufälliger Prüfungstest")
                        .font(.title3.weight(.bold))
                        .fixedSize(horizontal: false, vertical: true)
                    Text("30 allgemeine + 3 Fragen für \(state.name)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 7) {
                            SkillChip(title: "33 Fragen", color: CoachTheme.accent, translatesTitle: false)
                            SkillChip(title: "60 Minuten", color: CoachTheme.reward, translatesTitle: false)
                        }
                        VStack(alignment: .leading, spacing: 7) {
                            SkillChip(title: "33 Fragen", color: CoachTheme.accent, translatesTitle: false)
                            SkillChip(title: "60 Minuten", color: CoachTheme.reward, translatesTitle: false)
                        }
                    }
                    if let bestScore {
                        Text("Bestwert: \(bestScore) von 33")
                            .font(.caption.weight(.semibold).monospacedDigit())
                            .foregroundStyle(CoachTheme.correct)
                    }
                }
                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(CoachTheme.accent)
                    .accessibilityHidden(true)
            }
        }
    }
}

struct OrientationMockExamView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage(OrientationMockExamProgress.bestScoresStorageKey) private var bestScoresRaw = "{}"

    let state: GermanFederalState
    private let startsImmediately: Bool

    @State private var phase = Phase.intro
    @State private var attempt: OrientationMockExamAttempt?
    @State private var answers: [String: Int] = [:]
    @State private var currentIndex = 0
    @State private var reviewIndex = 0
    @State private var remainingSeconds = OrientationMockExamFactory.durationSeconds
    @State private var deadline: Date?
    @State private var timerToken = UUID()
    @State private var showSubmitConfirmation = false
    @State private var generationFailed = false
    @State private var didAutoStart = false

    init(state: GermanFederalState, startsImmediately: Bool = false) {
        self.state = state
        self.startsImmediately = startsImmediately
    }

    var body: some View {
        Group {
            switch phase {
            case .intro:
                introView
            case .testing:
                examView
            case .result:
                resultView
            case .review:
                reviewView
            }
        }
        .navigationTitle(navigationTitle)
        .teachingLanguageSwitcher()
        .navigationBarTitleDisplayMode(.inline)
        .coachBackground()
        .onAppear {
            guard startsImmediately, !didAutoStart else { return }
            didAutoStart = true
            startNewAttempt()
        }
        .task(id: timerToken) {
            await runTimer()
        }
        .confirmationDialog(
            "Test jetzt abgeben?",
            isPresented: $showSubmitConfirmation,
            titleVisibility: .visible
        ) {
            Button("Test abgeben") { finishAttempt() }
            Button("Weiter bearbeiten", role: .cancel) {}
        } message: {
            Text(submitConfirmationMessage)
        }
        .alert("Test konnte nicht erstellt werden", isPresented: $generationFailed) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Der vollständige Fragenkatalog ist momentan nicht verfügbar.")
        }
    }

    private var introView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CoachCard(tint: CoachTheme.accent) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top, spacing: 13) {
                            CoachIconTile(icon: "checklist.checked", tint: CoachTheme.accent, size: 58)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Prüfungssimulation")
                                    .font(.title2.weight(.bold))
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("Leben in Deutschland")
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }

                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: 7) {
                                SkillChip(title: "30 allgemein", color: CoachTheme.listening, translatesTitle: false)
                                SkillChip(title: "3 × \(state.name)", color: CoachTheme.reward, translatesTitle: false)
                            }
                            VStack(alignment: .leading, spacing: 7) {
                                SkillChip(title: "30 allgemeine Fragen", color: CoachTheme.listening, translatesTitle: false)
                                SkillChip(title: "3 Fragen für \(state.name)", color: CoachTheme.reward, translatesTitle: false)
                            }
                        }

                        examFact(icon: "number.square.fill", text: "33 Fragen mit je vier Antwortmöglichkeiten")
                        examFact(icon: "timer", text: "60 Minuten Bearbeitungszeit")
                        examFact(icon: "eye.slash.fill", text: "Lösungen erscheinen erst nach der Abgabe")
                    }
                }

                CoachCard(tint: CoachTheme.correct) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Auswertung")
                            .font(.headline)
                        resultRule(
                            score: OrientationMockExamFactory.lifeInGermanyPassScore,
                            title: "Test Leben in Deutschland",
                            tint: CoachTheme.correct
                        )
                        resultRule(
                            score: OrientationMockExamFactory.citizenshipPassScore,
                            title: "Kenntnisnachweis für Einbürgerung",
                            tint: CoachTheme.reward
                        )
                        if let bestScore {
                            Divider()
                            Label("Dein Bestwert für \(state.name): \(bestScore) von 33", systemImage: "trophy.fill")
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(CoachTheme.correct)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                Button(action: startNewAttempt) {
                    Label("Zufallstest starten", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryCoachButton(tint: CoachTheme.accent))
            }
            .padding()
        }
    }

    private var examView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    examHeader

                    Color.clear
                        .frame(height: 0)
                        .id("mock-exam-question-start")

                    if let question = currentQuestion {
                        examQuestionCard(question)
                            .id(question.id)
                        questionNavigation
                    }
                }
                .padding()
            }
            .onChange(of: currentIndex) { _, _ in
                if reduceMotion {
                    proxy.scrollTo("mock-exam-question-start", anchor: .top)
                } else {
                    withAnimation(CoachMotion.navigation) {
                        proxy.scrollTo("mock-exam-question-start", anchor: .top)
                    }
                }
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 42)
                .onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    moveQuestion(by: value.translation.width < 0 ? 1 : -1)
                }
        )
    }

    private var examHeader: some View {
        CoachCard(tint: remainingSeconds <= 300 ? CoachTheme.incorrect : CoachTheme.accent) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Label(timeText, systemImage: "timer")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(remainingSeconds <= 300 ? CoachTheme.incorrect : CoachTheme.accent)
                        .accessibilityLabel("Verbleibende Zeit: \(accessibleTimeText)")
                    Spacer()
                    Text("\(answers.count)/33 beantwortet")
                        .font(.caption.weight(.semibold).monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                LessonProgressBar(progress: Double(answers.count) / 33)

                HStack(spacing: 10) {
                    Menu {
                        ForEach(Array(examQuestions.enumerated()), id: \.element.id) { index, question in
                            Button {
                                goToQuestion(index)
                            } label: {
                                Label(
                                    "Frage \(index + 1)",
                                    systemImage: answers[question.id] == nil ? "circle" : "checkmark.circle.fill"
                                )
                            }
                        }
                    } label: {
                        Label("Frage wählen", systemImage: "square.grid.3x3.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryCoachButton(tint: CoachTheme.accent))

                    Button {
                        showSubmitConfirmation = true
                    } label: {
                        Label("Abgeben", systemImage: "checkmark.seal.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryCoachButton(tint: CoachTheme.correct))
                }
            }
        }
    }

    private func examQuestionCard(_ question: OrientationQuestion) -> some View {
        let selectedAnswer = answers[question.id]
        let isStateQuestion = question.scope == .state

        return VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top, spacing: 10) {
                Text("\(currentIndex + 1)")
                    .font(.caption.weight(.heavy).monospacedDigit())
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background((isStateQuestion ? CoachTheme.reward : CoachTheme.accent), in: Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text(isStateQuestion ? "LANDESFRAGE" : "ALLGEMEINE FRAGE")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(isStateQuestion ? CoachTheme.reward : CoachTheme.accent)
                    Text(question.question)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if let imageName = question.imageName {
                OrientationQuestionImage(
                    name: imageName,
                    accessibilityLabel: "Abbildung zu: \(question.question)"
                )
                if question.usesNumberedImages {
                    Text("Bild 1 bis Bild 4 sind von links nach rechts angeordnet.")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            ForEach(Array(question.choices.enumerated()), id: \.offset) { index, choice in
                Button {
                    choose(index, for: question)
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: selectedAnswer == index ? "largecircle.fill.circle" : "circle")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(selectedAnswer == index ? CoachTheme.accent : Color.secondary)
                            .frame(width: 22, height: 22)
                            .accessibilityHidden(true)
                        Text(choice)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 4)
                    }
                }
                .buttonStyle(
                    SecondaryCoachButton(
                        tint: selectedAnswer == index ? CoachTheme.accent : CoachTheme.primary
                    )
                )
                .accessibilityLabel("Antwort \(index + 1) von 4: \(choice)")
                .accessibilityValue(selectedAnswer == index ? "Ausgewählt" : "Nicht ausgewählt")
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CoachTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
        .overlay(
            RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
                .stroke((isStateQuestion ? CoachTheme.reward : CoachTheme.accent).opacity(0.22))
        )
    }

    private var questionNavigation: some View {
        VStack(spacing: 9) {
            Text("Frage \(currentIndex + 1) von 33")
                .font(.caption.weight(.semibold).monospacedDigit())
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Button {
                    moveQuestion(by: -1)
                } label: {
                    Label("Zurück", systemImage: "chevron.left")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryCoachButton(tint: CoachTheme.accent))
                .disabled(currentIndex == 0)

                if currentIndex == examQuestions.count - 1 {
                    Button {
                        showSubmitConfirmation = true
                    } label: {
                        Label("Abgeben", systemImage: "checkmark.seal.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryCoachButton(tint: CoachTheme.correct))
                } else {
                    Button {
                        moveQuestion(by: 1)
                    } label: {
                        HStack(spacing: 7) {
                            Text("Weiter")
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryCoachButton(tint: CoachTheme.accent))
                }
            }
        }
    }

    private var resultView: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let result = result {
                    CoachMascot(
                        mood: result.reachedCitizenshipThreshold ? .achievement : .supportive,
                        size: 92
                    )

                    Text(resultTitle(result))
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.center)

                    scoreRing(result.correctCount)

                    CoachCard(tint: result.passedLifeInGermany ? CoachTheme.correct : CoachTheme.accent) {
                        VStack(alignment: .leading, spacing: 11) {
                            resultStatus(
                                title: "Test Leben in Deutschland",
                                detail: "Mindestens 15 richtige Antworten",
                                reached: result.passedLifeInGermany
                            )
                            Divider()
                            resultStatus(
                                title: "Kenntnisnachweis Einbürgerung",
                                detail: "Mindestens 17 richtige Antworten",
                                reached: result.reachedCitizenshipThreshold
                            )
                            Divider()
                            Label(
                                "Landesfragen: \(result.stateCorrectCount) von 3 richtig",
                                systemImage: "map.fill"
                            )
                            .font(.callout.weight(.semibold))
                            if result.unansweredCount > 0 {
                                Label(
                                    "\(result.unansweredCount) nicht beantwortet",
                                    systemImage: "questionmark.circle.fill"
                                )
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(CoachTheme.reward)
                            }
                            Label("Bestwert für \(state.name): \(bestScore ?? result.correctCount) von 33", systemImage: "trophy.fill")
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(CoachTheme.correct)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    if !missedQuestions.isEmpty {
                        Button {
                            reviewIndex = 0
                            transition(to: .review)
                        } label: {
                            Label("Fehler und Lücken prüfen", systemImage: "magnifyingglass")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryCoachButton(tint: CoachTheme.reward))
                    }

                    Button(action: startNewAttempt) {
                        Label("Neuen Zufallstest starten", systemImage: "shuffle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryCoachButton(tint: CoachTheme.accent))

                    Button {
                        dismiss()
                    } label: {
                        Label("Zurück zu den 310 Fragen", systemImage: "books.vertical.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryCoachButton(tint: CoachTheme.primary))
                }
            }
            .padding()
        }
    }

    private var reviewView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Fehler und Lücken")
                                .font(.title2.weight(.bold))
                            Text("\(missedQuestions.count) Fragen aus diesem Test")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button {
                            transition(to: .result)
                        } label: {
                            Image(systemName: "xmark")
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Fehlerprüfung schließen")
                    }

                    Color.clear
                        .frame(height: 0)
                        .id("mock-review-question-start")

                    if let question = currentReviewQuestion {
                        reviewQuestionCard(question)
                        reviewNavigation
                    }
                }
                .padding()
            }
            .onChange(of: reviewIndex) { _, _ in
                if reduceMotion {
                    proxy.scrollTo("mock-review-question-start", anchor: .top)
                } else {
                    withAnimation(CoachMotion.navigation) {
                        proxy.scrollTo("mock-review-question-start", anchor: .top)
                    }
                }
            }
        }
    }

    private func reviewQuestionCard(_ question: OrientationQuestion) -> some View {
        let selectedAnswer = answers[question.id]

        return VStack(alignment: .leading, spacing: 13) {
            Text(question.question)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)

            if let imageName = question.imageName {
                OrientationQuestionImage(
                    name: imageName,
                    accessibilityLabel: "Abbildung zu: \(question.question)"
                )
            }

            ForEach(Array(question.choices.enumerated()), id: \.offset) { index, choice in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: selectedAnswer == index ? "largecircle.fill.circle" : "circle")
                        .foregroundStyle(reviewChoiceTint(index, question: question))
                        .frame(width: 22, height: 22)
                    Text(choice)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 4)
                    if index == question.answerIndex {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(CoachTheme.correct)
                    } else if selectedAnswer == index {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(CoachTheme.incorrect)
                    }
                }
                .padding(13)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    reviewChoiceTint(index, question: question).opacity(0.08),
                    in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
                        .stroke(reviewChoiceTint(index, question: question).opacity(0.24))
                )
            }

            CoachFeedbackPanel(
                isCorrect: false,
                title: selectedAnswer == nil ? "Nicht beantwortet" : "Noch nicht richtig",
                message: "Richtige Antwort: \(question.answer)"
            )
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CoachTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
    }

    private var reviewNavigation: some View {
        VStack(spacing: 9) {
            Text("Fehler \(reviewIndex + 1) von \(missedQuestions.count)")
                .font(.caption.weight(.semibold).monospacedDigit())
                .foregroundStyle(.secondary)
            HStack(spacing: 10) {
                Button {
                    moveReview(by: -1)
                } label: {
                    Label("Zurück", systemImage: "chevron.left")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryCoachButton(tint: CoachTheme.reward))
                .disabled(reviewIndex == 0)

                Button {
                    if reviewIndex == missedQuestions.count - 1 {
                        transition(to: .result)
                    } else {
                        moveReview(by: 1)
                    }
                } label: {
                    Label(
                        reviewIndex == missedQuestions.count - 1 ? "Fertig" : "Weiter",
                        systemImage: reviewIndex == missedQuestions.count - 1 ? "checkmark" : "chevron.right"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryCoachButton(tint: CoachTheme.reward))
            }
        }
    }

    private var navigationTitle: String {
        switch phase {
        case .intro: "Zufallstest"
        case .testing: "Prüfungstest"
        case .result: "Ergebnis"
        case .review: "Fehler prüfen"
        }
    }

    private var examQuestions: [OrientationQuestion] {
        attempt?.questions ?? []
    }

    private var currentQuestion: OrientationQuestion? {
        guard examQuestions.indices.contains(currentIndex) else { return nil }
        return examQuestions[currentIndex]
    }

    private var result: OrientationMockExamResult? {
        guard let attempt else { return nil }
        return OrientationMockExamFactory.result(for: attempt, answers: answers)
    }

    private var missedQuestions: [OrientationQuestion] {
        examQuestions.filter { answers[$0.id] != $0.answerIndex }
    }

    private var currentReviewQuestion: OrientationQuestion? {
        guard missedQuestions.indices.contains(reviewIndex) else { return nil }
        return missedQuestions[reviewIndex]
    }

    private var bestScore: Int? {
        OrientationMockExamProgress.bestScore(for: state, from: bestScoresRaw)
    }

    private var timeText: String {
        String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
    }

    private var accessibleTimeText: String {
        "\(remainingSeconds / 60) Minuten und \(remainingSeconds % 60) Sekunden"
    }

    private var submitConfirmationMessage: String {
        let unanswered = OrientationMockExamFactory.totalQuestionCount - answers.count
        if unanswered == 0 {
            return "Alle 33 Fragen sind beantwortet. Danach wird dein Ergebnis angezeigt."
        }
        return "Noch \(unanswered) Fragen sind nicht beantwortet. Du kannst zurückgehen oder den Test trotzdem abgeben."
    }

    private func examFact(icon: String, text: String) -> some View {
        Label(text, systemImage: icon)
            .font(.callout.weight(.semibold))
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func resultRule(score: Int, title: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(score)")
                .font(.caption.weight(.heavy).monospacedDigit())
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(tint, in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                Text("von 33 Fragen richtig")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func resultStatus(title: String, detail: String, reached: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: reached ? "checkmark.seal.fill" : "circle.dashed")
                .foregroundStyle(reached ? CoachTheme.correct : CoachTheme.reward)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout.weight(.bold))
                    .fixedSize(horizontal: false, vertical: true)
                Text(reached ? "Ziel erreicht" : detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func scoreRing(_ score: Int) -> some View {
        ZStack {
            Circle()
                .stroke(CoachTheme.accent.opacity(0.12), lineWidth: 12)
            Circle()
                .trim(from: 0, to: Double(score) / 33)
                .stroke(
                    score >= OrientationMockExamFactory.citizenshipPassScore
                        ? CoachTheme.correct
                        : CoachTheme.reward,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 1) {
                Text("\(score)")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .contentTransition(.numericText())
                Text("von 33")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 142, height: 142)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(score) von 33 Fragen richtig")
    }

    private func resultTitle(_ result: OrientationMockExamResult) -> String {
        if result.reachedCitizenshipThreshold { return "Beide Ziele erreicht" }
        if result.passedLifeInGermany { return "LiD-Ziel erreicht" }
        return "Dein nächster Schritt ist klar"
    }

    private func reviewChoiceTint(_ index: Int, question: OrientationQuestion) -> Color {
        if index == question.answerIndex { return CoachTheme.correct }
        if answers[question.id] == index { return CoachTheme.incorrect }
        return CoachTheme.primary
    }

    private func startNewAttempt() {
        guard let newAttempt = OrientationMockExamFactory.make(for: state) else {
            generationFailed = true
            return
        }
        attempt = newAttempt
        answers = [:]
        currentIndex = 0
        reviewIndex = 0
        remainingSeconds = OrientationMockExamFactory.durationSeconds
        deadline = Date().addingTimeInterval(TimeInterval(OrientationMockExamFactory.durationSeconds))
        transition(to: .testing)
        timerToken = UUID()
        CoachFeedback.selection()
    }

    private func choose(_ index: Int, for question: OrientationQuestion) {
        guard question.choices.indices.contains(index) else { return }
        withAnimation(reduceMotion ? nil : CoachMotion.quick) {
            answers[question.id] = index
        }
        CoachFeedback.selection()
    }

    private func moveQuestion(by offset: Int) {
        goToQuestion(currentIndex + offset)
    }

    private func goToQuestion(_ index: Int) {
        guard examQuestions.indices.contains(index) else { return }
        if reduceMotion {
            currentIndex = index
        } else {
            withAnimation(CoachMotion.navigation) {
                currentIndex = index
            }
        }
        CoachFeedback.selection()
    }

    private func moveReview(by offset: Int) {
        let destination = reviewIndex + offset
        guard missedQuestions.indices.contains(destination) else { return }
        if reduceMotion {
            reviewIndex = destination
        } else {
            withAnimation(CoachMotion.navigation) {
                reviewIndex = destination
            }
        }
        CoachFeedback.selection()
    }

    private func finishAttempt() {
        guard let result else { return }
        deadline = nil
        timerToken = UUID()
        bestScoresRaw = OrientationMockExamProgress.recording(
            score: result.correctCount,
            for: state,
            in: bestScoresRaw
        )
        transition(to: .result)
        result.reachedCitizenshipThreshold ? CoachFeedback.success() : CoachFeedback.warning()
    }

    private func transition(to newPhase: Phase) {
        if reduceMotion {
            phase = newPhase
        } else {
            withAnimation(CoachMotion.standard) {
                phase = newPhase
            }
        }
    }

    private func runTimer() async {
        guard phase == .testing, let deadline else { return }
        while !Task.isCancelled && phase == .testing {
            let seconds = max(0, Int(deadline.timeIntervalSinceNow.rounded(.up)))
            remainingSeconds = seconds
            if seconds == 0 {
                finishAttempt()
                return
            }
            try? await Task.sleep(for: .seconds(1))
        }
    }
}

private extension OrientationMockExamView {
    enum Phase {
        case intro
        case testing
        case result
        case review
    }
}
