// swift-tools-version: 5.9
import PackageDescription

// Fast, host-runnable checks for pure learning logic; the iOS suite remains in Xcode.
let package = Package(
    name: "DeutschCoachCore",
    platforms: [.macOS(.v13)],
    targets: [
        .target(name: "DeutschB1Coach", path: "DeutschB1Coach/Services", exclude: [
            "ContentLoader.swift", "CurriculumFactory.swift", "CurriculumProgression.swift",
            "ExamReadiness.swift", "FluencyTaskCatalog.swift", "GermanSpeechService.swift",
            "IntegrationCourseCurriculum.swift", "OnDeviceGermanVoiceRenderer.swift",
            "OrientationMockExam.swift", "OrientationQuestionRepository.swift", "PlacementEngine.swift",
            "PremiumAccessService.swift", "ProductExperienceService.swift", "ProgressService.swift",
            "SimplifiedExplanationCatalog.swift", "SpeechRecognitionService.swift", "SpeechScorer.swift",
            "StudyReminderService.swift", "VocabularyStudyProgress.swift"
        ], sources: [
            "SM2Scheduler.swift", "FreeResponseEvaluator.swift", "LiveContentConfiguration.swift",
            "ContentRevisionCache.swift"
        ]),
        .testTarget(name: "DeutschCoachCoreTests", dependencies: ["DeutschB1Coach"],
                    path: "DeutschB1Coach/Tests", exclude: ["CurriculumIntegrityTests.swift", "SpeechScorerTests.swift"])
    ]
)
