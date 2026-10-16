import SwiftData
import SwiftUI

struct ExamPrepView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Query(sort: \LearningActivity.createdAt, order: .reverse) private var activities: [LearningActivity]
    @AppStorage(ExamTargetDate.storageKey) private var examTargetDateInterval = 0.0
    @State private var exam: MockExam?
    @State private var errorMessage: String?
    @State private var showsTargetDate = false
    @State private var showsStrategies = false

    private var readiness: ExamReadinessSnapshot {
        ExamReadinessSnapshot(activities: activities)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                readinessCard

                if let errorMessage {
                    Label {
                        TeachingText(english: errorMessage)
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                        .foregroundStyle(CoachTheme.incorrect)
                        .padding(16)
                        .background(CoachTheme.surface, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
                }

                CoachSectionHeader(
                    title: "Exam sections",
                    subtitle: "Your latest score determines the next recommended focus"
                )

                ForEach(exam?.sections ?? []) { section in
                    sectionLink(section)
                }

                CoachCard(tint: CoachTheme.reward) {
                    DisclosureGroup(isExpanded: $showsStrategies) {
                        VStack(alignment: .leading, spacing: 12) {
                            strategy("Hören", "Read the question first, identify key words, and do not stop at an unfamiliar word.")
                            strategy("Lesen", "Scan for names, dates, conditions, and contrast words before reading closely.")
                            strategy("Schreiben", "Plan four points, use connectors, then reserve time for verb position and capitalization.")
                            strategy("Sprechen", "Answer directly, give a reason and example, and keep the interaction moving.")
                        }
                        .padding(.top, 12)
                    } label: {
                        TeachingLabel(english: "Exam strategy", systemImage: "lightbulb.max.fill")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundStyle(.primary)
                    }
                    .tint(CoachTheme.reward)
                }

                TeachingLabel(
                    english: "This is original practice material. Confirm the format, scoring, and registration rules with your chosen exam provider.",
                    systemImage: "info.circle"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            }
            .padding()
            .padding(.top, -4)
        }
        .teachingNavigationTitle("Exam Coach")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showsTargetDate = true } label: {
                    Image(systemName: examTargetDate == nil ? "calendar.badge.plus" : "calendar")
                }
                .teachingAccessibilityLabel(examTargetDate == nil ? "Set exam date" : "Change exam date")
            }
        }
        .coachBackground()
        .task { loadExam() }
        .sheet(isPresented: $showsTargetDate) {
            ExamTargetDateSheet(targetDateInterval: $examTargetDateInterval)
        }
    }

    private var readinessCard: some View {
        CoachCard(tint: readinessTint) {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    if dynamicTypeSize.isAccessibilitySize || horizontalSizeClass == .compact {
                        HStack(alignment: .top, spacing: 13) {
                            readinessRing
                            readinessSummary
                        }
                    } else {
                        HStack(spacing: 16) {
                            readinessRing
                            readinessSummary
                            Spacer(minLength: 0)
                            CoachMascot(mood: readiness.isPracticeReady ? .achievement : .supportive, size: 60, animates: false)
                        }
                    }
                }

                ProgressView(value: readiness.progress)
                    .tint(readinessTint)
                    .teachingAccessibilityLabel("Overall B1 practice readiness")
                    .teachingAccessibilityValue("\(Int(readiness.progress * 100)) percent")

                readinessMetrics

                if let nextExamSection {
                    NavigationLink {
                        ExamSectionSessionView(section: nextExamSection)
                    } label: {
                        TeachingLabel(english: nextActionTitle, systemImage: readiness.nextSection.icon)
                    }
                    .buttonStyle(PrimaryCoachButton(tint: readinessTint))
                }

                if readiness.isPracticeReady {
                    ShareLink(item: shareText) {
                        TeachingLabel(english: "Share checkpoint", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryCoachButton(tint: CoachTheme.primary))
                }
            }
        }
    }

    private var readinessRing: some View {
        DailyFocusRing(progress: readiness.progress, tint: readinessTint, size: 68)
            .teachingAccessibilityLabel("Overall B1 practice score")
            .teachingAccessibilityValue(
                "\(Int(readiness.progress * 100)) percent; \(readiness.passedSectionCount) of 4 sections at practice level"
            )
    }

    private var readinessSummary: some View {
        VStack(alignment: .leading, spacing: 4) {
            TeachingText(english: readinessTitle)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)
            TeachingText(english: "\(readiness.passedSectionCount) of 4 sections ready")
                .font(.caption.weight(.bold))
                .foregroundStyle(readinessTint)
            TeachingText(english: readinessMessage)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var readinessMetrics: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                TeachingLabel(
                    english: "\(readiness.totalAttemptCount) attempt\(readiness.totalAttemptCount == 1 ? "" : "s")",
                    systemImage: "clock.arrow.circlepath"
                )
                TeachingLabel(english: "60% target", systemImage: "scope")
            }
            .lineLimit(1)
            .minimumScaleFactor(0.78)

            TeachingLabel(english: targetDateLabel, systemImage: "calendar")
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
    }

    private func sectionLink(_ section: MockExamSection) -> some View {
        let examSection = B1ExamSection(rawValue: section.skill) ?? .speaking
        let sectionReadiness = readiness.readiness(for: examSection)
        let isRecommended = readiness.nextSection == examSection

        return NavigationLink {
            ExamSectionSessionView(section: section)
        } label: {
            CoachCard(padding: 15, tint: isRecommended ? examSection.tint : nil) {
                HStack(spacing: 13) {
                    CoachIconTile(icon: examSection.icon, tint: examSection.tint, size: 46)
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 7) {
                            TeachingText(english: section.skill)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.primary)
                        }
                        TeachingText(
                            english: (isRecommended ? "Recommended · " : "")
                                + sectionDetail(section, readiness: sectionReadiness)
                        )
                            .font(.caption)
                            .foregroundStyle(isRecommended ? examSection.tint : Color.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer(minLength: 4)
                    sectionScore(sectionReadiness, tint: examSection.tint)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .buttonStyle(CoachCardButtonStyle())
    }

    private func sectionScore(_ section: ExamSectionReadiness, tint: Color) -> some View {
        VStack(alignment: .trailing, spacing: 3) {
            Image(systemName: section.isAtPracticeLevel ? "checkmark.circle.fill" : section.latestScore == nil ? "play.circle.fill" : "arrow.clockwise.circle.fill")
                .font(.title3)
                .foregroundStyle(section.isAtPracticeLevel ? CoachTheme.correct : tint)
            Group {
                if let score = section.latestScore {
                    Text("\(Int(score * 100))%")
                } else {
                    TeachingText(english: "Start")
                }
            }
            .font(.caption.monospacedDigit().weight(.bold))
            .foregroundStyle(.primary)
        }
        .accessibilityElement(children: .combine)
    }

    private func sectionDetail(_ section: MockExamSection, readiness: ExamSectionReadiness) -> String {
        var details = ["\(section.tasks.count) tasks", "\(section.durationMinutes) min"]
        if readiness.attemptCount > 0 { details.append("\(readiness.attemptCount)x trained") }
        if let latest = readiness.latestScore, let best = readiness.bestScore, best > latest {
            details.append("best \(Int(best * 100))%")
        }
        return details.joined(separator: " · ")
    }

    private func strategy(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            TeachingText(english: title).font(.headline).foregroundStyle(CoachTheme.primary)
            TeachingText(english: text).font(.callout).foregroundStyle(.secondary)
        }
    }

    private var nextExamSection: MockExamSection? {
        exam?.sections.first { $0.skill == readiness.nextSection.rawValue }
    }

    private var examTargetDate: Date? {
        ExamTargetDate.date(from: examTargetDateInterval)
    }

    private var targetDateLabel: String {
        guard let days = ExamTargetDate.daysRemaining(interval: examTargetDateInterval) else { return "Set exam date" }
        switch days {
        case ..<0: return "Exam date passed"
        case 0: return "Exam today"
        case 1: return "1 day to exam"
        default: return "\(days) days to exam"
        }
    }

    private var readinessTint: Color {
        if readiness.isPracticeReady { return CoachTheme.correct }
        if readiness.passedSectionCount >= 2 { return CoachTheme.accent }
        return readiness.nextSection.tint
    }

    private var readinessTitle: String {
        switch readiness.passedSectionCount {
        case 4: "Practice checkpoint reached"
        case 2...3: "Closing the final gaps"
        case 1: "Your exam base is growing"
        default: "Start your readiness check"
        }
    }

    private var readinessMessage: String {
        if readiness.isPracticeReady {
            return "All four latest section scores meet the practice target. Keep them fresh with another timed check before exam day."
        }
        if readiness.totalAttemptCount == 0 {
            return "Complete each section once. Your results will create a personal exam plan."
        }
        return "\(readiness.nextSection.rawValue) is your best next move. Raise its latest score to 60% or higher."
    }

    private var nextActionTitle: String {
        readiness.isPracticeReady
            ? "Recheck \(readiness.nextSection.rawValue)"
            : "Train \(readiness.nextSection.rawValue) next"
    }

    private var shareText: String {
        "I reached the B1 practice checkpoint in Deutsch B1 Coach with all four skills at or above the practice target."
    }

    private func loadExam() {
        guard let url = Bundle.main.url(forResource: "mock_exam_b1", withExtension: "json") else {
            errorMessage = "B1 mock exam resource is missing."
            return
        }
        do {
            exam = try JSONDecoder().decode(MockExam.self, from: Data(contentsOf: url))
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private extension B1ExamSection {
    var tint: Color {
        switch self {
        case .listening: CoachTheme.listening
        case .reading: CoachTheme.reading
        case .writing: CoachTheme.writing
        case .speaking: CoachTheme.speaking
        }
    }
}

private struct ExamTargetDateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var targetDateInterval: Double
    @State private var hasTargetDate: Bool
    @State private var targetDate: Date

    init(targetDateInterval: Binding<Double>) {
        _targetDateInterval = targetDateInterval
        let storedInterval = targetDateInterval.wrappedValue
        let fallbackDate = Calendar.current.date(byAdding: .day, value: 30, to: .now) ?? .now
        _hasTargetDate = State(initialValue: storedInterval > 0)
        _targetDate = State(initialValue: ExamTargetDate.date(from: storedInterval) ?? fallbackDate)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: $hasTargetDate) {
                        TeachingText(english: "I have an exam date")
                    }
                    if hasTargetDate {
                        DatePicker(
                            selection: $targetDate,
                            in: Calendar.current.startOfDay(for: .now)...,
                            displayedComponents: .date
                        ) {
                            TeachingText(english: "Exam date")
                        }
                        .datePickerStyle(.graphical)
                    }
                } footer: {
                    TeachingText(english: "Your date stays on this device and is used only for the preparation countdown.")
                }
            }
            .teachingNavigationTitle("Exam target")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    TeachingButton("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    TeachingButton("Done") {
                        targetDateInterval = hasTargetDate ? targetDate.timeIntervalSince1970 : 0
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

private struct ExamSectionSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let section: MockExamSection
    @State private var answers: [String: String] = [:]
    @State private var writtenResponses: [Int: String] = [:]
    @State private var checkedRubric: Set<String> = []
    @State private var remainingSeconds: Int
    @State private var isComplete = false
    @State private var finalScore = 0.0
    @State private var attemptID = UUID()

    init(section: MockExamSection) {
        self.section = section
        _remainingSeconds = State(initialValue: section.durationMinutes * 60)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    SkillChip(title: section.skill, color: skillColor, translatesTitle: false)
                    Spacer()
                    Label(timeText, systemImage: "timer")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(remainingSeconds < 300 ? CoachTheme.incorrect : CoachTheme.accent)
                }

                ForEach(Array(section.tasks.enumerated()), id: \.offset) { taskIndex, task in
                    taskView(task, index: taskIndex)
                }

                Button {
                    finish()
                } label: {
                    TeachingLabel(
                        english: "Finish \(section.skill)",
                        systemImage: "checkmark.seal.fill",
                        protectedGerman: [section.skill]
                    )
                }
                .buttonStyle(PrimaryCoachButton())
            }
            .padding()
        }
        .navigationTitle(section.skill)
        .teachingLanguageSwitcher()
        .navigationBarTitleDisplayMode(.inline)
        .coachBackground()
        .task(id: attemptID) {
            while remainingSeconds > 0 && !isComplete {
                try? await Task.sleep(for: .seconds(1))
                if !Task.isCancelled { remainingSeconds -= 1 }
            }
            if remainingSeconds == 0 && !isComplete { finish() }
        }
        .sheet(isPresented: $isComplete) {
            VStack(spacing: 16) {
                CoachMascot(mood: finalScore >= 0.6 ? .achievement : .supportive, size: 92)
                TeachingText(english: resultTitle)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                Text("\(Int(finalScore * 100))%")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(finalScore >= 0.6 ? CoachTheme.correct : CoachTheme.accent)
                    .contentTransition(.numericText())
                ProgressView(value: finalScore)
                    .tint(finalScore >= 0.6 ? CoachTheme.correct : CoachTheme.accent)
                TeachingText(english: resultMessage)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Button {
                    isComplete = false
                    dismiss()
                } label: {
                    TeachingLabel(english: "Back to readiness", systemImage: "chart.bar.fill")
                }
                .buttonStyle(PrimaryCoachButton(tint: finalScore >= 0.6 ? CoachTheme.correct : CoachTheme.accent))

                Button {
                    resetSession()
                } label: {
                    TeachingLabel(english: "Try this section again", systemImage: "arrow.clockwise")
                }
                .buttonStyle(SecondaryCoachButton(tint: finalScore >= 0.6 ? CoachTheme.correct : CoachTheme.accent))
            }
            .padding()
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    private func taskView(_ task: MockExamTask, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            TeachingText(english: "Task \(index + 1)")
                .font(.caption.weight(.bold))
                .foregroundStyle(skillColor)
            Text(task.prompt).font(.headline)

            if let audioScript = task.audioScript {
                Button { speak(audioScript) } label: {
                    TeachingLabel(english: "Play recording", systemImage: "speaker.wave.2.fill")
                }
                .buttonStyle(PrimaryCoachButton(tint: CoachTheme.listening))
            }
            if let text = task.text {
                Text(text)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .systemBackground), in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
            }
            ForEach(task.questions ?? [], id: \.self) { question in
                VStack(alignment: .leading, spacing: 8) {
                    Text(question.question).font(.headline)
                    ForEach(question.choices, id: \.self) { choice in
                        Button {
                            answers[question.question] = choice
                        } label: {
                            HStack {
                                Text(choice)
                                Spacer()
                                if answers[question.question] == choice { Image(systemName: "checkmark.circle.fill") }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SecondaryCoachButton(tint: skillColor))
                    }
                }
            }
            if task.questions == nil, section.skill == "Schreiben" {
                CoachTextEditor(
                    placeholder: "Write your timed exam response here...",
                    text: Binding(
                        get: { writtenResponses[index, default: ""] },
                        set: { writtenResponses[index] = $0 }
                    ),
                    minHeight: 180,
                    tint: CoachTheme.writing
                )
                TeachingText(
                    english: "\(writtenResponses[index, default: ""].split(whereSeparator: \.isWhitespace).count) words"
                )
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            if section.skill == "Sprechen" {
                NavigationLink {
                    SpeakingPracticeView(taskTitle: task.prompt, level: .b1)
                } label: {
                    TeachingLabel(english: "Open recorder", systemImage: "mic.fill")
                }
                .buttonStyle(PrimaryCoachButton(tint: CoachTheme.speaking))
            }
            ForEach(task.rubric ?? [], id: \.self) { item in
                Button {
                    let key = "\(index)-\(item)"
                    if checkedRubric.contains(key) { checkedRubric.remove(key) } else { checkedRubric.insert(key) }
                } label: {
                    HStack {
                        Image(systemName: checkedRubric.contains("\(index)-\(item)") ? "checkmark.square.fill" : "square")
                        TeachingText(english: item.capitalized).multilineTextAlignment(.leading)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(CoachTheme.surface, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
    }

    private var timeText: String {
        String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
    }

    private var skillArea: SkillArea {
        switch section.skill {
        case "Hören": .listening
        case "Lesen": .reading
        case "Schreiben": .writing
        default: .speaking
        }
    }

    private var skillColor: Color {
        switch skillArea {
        case .listening: CoachTheme.listening
        case .reading: CoachTheme.accent
        case .writing: CoachTheme.primary
        default: CoachTheme.speaking
        }
    }

    private var resultTitle: String {
        finalScore >= 0.6 ? "Practice target reached" : "One gap to close"
    }

    private var resultMessage: String {
        if finalScore >= 0.6 {
            return "Your latest \(section.skill) score now counts toward the four-skill B1 checkpoint."
        }
        let pointsNeeded = max(0, Int(ceil((0.6 - finalScore) * 100)))
        return "You are \(pointsNeeded) percentage point\(pointsNeeded == 1 ? "" : "s") from the practice target. Retry now or follow the updated recommendation."
    }

    private func finish() {
        guard !isComplete else { return }
        let questions = section.tasks.flatMap { $0.questions ?? [] }
        if !questions.isEmpty {
            let correct = questions.filter { answers[$0.question] == $0.answer }.count
            finalScore = Double(correct) / Double(questions.count)
        } else {
            let rubricCount = section.tasks.flatMap { $0.rubric ?? [] }.count
            let rubricScore = rubricCount == 0 ? 0.6 : Double(checkedRubric.count) / Double(rubricCount)
            let writingWords = writtenResponses.values.flatMap { $0.split(whereSeparator: \.isWhitespace) }.count
            let completionScore = section.skill == "Schreiben" ? min(1, Double(writingWords) / 80) : rubricScore
            finalScore = (rubricScore * 0.65) + (completionScore * 0.35)
        }
        try? ProgressService().recordPractice(
            level: .b1,
            skill: skillArea,
            score: finalScore,
            xp: finalScore >= 0.6 ? 25 : 12,
            sourceId: "mock-\(section.skill)",
            modelContext: modelContext
        )
        if finalScore >= 0.6 {
            CoachFeedback.success()
        } else {
            CoachFeedback.warning()
        }
        isComplete = true
    }

    private func resetSession() {
        answers.removeAll()
        writtenResponses.removeAll()
        checkedRubric.removeAll()
        remainingSeconds = section.durationMinutes * 60
        finalScore = 0
        isComplete = false
        attemptID = UUID()
    }

    private func speak(_ text: String) {
        GermanSpeechService.shared.speak(text, style: .listening)
    }
}
