import Charts
import SwiftData
import SwiftUI

struct ProgressStatsView: View {
    @AppStorage("preferredLevel") private var preferredLevel = CEFRLevel.a1.rawValue
    @AppStorage(TeachingLanguage.storageKey) private var teachingLanguageCode = TeachingLanguage.defaultLanguage.rawValue
    @Query private var progress: [UserProgress]
    @Query(sort: \LearningActivity.createdAt, order: .reverse) private var activities: [LearningActivity]
    @Query private var lessonRecords: [LessonRecord]
    @Query private var reviewItems: [ReviewItem]
    @State private var lessons: [CompleteLessonDTO] = []
    @State private var selectedLevel: CEFRLevel = .a1
    @State private var appliedPreferredLevel = false
    @State private var showsSettings = false
    @State private var selectedCategory = ProgressCategory.overview
    @State private var premium = PremiumAccessService.shared
    @State private var showsPremium = false

    private var teachingLanguage: TeachingLanguage {
        TeachingLanguage.resolve(teachingLanguageCode)
    }

    private var totalXP: Int {
        activities.reduce(0) { $0 + $1.xp }
    }

    private var completedLessons: Int {
        lessonRecords.filter(\.isCompleted).count
    }

    private var reviewedCards: Int {
        reviewItems.filter { $0.lastReviewedAt != nil }.count
    }

    private var levelProgressItem: UserProgress? {
        progress.first { $0.level == selectedLevel.rawValue }
    }

    private var levelLessonCount: Int {
        lessons.filter { $0.level == selectedLevel }.count
    }

    private var levelCompletedLessons: Int {
        lessonRecords.filter { $0.level == selectedLevel.rawValue && $0.isCompleted }.count
    }

    private var completedPracticalMissions: Int {
        Set(activities.filter {
            $0.level == selectedLevel.rawValue && $0.sourceId.hasPrefix("practical-mission-")
        }.map(\.sourceId)).count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    levelPicker.coachReveal(index: 0)
                    progressCategoryPicker.coachReveal(index: 1)
                    progressCategoryContent.coachReveal(index: 2)
                }
                .padding(.horizontal)
                .padding(.top, 4)
                .padding(.bottom, 24)
            }
            .refreshable {
                try? await Task.sleep(nanoseconds: 180_000_000)
                CoachFeedback.selection()
            }
            .navigationTitle(teachingLanguage.interfaceText(.progress))
            .teachingLanguageSwitcher()
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    ShareLink(item: progressShareText) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .teachingAccessibilityLabel("Share progress")

                    Button { showsSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .teachingAccessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showsSettings) { SettingsView() }
            .sheet(isPresented: $showsPremium) { PremiumView() }
            .coachBackground()
            .task {
                lessons = (try? ContentLoader.shared.loadLessons()) ?? []
                guard !appliedPreferredLevel else { return }
                let storedLevel = CEFRLevel(rawValue: preferredLevel) ?? .a1
                selectedLevel = PremiumAccessPolicy.canOpenLevel(storedLevel, isPremium: premium.isPremium)
                    ? storedLevel
                    : .a1
                appliedPreferredLevel = true
            }
            .onChange(of: selectedLevel) { _, level in
                guard PremiumAccessPolicy.canOpenLevel(level, isPremium: premium.isPremium) else {
                    selectedLevel = .a1
                    showsPremium = true
                    return
                }
                preferredLevel = level.rawValue
                CoachFeedback.selection()
            }
            .onChange(of: premium.isPremium) { _, isPremium in
                if !isPremium, selectedCategory.requiresPremium {
                    selectedCategory = .overview
                }
            }
        }
    }

    private var progressCategoryPicker: some View {
        CoachCategoryPicker(
            title: "Show progress",
            selection: Binding(
                get: { selectedCategory },
                set: { category in
                    guard premium.isPremium || !category.requiresPremium else {
                        showsPremium = true
                        return
                    }
                    selectedCategory = category
                }
            ),
            options: ProgressCategory.allCases.map {
                CoachCategoryOption(
                    value: $0,
                    title: $0.requiresPremium && !premium.isPremium ? "\($0.rawValue) · Full" : $0.rawValue,
                    icon: $0.icon,
                    tint: $0.tint
                )
            }
        )
    }

    @ViewBuilder private var progressCategoryContent: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            switch selectedCategory {
            case .overview:
                overview
                nextFocus
            case .skills:
                skillBreakdown
                milestones
            case .history:
                weeklyChart
                recentActivity
            }
        }
        .id(selectedCategory)
        .transition(.opacity)
        .animation(CoachMotion.quick, value: selectedCategory)
    }

    private var levelPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            TeachingText(english: "Level snapshot")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
            Picker(selection: $selectedLevel) {
                ForEach(CEFRLevel.allCases) { level in
                    Text(level.rawValue).tag(level)
                }
            } label: {
                TeachingText(english: "Level snapshot")
            }
            .pickerStyle(.segmented)
        }
    }

    private var progressShareText: String {
        let streak = progress.map(\.streakDays).max() ?? 0
        return "My Deutsch B1 Coach progress: \(totalXP) XP, \(completedLessons) lessons, \(reviewedCards) reviewed cards, and a \(streak)-day streak."
    }

    private var overview: some View {
        CoachSpotlightCard(
            tint: readinessTint,
            companion: readiness >= 0.75 ? CoachTheme.correct : CoachTheme.listening
        ) {
            VStack(alignment: .leading, spacing: 16) {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .center, spacing: 16) {
                        readinessSpotlightRing
                        readinessIdentity
                    }
                    VStack(alignment: .leading, spacing: 13) {
                        readinessSpotlightRing
                        readinessIdentity
                    }
                }

                CoachSpotlightProgress(progress: readiness)

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 92), spacing: 10)],
                    alignment: .leading,
                    spacing: 10
                ) {
                    spotlightMetric(value: "\(totalXP)", label: "total XP", icon: "bolt.fill")
                    spotlightMetric(value: "\(completedLessons)", label: "lessons", icon: "book.fill")
                    spotlightMetric(value: "\(reviewedCards)", label: "reviewed", icon: "rectangle.stack.fill")
                }
            }
        }
    }

    private var readinessIdentity: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 7) {
                CoachSpotlightBadge(title: selectedLevel.rawValue)
                CoachSpotlightBadge(
                    title: "\(levelProgressItem?.streakDays ?? 0) day streak",
                    icon: "flame.fill"
                )
            }
            TeachingText(english: readinessTitle)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            TeachingText(english: "Readiness combines course mastery with your four active skills.")
                .font(.callout.weight(.medium))
                .foregroundStyle(.white.opacity(0.84))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var readinessSpotlightRing: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.20), lineWidth: 9)
            Circle()
                .trim(from: 0, to: readiness)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text("\(Int(readiness * 100))%")
                    .font(.system(.headline, design: .rounded, weight: .bold).monospacedDigit())
                TeachingText(english: "Ready")
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(.white)
        }
        .frame(width: 86, height: 86)
        .accessibilityElement(children: .combine)
        .teachingAccessibilityLabel("Readiness")
        .teachingAccessibilityValue("\(Int(readiness * 100)) percent")
    }

    private func spotlightMetric(value: String, label: String, icon: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.callout.weight(.bold))
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.14), in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.system(.headline, design: .rounded, weight: .bold).monospacedDigit())
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)
                TeachingText(english: label)
                    .font(.footnote)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var nextFocus: some View {
        VStack(alignment: .leading, spacing: 11) {
            CoachSectionHeader(title: "Next best focus", subtitle: "Based on your current \(selectedLevel.rawValue) scores")
            CoachCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 13) {
                        CoachIconTile(icon: focus.icon, tint: focus.tint, size: 50)
                        VStack(alignment: .leading, spacing: 4) {
                            TeachingText(english: focus.title)
                                .font(.title3.weight(.bold))
                            TeachingText(english: focus.message)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                    NavigationLink {
                        focusDestination
                    } label: {
                        TeachingLabel(english: focus.button, systemImage: "arrow.right")
                    }
                    .buttonStyle(PrimaryCoachButton(tint: focus.tint))
                }
            }
        }
    }

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 11) {
            CoachSectionHeader(title: "Last 7 days", subtitle: "Consistency matters more than marathon sessions")
            CoachCard {
                Chart(weeklyXP, id: \.date) { point in
                    BarMark(
                        x: .value("Day", point.date, unit: .day),
                        y: .value("XP", point.xp)
                    )
                    .foregroundStyle(point.xp > 0 ? CoachTheme.primary : CoachTheme.primary.opacity(0.18))
                    .cornerRadius(3)
                }
                .frame(height: 160)
                .chartYScale(domain: 0...max(20, weeklyXP.map(\.xp).max() ?? 20))
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisValueLabel(format: .dateTime.weekday(.narrow))
                    }
                }
                .teachingAccessibilityLabel("XP earned over the last seven days")
            }
        }
    }

    private var skillBreakdown: some View {
        VStack(alignment: .leading, spacing: 11) {
            CoachSectionHeader(title: "Skill balance", subtitle: "Scores use your latest practice attempts")
            CoachCard {
                VStack(spacing: 13) {
                    skillLine("Grammar", score: levelProgressItem?.grammarMastery ?? 0, icon: "text.book.closed.fill", tint: CoachTheme.primary)
                    skillLine("Vocabulary", score: levelProgressItem?.vocabularyRetention ?? 0, icon: "rectangle.stack.fill", tint: CoachTheme.accent)
                    skillLine("Speaking", score: average(skill: .speaking), icon: "mic.fill", tint: CoachTheme.speaking)
                    skillLine("Listening", score: average(skill: .listening), icon: "headphones", tint: CoachTheme.listening)
                    skillLine("Reading", score: average(skill: .reading), icon: "doc.text.fill", tint: CoachTheme.reading)
                    skillLine("Writing", score: average(skill: .writing), icon: "square.and.pencil", tint: CoachTheme.writing)

                    Divider()

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            TeachingLabel(english: "Course path", systemImage: "map.fill")
                                .font(.callout.weight(.semibold))
                            Spacer()
                            Text("\(levelCompletedLessons)/\(levelLessonCount)")
                                .font(.caption.monospacedDigit().weight(.bold))
                                .foregroundStyle(CoachTheme.primary)
                        }
                        ProgressView(value: Double(levelCompletedLessons), total: Double(max(levelLessonCount, 1)))
                            .tint(CoachTheme.primary)
                    }
                }
            }
        }
    }

    private var milestones: some View {
        VStack(alignment: .leading, spacing: 11) {
            CoachSectionHeader(title: "Milestones", subtitle: "Small wins that mark real momentum")
            CoachCard {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 122), spacing: 14)],
                    alignment: .center,
                    spacing: 18
                ) {
                    NativeAchievementBadge(
                        title: "First lesson",
                        detail: "Complete your first guided lesson",
                        icon: "book.closed.fill",
                        tint: CoachTheme.primary,
                        isUnlocked: completedLessons >= 1
                    )
                    NativeAchievementBadge(
                        title: "Practical communicator",
                        detail: "Complete all five real-life missions at this level",
                        icon: "mug.fill",
                        tint: CoachTheme.reward,
                        isUnlocked: completedPracticalMissions >= 5
                    )
                    NativeAchievementBadge(
                        title: "Recall rhythm",
                        detail: "Review 100 different cards",
                        icon: "rectangle.stack.fill",
                        tint: CoachTheme.listening,
                        isUnlocked: reviewedCards >= 100
                    )
                    NativeAchievementBadge(
                        title: "Seven-day streak",
                        detail: "Study on seven consecutive days",
                        icon: "clock.fill",
                        tint: CoachTheme.accent,
                        isUnlocked: progress.map(\.streakDays).max() ?? 0 >= 7
                    )
                    NativeAchievementBadge(
                        title: "B1 checkpoint",
                        detail: "Reach 75% B1 readiness",
                        icon: "doc.text.fill",
                        tint: GermanGrammarCase.nominative.color,
                        isUnlocked: readiness(for: .b1) >= 0.75
                    )
                }
            }
        }
    }

    @ViewBuilder private var recentActivity: some View {
        if !activities.isEmpty {
            VStack(alignment: .leading, spacing: 11) {
                CoachSectionHeader(title: "Recent activity")
                CoachCard(padding: 0) {
                    VStack(spacing: 0) {
                        ForEach(Array(activities.prefix(6).enumerated()), id: \.element.id) { index, activity in
                            HStack(spacing: 12) {
                                CoachIconTile(icon: icon(for: activity.skill), tint: color(for: activity.skill), size: 40)
                                VStack(alignment: .leading, spacing: 2) {
                                    TeachingText(english: activity.skill.capitalized)
                                        .font(.callout.weight(.semibold))
                                    Text(activity.createdAt, style: .relative)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("+\(activity.xp) XP")
                                    .font(.caption.monospacedDigit().weight(.bold))
                                    .foregroundStyle(CoachTheme.accent)
                            }
                            .padding(13)
                            if index < min(activities.count, 6) - 1 {
                                Divider().padding(.leading, 65)
                            }
                        }
                    }
                }
            }
        }
    }

    private func skillLine(_ title: String, score: Double, icon: String, tint: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    TeachingText(english: title).font(.callout.weight(.semibold))
                    Spacer()
                    Text("\(Int(score * 100))%")
                        .font(.caption.monospacedDigit().weight(.bold))
                        .foregroundStyle(tint)
                }
                ProgressView(value: score).tint(tint)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func average(level: CEFRLevel? = nil, skill: SkillArea) -> Double {
        let targetLevel = level ?? selectedLevel
        let values = activities
            .filter { $0.level == targetLevel.rawValue && $0.skill == skill.rawValue }
            .prefix(20)
            .map(\.score)
        return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
    }

    private func readiness(for level: CEFRLevel) -> Double {
        let item = progress.first { $0.level == level.rawValue }
        let foundation = ((item?.grammarMastery ?? 0) + (item?.vocabularyRetention ?? 0)) / 2
        let activeValues = [
            average(level: level, skill: .speaking),
            average(level: level, skill: .listening),
            average(level: level, skill: .reading),
            average(level: level, skill: .writing)
        ]
        let active = activeValues.reduce(0, +) / Double(activeValues.count)
        return (foundation * 0.6) + (active * 0.4)
    }

    private var readiness: Double {
        readiness(for: selectedLevel)
    }

    private var readinessTint: Color {
        if readiness >= 0.75 { return CoachTheme.correct }
        if readiness >= 0.45 { return CoachTheme.primary }
        return CoachTheme.accent
    }

    private var readinessTitle: String {
        if readiness >= 0.75 { return "Checkpoint ready" }
        if readiness >= 0.45 { return "Building momentum" }
        return "Foundation phase"
    }

    private var focus: ProgressFocus {
        let foundationScores = [
            ("Grammar", levelProgressItem?.grammarMastery ?? 0),
            ("Vocabulary", levelProgressItem?.vocabularyRetention ?? 0)
        ]
        let activeScores = [
            ("Speaking", average(skill: .speaking)),
            ("Listening", average(skill: .listening)),
            ("Reading", average(skill: .reading)),
            ("Writing", average(skill: .writing))
        ]
        let weakest = (foundationScores + activeScores).min { $0.1 < $1.1 }?.0 ?? "Course"

        switch weakest {
        case "Grammar":
            return .grammar
        case "Vocabulary":
            return .vocabulary
        case "Speaking":
            return .speaking
        case "Listening":
            return .listening
        case "Reading":
            return .reading
        default:
            return .writing
        }
    }

    @ViewBuilder private var focusDestination: some View {
        switch focus {
        case .grammar:
            GrammarFlashcardsView(level: selectedLevel)
        case .vocabulary:
            VocabularyFlashcardsView(level: selectedLevel)
        case .speaking:
            PremiumGate(feature: .advancedPractice) {
                SpeakingPracticeView(level: selectedLevel)
            }
        case .listening:
            PremiumGate(feature: .advancedPractice) {
                ListeningDrillView(level: selectedLevel)
            }
        case .reading:
            PremiumGate(feature: .advancedPractice) {
                ReadingDrillView(level: selectedLevel)
            }
        case .writing:
            PremiumGate(feature: .advancedPractice) {
                WritingPracticeView(level: selectedLevel)
            }
        }
    }

    private var weeklyXP: [(date: Date, xp: Int)] {
        let calendar = Calendar.current
        return (0..<7).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: .now) ?? .now
            let xp = activities
                .filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
                .reduce(0) { $0 + $1.xp }
            return (calendar.startOfDay(for: date), xp)
        }
    }

    private func icon(for skill: String) -> String {
        switch SkillArea(rawValue: skill) {
        case .speaking: "mic.fill"
        case .listening: "headphones"
        case .writing: "square.and.pencil"
        case .reading: "doc.text.fill"
        case .vocabulary: "rectangle.stack.fill"
        default: "text.book.closed.fill"
        }
    }

    private func color(for skill: String) -> Color {
        switch SkillArea(rawValue: skill) {
        case .speaking: CoachTheme.speaking
        case .listening: CoachTheme.listening
        case .writing: CoachTheme.writing
        case .reading: CoachTheme.reading
        case .vocabulary: CoachTheme.accent
        default: CoachTheme.primary
        }
    }
}

private enum ProgressCategory: String, CaseIterable, Hashable {
    case overview = "Overview"
    case skills = "Skills"
    case history = "History"

    var icon: String {
        switch self {
        case .overview: "gauge.with.dots.needle.50percent"
        case .skills: "chart.bar.fill"
        case .history: "clock.arrow.circlepath"
        }
    }

    var tint: Color {
        switch self {
        case .overview: CoachTheme.primary
        case .skills: CoachTheme.listening
        case .history: CoachTheme.reward
        }
    }

    var requiresPremium: Bool {
        self != .overview
    }
}

private enum ProgressFocus {
    case grammar
    case vocabulary
    case speaking
    case listening
    case reading
    case writing

    var title: String {
        switch self {
        case .grammar: "Strengthen grammar"
        case .vocabulary: "Grow active vocabulary"
        case .speaking: "Speak out loud"
        case .listening: "Tune your ear"
        case .reading: "Read for meaning"
        case .writing: "Write a short response"
        }
    }

    var message: String {
        switch self {
        case .grammar: "A short rule-and-example session will support every other skill."
        case .vocabulary: "Recall words in context so they are ready when you speak and write."
        case .speaking: "One recorded answer will build fluency and reveal your next improvement."
        case .listening: "Try a short audio challenge before reading the transcript."
        case .reading: "Practice finding the main point before translating every word."
        case .writing: "Turn your vocabulary and grammar into a useful message."
        }
    }

    var button: String {
        switch self {
        case .grammar: "Open grammar practice"
        case .vocabulary: "Open vocabulary cards"
        case .speaking: "Open speaking practice"
        case .listening: "Open listening practice"
        case .reading: "Open reading practice"
        case .writing: "Open writing practice"
        }
    }

    var icon: String {
        switch self {
        case .grammar: "text.book.closed.fill"
        case .vocabulary: "rectangle.stack.fill"
        case .speaking: "mic.fill"
        case .listening: "headphones"
        case .reading: "doc.text.magnifyingglass"
        case .writing: "square.and.pencil"
        }
    }

    var tint: Color {
        switch self {
        case .grammar: CoachTheme.primary
        case .vocabulary: CoachTheme.accent
        case .speaking: CoachTheme.speaking
        case .listening: CoachTheme.listening
        case .reading: CoachTheme.reading
        case .writing: CoachTheme.writing
        }
    }
}
