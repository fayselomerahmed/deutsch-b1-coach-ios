import SwiftData
import SwiftUI

struct PracticalMissionsView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \LearningActivity.createdAt, order: .reverse) private var activities: [LearningActivity]
    @State private var missions: [PracticalMissionDTO] = []
    @State private var expandedChapterIDs: Set<String> = []

    let level: CEFRLevel

    private var levelMissions: [PracticalMissionDTO] {
        missions.filter { $0.level == level }.sorted { $0.order < $1.order }
    }

    private var missionChapters: [PracticalMissionChapter] {
        chapters(from: missions)
    }

    private var completedCount: Int {
        levelMissions.filter(isCompleted).count
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                missionHeader.coachReveal(index: 0)

                ForEach(Array(missionChapters.enumerated()), id: \.element.id) { chapterIndex, chapter in
                    VStack(alignment: .leading, spacing: 8) {
                        DisclosureGroup(isExpanded: chapterBinding(chapter.id)) {
                            VStack(spacing: 10) {
                                ForEach(Array(chapter.missions.enumerated()), id: \.element.id) { rowIndex, mission in
                                    NavigationLink {
                                        PracticalMissionDetailView(mission: mission)
                                    } label: {
                                        missionRow(mission)
                                    }
                                    .buttonStyle(CoachCardButtonStyle())
                                    .coachReveal(index: rowIndex)
                                }
                            }
                            .padding(.top, 10)
                        } label: {
                            chapterLabel(chapter)
                        }
                        .tint(chapter.tint)

                        if chapter.id != missionChapters.last?.id {
                            Divider()
                        }
                    }
                    .coachReveal(index: chapterIndex + 1)
                }
            }
            .padding()
        }
        .teachingNavigationTitle("Real-life German")
        .navigationBarTitleDisplayMode(.inline)
        .coachBackground()
        .task {
            let loadedMissions = (try? ContentLoader.shared.loadPracticalMissions()) ?? []
            missions = loadedMissions
            if expandedChapterIDs.isEmpty, let firstChapter = chapters(from: loadedMissions).first {
                expandedChapterIDs.insert(firstChapter.id)
            }
        }
    }

    private var missionHeader: some View {
        CoachCard(tint: CoachTheme.speaking) {
            HStack(spacing: 14) {
                CoachMascot(mood: completedCount == levelMissions.count && !levelMissions.isEmpty ? .achievement : .supportive, size: 58, animates: false)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        SkillChip(title: level.rawValue, color: CoachTheme.primary)
                        SkillChip(title: "\(completedCount)/\(levelMissions.count) complete", color: CoachTheme.speaking)
                    }
                    TeachingText(english: "Build the German you need for real life.")
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(missionChapters.count) focused chapters keep the path clear and manageable.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    ProgressView(value: Double(completedCount), total: Double(max(levelMissions.count, 1)))
                        .tint(CoachTheme.speaking)
                }
            }
        }
    }

    private func missionRow(_ mission: PracticalMissionDTO) -> some View {
        let complete = isCompleted(mission)
        let bestScore = activities
            .filter { $0.sourceId == mission.activitySourceID }
            .map(\.score)
            .max()

        return CoachCard(padding: 14, tint: complete ? CoachTheme.correct : CoachTheme.speaking) {
            HStack(spacing: 13) {
                CoachIconTile(
                    icon: complete ? "checkmark" : mission.icon,
                    tint: complete ? CoachTheme.correct : CoachTheme.speaking,
                    size: 48
                )
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        TeachingText(english: "Mission \(mission.order)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(complete ? CoachTheme.correct : CoachTheme.speaking)
                        if let bestScore {
                            TeachingText(english: "Best \(Int(bestScore * 100))%")
                                .font(.caption2.monospacedDigit().weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                    TeachingText(english: mission.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    TeachingText(english: mission.setting)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private func chapterLabel(_ chapter: PracticalMissionChapter) -> some View {
        HStack(spacing: 12) {
            CoachIconTile(icon: chapter.icon, tint: chapter.tint, size: 42)
            VStack(alignment: .leading, spacing: 2) {
                TeachingText(english: chapter.title)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                TeachingText(english: chapter.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 4)
            SkillChip(title: "\(chapter.missions.count)", color: chapter.tint)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(chapter.title), \(chapter.missions.count) missions")
    }

    private func chapterBinding(_ id: String) -> Binding<Bool> {
        Binding(
            get: { expandedChapterIDs.contains(id) },
            set: { isExpanded in
                withAnimation(reduceMotion ? nil : CoachMotion.standard) {
                    if isExpanded {
                        expandedChapterIDs.insert(id)
                    } else {
                        expandedChapterIDs.remove(id)
                    }
                }
            }
        )
    }

    private func chapters(from source: [PracticalMissionDTO]) -> [PracticalMissionChapter] {
        let definitions: [(String, String, String, String, Color, ClosedRange<Int>)]
        switch level {
        case .a1:
            definitions = [
                ("a1-start", "Meet and communicate", "Introductions, cafes, and shopping", "person.2.fill", CoachTheme.primary, 1...3),
                ("a1-daily", "Daily essentials", "Supermarket, directions, and health", "basket.fill", CoachTheme.speaking, 4...6)
            ]
        case .a2:
            definitions = [
                ("a2-independent", "Work and independence", "Shifts, services, and customer conversations", "briefcase.fill", CoachTheme.speaking, 1...3),
                ("a2-services", "Health and public life", "Appointments, travel, and authorities", "building.2.fill", CoachTheme.listening, 4...6)
            ]
        case .b1:
            definitions = [
                ("b1-work", "Work and career", "Interviews, teamwork, and responsible communication", "briefcase.fill", CoachTheme.speaking, 1...4),
                ("b1-services", "Family and essential services", "School, insurance, authorities, and banking", "building.2.crop.circle.fill", CoachTheme.listening, 5...8),
                ("b1-community", "Build your life", "Housing, neighbors, qualifications, and community", "house.and.flag.fill", CoachTheme.primary, 9...12),
                ("b1-exam", "B1 exam capstone", "Plan, react, and express a supported opinion", "checkmark.seal.fill", CoachTheme.reward, 13...13)
            ]
        }

        return definitions.compactMap { definition in
            let chapterMissions = source
                .filter { $0.level == level && definition.5.contains($0.order) }
                .sorted { $0.order < $1.order }
            guard !chapterMissions.isEmpty else { return nil }
            return PracticalMissionChapter(
                id: definition.0,
                title: definition.1,
                subtitle: definition.2,
                icon: definition.3,
                tint: definition.4,
                missions: chapterMissions
            )
        }
    }

    private func isCompleted(_ mission: PracticalMissionDTO) -> Bool {
        activities.contains { $0.sourceId == mission.activitySourceID }
    }
}

private struct PracticalMissionChapter: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let missions: [PracticalMissionDTO]
}

struct PracticalMissionDetailView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LearningActivity.createdAt, order: .reverse) private var activities: [LearningActivity]
    @StateObject private var recognition = SpeechRecognitionService()
    @StateObject private var repetitionRecognition = SpeechRecognitionService()
    @AppStorage("practicalRolePlayResponseMode") private var responseMode = PracticalResponseMode.voice.rawValue
    @AppStorage("practicalRolePlayAutoPlay") private var autoPlaysPartner = true
    @AppStorage("practicalRolePlayShowsText") private var showsDialogueText = true
    @State private var turnIndex = 0
    @State private var response = ""
    @State private var score: SpeechScore?
    @State private var intentCorrection: IntentPreservingCorrection?
    @State private var isEvaluatingResponse = false
    @State private var coachingTask: Task<Void, Never>?
    @State private var repetitionTranscript = ""
    @State private var repetitionEvaluation: RepetitionEvaluation?
    @State private var repetitionWasSkipped = false
    @State private var turnScores: [Double] = []
    @State private var completedResponses: [PracticalConversationResponse] = []
    @State private var startedAt: Date?
    @State private var showsTranslation = false
    @State private var showsModelAnswer = false
    @State private var showsHistory = false
    @State private var showsPhrases = false
    @State private var showsMissionBrief = false
    @State private var missionComplete = false
    @State private var errorMessage: String?

    let mission: PracticalMissionDTO

    private var currentTurn: PracticalTurnDTO? {
        mission.turns.indices.contains(turnIndex) ? mission.turns[turnIndex] : nil
    }

    private var priorBest: Double? {
        activities.filter { $0.sourceId == mission.activitySourceID }.map(\.score).max()
    }

    private var selectedResponseMode: PracticalResponseMode {
        PracticalResponseMode(rawValue: responseMode) ?? .voice
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    missionOverview.coachReveal(index: 0)

                    if missionComplete {
                        completionView
                            .transition(reduceMotion ? .identity : .opacity.combined(with: .scale(scale: 0.96)))
                    } else if let turn = currentTurn {
                        conversationProgress.coachReveal(index: 1)
                        conversationStage(turn)
                            .id("conversation-\(turnIndex)")
                            .transition(turnTransition)
                        responseCoach(turn)
                            .id("response-\(turnIndex)")
                            .transition(turnTransition)
                    }

                    missionToolkit.coachReveal(index: 4)
                }
                .padding()
            }
            .teachingNavigationTitle(mission.title)
            .navigationBarTitleDisplayMode(.inline)
            .coachBackground()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Toggle(isOn: $autoPlaysPartner) {
                            TeachingText(english: "Play partner automatically")
                        }
                        Toggle(isOn: $showsDialogueText) {
                            TeachingText(english: "Show dialogue text")
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .teachingAccessibilityLabel("Conversation options")
                }
            }
            .onReceive(recognition.$transcript) { transcript in
                guard !transcript.isEmpty else { return }
                response = transcript
            }
            .onReceive(repetitionRecognition.$transcript) { transcript in
                guard !transcript.isEmpty else { return }
                repetitionTranscript = transcript
            }
            .task(id: "\(turnIndex)-\(missionComplete)-\(autoPlaysPartner)") {
                guard autoPlaysPartner, !missionComplete, let turn = currentTurn else { return }
                if !reduceMotion {
                    try? await Task.sleep(for: .milliseconds(180))
                }
                guard !Task.isCancelled else { return }
                GermanSpeechService.shared.speak(turn.partnerCue, style: .listening)
            }
            .animation(reduceMotion ? nil : CoachMotion.navigation, value: turnIndex)
            .animation(reduceMotion ? nil : CoachMotion.spring, value: missionComplete)
            .onAppear {
                prepareVisualQAFeedbackIfNeeded()
                scrollToVisualQAFeedbackIfNeeded(scrollProxy)
            }
            .onDisappear {
                coachingTask?.cancel()
                recognition.stop()
                repetitionRecognition.stop()
                GermanSpeechService.shared.stop()
            }
        }
    }

    private var missionOverview: some View {
        CoachCard(padding: 14, tint: CoachTheme.speaking) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    CoachIconTile(icon: mission.icon, tint: CoachTheme.speaking, size: 44)
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 7) {
                            SkillChip(title: mission.level.rawValue, color: CoachTheme.primary)
                            SkillChip(title: "\(mission.turns.count) exchanges", color: CoachTheme.listening)
                        }
                        TeachingText(english: mission.setting)
                            .font(.callout.weight(.semibold))
                            .fixedSize(horizontal: false, vertical: true)
                        TeachingText(english: "Partner: \(mission.partnerRole)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }

                DisclosureGroup(isExpanded: $showsMissionBrief) {
                    VStack(alignment: .leading, spacing: 10) {
                        TeachingText(english: mission.goal)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        TeachingText(english: "You will practice")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(CoachTheme.speaking)

                        ForEach(mission.canDo, id: \.self) { outcome in
                            TeachingLabel(english: outcome, systemImage: "checkmark.circle.fill")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.top, 8)
                } label: {
                    HStack {
                        TeachingLabel(english: "Mission brief", systemImage: "scope")
                        if let priorBest {
                            Spacer()
                            SkillChip(title: "Best \(Int(priorBest * 100))%", color: CoachTheme.correct)
                        }
                    }
                    .font(.callout.weight(.semibold))
                }
                .tint(CoachTheme.speaking)
            }
        }
    }

    private var conversationProgress: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                TeachingLabel(english: "Live role-play", systemImage: "person.wave.2.fill")
                    .font(.headline)
                Spacer()
                Text("\(turnIndex + 1) / \(mission.turns.count)")
                    .font(.caption.monospacedDigit().weight(.bold))
                    .foregroundStyle(CoachTheme.speaking)
                    .contentTransition(.numericText())
            }
            LessonProgressBar(progress: Double(turnIndex + 1) / Double(max(mission.turns.count, 1)))
        }
    }

    private func conversationStage(_ turn: PracticalTurnDTO) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if !completedResponses.isEmpty {
                DisclosureGroup(
                    isExpanded: $showsHistory,
                    content: {
                        VStack(spacing: 12) {
                            ForEach(completedResponses) { completed in
                                let earlierTurn = mission.turns[completed.turnIndex]
                                partnerBubble(earlierTurn, isCurrent: false)
                                learnerBubble(completed)
                            }
                        }
                        .padding(.top, 12)
                    },
                    label: {
                        Label(
                            "Conversation so far (\(completedResponses.count))",
                            systemImage: "text.bubble.fill"
                        )
                        .font(.callout.weight(.semibold))
                    }
                )
                .tint(CoachTheme.listening)
            }

            partnerBubble(turn, isCurrent: true)
        }
    }

    private func partnerBubble(_ turn: PracticalTurnDTO, isCurrent: Bool) -> some View {
        HStack(alignment: .bottom, spacing: 9) {
            if isCurrent {
                CoachMascot(mood: .welcome, size: 38, animates: true)
            } else {
                CoachIconTile(icon: "person.fill", tint: CoachTheme.listening, size: 38)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label(mission.partnerRole, systemImage: "bubble.left.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CoachTheme.listening)
                    Spacer()
                    Button {
                        GermanSpeechService.shared.speak(turn.partnerCue, style: .listening)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(CoachIconButtonStyle(tint: CoachTheme.listening))
                    .teachingAccessibilityLabel("Play partner cue")
                }

                if showsDialogueText || !isCurrent {
                    RolePlayPromptText(
                        text: turn.partnerCue,
                        tint: CoachTheme.listening,
                        emphasizes: isCurrent
                    )
                } else {
                    TeachingLabel(english: "Audio challenge", systemImage: "waveform")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(CoachTheme.listening)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                }

                if isCurrent {
                    HStack(spacing: 14) {
                        Button {
                            withAnimation(reduceMotion ? nil : CoachMotion.quick) {
                                showsTranslation.toggle()
                            }
                        } label: {
                            if showsTranslation {
                                TeachingText(english: "Hide meaning")
                            } else {
                                TeachingText(english: "Show meaning")
                            }
                        }
                        Button {
                            withAnimation(reduceMotion ? nil : CoachMotion.quick) {
                                showsDialogueText.toggle()
                            }
                        } label: {
                            if showsDialogueText {
                                TeachingText(english: "Hide German")
                            } else {
                                TeachingText(english: "Show German")
                            }
                        }
                    }
                    .font(.caption.weight(.semibold))
                    .buttonStyle(.plain)
                    .foregroundStyle(CoachTheme.listening)

                    if showsTranslation {
                        TeachingText(english: turn.cueTranslation)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .transition(reduceMotion ? .identity : .opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .padding(13)
            .background(
                CoachTheme.listening.opacity(0.10),
                in: RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
                    .stroke(CoachTheme.listening.opacity(0.18))
            )
            .frame(maxWidth: 620, alignment: .leading)

            Spacer(minLength: 20)
        }
        .animation(reduceMotion ? nil : CoachMotion.quick, value: showsTranslation)
        .animation(reduceMotion ? nil : CoachMotion.quick, value: showsDialogueText)
    }

    private func learnerBubble(_ completed: PracticalConversationResponse) -> some View {
        HStack(alignment: .bottom, spacing: 9) {
            Spacer(minLength: 20)
            VStack(alignment: .trailing, spacing: 6) {
                HStack {
                    TeachingText(english: "You")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CoachTheme.speaking)
                    SkillChip(
                        title: "\(Int(completed.score * 100))%",
                        color: completed.score >= 0.62 ? CoachTheme.correct : CoachTheme.reward
                    )
                }
                Text(completed.text)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(13)
            .background(
                CoachTheme.speaking.opacity(0.10),
                in: RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
                    .stroke(CoachTheme.speaking.opacity(0.18))
            )
            .frame(maxWidth: 620, alignment: .trailing)

            CoachIconTile(icon: "person.crop.circle.fill", tint: CoachTheme.speaking, size: 38)
        }
    }

    private func responseCoach(_ turn: PracticalTurnDTO) -> some View {
        CoachCard(tint: CoachTheme.speaking) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    TeachingLabel(english: "Your response", systemImage: selectedResponseMode.icon)
                        .font(.headline)
                        .foregroundStyle(CoachTheme.speaking)
                    Spacer()
                    if !GermanSpeechService.shared.hasBundledNeuralAudio(for: turn.modelResponse) {
                        Image(systemName: "waveform.badge.exclamationmark")
                            .foregroundStyle(CoachTheme.reward)
                            .teachingAccessibilityLabel("Natural model audio is not bundled")
                    }
                }

                Picker(selection: $responseMode) {
                    ForEach(PracticalResponseMode.allCases) { mode in
                        TeachingLabel(english: mode.title, systemImage: mode.icon)
                            .tag(mode.rawValue)
                    }
                } label: {
                    TeachingText(english: "Response method")
                }
                .pickerStyle(.segmented)
                .teachingAccessibilityLabel("Choose voice or text response")

                replyGuide(turn)

                Group {
                    if selectedResponseMode == .voice {
                        voiceResponseControls(turn)
                    } else {
                        textResponseControls(turn)
                    }
                }
                .id(selectedResponseMode)
                .transition(reduceMotion ? .identity : .opacity.combined(with: .move(edge: .bottom)))
                .animation(reduceMotion ? nil : CoachMotion.quick, value: selectedResponseMode)

                if let errorMessage {
                    CoachFeedbackPanel(
                        isCorrect: false,
                        title: "Microphone needs attention",
                        message: errorMessage
                    )
                    .transition(reduceMotion ? .identity : .opacity.combined(with: .scale(scale: 0.98)))
                }

                if isEvaluatingResponse {
                    responseAnalysisProgress
                        .transition(reduceMotion ? .identity : .opacity.combined(with: .scale(scale: 0.98)))
                }

                if let score {
                    scoredResponse(turn, score: score)
                        .transition(reduceMotion ? .identity : .opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .animation(reduceMotion ? nil : CoachMotion.spring, value: score != nil)
            .animation(reduceMotion ? nil : CoachMotion.spring, value: isEvaluatingResponse)
            .animation(reduceMotion ? nil : CoachMotion.spring, value: errorMessage != nil)
        }
    }

    private var responseAnalysisProgress: some View {
        HStack(spacing: 12) {
            ProgressView()
                .controlSize(.regular)
                .tint(CoachTheme.speaking)
            VStack(alignment: .leading, spacing: 3) {
                TeachingText(english: "Understanding your message")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                TeachingText(english: "Keeping your facts while correcting the German...")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            CoachTheme.speaking.opacity(0.09),
            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
        )
        .accessibilityElement(children: .combine)
        .teachingAccessibilityLabel("Understanding your answer and preparing a corrected German sentence")
    }

    private func replyGuide(_ turn: PracticalTurnDTO) -> some View {
        DisclosureGroup(isExpanded: $showsModelAnswer) {
            VStack(alignment: .leading, spacing: 11) {
                TeachingText(english: "Use one complete sentence. Your own details are welcome; these words make your answer clear.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if !turn.requiredPhrases.isEmpty {
                    TeachingText(english: "Useful words for this reply")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CoachTheme.speaking)

                    FlowLayout(spacing: 8) {
                        ForEach(turn.requiredPhrases, id: \.self) { phrase in
                            Button {
                                useReplyPhrase(phrase)
                            } label: {
                                Label(phrase, systemImage: "plus.circle.fill")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(CoachTheme.speaking)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(CoachTheme.speaking.opacity(0.10), in: Capsule())
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint(
                                selectedResponseMode == .text
                                    ? "Add this phrase to your answer"
                                    : "Hear this phrase"
                            )
                        }
                    }
                }

                if !turn.grammarMarkers.isEmpty {
                    TeachingText(english: "Grammar to notice: \(turn.grammarMarkers.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Divider()

                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        TeachingText(english: "One natural example")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(CoachTheme.correct)
                        RolePlayPromptText(
                            text: turn.modelResponse,
                            tint: CoachTheme.correct,
                            emphasizes: false
                        )
                        TeachingText(english: turn.responseTranslation)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 4)
                    Button {
                        GermanSpeechService.shared.speak(turn.modelResponse, style: .model)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .frame(width: 38, height: 38)
                    }
                    .buttonStyle(CoachIconButtonStyle(tint: CoachTheme.correct))
                    .teachingAccessibilityLabel("Hear one natural answer")
                }
            }
            .padding(.top, 9)
        } label: {
            HStack(spacing: 8) {
                TeachingLabel(english: "Help me answer", systemImage: "lightbulb.max.fill")
                Spacer()
                TeachingText(english: "phrases + example")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .font(.callout.weight(.semibold))
            .foregroundStyle(CoachTheme.speaking)
        }
        .tint(CoachTheme.speaking)
        .padding(12)
        .background(
            CoachTheme.speaking.opacity(0.07),
            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                .stroke(CoachTheme.speaking.opacity(0.18), lineWidth: 1)
        }
    }

    private func useReplyPhrase(_ phrase: String) {
        if selectedResponseMode == .voice {
            GermanSpeechService.shared.speak(phrase, style: .model)
        } else {
            let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
            response = trimmed.isEmpty ? phrase : "\(trimmed) \(phrase)"
        }
        CoachFeedback.selection()
    }

    @ViewBuilder
    private func voiceResponseControls(_ turn: PracticalTurnDTO) -> some View {
        if recognition.isRecording {
            VStack(spacing: 12) {
                RolePlayRecordingWaveform()
                TeachingText(english: "Listening to your German...")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(CoachTheme.speaking)

                Button {
                    stopRecording()
                } label: {
                    TeachingLabel(english: "Stop recording", systemImage: "stop.fill")
                }
                .buttonStyle(PrimaryCoachButton(tint: CoachTheme.incorrect))
            }
        } else {
            if response.isEmpty {
                Button {
                    startRecording()
                } label: {
                    TeachingLabel(english: "Start speaking", systemImage: "mic.fill")
                }
                .buttonStyle(PrimaryCoachButton(tint: CoachTheme.speaking))
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    TeachingText(english: "I heard")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                    RolePlayPromptText(
                        text: response,
                        tint: CoachTheme.speaking,
                        emphasizes: true
                    )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(
                            CoachTheme.speaking.opacity(0.08),
                            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                        )
                }
                if score == nil && !isEvaluatingResponse {
                    responseActions(turn)
                }
            }
        }
    }

    private func textResponseControls(_ turn: PracticalTurnDTO) -> some View {
        VStack(spacing: 12) {
            TeachingTextField(prompt: "Type your German answer", text: $response, axis: .vertical)
                .textFieldStyle(CoachTextFieldStyle(tint: CoachTheme.speaking))
                .germanKeyboardAccessory(text: $response)
                .disabled(score != nil)
            if score == nil {
                Button {
                    evaluate(turn)
                } label: {
                    if isEvaluatingResponse {
                        TeachingLabel(english: "Understanding answer", systemImage: "text.magnifyingglass")
                    } else {
                        TeachingLabel(english: "Check response", systemImage: "checkmark.circle.fill")
                    }
                }
                .buttonStyle(PrimaryCoachButton(tint: CoachTheme.speaking))
                .disabled(
                    isEvaluatingResponse
                        || response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )
            }
        }
    }

    private func responseActions(_ turn: PracticalTurnDTO) -> some View {
        HStack(spacing: 9) {
            Button {
                retryTurn(startsRecording: true)
            } label: {
                TeachingLabel(english: "Record again", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryCoachButton(tint: CoachTheme.speaking))

            Button {
                evaluate(turn)
            } label: {
                TeachingLabel(english: "Check", systemImage: "checkmark")
            }
            .buttonStyle(PrimaryCoachButton(tint: CoachTheme.speaking))
        }
    }

    private func scoredResponse(_ turn: PracticalTurnDTO, score: SpeechScore) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            CoachFeedbackPanel(
                isCorrect: score.overall >= 0.62,
                title: score.overall >= 0.62 ? "Your meaning was understood" : "Your idea needs one clearer try",
                message: intentCorrection?.coachingNote
                    ?? score.feedback.first
                    ?? "I kept your message and prepared a natural corrected version."
            )

            SpeakingCorrectionCoach(
                transcript: response,
                correction: score.correction,
                translation: correctionTranslation(for: turn, correctedText: score.correction.correctedText)
            )

            HStack(spacing: 8) {
                SkillChip(title: "Your meaning", color: CoachTheme.correct)
                SkillChip(
                    title: intentCorrection?.source == .onDeviceAI
                        ? "Private on-device coach"
                        : "Offline grammar coach",
                    color: CoachTheme.speaking
                )
            }

            guidedRepetition(turn)
                .id("guided-repetition")

            Button {
                retryTurn(startsRecording: false)
            } label: {
                TeachingLabel(english: "Improve my original answer", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryCoachButton(tint: CoachTheme.speaking))

            Button {
                advance(with: score.overall)
            } label: {
                Label(
                    canContinueAfterRepetition
                        ? (turnIndex == mission.turns.count - 1 ? "Complete mission" : "Continue conversation")
                        : "Repeat your corrected answer first",
                    systemImage: canContinueAfterRepetition
                        ? (turnIndex == mission.turns.count - 1 ? "checkmark.seal.fill" : "arrow.right")
                        : "mic.badge.plus"
                )
            }
            .buttonStyle(PrimaryCoachButton(tint: CoachTheme.correct))
            .disabled(!canContinueAfterRepetition)
        }
    }

    private var canContinueAfterRepetition: Bool {
        repetitionEvaluation != nil || repetitionWasSkipped
    }

    private func guidedRepetition(_ turn: PracticalTurnDTO) -> some View {
        let target = repetitionTarget(for: turn)

        return VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top, spacing: 10) {
                CoachIconTile(
                    icon: repetitionEvaluation?.isSuccessful == true ? "checkmark" : "waveform",
                    tint: repetitionEvaluation?.isSuccessful == true ? CoachTheme.correct : CoachTheme.listening,
                    size: 40
                )
                VStack(alignment: .leading, spacing: 3) {
                    TeachingText(english: "Repeat your corrected answer")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                    TeachingText(english: "This is your own idea in natural German. Listen, then say it again.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TeachingLabel(english: "Your corrected German", systemImage: "checkmark.bubble.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CoachTheme.correct)
                    Spacer()
                    Button {
                        GermanSpeechService.shared.speak(target, style: .model)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .frame(width: 38, height: 38)
                    }
                    .buttonStyle(CoachIconButtonStyle(tint: CoachTheme.listening))
                    .teachingAccessibilityLabel("Hear the correct answer")
                }

                RolePlayPromptText(
                    text: target,
                    tint: CoachTheme.correct,
                    emphasizes: true
                )
                if let correction = intentCorrection {
                    Label {
                        TeachingText(english: correction.coachingNote)
                    } icon: {
                        Image(systemName: "lightbulb.fill")
                    }
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                } else {
                    TeachingText(english: turn.responseTranslation)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .background(
                Color(uiColor: .systemBackground).opacity(0.9),
                in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                    .stroke(CoachTheme.correct.opacity(0.24), lineWidth: 1)
            }

            if repetitionRecognition.isRecording {
                VStack(spacing: 10) {
                    RolePlayRecordingWaveform()
                    TeachingText(english: "Repeat the model now")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(CoachTheme.speaking)

                    if !repetitionTranscript.isEmpty {
                        Text(repetitionTranscript)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Button {
                        stopRepetition()
                    } label: {
                        TeachingLabel(english: "Stop repetition", systemImage: "stop.fill")
                    }
                    .buttonStyle(PrimaryCoachButton(tint: CoachTheme.incorrect))
                }
            } else if let evaluation = repetitionEvaluation {
                repetitionResult(turn, evaluation: evaluation)
            } else if repetitionTranscript.isEmpty {
                HStack(spacing: 9) {
                    Button {
                        GermanSpeechService.shared.speak(target, style: .model)
                    } label: {
                        TeachingLabel(english: "Listen", systemImage: "speaker.wave.2.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryCoachButton(tint: CoachTheme.listening))

                    Button {
                        startRepetition()
                    } label: {
                        TeachingLabel(english: "Repeat", systemImage: "mic.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryCoachButton(tint: CoachTheme.speaking))
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    TeachingText(english: "I heard")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text(repetitionTranscript)
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 9) {
                        Button {
                            retryRepetition(startsRecording: true)
                        } label: {
                            TeachingLabel(english: "Record again", systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SecondaryCoachButton(tint: CoachTheme.speaking))

                        Button {
                            evaluateRepetition(turn)
                        } label: {
                            TeachingLabel(english: "Check repeat", systemImage: "checkmark")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryCoachButton(tint: CoachTheme.speaking))
                    }
                }
            }

            if repetitionEvaluation == nil && !repetitionWasSkipped {
                Button {
                    repetitionWasSkipped = true
                } label: {
                    TeachingText(english: "Continue without microphone")
                }
                .font(.caption.weight(.semibold))
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [
                    CoachTheme.listening.opacity(0.14),
                    CoachTheme.correct.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
                .stroke(CoachTheme.listening.opacity(0.22), lineWidth: 1)
        }
        .animation(reduceMotion ? nil : CoachMotion.spring, value: repetitionEvaluation)
    }

    private func repetitionResult(
        _ turn: PracticalTurnDTO,
        evaluation: RepetitionEvaluation
    ) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            CoachFeedbackPanel(
                isCorrect: evaluation.isSuccessful,
                title: evaluation.isSuccessful
                    ? "Corrected answer repeated clearly"
                    : "One more focused repetition",
                message: evaluation.feedback
            )

            HStack(spacing: 8) {
                SkillChip(
                    title: "Answer match \(Int(evaluation.accuracy * 100))%",
                    color: evaluation.isSuccessful ? CoachTheme.correct : CoachTheme.reward
                )
                SkillChip(
                    title: "\(evaluation.matchedWords)/\(evaluation.targetWords) words",
                    color: CoachTheme.speaking
                )
            }

            if !evaluation.correction.issues.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    TeachingText(english: "Polish these parts")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CoachTheme.accent)
                    ForEach(evaluation.correction.issues) { issue in
                        Label {
                            TeachingText(english: issue.message)
                        } icon: {
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            Button {
                retryRepetition(startsRecording: true)
            } label: {
                Label(
                    evaluation.isSuccessful ? "Repeat once more" : "Try repetition again",
                    systemImage: "mic.fill"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryCoachButton(tint: CoachTheme.speaking))
        }
    }

    private var missionToolkit: some View {
        CoachCard(tint: CoachTheme.primary) {
            VStack(alignment: .leading, spacing: 14) {
                DisclosureGroup(isExpanded: $showsPhrases) {
                    VStack(spacing: 0) {
                        ForEach(Array(mission.phrases.enumerated()), id: \.offset) { index, phrase in
                            phraseRow(phrase)
                            if index < mission.phrases.count - 1 { Divider() }
                        }
                    }
                    .padding(.top, 8)
                } label: {
                    TeachingLabel(english: "Useful phrases", systemImage: "quote.bubble.fill")
                        .font(.headline)
                }
                .tint(CoachTheme.speaking)

                Divider()

                NavigationLink {
                    WritingPracticeView(
                        prompt: mission.writingPrompt,
                        checklist: mission.writingChecklist,
                        level: mission.level
                    )
                } label: {
                    HStack(spacing: 12) {
                        CoachIconTile(icon: "square.and.pencil", tint: CoachTheme.writing)
                        VStack(alignment: .leading, spacing: 3) {
                            TeachingText(english: "Written follow-up")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            TeachingText(english: "Use the same situation in a practical message")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(CoachCardButtonStyle())
            }
        }
    }

    private func phraseRow(_ phrase: PracticalPhraseDTO) -> some View {
        HStack(spacing: 11) {
            Button {
                GermanSpeechService.shared.speak(phrase.german, style: .model)
            } label: {
                Image(systemName: "speaker.wave.2.fill")
            }
            .buttonStyle(CoachIconButtonStyle(tint: CoachTheme.speaking))
            .teachingAccessibilityLabel(
                "Play \(phrase.german)",
                protectedGerman: [phrase.german]
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(phrase.german)
                    .font(.callout.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                TeachingText(english: phrase.english)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 4)
        }
        .padding(.vertical, 9)
    }

    private var completionView: some View {
        CoachCard(tint: CoachTheme.correct) {
            VStack(spacing: 14) {
                CoachMascot(mood: .achievement, size: 76)
                TeachingText(english: "Mission complete")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                TeachingText(english: "You kept a \(mission.turns.count)-part conversation moving in \(mission.setting.lowercased()).")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    replayModelConversation()
                } label: {
                    TeachingLabel(english: "Replay full dialogue", systemImage: "speaker.wave.2.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryCoachButton(tint: CoachTheme.listening))

                Button {
                    dismiss()
                } label: {
                    TeachingLabel(english: "Choose next mission", systemImage: "books.vertical.fill")
                }
                .buttonStyle(PrimaryCoachButton(tint: CoachTheme.correct))

                Button {
                    turnIndex = 0
                    turnScores = []
                    completedResponses = []
                    missionComplete = false
                    resetTurn()
                } label: {
                    TeachingLabel(english: "Practice again", systemImage: "arrow.clockwise")
                }
                .buttonStyle(SecondaryCoachButton(tint: CoachTheme.correct))
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func startRecording() {
        Task {
            await recognition.requestAuthorization()
            if let authorizationError = recognition.authorizationError {
                errorMessage = authorizationError
                return
            }
            do {
                startedAt = .now
                response = ""
                score = nil
                errorMessage = nil
                GermanSpeechService.shared.stop()
                try await recognition.start()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func stopRecording() {
        recognition.stop()
        if !recognition.transcript.isEmpty {
            response = recognition.transcript
        }
    }

    private func startRepetition() {
        Task {
            await repetitionRecognition.requestAuthorization()
            if let authorizationError = repetitionRecognition.authorizationError {
                errorMessage = authorizationError
                return
            }
            do {
                repetitionTranscript = ""
                repetitionEvaluation = nil
                repetitionWasSkipped = false
                errorMessage = nil
                GermanSpeechService.shared.stop()
                try await repetitionRecognition.start()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func stopRepetition() {
        repetitionRecognition.stop()
        if !repetitionRecognition.transcript.isEmpty {
            repetitionTranscript = repetitionRecognition.transcript
        }
    }

    private func evaluateRepetition(_ turn: PracticalTurnDTO) {
        stopRepetition()
        repetitionEvaluation = SpeechScorer().scoreRepetition(
            recognizedText: repetitionTranscript,
            expectedText: repetitionTarget(for: turn)
        )
        if repetitionEvaluation?.isSuccessful == true {
            CoachFeedback.success()
        } else {
            CoachFeedback.warning()
        }
    }

    private func retryRepetition(startsRecording: Bool) {
        repetitionRecognition.stop()
        repetitionTranscript = ""
        repetitionEvaluation = nil
        repetitionWasSkipped = false
        CoachFeedback.selection()
        if startsRecording {
            startRepetition()
        }
    }

    private func evaluate(_ turn: PracticalTurnDTO) {
        stopRecording()
        if startedAt != nil, !recognition.transcript.isEmpty { response = recognition.transcript }
        let learnerResponse = response.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !learnerResponse.isEmpty, !isEvaluatingResponse else { return }

        let duration = startedAt.map { Date().timeIntervalSince($0) } ?? defaultDuration
        let baselineScore = SpeechScorer().score(
            recognizedText: learnerResponse,
            prompt: SpeechPrompt(
                expectedAnswer: turn.modelResponse,
                requiredPhrases: turn.requiredPhrases,
                grammarMarkers: turn.grammarMarkers,
                targetDuration: targetDuration
            ),
            duration: duration
        )

        coachingTask?.cancel()
        isEvaluatingResponse = true
        score = nil
        intentCorrection = nil
        repetitionTranscript = ""
        repetitionEvaluation = nil
        repetitionWasSkipped = false
        let evaluatedTurnIndex = turnIndex

        coachingTask = Task {
            let personalizedCorrection = await IntentPreservingGermanCoach.shared.correct(
                learnerResponse,
                partnerCue: turn.partnerCue,
                scenario: mission.setting,
                level: mission.level.rawValue
            )
            guard !Task.isCancelled, evaluatedTurnIndex == turnIndex else { return }

            intentCorrection = personalizedCorrection
            score = personalizedScore(
                baseline: baselineScore,
                learnerResponse: learnerResponse,
                correction: personalizedCorrection
            )
            isEvaluatingResponse = false

            GermanSpeechService.shared.speak(
                personalizedCorrection.correctedText,
                style: .model
            )
            if (score?.overall ?? 0) >= 0.62 {
                CoachFeedback.success()
            } else {
                CoachFeedback.warning()
            }
        }
    }

    private func personalizedScore(
        baseline: SpeechScore,
        learnerResponse: String,
        correction: IntentPreservingCorrection
    ) -> SpeechScore {
        let formEvaluation = SpeechScorer().scoreRepetition(
            recognizedText: learnerResponse,
            expectedText: correction.correctedText
        )
        let hasCompleteMessage = learnerResponse.split(whereSeparator: \.isWhitespace).count >= 3
        let personalizedOverall = hasCompleteMessage
            ? max(baseline.overall, min(0.95, 0.55 + formEvaluation.accuracy * 0.4))
            : baseline.overall
        let feedback = formEvaluation.accuracy >= 0.9
            ? ["Your own sentence was already clear. Practise it once for confident delivery."]
            : ["Your meaning is preserved below. Listen to the repaired German and repeat it."]

        return SpeechScore(
            pronunciation: baseline.pronunciation,
            grammarAccuracy: formEvaluation.accuracy,
            fluency: baseline.fluency,
            vocabularyRange: baseline.vocabularyRange,
            overall: personalizedOverall,
            feedback: feedback,
            correction: correction.applying(to: baseline.correction)
        )
    }

    private func repetitionTarget(for turn: PracticalTurnDTO) -> String {
        intentCorrection?.correctedText
            ?? score?.correction.correctedText
            ?? turn.modelResponse
    }

    private func correctionTranslation(
        for turn: PracticalTurnDTO,
        correctedText: String
    ) -> String? {
        let normalize: (String) -> String = {
            $0.lowercased()
                .trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))
        }
        return normalize(correctedText) == normalize(turn.modelResponse)
            ? turn.responseTranslation
            : nil
    }

    private func advance(with currentScore: Double) {
        turnScores.append(currentScore)
        completedResponses.append(
            PracticalConversationResponse(
                turnIndex: turnIndex,
                text: intentCorrection?.correctedText ?? response,
                score: currentScore
            )
        )
        if turnIndex < mission.turns.count - 1 {
            withAnimation(reduceMotion ? nil : CoachMotion.navigation) {
                turnIndex += 1
                resetTurn()
            }
            CoachFeedback.selection()
        } else {
            completeMission()
        }
    }

    private func completeMission() {
        let average = turnScores.isEmpty ? 0 : turnScores.reduce(0, +) / Double(turnScores.count)
        let xp = mission.level == .b1 ? 18 : (mission.level == .a2 ? 15 : 12)
        try? ProgressService().recordPractice(
            level: mission.level,
            skill: .speaking,
            score: average,
            xp: xp,
            sourceId: mission.activitySourceID,
            modelContext: modelContext
        )
        withAnimation(reduceMotion ? nil : CoachMotion.spring) { missionComplete = true }
        CoachFeedback.success()
    }

    private func retryTurn(startsRecording: Bool) {
        resetTurn()
        CoachFeedback.selection()
        if startsRecording {
            startRecording()
        }
    }

    private func replayModelConversation() {
        let segments = mission.turns.flatMap { turn in
            [
                (turn.partnerCue, GermanSpeechStyle.listening),
                (turn.modelResponse, GermanSpeechStyle.model)
            ]
        }
        GermanSpeechService.shared.speakSequence(segments)
    }

    private func resetTurn() {
        coachingTask?.cancel()
        coachingTask = nil
        recognition.stop()
        repetitionRecognition.stop()
        response = ""
        score = nil
        intentCorrection = nil
        isEvaluatingResponse = false
        repetitionTranscript = ""
        repetitionEvaluation = nil
        repetitionWasSkipped = false
        startedAt = nil
        showsTranslation = false
        showsModelAnswer = false
        errorMessage = nil
    }

    private var targetDuration: ClosedRange<TimeInterval> {
        switch mission.level {
        case .a1: 5...20
        case .a2: 8...30
        case .b1: 12...45
        }
    }

    private var defaultDuration: TimeInterval {
        switch mission.level {
        case .a1: 10
        case .a2: 16
        case .b1: 24
        }
    }

    private var turnTransition: AnyTransition {
        reduceMotion
            ? .identity
            : .asymmetric(
                insertion: .opacity
                    .combined(with: .move(edge: .trailing))
                    .combined(with: .scale(scale: 0.98)),
                removal: .opacity.combined(with: .move(edge: .leading))
            )
    }

    private func prepareVisualQAFeedbackIfNeeded() {
#if DEBUG
        guard ProcessInfo.processInfo.arguments.contains("-visualQARolePlayFeedback"),
              score == nil,
              let turn = currentTurn
        else { return }

        response = "ich habe 6 jahre erfahrung in software entwickelung"
        let baseline = SpeechScorer().score(
            recognizedText: response,
            prompt: SpeechPrompt(
                expectedAnswer: turn.modelResponse,
                requiredPhrases: turn.requiredPhrases,
                grammarMarkers: turn.grammarMarkers,
                targetDuration: targetDuration
            ),
            duration: defaultDuration
        )
        let personalizedCorrection = IntentPreservingCorrection(
            correctedText: "Ich habe 6 Jahre Erfahrung in der Softwareentwicklung.",
            coachingNote: "I kept your six years of experience and corrected the compound noun and dative phrase.",
            issues: [
                SpeechCorrectionIssue(
                    kind: .grammar,
                    title: "Compound noun",
                    message: "Use the German compound noun “Softwareentwicklung”."
                ),
                SpeechCorrectionIssue(
                    kind: .grammar,
                    title: "Dative after “in”",
                    message: "For this field of work, say “in der Softwareentwicklung”."
                )
            ],
            source: .offlineGrammar
        )
        intentCorrection = personalizedCorrection
        score = personalizedScore(
            baseline: baseline,
            learnerResponse: response,
            correction: personalizedCorrection
        )
        repetitionTranscript = "Ich habe sechs Jahre Erfahrung in Softwareentwicklung"
        repetitionEvaluation = SpeechScorer().scoreRepetition(
            recognizedText: repetitionTranscript,
            expectedText: personalizedCorrection.correctedText
        )
#endif
    }

    private func scrollToVisualQAFeedbackIfNeeded(_ proxy: ScrollViewProxy) {
#if DEBUG
        guard ProcessInfo.processInfo.arguments.contains("-visualQARolePlayFeedback") else { return }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(250))
            proxy.scrollTo("guided-repetition", anchor: .top)
        }
#endif
    }
}

private struct RolePlayPromptText: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    let text: String
    let tint: Color
    let emphasizes: Bool

    var body: some View {
        Text(text)
            .font(.system(emphasizes ? .title3 : .body, design: .rounded, weight: emphasizes ? .bold : .semibold))
            .foregroundStyle(.primary)
            .lineSpacing(emphasizes ? 3 : 1)
            .fixedSize(horizontal: false, vertical: true)
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(tint)
                    .frame(width: 3)
                    .offset(x: -9)
                    .opacity(emphasizes ? 0.72 : 0)
            }
            .padding(.leading, emphasizes ? 8 : 0)
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(reduceMotion || isVisible ? 1 : 0.94, anchor: .leading)
            .offset(y: reduceMotion || isVisible ? 0 : 5)
            .onAppear {
                if reduceMotion {
                    isVisible = true
                } else {
                    withAnimation(CoachMotion.spring) {
                        isVisible = true
                    }
                }
            }
            .accessibilityLabel(text)
    }
}

private struct RolePlayRecordingWaveform: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isActive = false

    private let restingHeights: [CGFloat] = [10, 18, 13, 22, 12, 17, 9]
    private let activeHeights: [CGFloat] = [25, 12, 30, 16, 28, 11, 23]

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(restingHeights.indices, id: \.self) { index in
                Capsule()
                    .fill(CoachTheme.speaking)
                    .frame(
                        width: 4,
                        height: isActive && !reduceMotion ? activeHeights[index] : restingHeights[index]
                    )
                    .animation(
                        reduceMotion
                            ? nil
                            : CoachMotion.standard
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.025),
                        value: isActive
                    )
            }
        }
        .frame(height: 34)
        .onAppear { isActive = true }
        .accessibilityHidden(true)
    }
}

private enum PracticalResponseMode: String, CaseIterable, Identifiable {
    case voice
    case text

    var id: String { rawValue }

    var title: String {
        switch self {
        case .voice: "Voice"
        case .text: "Text"
        }
    }

    var icon: String {
        switch self {
        case .voice: "mic.fill"
        case .text: "keyboard"
        }
    }
}

private struct PracticalConversationResponse: Identifiable {
    var id: Int { turnIndex }
    let turnIndex: Int
    let text: String
    let score: Double
}

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        let maxWidth = proposal.width ?? .greatestFiniteMagnitude
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if lineWidth > 0, lineWidth + spacing + size.width > maxWidth {
                totalHeight += lineHeight + spacing
                lineWidth = 0
                lineHeight = 0
            }
            lineWidth += (lineWidth > 0 ? spacing : 0) + size.width
            lineHeight = max(lineHeight, size.height)
        }

        return CGSize(width: proposal.width ?? lineWidth, height: totalHeight + lineHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        var point = bounds.origin
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if point.x > bounds.minX, point.x + size.width > bounds.maxX {
                point.x = bounds.minX
                point.y += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: point, proposal: ProposedViewSize(size))
            point.x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
