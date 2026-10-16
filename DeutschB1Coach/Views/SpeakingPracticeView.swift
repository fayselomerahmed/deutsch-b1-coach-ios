import SwiftUI
import AVFoundation
import SwiftData

struct SpeakingPracticeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: SpeakingPracticeViewModel
    @StateObject private var recognition = SpeechRecognitionService()
    @State private var premium = PremiumAccessService.shared
    @State private var showsPremium = false
    let taskTitle: String
    let level: CEFRLevel
    let isFreeSample: Bool

    init(
        prompt: SpeechPrompt? = nil,
        taskTitle: String? = nil,
        level: CEFRLevel = .b1,
        isFreeSample: Bool = false
    ) {
        let task = FluencyTaskCatalog.speaking(level: level, prompt: taskTitle)
        self._viewModel = State(initialValue: SpeakingPracticeViewModel(prompt: prompt ?? task.speechPrompt))
        self.taskTitle = task.prompt
        self.level = level
        self.isFreeSample = isFreeSample
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if isFreeSample && !premium.isPremium {
                    TeachingLabel(english: "FREE SPEAKING SAMPLE", systemImage: "mic.badge.plus")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(CoachTheme.speaking)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(CoachTheme.speaking.opacity(0.12), in: Capsule())
                }
                TeachingText(english: "Answer the prompt")
                    .font(.system(.title, design: .rounded, weight: .bold))
                TeachingText(english: taskTitle)
                    .font(.title3)
                Button {
                    viewModel.playModel()
                } label: {
                    TeachingLabel(english: "Play model", systemImage: "speaker.wave.2.fill")
                }
                .buttonStyle(SecondaryCoachButton(tint: CoachTheme.primary))
                TeachingTextField(
                    prompt: "Recognized speech appears here",
                    text: $viewModel.recognizedText,
                    axis: .vertical
                )
                    .textFieldStyle(CoachTextFieldStyle(tint: CoachTheme.speaking))
                    .germanKeyboardAccessory(text: $viewModel.recognizedText)
                HStack(spacing: 8) {
                    Button {
                        Task {
                            await recognition.requestAuthorization()
                            if let authorizationError = recognition.authorizationError {
                                viewModel.errorMessage = authorizationError
                                return
                            }
                            viewModel.start()
                            do {
                                try await recognition.start()
                            } catch {
                                viewModel.errorMessage = error.localizedDescription
                            }
                        }
                    } label: {
                        if viewModel.startedAt == nil {
                            TeachingLabel(english: "Start", systemImage: "mic.fill")
                        } else {
                            TeachingLabel(english: "Restart", systemImage: "mic.fill")
                        }
                    }
                    .buttonStyle(SecondaryCoachButton(tint: CoachTheme.speaking))
                    Button {
                        recognition.stop()
                        viewModel.recognizedText = recognition.transcript
                    } label: {
                        TeachingLabel(english: "Stop", systemImage: "stop.fill")
                    }
                    .buttonStyle(SecondaryCoachButton(tint: CoachTheme.incorrect))
                    .disabled(!recognition.isRecording)
                    Button {
                        if !recognition.transcript.isEmpty {
                            viewModel.recognizedText = recognition.transcript
                        }
                        viewModel.scoreCurrentAnswer()
                        if let score = viewModel.score {
                            score.overall >= 0.7 ? CoachFeedback.success() : CoachFeedback.warning()
                            if isFreeSample && !premium.isPremium {
                                FreeExperienceStore.completeSpeakingSample()
                            } else {
                                PrivateProductAnalytics.record(.speakingCorrectionReceived)
                            }
                            try? ProgressService().recordPractice(
                                level: level,
                                skill: .speaking,
                                score: score.overall,
                                xp: score.overall >= 0.7 ? 12 : 6,
                                sourceId: "speaking-\(taskTitle.hashValue)",
                                modelContext: modelContext
                            )
                        }
                    } label: {
                        CoachActionLabel(
                            title: "Score",
                            successTitle: "Scored",
                            icon: "checkmark.seal.fill",
                            isComplete: viewModel.score != nil
                        )
                    }
                    .buttonStyle(PrimaryCoachButton())
                    .disabled(viewModel.recognizedText.isEmpty)
                }
                if recognition.isRecording {
                    TeachingLabel(english: "Recording...", systemImage: "waveform")
                        .font(.headline)
                        .foregroundStyle(CoachTheme.speaking)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(CoachTheme.softRose, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
                }
                if !recognition.transcript.isEmpty {
                    Text(recognition.transcript)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                if let error = viewModel.errorMessage {
                    CoachFeedbackPanel(
                        isCorrect: false,
                        title: "Recording needs attention",
                        message: error
                    )
                }
                if let score = viewModel.score {
                    CoachFeedbackPanel(
                        isCorrect: score.overall >= 0.7,
                        title: score.overall >= 0.7 ? "Strong speaking practice" : "Good practice attempt",
                        message: score.feedback.first ?? "Use the breakdown below to choose your next focus."
                    )

                    SpeakingCorrectionCoach(
                        transcript: viewModel.recognizedText,
                        correction: score.correction
                    )

                    CoachCard {
                        VStack(spacing: 16) {
                            Gauge(value: score.overall) {
                                TeachingText(english: "Overall")
                            } currentValueLabel: {
                                Text("\(Int(score.overall * 100))%")
                                    .font(.system(.title2, design: .rounded, weight: .bold))
                            }
                            .tint(CoachTheme.primary)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                                CoachMetric(value: "\(Int(score.pronunciation * 100))%", label: "Clarity", icon: "waveform", tint: CoachTheme.speaking)
                                CoachMetric(value: "\(Int(score.grammarAccuracy * 100))%", label: "Grammar", icon: "text.book.closed.fill", tint: CoachTheme.primary)
                                CoachMetric(value: "\(Int(score.fluency * 100))%", label: "Fluency", icon: "metronome.fill", tint: CoachTheme.accent)
                                CoachMetric(value: "\(Int(score.vocabularyRange * 100))%", label: "Vocabulary", icon: "rectangle.stack.fill", tint: CoachTheme.listening)
                            }

                            ForEach(score.feedback.dropFirst(), id: \.self) { feedback in
                                Label {
                                    TeachingText(english: feedback)
                                } icon: {
                                    Image(systemName: "lightbulb.fill")
                                }
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }

                    if isFreeSample && !premium.isPremium {
                        CoachCard(tint: CoachTheme.accent) {
                            VStack(alignment: .leading, spacing: 10) {
                                TeachingText(english: "Keep improving this answer")
                                    .font(.headline)
                                TeachingText(english: "The full coach gives you unlimited corrections, natural model audio, roleplays, and focused retries for your weak areas.")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                TeachingButton("Continue speaking practice") {
                                    showsPremium = true
                                }
                                .buttonStyle(PrimaryCoachButton(tint: CoachTheme.accent))
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding()
        }
        .teachingNavigationTitle("Speaking")
        .coachBackground()
        .sheet(isPresented: $showsPremium) {
            PremiumView(entryPoint: .speakingCorrection)
        }
    }
}
