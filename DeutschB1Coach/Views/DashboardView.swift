import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AppStorage("learnerName") private var learnerName = ""
    @AppStorage("preferredLevel") private var preferredLevel = CEFRLevel.a1.rawValue
    @AppStorage("placementRecommendedLevel") private var placementRecommendedLevel = ""
    @AppStorage(FreeExperienceStore.speakingSampleCompletedKey) private var speakingSampleCompleted = false
    @AppStorage(FreeExperienceStore.readinessCheckCompletedKey) private var readinessCheckCompleted = false
    @AppStorage("selectedTab") private var selectedTab = 0
    @AppStorage(ExamTargetDate.storageKey) private var examTargetDateInterval = 0.0
    @AppStorage(TeachingLanguage.storageKey) private var teachingLanguageCode = TeachingLanguage.defaultLanguage.rawValue
    @Query private var progress: [UserProgress]
    @Query(sort: \ReviewItem.dueDate) private var reviewItems: [ReviewItem]
    @Query private var lessonRecords: [LessonRecord]
    @Query private var activities: [LearningActivity]
    @State private var lessons: [CompleteLessonDTO] = []
    @State private var showsPremium = false
    @State private var premiumEntryPoint = PremiumEntryPoint.direct
    @State private var showsSettings = false
    @State private var showsMorePractice = false
    @State private var showsMoreHome = false
    @State private var selectedHomeCategory = HomeCategory.practice
    @State private var premium = PremiumAccessService.shared

    private var activeLevel: CEFRLevel {
        if premium.isPremium {
            return CEFRLevel(rawValue: preferredLevel) ?? .a1
        }
        return CEFRLevel(rawValue: placementRecommendedLevel)
            ?? CEFRLevel(rawValue: preferredLevel)
            ?? .a1
    }

    private var teachingLanguage: TeachingLanguage {
        TeachingLanguage.resolve(teachingLanguageCode)
    }

    private var levelLessons: [CompleteLessonDTO] {
        lessons.filter { $0.level == activeLevel }.sorted { $0.order < $1.order }
    }

    private var nextLesson: CompleteLessonDTO? {
        levelLessons.first { lesson in
            lessonRecords.first { $0.lessonId == lesson.id }?.isCompleted != true
        }
    }

    private var dueCount: Int {
        reviewItems.filter { $0.isActive && $0.dueDate <= .now }.count
    }

    private var totalXP: Int {
        activities.reduce(0) { $0 + $1.xp }
    }

    private var streak: Int {
        progress.map(\.streakDays).max() ?? 0
    }

    private var completedAtLevel: Int {
        lessonRecords.filter { $0.level == activeLevel.rawValue && $0.isCompleted }.count
    }

    private var activeProgress: UserProgress? {
        progress.first { $0.level == activeLevel.rawValue }
    }

    private var studiedLessonToday: Bool {
        lessonRecords.contains { record in
            record.completedAt.map(Calendar.current.isDateInToday) == true
        }
    }

    private var spokeToday: Bool {
        activities.contains {
            $0.skill == SkillArea.speaking.rawValue && Calendar.current.isDateInToday($0.createdAt)
        }
    }

    private var reviewedToday: Bool {
        activities.contains {
            [SkillArea.vocabulary.rawValue, SkillArea.grammar.rawValue].contains($0.skill) &&
            Calendar.current.isDateInToday($0.createdAt)
        }
    }

    private var recallGoalComplete: Bool {
        reviewedToday || dueCount == 0
    }

    private var questWins: Int {
        [studiedLessonToday, spokeToday, recallGoalComplete].filter { $0 }.count
    }

    private var examReadiness: ExamReadinessSnapshot {
        ExamReadinessSnapshot(activities: activities)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    nextLessonSection.coachReveal(index: 0)
                    focusSessionCard.coachReveal(index: 1)
                    orientationCourseCard.coachReveal(index: 2)
                    homeExploreSection.coachReveal(index: 3)
                }
                .padding(.horizontal)
                .padding(.top, 4)
                .padding(.bottom, 24)
            }
            .navigationTitle(teachingLanguage.interfaceText(.home))
            .teachingLanguageSwitcher()
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { presentPremium(.direct) } label: {
                        Image(systemName: "crown.fill")
                    }
                    .foregroundStyle(CoachTheme.accent)
                    .teachingAccessibilityLabel("Premium")

                    Button { showsSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .teachingAccessibilityLabel("Settings")
                }
            }
            .coachBackground()
            .sheet(isPresented: $showsPremium) { PremiumView(entryPoint: premiumEntryPoint) }
            .sheet(isPresented: $showsSettings) { SettingsView() }
            .task {
                lessons = (try? ContentLoader.shared.loadLessons()) ?? []
            }
        }
    }

    private var homeCategoryPicker: some View {
        CoachCategoryPicker(
            title: nil,
            selection: $selectedHomeCategory,
            options: HomeCategory.allCases.map {
                CoachCategoryOption(
                    value: $0,
                    title: $0.rawValue,
                    icon: $0.icon,
                    tint: $0.tint
                )
            }
        )
    }

    private var homeExploreSection: some View {
        DisclosureGroup(isExpanded: $showsMoreHome) {
            VStack(alignment: .leading, spacing: 14) {
                homeCategoryPicker
                homeCategoryContent
            }
            .padding(.top, 12)
        } label: {
            HStack(spacing: 11) {
                CoachIconTile(icon: "square.grid.2x2.fill", tint: CoachTheme.listening, size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    TeachingText(english: "More for you")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    TeachingText(english: "Practice, progress, and exam tools")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .tint(CoachTheme.listening)
        .padding(13)
        .background(CoachTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous).stroke(CoachTheme.stroke))
        .onChange(of: showsMoreHome) { _, _ in CoachFeedback.selection() }
    }

    @ViewBuilder private var homeCategoryContent: some View {
        Group {
            switch selectedHomeCategory {
            case .practice:
                skillStudio
            case .progress:
                levelSnapshot
            case .exam:
                examCoach
            }
        }
        .id(selectedHomeCategory)
        .transition(.opacity)
        .animation(CoachMotion.quick, value: selectedHomeCategory)
    }

    private var focusSessionCard: some View {
        NavigationLink {
            if premium.isPremium || activeLevel == .a1 {
                DailyFocusView(level: activeLevel)
            } else {
                PremiumLockedView(feature: .advancedPractice)
            }
        } label: {
            CoachCard(padding: 14, tint: focusTint) {
                VStack(alignment: .leading, spacing: 9) {
                    HStack(spacing: 10) {
                        CoachMascot(mood: questWins == 3 ? .achievement : .welcome, size: 44)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 2) {
                            TeachingText(english: personalGreeting)
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .foregroundStyle(CoachTheme.ink)
                                .fixedSize(horizontal: false, vertical: true)
                            TeachingText(english: "Today's plan")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(focusTint)
                        }
                        Spacer(minLength: 4)
                        if !premium.isPremium && activeLevel != .a1 {
                            PremiumLockBadge()
                        }
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(focusTint)
                            .accessibilityHidden(true)
                    }

                    TeachingText(english: questWins == 3 ? "Daily goal complete. Excellent work!" : focusNextText)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    CoachRoadProgress(progress: Double(questWins) / 3, tint: focusTint)

                    HStack(spacing: 8) {
                        focusStatusRow
                        Spacer(minLength: 8)
                        SkillChip(title: activeLevel.rawValue, color: focusTint)
                    }
                }
            }
        }
        .buttonStyle(CoachCardButtonStyle())
    }

    private var orientationCourseCard: some View {
        NavigationLink {
            OrientationQuestionCatalogOverview()
        } label: {
            CoachCard(padding: 14, tint: CoachTheme.reward) {
                HStack(alignment: .center, spacing: 12) {
                    CoachIconTile(
                        icon: "building.columns.fill",
                        tint: CoachTheme.reward,
                        size: 48
                    )

                    VStack(alignment: .leading, spacing: 3) {
                        TeachingText(english: "Orientation course")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        TeachingText(english: "Germany: 300 questions + 10 for your federal state")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        TeachingText(english: "Question catalogues and mock test")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CoachTheme.reward)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 4)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CoachTheme.reward)
                        .accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(CoachCardButtonStyle())
        .teachingAccessibilityLabel("Orientation course. 300 questions and 10 questions for your federal state.")
    }

    private var focusStatusRow: some View {
        HStack(spacing: 8) {
            focusStatus(icon: "book.fill", complete: studiedLessonToday, tint: CoachTheme.primary)
            focusStatus(icon: "mic.fill", complete: spokeToday, tint: CoachTheme.speaking)
            focusStatus(icon: "rectangle.stack.fill", complete: recallGoalComplete, tint: CoachTheme.accent)
            Text("\(questWins)/3")
                .font(.caption.monospacedDigit().weight(.bold))
                .foregroundStyle(focusTint)
                .contentTransition(.numericText())
        }
    }

    @ViewBuilder private var nextLessonSection: some View {
        if let lesson = nextLesson {
            NavigationLink {
                if PremiumAccessPolicy.canOpenLesson(
                    lesson,
                    preferredLevel: activeLevel,
                    isPremium: premium.isPremium
                ) {
                    LessonDetailView(lesson: lesson)
                } else {
                    PremiumLockedView(feature: .completeCourse)
                }
            } label: {
                CoachSpotlightCard(tint: CoachTheme.primary, companion: CoachTheme.listening) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .center, spacing: 8) {
                            CoachSpotlightBadge(title: "Next on your path", icon: "map.fill")
                            CoachSpotlightBadge(title: lesson.level.rawValue)
                            Spacer(minLength: 6)
                            if !PremiumAccessPolicy.canOpenLesson(
                                lesson,
                                preferredLevel: activeLevel,
                                isPremium: premium.isPremium
                            ) {
                                PremiumLockBadge()
                            }
                        }

                        ViewThatFits(in: .horizontal) {
                            HStack(alignment: .center, spacing: 15) {
                                nextLessonArtwork(lesson)
                                nextLessonHeroIdentity(lesson)
                            }
                            VStack(alignment: .leading, spacing: 12) {
                                nextLessonArtwork(lesson)
                                nextLessonHeroIdentity(lesson)
                            }
                        }

                        CoachSpotlightProgress(progress: courseProgress)

                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: 10) {
                                nextLessonPositionLabel(lesson)
                                Spacer(minLength: 8)
                                nextLessonAction
                            }
                            VStack(alignment: .leading, spacing: 10) {
                                nextLessonPositionLabel(lesson)
                                nextLessonAction
                            }
                        }
                    }
                }
            }
            .buttonStyle(CoachCardButtonStyle())
        } else {
            CoachCard(tint: CoachTheme.correct) {
                CoachEmptyState(
                    icon: "checkmark.seal.fill",
                    title: "\(activeLevel.rawValue) path complete",
                    message: activeLevel == .b1 ? "Keep your skills sharp in Practice and try a full mock exam." : "Choose the next level in Settings when you are ready.",
                    tint: CoachTheme.correct
                )
            }
        }
    }

    private func nextLessonArtwork(_ lesson: CompleteLessonDTO) -> some View {
        LessonMemoryVisual(lesson: lesson)
            .frame(width: 92, height: 92)
            .clipShape(RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                    .stroke(Color.white.opacity(colorScheme == .dark ? 0.30 : 0.78), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.16), radius: 7, y: 4)
            .accessibilityHidden(true)
    }

    private func nextLessonHeroIdentity(_ lesson: CompleteLessonDTO) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(lesson.title)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            TeachingText(english: lesson.scenario)
                .font(.callout.weight(.medium))
                .foregroundStyle(.white.opacity(0.88))
                .multilineTextAlignment(.leading)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 : 3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func nextLessonPositionLabel(_ lesson: CompleteLessonDTO) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "book.pages.fill")
                .accessibilityHidden(true)
            TeachingText(english: "Lesson \(nextLessonPosition(lesson)) of \(levelLessons.count)")
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.footnote.weight(.semibold).monospacedDigit())
        .foregroundStyle(.white.opacity(0.86))
    }

    private var nextLessonAction: some View {
        HStack(spacing: 7) {
            Image(systemName: "play.fill")
                .accessibilityHidden(true)
            TeachingText(english: "Continue")
                .fixedSize(horizontal: false, vertical: true)
            Image(systemName: "arrow.right")
                .accessibilityHidden(true)
        }
        .font(.system(.callout, design: .rounded, weight: .bold))
        .foregroundStyle(CoachTheme.primary)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.96), in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.50), lineWidth: 1))
        .shadow(color: .black.opacity(0.10), radius: 4, y: 2)
    }

    private var courseProgress: Double {
        guard !levelLessons.isEmpty else { return 0 }
        return Double(completedAtLevel) / Double(levelLessons.count)
    }

    private func nextLessonPosition(_ lesson: CompleteLessonDTO) -> Int {
        (levelLessons.firstIndex(where: { $0.id == lesson.id }) ?? 0) + 1
    }

    private var skillStudio: some View {
        VStack(alignment: .leading, spacing: 10) {
            CoachSectionHeader(title: "Recommended practice")
            practiceLaunch(recommendedPractice, featured: true)

            DisclosureGroup(isExpanded: $showsMorePractice) {
                VStack(spacing: 7) {
                    ForEach(DashboardPracticeMode.allCases.filter { $0 != recommendedPractice }) { mode in
                        practiceLaunch(mode, featured: false)
                    }
                }
                .padding(.top, 9)
            } label: {
                TeachingLabel(english: "More practice", systemImage: "square.grid.2x2")
                    .font(.callout.weight(.semibold))
            }
            .tint(CoachTheme.primary)
            .padding(12)
            .background(CoachTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
            .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(CoachTheme.stroke))
            .onChange(of: showsMorePractice) { _, _ in
                CoachFeedback.selection()
            }
        }
    }

    private var levelSnapshot: some View {
        VStack(alignment: .leading, spacing: 11) {
            CoachSectionHeader(title: "\(activeLevel.rawValue) snapshot", subtitle: "Your course, recall, and consistency")
            CoachCard(tint: CoachTheme.listening) {
                VStack(alignment: .leading, spacing: 15) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 10) {
                        CoachMetric(value: "\(completedAtLevel)/\(levelLessons.count)", label: "lessons", icon: "book.fill", tint: CoachTheme.primary)
                        CoachMetric(value: "\(streak)d", label: "streak", icon: "flame.fill", tint: CoachTheme.accent)
                        CoachMetric(value: "\(totalXP)", label: "total XP", icon: "bolt.fill", tint: CoachTheme.listening)
                    }

                    Divider()

                    masteryLine("Grammar", value: activeProgress?.grammarMastery ?? 0, tint: CoachTheme.primary)
                    masteryLine("Vocabulary", value: activeProgress?.vocabularyRetention ?? 0, tint: CoachTheme.accent)
                }
            }
        }
    }

    private var examCoach: some View {
        NavigationLink {
            if premium.isPremium {
                ExamPrepView()
            } else if !readinessCheckCompleted {
                QuizView(level: .b1, sessionMode: .readinessPreview)
            } else {
                PremiumLockedView(feature: .exam)
            }
        } label: {
            CoachCard(tint: CoachTheme.listening) {
                HStack(spacing: 14) {
                    CoachIconTile(icon: "checkmark.seal.fill", tint: CoachTheme.listening, size: 50)
                    VStack(alignment: .leading, spacing: 4) {
                        TeachingText(english: "B1 Exam Coach")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.primary)
                        TeachingText(english: examCoachDetail)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer(minLength: 4)
                    if !premium.isPremium && readinessCheckCompleted {
                        PremiumLockBadge()
                    } else if !premium.isPremium {
                        SkillChip(title: "FREE CHECK", color: CoachTheme.correct)
                    }
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("\(examReadiness.passedSectionCount)/4")
                            .font(.system(.headline, design: .rounded, weight: .bold).monospacedDigit())
                            .foregroundStyle(examReadiness.isPracticeReady ? CoachTheme.correct : CoachTheme.listening)
                        TeachingText(english: "ready")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .buttonStyle(CoachCardButtonStyle())
    }

    private var examCoachDetail: String {
        if examReadiness.isPracticeReady {
            return examCountdown.map { "Checkpoint reached. \($0)" } ?? "All four skills meet the practice target."
        }
        if examReadiness.totalAttemptCount == 0 {
            return "Take your first timed section and get a personal readiness plan."
        }
        let next = "Next focus: \(examReadiness.nextSection.rawValue)."
        return examCountdown.map { "\(next) \($0)" } ?? next
    }

    private var examCountdown: String? {
        guard let days = ExamTargetDate.daysRemaining(interval: examTargetDateInterval) else { return nil }
        switch days {
        case ..<0: return "Update your exam date."
        case 0: return "Exam today."
        case 1: return "1 day remains."
        default: return "\(days) days remain."
        }
    }

    private func focusStatus(icon: String, complete: Bool, tint: Color) -> some View {
        Image(systemName: complete ? "checkmark" : icon)
            .font(.caption2.weight(.bold))
            .foregroundStyle(complete ? .white : tint)
            .frame(width: 25, height: 25)
            .background(complete ? CoachTheme.correct : tint.opacity(0.12), in: Circle())
            .teachingAccessibilityLabel(complete ? "Complete" : "Not complete")
    }

    private var focusTint: Color {
        questWins == 3 ? CoachTheme.correct : dueCount > 0 ? CoachTheme.accent : CoachTheme.primary
    }

    private var focusNextText: String {
        if dueCount > 0 { return "Start with \(dueCount) review card\(dueCount == 1 ? "" : "s")" }
        if !studiedLessonToday { return "Continue your next \(activeLevel.rawValue) lesson" }
        if !spokeToday { return "Build confidence with one spoken answer" }
        return "Choose a short session that fits your time"
    }

    private var recommendedPractice: DashboardPracticeMode {
        if dueCount > 0 { return .review }
        if !premium.isPremium && !speakingSampleCompleted { return .speaking }
        if !premium.isPremium && !readinessCheckCompleted { return .quiz }
        if !premium.isPremium { return .review }
        if !spokeToday { return .speaking }
        return .listening
    }

    @ViewBuilder private func practiceLaunch(_ mode: DashboardPracticeMode, featured: Bool) -> some View {
        if mode == .review {
            Button {
                CoachFeedback.selection()
                selectedTab = 3
            } label: {
                practiceLaunchLabel(mode, featured: featured)
            }
            .buttonStyle(CoachCardButtonStyle())
        } else if isPracticeLocked(mode) {
            Button {
                CoachFeedback.selection()
                presentPremium(entryPoint(for: mode))
            } label: {
                practiceLaunchLabel(mode, featured: featured)
            }
            .buttonStyle(CoachCardButtonStyle())
        } else {
            NavigationLink {
                practiceDestination(mode)
            } label: {
                practiceLaunchLabel(mode, featured: featured)
            }
            .buttonStyle(CoachCardButtonStyle())
        }
    }

    @ViewBuilder private func practiceDestination(_ mode: DashboardPracticeMode) -> some View {
        switch mode {
        case .speaking:
            SpeakingPracticeView(level: activeLevel, isFreeSample: !premium.isPremium)
        case .listening:
            ListeningDrillView(level: activeLevel)
        case .quiz:
            QuizView(
                level: activeLevel,
                sessionMode: premium.isPremium || activeLevel == .a1 ? .standard : .readinessPreview
            )
        case .game:
            VocabularyMatchGameView(level: activeLevel)
        case .review:
            EmptyView()
        }
    }

    @ViewBuilder private func practiceLaunchLabel(_ mode: DashboardPracticeMode, featured: Bool) -> some View {
        if featured {
            HStack(spacing: 14) {
                Image(systemName: mode.icon)
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(mode.tint)
                    .frame(width: 50, height: 50)
                    .background(.white.opacity(0.94), in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.72), lineWidth: 2))

                VStack(alignment: .leading, spacing: 4) {
                    TeachingText(english: "RECOMMENDED")
                        .font(.caption2.weight(.black))
                        .foregroundStyle(.white.opacity(0.82))
                    TeachingText(english: mode.title)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                    TeachingText(english: practiceDetail(mode))
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.white.opacity(0.90))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 6)
                if isPracticeLocked(mode) {
                    PremiumLockBadge()
                } else if !premium.isPremium && isFreeSample(mode) {
                    SkillChip(title: "FREE SAMPLE", color: CoachTheme.correct)
                }
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            .padding(15)
            .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
            .background(
                CoachTheme.actionGradient(tint: mode.tint, companion: mode.companion),
                in: RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
                    .stroke(.white.opacity(0.28), lineWidth: 1)
            )
            .shadow(color: mode.tint.opacity(colorScheme == .dark ? 0.28 : 0.20), radius: 12, y: 5)
        } else {
            HStack(spacing: 10) {
                CoachIconTile(icon: mode.icon, tint: mode.tint, size: 36)
                VStack(alignment: .leading, spacing: 2) {
                    TeachingText(english: mode.title)
                        .font(.callout.weight(.bold))
                        .foregroundStyle(.primary)
                    TeachingText(english: practiceDetail(mode))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 4)
                if isPracticeLocked(mode) {
                    PremiumLockBadge()
                } else if !premium.isPremium && isFreeSample(mode) {
                    SkillChip(title: "FREE", color: CoachTheme.correct)
                }
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .padding(10)
            .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
            .background(CoachTheme.surface, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
            .overlay(
                RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                    .stroke(CoachTheme.stroke, lineWidth: 1)
            )
        }
    }

    private func practiceDetail(_ mode: DashboardPracticeMode) -> String {
        switch mode {
        case .speaking: "Build one answer"
        case .listening: "Audio challenge"
        case .quiz: "20 questions"
        case .game: "Match words and meanings"
        case .review: dueCount == 0 ? "Queue clear" : "\(dueCount) due"
        }
    }

    private func masteryLine(_ title: String, value: Double, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                TeachingText(english: title).font(.callout.weight(.semibold))
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.caption.monospacedDigit().weight(.bold))
                    .foregroundStyle(tint)
            }
            ProgressView(value: value)
                .tint(tint)
        }
        .accessibilityElement(children: .combine)
    }

    private func isFreeSample(_ mode: DashboardPracticeMode) -> Bool {
        return switch mode {
        case .speaking: !speakingSampleCompleted
        case .quiz: activeLevel != .a1 && !readinessCheckCompleted
        default: false
        }
    }

    private func isPracticeLocked(_ mode: DashboardPracticeMode) -> Bool {
        guard !premium.isPremium else { return false }
        return switch mode {
        case .speaking: speakingSampleCompleted
        case .quiz: activeLevel != .a1 && readinessCheckCompleted
        case .listening, .game: true
        case .review: false
        }
    }

    private func entryPoint(for mode: DashboardPracticeMode) -> PremiumEntryPoint {
        switch mode {
        case .speaking: .speakingCorrection
        case .quiz: .readinessResult
        case .listening: .advancedPractice
        case .game: .games
        case .review: .direct
        }
    }

    private func presentPremium(_ entryPoint: PremiumEntryPoint) {
        premiumEntryPoint = entryPoint
        showsPremium = true
    }

    private var personalGreeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        let greeting = hour < 12 ? "Guten Morgen" : hour < 18 ? "Guten Tag" : "Guten Abend"
        let trimmedName = learnerName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.isEmpty ? greeting : "\(greeting), \(trimmedName)"
    }
}

private enum HomeCategory: String, CaseIterable, Hashable {
    case practice = "Practice"
    case progress = "Progress"
    case exam = "Exam"

    var icon: String {
        switch self {
        case .practice: "play.fill"
        case .progress: "chart.line.uptrend.xyaxis"
        case .exam: "checkmark.seal.fill"
        }
    }

    var tint: Color {
        switch self {
        case .practice: CoachTheme.primary
        case .progress: CoachTheme.listening
        case .exam: CoachTheme.reward
        }
    }
}

private enum DashboardPracticeMode: String, CaseIterable, Identifiable {
    case speaking
    case listening
    case quiz
    case game
    case review

    var id: String { rawValue }

    var title: String {
        switch self {
        case .speaking: "Speak"
        case .listening: "Listen"
        case .quiz: "Quiz"
        case .game: "Word Match"
        case .review: "Review"
        }
    }

    var icon: String {
        switch self {
        case .speaking: "mic.fill"
        case .listening: "headphones"
        case .quiz: "checkmark.circle.fill"
        case .game: "square.grid.2x2.fill"
        case .review: "rectangle.stack.fill"
        }
    }

    var tint: Color {
        switch self {
        case .speaking: CoachTheme.speaking
        case .listening: CoachTheme.listening
        case .quiz: CoachTheme.primary
        case .game: CoachTheme.reward
        case .review: CoachTheme.accent
        }
    }

    var companion: Color {
        switch self {
        case .speaking: CoachTheme.accent
        case .listening: CoachTheme.reading
        case .quiz: CoachTheme.listening
        case .game: CoachTheme.correct
        case .review: CoachTheme.reward
        }
    }

    var requiresPremium: Bool {
        switch self {
        case .speaking, .listening, .game: true
        case .quiz, .review: false
        }
    }
}
