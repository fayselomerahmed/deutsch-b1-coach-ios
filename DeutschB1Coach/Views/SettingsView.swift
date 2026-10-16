import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("learnerName") private var learnerName = ""
    @AppStorage("preferredLevel") private var preferredLevel = CEFRLevel.a1.rawValue
    @AppStorage("dailyMinutes") private var dailyMinutes = 15
    @AppStorage("remindersEnabled") private var remindersEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 19
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("didCompletePlacement") private var didCompletePlacement = true
    @AppStorage("selectedLearningWeakness") private var selectedLearningWeakness = SkillArea.listening.rawValue
    @AppStorage("opensOnHomeScreen") private var opensOnHomeScreen = true
    @AppStorage(TeachingLanguage.storageKey) private var teachingLanguageCode = TeachingLanguage.defaultLanguage.rawValue
    @AppStorage(PrivateProductAnalytics.sharingStorageKey) private var sharesAnonymousImprovementData = false
    @State private var reminderTime = Date()
    @State private var reminderError: String?
    @State private var showsPremium = false
    @State private var showsAppGuide = false
    @State private var confirmsReset = false
    @State private var ownerAccessTapCount = 0
    @State private var showsOwnerContentStudio = false
    @State private var premium = PremiumAccessService.shared
    @ObservedObject private var translations = TeachingTranslationStore.shared
    @ObservedObject private var speech = GermanSpeechService.shared

    private var teachingLanguage: TeachingLanguage { TeachingLanguage.resolve(teachingLanguageCode) }
    private var resetConfirmationTitle: String {
        translations.text(
            for: "Reset all learning progress?",
            language: teachingLanguage
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TeachingTextField(prompt: "Name", text: $learnerName)
                    Picker(selection: Binding(
                        get: { preferredLevel },
                        set: { value in
                            let level = CEFRLevel(rawValue: value) ?? .a1
                            guard PremiumAccessPolicy.canOpenLevel(level, isPremium: premium.isPremium) else {
                                showsPremium = true
                                return
                            }
                            preferredLevel = value
                        }
                    )) {
                        ForEach(CEFRLevel.allCases) { Text($0.rawValue).tag($0.rawValue) }
                    } label: {
                        TeachingText(english: "Current level")
                    }
                    Stepper(value: $dailyMinutes, in: 5...60, step: 5) {
                        TeachingText(english: "Daily goal: \(dailyMinutes) minutes")
                    }
                    Picker(selection: $selectedLearningWeakness) {
                        ForEach(SkillArea.allCases) { skill in
                            TeachingText(english: skill.learningFocusTitle)
                                .tag(skill.rawValue)
                        }
                    } label: {
                        TeachingText(english: "Learning focus")
                    }
                } header: {
                    TeachingText(english: "Learner")
                }

                Section {
                    Picker(selection: $teachingLanguageCode) {
                        ForEach(TeachingLanguage.allCases) { language in
                            Text(language.flaggedPickerName).tag(language.rawValue)
                        }
                    } label: {
                        Label(teachingLanguage.interfaceText(.teachingLanguage), systemImage: "globe")
                    }

                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "character.bubble.fill")
                            .foregroundStyle(CoachTheme.listening)
                        TeachingText(english: "Word meanings, grammar explanations, instructions, and feedback use this language. German examples stay German.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    TeachingLanguageStatusView()
                } header: {
                    Text(teachingLanguage.interfaceText(.teachingLanguage))
                }

                Section {
                    Toggle(isOn: $opensOnHomeScreen) {
                        TeachingText(english: "Open the app on Home")
                    }
                    TeachingText(english: "Turn this off to reopen the last tab you were using.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Button {
                        showsAppGuide = true
                    } label: {
                        TeachingLabel(english: "Show app guide", systemImage: "questionmark.circle.fill")
                    }
                    TeachingText(english: "A short guide explains Home, Learn, Practice, Review, and Progress.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } header: {
                    TeachingText(english: "Easy to use")
                }

                Section {
                    Toggle(isOn: $remindersEnabled) {
                        TeachingText(english: "Daily reminder")
                    }
                    if remindersEnabled {
                        DatePicker(selection: $reminderTime, displayedComponents: .hourAndMinute) {
                            TeachingText(english: "Time")
                        }
                    }
                    if let reminderError {
                        TeachingText(english: reminderError)
                            .foregroundStyle(CoachTheme.incorrect)
                    }
                } header: {
                    TeachingText(english: "Study reminder")
                }

                Section {
                    LabeledContent {
                        TeachingText(english: "Thorsten · Natural")
                    } label: {
                        TeachingText(english: "Voice")
                    }
                    LabeledContent {
                        TeachingText(
                            english: GermanSpeechService.shared.hasDynamicNeuralVoice
                                ? "All lessons and corrections"
                                : "\(GermanSpeechService.shared.bundledNeuralClipCount) offline clips"
                        )
                    } label: {
                        TeachingText(english: "Coverage")
                    }
                    TeachingLabel(
                        english: "Natural speech is generated privately on this device.",
                        systemImage: "waveform.and.person.filled"
                    )
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    Picker(
                        selection: Binding(
                            get: { speech.playbackSpeed },
                            set: { speech.setPlaybackSpeed($0) }
                        )
                    ) {
                        ForEach(GermanSpeechSpeed.allCases) { speed in
                            Text(speed.title).tag(speed)
                        }
                    } label: {
                        TeachingText(english: "Playback speed")
                    }
                    Button {
                        speech.toggle(
                            GermanSpeechService.previewText,
                            style: .model
                        )
                    } label: {
                        TeachingLabel(english: "Preview voice", systemImage: "speaker.wave.2.fill")
                    }
                } header: {
                    TeachingText(english: "German audio")
                }

                Section {
                    Button {
                        showsPremium = true
                    } label: {
                        HStack {
                            TeachingLabel(english: "Plans and purchases", systemImage: "crown.fill")
                            Spacer()
                            TeachingText(english: premium.accessBadgeTitle)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(premium.isPremium ? CoachTheme.correct : CoachTheme.accent)
                        }
                    }
                } header: {
                    TeachingText(english: "Premium")
                }

                Section {
                    NavigationLink {
                        OrganizationAccessView()
                    } label: {
                        TeachingLabel(english: "School or partner access", systemImage: "building.2.fill")
                    }
                    TeachingText(english: "Use this only when a participating school, employer, or support organization has arranged access for you.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } header: {
                    TeachingText(english: "Organization access")
                }

                Section {
                    TeachingButton("Take placement again") {
                        didCompletePlacement = false
                        dismiss()
                    }
                    TeachingButton("Reset progress", role: .destructive) {
                        confirmsReset = true
                    }
                } header: {
                    TeachingText(english: "Learning data")
                }

                Section {
                    TeachingLabel(
                        english: "Learning progress stays on this device and is never uploaded with curriculum updates.",
                        systemImage: "lock.shield.fill"
                    )
                    TeachingLabel(
                        english: "Verified curriculum updates may be downloaded from the secure content service.",
                        systemImage: "checkmark.icloud.fill"
                    )
                    TeachingLabel(
                        english: "Speech is processed by Apple's speech recognition service when you use the microphone.",
                        systemImage: "waveform.badge.mic"
                    )
                    TeachingLabel(
                        english: "Aggregate milestones such as lesson completion are counted locally. Answers, names, and transcripts are never included.",
                        systemImage: "chart.bar.doc.horizontal.fill"
                    )
                    TeachingLabel(
                        english: "The app contains no advertising or third-party tracking SDK.",
                        systemImage: "hand.raised.slash.fill"
                    )
                    Toggle(isOn: $sharesAnonymousImprovementData) {
                        TeachingText(english: "Share anonymous improvement data")
                    }
                    TeachingText(
                        english: "Off by default. When enabled, the app shares only aggregate milestone names and the app build with Deutsch Coach. It never sends a device ID, account, answer, transcript, or recording."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    Link(destination: URL(string: "https://example.invalid/privacy")!) {
                        TeachingLabel(english: "Read the privacy policy", systemImage: "doc.text.fill")
                    }
                } header: {
                    TeachingText(english: "Privacy")
                }

                Section {
                    Button {
                        ownerAccessTapCount += 1
                        if ownerAccessTapCount >= 7 {
                            ownerAccessTapCount = 0
                            showsOwnerContentStudio = true
                            CoachFeedback.success()
                        }
                    } label: {
                        LabeledContent {
                            Text(appVersion)
                        } label: {
                            TeachingText(english: "Version")
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Owner access")
                    LabeledContent {
                        Text("CEFR A1-B1")
                    } label: {
                        TeachingText(english: "Curriculum")
                    }
                    Link(destination: URL(string: "https://example.invalid/support")!) {
                        TeachingLabel(english: "Help and support", systemImage: "questionmark.circle.fill")
                    }
                } header: {
                    TeachingText(english: "About")
                }
            }
            .navigationTitle(teachingLanguage.interfaceText(.settings))
            .teachingLanguageSwitcher()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(teachingLanguage.interfaceText(.done)) { dismiss() }
                }
            }
            .onAppear {
                reminderTime = Calendar.current.date(from: DateComponents(hour: reminderHour, minute: reminderMinute)) ?? .now
            }
            .task(id: "\(teachingLanguage.rawValue)-reset-confirmation") {
                translations.request(
                    "Reset all learning progress?",
                    language: teachingLanguage
                )
            }
            .onChange(of: remindersEnabled) { _, enabled in
                Task { await updateReminder(enabled: enabled) }
            }
            .onChange(of: reminderTime) { _, date in
                let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                reminderHour = components.hour ?? 19
                reminderMinute = components.minute ?? 0
                if remindersEnabled { Task { await updateReminder(enabled: true) } }
            }
            .sheet(isPresented: $showsPremium) { PremiumView(entryPoint: .settings) }
            .sheet(isPresented: $showsAppGuide) { AppGuideSheet() }
            .navigationDestination(isPresented: $showsOwnerContentStudio) {
                AdminContentStudioView()
            }
            .confirmationDialog(resetConfirmationTitle, isPresented: $confirmsReset, titleVisibility: .visible) {
                TeachingButton("Reset progress", role: .destructive) { resetProgress() }
                TeachingButton("Cancel", role: .cancel) {}
            } message: {
                TeachingText(english: "Vocabulary and grammar content will remain, but lesson completion, review schedules, scores, and streaks will restart.")
            }
            .task(id: teachingLanguageCode) {
                translations.request("Reset all learning progress?", language: teachingLanguage)
            }
        }
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }

    @MainActor
    private func updateReminder(enabled: Bool) async {
        do {
            if enabled {
                try await StudyReminderService().scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
            } else {
                StudyReminderService().cancelReminder()
            }
            reminderError = nil
        } catch {
            remindersEnabled = false
            reminderError = error.localizedDescription
        }
    }

    private func resetProgress() {
        try? modelContext.delete(model: LearningActivity.self)
        try? modelContext.delete(model: LessonRecord.self)
        let reviews = (try? modelContext.fetch(FetchDescriptor<ReviewItem>())) ?? []
        for review in reviews {
            review.easeFactor = 2.5
            review.intervalDays = 0
            review.repetitions = 0
            review.dueDate = .now
            review.lastReviewedAt = nil
            review.lapseCount = 0
            review.isActive = false
            review.isMemorized = false
            review.isMarked = false
        }
        let progress = (try? modelContext.fetch(FetchDescriptor<UserProgress>())) ?? []
        for item in progress {
            item.grammarMastery = 0
            item.vocabularyRetention = 0
            item.speakingTrend = []
            item.listeningTrend = []
            item.writingTrend = []
            item.readingTrend = []
            item.streakDays = 0
            item.lastStudyDate = nil
            item.weakTopicIds = []
        }
        VocabularyDeckProgressStore.clear()
        try? modelContext.save()
    }
}

private struct AppGuideSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var didCompleteGuide = false

    var body: some View {
        FirstLaunchTutorialView(didCompleteTutorial: $didCompleteGuide)
            .onChange(of: didCompleteGuide) { _, didComplete in
                if didComplete {
                    dismiss()
                }
            }
    }
}

struct AdminContentStudioView: View {
    @StateObject private var manager = AdminContentManager.shared
    @StateObject private var liveContent = LiveContentService.shared
    @State private var statusMessage: String?

    private let dashboardURL = URL(
        string: "https://example.invalid"
    )!

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                ownerHeader

                Link(destination: dashboardURL) {
                    Label("Open secure web dashboard", systemImage: "arrow.up.right.square.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryCoachButton(tint: CoachTheme.primary))

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "person.badge.shield.checkmark.fill")
                        .foregroundStyle(CoachTheme.correct)
                    Text("Publishing is protected by ChatGPT sign-in and your one-time owner activation code.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let statusMessage {
                    Text(statusMessage)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(CoachTheme.incorrect)
                        .fixedSize(horizontal: false, vertical: true)
                }

                CoachSectionHeader(
                    title: "Published content",
                    subtitle: "The iPhone checks this live library whenever the app opens or returns"
                )

                ForEach(AdminContentManager.supportedFiles) { file in
                    contentFileRow(file)
                }
            }
            .padding()
            .padding(.bottom, 24)
        }
        .navigationTitle("Content Studio")
        .navigationBarTitleDisplayMode(.inline)
        .coachBackground()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await refreshStatus() }
                } label: {
                    if liveContent.isRefreshing {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .accessibilityLabel("Refresh live content status")
                .disabled(liveContent.isRefreshing)
            }
        }
        .task {
            await refreshStatus()
        }
    }

    private var ownerHeader: some View {
        CoachCard(tint: CoachTheme.reward) {
            HStack(alignment: .top, spacing: 13) {
                CoachIconTile(icon: "lock.shield.fill", tint: CoachTheme.reward, size: 52)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Owner Content Studio")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                    Text("Publish course corrections and new lessons from your web dashboard. Learners keep their progress, and the last verified course works offline.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func contentFileRow(_ file: AdminManagedContentFile) -> some View {
        let isPublished = liveContent.publishedVersions[file.fileName] != nil
        let hasVerifiedCache = manager.hasOverride(for: file.fileName)

        return CoachCard(padding: 13, tint: isPublished ? CoachTheme.accent : CoachTheme.listening) {
            HStack(alignment: .top, spacing: 11) {
                CoachIconTile(
                    icon: isPublished ? "checkmark.icloud.fill" : "shippingbox.fill",
                    tint: isPublished ? CoachTheme.accent : CoachTheme.listening,
                    size: 42
                )
                VStack(alignment: .leading, spacing: 3) {
                    Text(file.title)
                        .font(.headline)
                    Text("\(file.fileName).json")
                        .font(.caption.monospaced().weight(.semibold))
                        .foregroundStyle(isPublished ? CoachTheme.accent : CoachTheme.listening)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(file.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 4)
                Text(isPublished ? "LIVE" : (hasVerifiedCache ? "CACHED" : "BUNDLED"))
                    .font(.caption2.weight(.black))
                    .foregroundStyle(isPublished ? CoachTheme.accent : CoachTheme.listening)
            }
        }
        .id("\(file.id)-\(manager.revision)-\(liveContent.publishedVersions[file.fileName] ?? 0)")
    }

    @MainActor
    private func refreshStatus() async {
        do {
            _ = try await liveContent.refreshPublishedContent()
            statusMessage = nil
        } catch {
            statusMessage = "The live library could not be checked. The last verified course remains available."
        }
    }
}
