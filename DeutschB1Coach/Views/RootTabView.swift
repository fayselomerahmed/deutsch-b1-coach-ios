import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("didCompletePlacement") private var didCompletePlacement = false
    @AppStorage("selectedTab") private var selectedTab = 0
    @AppStorage("opensOnHomeScreen") private var opensOnHomeScreen = true
    @AppStorage(TeachingLanguage.storageKey) private var teachingLanguageCode = TeachingLanguage.defaultLanguage.rawValue
    @AppStorage(FirstLaunchFlow.didChooseLanguageStorageKey) private var didChooseTeachingLanguage = false
    @AppStorage(FirstLaunchFlow.didCompleteTutorialStorageKey) private var didCompleteFirstLaunchTutorial = false
    @AppStorage("selectedLearningWeakness") private var selectedLearningWeakness = ""
    @AppStorage("preferredLevel") private var preferredLevel = CEFRLevel.a1.rawValue
    @AppStorage("placementRecommendedLevel") private var placementRecommendedLevel = ""
    @AppStorage("didChooseLearningWeakness.v1") private var didChooseLearningWeakness = false
    @State private var seedError: String?
    @State private var isPreparingContent = true
    @State private var isApplyingLiveContent = false
    @State private var preparationPhase: ContentPreparationPhase = .checking
    @State private var premium = PremiumAccessService.shared
    @State private var appliedLaunchTab = false

    private var teachingLanguage: TeachingLanguage { TeachingLanguage.resolve(teachingLanguageCode) }

    private var contentTransition: AnyTransition {
        reduceMotion ? .identity : .opacity.combined(with: .offset(y: 4))
    }

    var body: some View {
        Group {
#if DEBUG
            if visualQARoute == "vocabulary" {
                NavigationStack {
                    VocabularyFlashcardsView(level: .a1, theme: "Essen")
                }
            } else if visualQARoute == "vocabulary-game" {
                NavigationStack {
                    VocabularyMatchGameView(level: .a1)
                }
            } else if visualQARoute == "grammar-builder" {
                grammarBuilderQA
            } else if visualQARoute == "coach-avatar" {
                NavigationStack {
                    CoachAvatarShowcaseView()
                }
            } else if visualQARoute == "orientation" {
                NavigationStack {
                    ScrollView {
                        OrientationQuestionCatalogOverview(previewState: .berlin)
                            .environment(\.locale, Locale(identifier: "de_DE"))
                            .padding()
                    }
                    .navigationTitle("Orientierung")
                    .coachBackground()
                }
            } else if visualQARoute == "orientation-catalog" {
                OrientationQuestionCatalogQAView()
            } else if visualQARoute == "orientation-mock" {
                NavigationStack {
                    OrientationMockExamView(state: .badenWuerttemberg, startsImmediately: true)
                }
            } else if visualQARoute == "settings" {
                SettingsView()
            } else if visualQARoute == "lesson-clarity" {
                lessonClarityQA
            } else if visualQARoute == "speaking-correction" {
                speakingCorrectionQA
            } else if visualQARoute == "role-play" {
                rolePlayQA
            } else if visualQARoute == "role-play-library" {
                NavigationStack {
                    PracticalMissionsView(level: .b1)
                }
            } else if visualQARoute == "phrasebook" {
                NavigationStack {
                    EverydayPhrasebookView(focusLevel: .b1)
                }
            } else if visualQARoute == "phrasebook-category" {
                phrasebookCategoryQA
            } else if visualQARoute == "answer-feedback" {
                answerFeedbackQA
            } else if visualQARoute == "onboarding" {
                OnboardingPlacementView(didCompletePlacement: .constant(false))
            } else if visualQARoute == "language-choice" {
                FirstLaunchLanguageView(
                    languageCode: .constant(TeachingLanguage.english.rawValue),
                    didChooseLanguage: .constant(false)
                )
            } else if visualQARoute == "tutorial" {
                FirstLaunchTutorialView(didCompleteTutorial: .constant(false))
            } else if visualQARoute == "learn-books" {
                LessonsView()
            } else if visualQARoute == "home" {
                DashboardView()
            } else if visualQARoute == "practice" {
                PracticeView()
            } else if visualQARoute == "progress" {
                ProgressStatsView()
            } else if visualQARoute == "exam" {
                NavigationStack {
                    ExamPrepView()
                }
            } else if visualQARoute == "level-book" {
                levelBookQA
            } else if visualQARoute == "journey-loader" {
                CourseJourneyLoadingView(phase: visualQAPreparationPhase)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(CoachTheme.pageGradient.ignoresSafeArea())
            } else {
                appContent
            }
#else
            appContent
#endif
        }
        .environment(\.defaultMinListRowHeight, 50)
        .background(alignment: .topLeading) {
            TeachingTranslationHost()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            GermanSpeechPlaybackBar()
        }
        .transaction { transaction in
            if reduceMotion {
                transaction.animation = nil
                transaction.disablesAnimations = true
            }
        }
        .task(id: didChooseTeachingLanguage) {
            if didCompletePlacement && !didChooseTeachingLanguage {
                didChooseTeachingLanguage = true
            }
            if didCompletePlacement && !didCompleteFirstLaunchTutorial {
                didCompleteFirstLaunchTutorial = true
            }
            guard didChooseTeachingLanguage || didCompletePlacement else { return }
            guard isPreparingContent else { return }
            await Task.yield()
            do {
                try await ContentLoader.shared.seedIfNeeded(modelContext: modelContext) { phase in
                    if reduceMotion {
                        preparationPhase = phase
                    } else {
                        withAnimation(CoachMotion.standard) {
                            preparationPhase = phase
                        }
                    }
                }
                seedError = nil
            } catch {
                seedError = error.localizedDescription
            }
            isPreparingContent = false
            await refreshLiveContent()
        }
        .task {
            if didCompletePlacement && placementRecommendedLevel.isEmpty {
                placementRecommendedLevel = preferredLevel
            }
            await PremiumAccessService.shared.refreshEntitlements()
        }
        .task(id: scenePhase) {
            guard scenePhase == .active else { return }
            await premium.monitorManagedAccess()
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active, !isPreparingContent else { return }
            Task {
                await refreshLiveContent()
            }
        }
        .onChange(of: premium.isPremium) { wasPremium, isPremium in
            if wasPremium && !isPremium {
                selectedTab = 0
            }
        }
    }

    @MainActor
    private func refreshLiveContent() async {
        guard !isApplyingLiveContent else { return }
        isApplyingLiveContent = true
        defer { isApplyingLiveContent = false }

        do {
            let changes = try await LiveContentService.shared.refreshPublishedContent()
            guard changes > 0 else { return }
            try await ContentLoader.shared.seedIfNeeded(modelContext: modelContext)
            seedError = nil
        } catch {
            // Network or backend failures never replace the last verified local course.
        }
    }

#if DEBUG
    private var visualQARoute: String? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-visualQARoute"), arguments.indices.contains(index + 1) else {
            return nil
        }
        return arguments[index + 1]
    }

    private var visualQALessonStep: Int {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-visualQALessonStep"),
              arguments.indices.contains(index + 1)
        else { return 2 }
        return Int(arguments[index + 1]) ?? 2
    }

    private var visualQAPreparationPhase: ContentPreparationPhase {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-visualQAPreparationPhase"),
              arguments.indices.contains(index + 1),
              let rawValue = Int(arguments[index + 1]),
              let phase = ContentPreparationPhase(rawValue: rawValue)
        else { return .vocabularyA2 }
        return phase
    }

    private var speakingCorrectionQA: some View {
        let prompt = SpeechPrompt(
            expectedAnswer: "Ich möchte einen Termin vereinbaren, weil ich starke Rückenschmerzen habe.",
            requiredPhrases: ["einen Termin vereinbaren", "weil ich", "Rückenschmerzen habe"],
            grammarMarkers: ["möchte", "weil"],
            targetDuration: 8...18
        )
        let transcript = "Ich möchte ein Termin weil ich starke Rückenschmerzen"
        let correction = SpeechScorer().score(
            recognizedText: transcript,
            prompt: prompt,
            duration: 7
        ).correction

        return NavigationStack {
            ScrollView {
                SpeakingCorrectionCoach(transcript: transcript, correction: correction)
                    .padding()
            }
            .teachingNavigationTitle("Speaking feedback")
            .coachBackground()
        }
    }

    @ViewBuilder private var rolePlayQA: some View {
        if let mission = try? ContentLoader.shared.loadPracticalMissions()
            .first(where: { $0.id == "b1-neighbor" }) {
            NavigationStack {
                PracticalMissionDetailView(mission: mission)
            }
        } else {
            CoachLoadingState(
                title: "Preparing role-play preview",
                message: "The real-life conversation will open when its content is ready."
            )
        }
    }

    @ViewBuilder private var phrasebookCategoryQA: some View {
        if let category = try? ContentLoader.shared.loadEverydayPhrasebook()
            .first(where: { $0.id == "appointments-services" }) {
            NavigationStack {
                EverydayPhraseListView(
                    title: category.title,
                    subtitle: category.subtitle,
                    icon: category.icon,
                    phrases: category.phrases,
                    tint: CoachTheme.reward
                )
            }
        } else {
            CoachLoadingState(
                title: "Preparing phrase preview",
                message: "The everyday phrase category will open when its content is ready."
            )
        }
    }

    private var answerFeedbackQA: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    CoachFeedbackPanel(
                        isCorrect: true,
                        title: "Correct",
                        message: "You connected the answer to the right meaning."
                    )
                    CoachFeedbackPanel(
                        isCorrect: false,
                        title: "Try once more",
                        message: "Use the highlighted clue and compare the word order."
                    )
                }
                .padding()
            }
            .teachingNavigationTitle("Answer feedback")
            .coachBackground()
        }
    }

    private var grammarBuilderQA: some View {
        let topic = GrammarTopic(
            id: "a2-causal-connectors",
            level: .a2,
            order: 1,
            title: "Reasons with weil",
            explanation: "Weil introduces a reason and sends the conjugated verb to the end of its clause.",
            examples: [
                ExampleSentence(
                    german: "Ich bleibe zu Hause, weil ich krank bin.",
                    english: "I stay at home because I am ill."
                )
            ],
            commonMistakes: [],
            practice: []
        )

        return NavigationStack {
            ScrollView {
                GrammarStructureBuilder(topic: topic)
                    .padding()
            }
            .teachingNavigationTitle("Sentence Builder")
            .navigationBarTitleDisplayMode(.inline)
            .coachBackground()
        }
    }

    @ViewBuilder private var lessonClarityQA: some View {
        if let lesson = try? ContentLoader.shared.loadLessons().first {
            NavigationStack {
                LessonDetailView(lesson: lesson, initialStep: visualQALessonStep)
            }
        } else {
            CoachLoadingState(
                title: "Preparing lesson preview",
                message: "The clarity review will open when the lesson is ready."
            )
        }
    }

    @ViewBuilder private var levelBookQA: some View {
        if let lessons = try? ContentLoader.shared.loadLessons().filter({ $0.level == .a1 }) {
            NavigationStack {
                LevelBookView(level: .a1, lessons: lessons)
            }
        } else {
            CoachLoadingState(
                title: "Preparing course book",
                message: "The A1 course book will open when its lessons are ready."
            )
        }
    }
#endif

    private var appContent: some View {
        ZStack {
            appContentPhase
        }
        .animation(reduceMotion ? nil : CoachMotion.standard, value: isPreparingContent)
        .animation(reduceMotion ? nil : CoachMotion.standard, value: seedError)
        .animation(reduceMotion ? nil : CoachMotion.standard, value: didCompletePlacement)
        .animation(reduceMotion ? nil : CoachMotion.standard, value: didCompleteFirstLaunchTutorial)
        .animation(reduceMotion ? nil : CoachMotion.standard, value: didChooseLearningWeakness)
    }

    @ViewBuilder private var appContentPhase: some View {
        if FirstLaunchFlow.requiresLanguageSelection(
            didChooseLanguage: didChooseTeachingLanguage,
            didCompleteOnboarding: didCompletePlacement
        ) {
            FirstLaunchLanguageView(
                languageCode: $teachingLanguageCode,
                didChooseLanguage: $didChooseTeachingLanguage
            )
            .transition(contentTransition)
        } else if FirstLaunchFlow.requiresTutorial(
            didChooseLanguage: didChooseTeachingLanguage,
            didCompleteTutorial: didCompleteFirstLaunchTutorial,
            didCompleteOnboarding: didCompletePlacement
        ) {
            FirstLaunchTutorialView(didCompleteTutorial: $didCompleteFirstLaunchTutorial)
                .transition(contentTransition)
        } else if isPreparingContent {
            CourseJourneyLoadingView(phase: preparationPhase)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(CoachTheme.pageGradient.ignoresSafeArea())
            .transition(contentTransition)
        } else if let seedError {
            CoachCard {
                CoachEmptyState(
                    icon: "exclamationmark.triangle.fill",
                    title: "Content could not load",
                    message: seedError
                )
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(CoachTheme.pageGradient.ignoresSafeArea())
            .transition(contentTransition)
        } else if didCompletePlacement && !didChooseLearningWeakness {
            LearningWeaknessSelectionView(
                initialSkill: SkillArea(rawValue: selectedLearningWeakness)
            ) { skill in
                selectedLearningWeakness = skill.rawValue
                didChooseLearningWeakness = true
            }
            .transition(contentTransition)
        } else if didCompletePlacement {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .mainFeatureTutorial(.home)
                    .tabItem { Label(teachingLanguage.interfaceText(.home), systemImage: "house") }
                    .tag(0)
                LessonsView()
                    .mainFeatureTutorial(.learn)
                    .tabItem { Label(teachingLanguage.interfaceText(.learn), systemImage: "book") }
                    .tag(1)
                PracticeView()
                    .mainFeatureTutorial(.practice)
                    .tabItem { Label(teachingLanguage.interfaceText(.practice), systemImage: "mic") }
                    .tag(2)
                ReviewView()
                    .mainFeatureTutorial(.review)
                    .tabItem { Label(teachingLanguage.interfaceText(.review), systemImage: "rectangle.stack") }
                    .tag(3)
                ProgressStatsView()
                    .mainFeatureTutorial(.progress)
                    .tabItem { Label(teachingLanguage.interfaceText(.progress), systemImage: "chart.line.uptrend.xyaxis") }
                    .tag(4)
            }
            .id(premium.accessRevision)
            .tint(CoachTheme.primary)
            .onAppear {
                guard !appliedLaunchTab else { return }
                appliedLaunchTab = true
                if opensOnHomeScreen {
                    selectedTab = 0
                }
            }
            .transition(contentTransition)
        } else {
            OnboardingPlacementView(didCompletePlacement: $didCompletePlacement)
                .transition(contentTransition)
        }
    }

}
