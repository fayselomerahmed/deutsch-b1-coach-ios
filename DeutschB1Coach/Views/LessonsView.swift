import SwiftData
import SwiftUI

struct LessonsView: View {
    @AppStorage("preferredLevel") private var preferredLevel = CEFRLevel.a1.rawValue
    @AppStorage("placementRecommendedLevel") private var placementRecommendedLevel = ""
    @AppStorage(TeachingLanguage.storageKey) private var teachingLanguageCode = TeachingLanguage.defaultLanguage.rawValue
    @Query private var lessonRecords: [LessonRecord]
    @State private var viewModel = LessonViewModel()
    @State private var appliedPreferredLevel = false
    @State private var premium = PremiumAccessService.shared
    @State private var showsPremium = false

    private var teachingLanguage: TeachingLanguage { TeachingLanguage.resolve(teachingLanguageCode) }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    if let loadError = viewModel.loadError {
                        CoachCard {
                            VStack(alignment: .leading, spacing: 10) {
                                CoachEmptyState(
                                    icon: "exclamationmark.triangle.fill",
                                    title: "Course unavailable",
                                    message: loadError,
                                    tint: CoachTheme.accent
                                )
                                TeachingButton("Try again") { viewModel.loadLessons() }
                                    .buttonStyle(PrimaryCoachButton())
                            }
                        }
                    } else if viewModel.lessons.isEmpty {
                        CoachCard {
                            CoachEmptyState(
                                icon: "books.vertical.fill",
                                title: "No lessons found",
                                message: "Reload the bundled curriculum to restore this level."
                            )
                        }
                    } else {
                        levelBookshelf.coachReveal(index: 0)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 4)
                .padding(.bottom, 24)
            }
            .navigationTitle(teachingLanguage.interfaceText(.learn))
            .teachingLanguageSwitcher()
            .coachBackground()
            .sheet(isPresented: $showsPremium) { PremiumView() }
            .onAppear {
                viewModel.loadLessons()
                guard !appliedPreferredLevel else { return }
                let storedLevel = CEFRLevel(rawValue: preferredLevel) ?? .a1
                viewModel.selectedLevel = PremiumAccessPolicy.canOpenLevel(storedLevel, isPremium: premium.isPremium)
                    ? storedLevel
                    : .a1
                appliedPreferredLevel = true
            }
            .onChange(of: viewModel.selectedLevel) { _, level in
                guard PremiumAccessPolicy.canOpenLevel(level, isPremium: premium.isPremium) else {
                    viewModel.selectedLevel = .a1
                    showsPremium = true
                    return
                }
                preferredLevel = level.rawValue
                CoachFeedback.selection()
            }
        }
    }

    private var levelBookshelf: some View {
        let previewLevel = CEFRLevel(rawValue: placementRecommendedLevel)
            ?? CEFRLevel(rawValue: preferredLevel)
            ?? .a1

        return VStack(alignment: .leading, spacing: 12) {
            CoachSectionHeader(
                title: "Course books",
                subtitle: "Learn in order from A1 to B1"
            )

            VStack(spacing: 12) {
                ForEach(CEFRLevel.allCases) { level in
                    courseBookLink(level: level, previewLevel: previewLevel)
                }
            }
        }
    }

    private func courseBookLink(level: CEFRLevel, previewLevel: CEFRLevel) -> some View {
        let levelLessons = lessons(for: level)
        return NavigationLink {
            if PremiumAccessPolicy.canOpenCourseBook(
                level,
                preferredLevel: previewLevel,
                isPremium: premium.isPremium
            ) {
                LevelBookView(level: level, lessons: levelLessons)
            } else {
                PremiumLockedView(feature: .completeCourse)
            }
        } label: {
            LevelBookCover(
                level: level,
                completed: levelLessons.filter { record(for: $0)?.isCompleted == true }.count,
                total: levelLessons.count,
                isCurrent: previewLevel == level,
                requiresPremium: !PremiumAccessPolicy.canOpenCourseBook(
                    level,
                    preferredLevel: previewLevel,
                    isPremium: premium.isPremium
                ),
                isPreview: !premium.isPremium && level == previewLevel && level != .a1
            )
        }
        .buttonStyle(CoachCardButtonStyle())
    }

    private func record(for lesson: CompleteLessonDTO) -> LessonRecord? {
        lessonRecords.first { $0.lessonId == lesson.id }
    }

    private func lessons(for level: CEFRLevel) -> [CompleteLessonDTO] {
        viewModel.lessons
            .filter { $0.level == level }
            .sorted { $0.order < $1.order }
    }

}

struct LevelBookView: View {
    @AppStorage("preferredLevel") private var preferredLevel = CEFRLevel.a1.rawValue
    @AppStorage("placementRecommendedLevel") private var placementRecommendedLevel = ""
    @Query private var lessonRecords: [LessonRecord]
    @State private var premium = PremiumAccessService.shared

    let level: CEFRLevel
    let lessons: [CompleteLessonDTO]

    private var tint: Color { levelBookTint(level) }
    private var previewLevel: CEFRLevel {
        CEFRLevel(rawValue: placementRecommendedLevel) ?? CEFRLevel(rawValue: preferredLevel) ?? .a1
    }
    private var modules: [CurriculumModuleDescriptor] {
        IntegrationCourseCurriculum.languageCourseModules(level: level)
    }
    private var completedCount: Int {
        lessons.filter { record(for: $0)?.isCompleted == true }.count
    }
    private var nextLesson: CompleteLessonDTO? {
        lessons.first { record(for: $0)?.isCompleted != true }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CoachCard(tint: tint) {
                    HStack(alignment: .top, spacing: 14) {
                        compactBook
                        VStack(alignment: .leading, spacing: 7) {
                            TeachingText(english: "\(level.rawValue) COURSE BOOK")
                                .font(.caption2.weight(.heavy))
                                .foregroundStyle(tint)
                            TeachingText(english: levelBookTitle(level))
                                .font(.title2.weight(.bold))
                                .fixedSize(horizontal: false, vertical: true)
                            TeachingText(english: levelBookSubtitle(level))
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("\(completedCount) of \(lessons.count) lessons complete")
                                .font(.caption.weight(.semibold).monospacedDigit())
                                .foregroundStyle(tint)
                            LessonProgressBar(
                                progress: lessons.isEmpty ? 0 : Double(completedCount) / Double(lessons.count)
                            )
                        }
                    }
                }

                if let nextLesson {
                    NavigationLink {
                        if PremiumAccessPolicy.canOpenLesson(
                            nextLesson,
                            preferredLevel: previewLevel,
                            isPremium: premium.isPremium
                        ) {
                            LessonDetailView(lesson: nextLesson)
                        } else {
                            PremiumLockedView(feature: .completeCourse)
                        }
                    } label: {
                        HStack {
                            Label(
                                record(for: nextLesson) == nil ? "Start next lesson" : "Continue learning",
                                systemImage: PremiumAccessPolicy.canOpenLesson(
                                    nextLesson,
                                    preferredLevel: previewLevel,
                                    isPremium: premium.isPremium
                                )
                                    ? "play.fill"
                                    : "lock.fill"
                            )
                            Spacer()
                            if !PremiumAccessPolicy.canOpenLesson(
                                nextLesson,
                                preferredLevel: previewLevel,
                                isPremium: premium.isPremium
                            ) {
                                PremiumLockBadge()
                            }
                        }
                    }
                    .buttonStyle(PrimaryCoachButton(tint: tint))
                }

                CoachSectionHeader(
                    title: "Chapters",
                    subtitle: "Complete each chapter to open the next one"
                )

                VStack(spacing: 10) {
                    ForEach(Array(modules.enumerated()), id: \.element.id) { index, module in
                        let chapterLessons = lessons(in: module)
                        let unlocked = isModuleUnlocked(module)
                        let chapter = LevelChapterRow(
                            chapterNumber: index + 1,
                            module: module,
                            tint: courseModuleTint(module.number - 1),
                            completed: chapterLessons.filter { record(for: $0)?.isCompleted == true }.count,
                            total: chapterLessons.count,
                            isUnlocked: unlocked,
                            isComplete: chapterLessons.allSatisfy { record(for: $0)?.isCompleted == true }
                        )

                        if unlocked {
                            NavigationLink {
                                CourseModuleView(
                                    module: module,
                                    lessons: chapterLessons,
                                    chapterNumber: index + 1
                                )
                            } label: {
                                chapter
                            }
                            .buttonStyle(CoachCardButtonStyle())
                        } else {
                            chapter
                        }
                    }
                }
            }
            .padding()
        }
        .teachingNavigationTitle("\(level.rawValue) Course Book")
        .navigationBarTitleDisplayMode(.inline)
        .coachBackground()
        .onAppear {
            if PremiumAccessPolicy.canOpenCourseBook(
                level,
                preferredLevel: previewLevel,
                isPremium: premium.isPremium
            ) {
                preferredLevel = level.rawValue
            }
        }
    }

    private var compactBook: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [tint, tint.opacity(0.72), CoachTheme.rewardGlow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Rectangle()
                .fill(Color.black.opacity(0.14))
                .frame(width: 8)
                .padding(.vertical, 5)
            VStack(spacing: 3) {
                Image(systemName: "character.book.closed.fill")
                Text(level.rawValue)
                    .font(.headline.weight(.heavy))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 74, height: 98)
        .shadow(color: tint.opacity(0.24), radius: 8, y: 4)
        .accessibilityHidden(true)
    }

    private func record(for lesson: CompleteLessonDTO) -> LessonRecord? {
        lessonRecords.first { $0.lessonId == lesson.id }
    }

    private func lessons(in module: CurriculumModuleDescriptor) -> [CompleteLessonDTO] {
        lessons.filter { module.itemIDs.contains($0.grammarTopicId) }
    }

    private func isModuleUnlocked(_ module: CurriculumModuleDescriptor) -> Bool {
        let chapterLessons = lessons(in: module)
        return chapterLessons.allSatisfy { record(for: $0)?.isCompleted == true }
            || module.itemIDs.contains(nextLesson?.grammarTopicId ?? "")
    }
}

private struct LevelBookCover: View {
    @Environment(\.colorScheme) private var colorScheme

    let level: CEFRLevel
    let completed: Int
    let total: Int
    let isCurrent: Bool
    let requiresPremium: Bool
    let isPreview: Bool

    private var tint: Color { levelBookTint(level) }
    private var usesSpotlight: Bool { isCurrent }

    var body: some View {
        HStack(spacing: 15) {
            bookVisual

            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .firstTextBaseline, spacing: 7) {
                    TeachingText(english: levelBookTitle(level))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(usesSpotlight ? Color.white : Color.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    if requiresPremium {
                        PremiumLockBadge()
                    } else if isPreview {
                        if usesSpotlight {
                            CoachSpotlightBadge(title: "Free sample")
                        } else {
                            SkillChip(title: "FREE SAMPLE", color: CoachTheme.correct)
                        }
                    } else if isCurrent {
                        CoachSpotlightBadge(title: "Current", icon: "location.fill")
                    }
                }
                TeachingText(english: levelBookSubtitle(level))
                    .font(.callout)
                    .foregroundStyle(usesSpotlight ? Color.white.opacity(0.84) : Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if usesSpotlight {
                    CoachSpotlightProgress(progress: progress)
                } else {
                    LessonProgressBar(progress: progress)
                }
                TeachingText(english: "\(completed)/\(total) lessons · 2 chapters")
                    .font(.footnote.weight(.semibold).monospacedDigit())
                    .foregroundStyle(usesSpotlight ? Color.white.opacity(0.88) : tint)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 2)
            Image(systemName: "chevron.right")
                .font(.headline.weight(.bold))
                .foregroundStyle(usesSpotlight ? Color.white : tint)
                .accessibilityHidden(true)
        }
        .padding(usesSpotlight ? 16 : 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            usesSpotlight
                ? AnyShapeStyle(CoachTheme.actionGradient(tint: tint, companion: CoachTheme.listening))
                : AnyShapeStyle(CoachTheme.surfaceGradient(tint: tint, colorScheme: colorScheme)),
            in: RoundedRectangle(cornerRadius: CoachTheme.cardRadius)
        )
        .overlay(
            RoundedRectangle(cornerRadius: CoachTheme.cardRadius)
                .stroke(
                    usesSpotlight ? Color.white.opacity(0.32) : tint.opacity(0.20),
                    lineWidth: 1
                )
        )
        .shadow(color: usesSpotlight ? tint.opacity(0.18) : .clear, radius: 12, y: 6)
    }

    private var progress: Double {
        total == 0 ? 0 : Double(completed) / Double(total)
    }

    private var bookVisual: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(usesSpotlight ? 0.88 : 0.76))
                .offset(x: 5, y: 2)

            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [
                            usesSpotlight ? Color.white.opacity(0.22) : tint,
                            tint.opacity(0.78),
                            CoachTheme.rewardGlow
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Rectangle()
                .fill(Color.black.opacity(0.16))
                .frame(width: 8)
                .padding(.vertical, 5)

            VStack(spacing: 5) {
                Image(systemName: "book.closed.fill")
                Text(level.rawValue)
                    .font(.title3.weight(.heavy))
                Capsule()
                    .fill(Color.white.opacity(0.64))
                    .frame(width: 30, height: 2)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 86, height: 114)
        .rotation3DEffect(.degrees(usesSpotlight ? -3 : 0), axis: (x: 0, y: 1, z: 0), perspective: 0.35)
        .shadow(color: .black.opacity(usesSpotlight ? 0.20 : 0.10), radius: 8, y: 5)
        .accessibilityHidden(true)
    }
}

private struct LevelChapterRow: View {
    @Environment(\.colorScheme) private var colorScheme

    let chapterNumber: Int
    let module: CurriculumModuleDescriptor
    let tint: Color
    let completed: Int
    let total: Int
    let isUnlocked: Bool
    let isComplete: Bool

    var body: some View {
        HStack(spacing: 12) {
            CoachIconTile(icon: isUnlocked ? module.icon : "lock.fill", tint: isUnlocked ? tint : .secondary, size: 46)
            VStack(alignment: .leading, spacing: 4) {
                TeachingText(english: "CHAPTER \(chapterNumber)")
                    .font(.caption2.weight(.heavy).monospacedDigit())
                    .foregroundStyle(isUnlocked ? tint : Color.secondary)
                TeachingText(english: module.title)
                    .font(.headline)
                    .foregroundStyle(isUnlocked ? Color.primary : Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                TeachingText(
                    english: isComplete
                        ? "Complete"
                        : isUnlocked
                            ? "\(completed)/\(total) lessons"
                            : "Complete chapter 1 first"
                )
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .foregroundStyle(isComplete ? CoachTheme.correct : isUnlocked ? tint : Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 4)
            Image(systemName: isComplete ? "checkmark.circle.fill" : isUnlocked ? "chevron.right" : "lock.fill")
                .foregroundStyle(isComplete ? CoachTheme.correct : isUnlocked ? tint : Color.secondary)
                .accessibilityHidden(true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 94, alignment: .leading)
        .background(
            CoachTheme.surfaceGradient(tint: isUnlocked ? tint : Color.secondary, colorScheme: colorScheme),
            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
        )
        .overlay(
            RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
                .stroke((isUnlocked ? tint : Color.secondary).opacity(0.18))
        )
        .opacity(isUnlocked ? 1 : 0.78)
    }
}

private struct CourseModuleView: View {
    @AppStorage("preferredLevel") private var preferredLevel = CEFRLevel.a1.rawValue
    @AppStorage("placementRecommendedLevel") private var placementRecommendedLevel = ""
    @Query private var lessonRecords: [LessonRecord]
    @State private var premium = PremiumAccessService.shared
    let module: CurriculumModuleDescriptor
    let lessons: [CompleteLessonDTO]
    let chapterNumber: Int

    private var nextLesson: CompleteLessonDTO? {
        lessons.first { record(for: $0)?.isCompleted != true }
    }
    private var previewLevel: CEFRLevel {
        CEFRLevel(rawValue: placementRecommendedLevel) ?? CEFRLevel(rawValue: preferredLevel) ?? .a1
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 13) {
                    CoachIconTile(icon: module.icon, tint: courseModuleTint(module.number - 1), size: 50)
                    VStack(alignment: .leading, spacing: 3) {
                        TeachingText(english: "CHAPTER \(chapterNumber)")
                            .font(.caption2.weight(.heavy))
                            .foregroundStyle(courseModuleTint(module.number - 1))
                        TeachingText(english: module.title)
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .fixedSize(horizontal: false, vertical: true)
                        TeachingText(english: module.subtitle)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(courseModuleTint(module.number - 1).opacity(0.09), in: RoundedRectangle(cornerRadius: CoachTheme.cardRadius))
                .overlay(RoundedRectangle(cornerRadius: CoachTheme.cardRadius).stroke(courseModuleTint(module.number - 1).opacity(0.16)))

                ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                    CourseLessonPathRow(
                        lesson: lesson,
                        number: lesson.order,
                        record: record(for: lesson),
                        isCurrent: nextLesson?.id == lesson.id,
                        previousNumber: index > 0 ? lessons[index - 1].order : lesson.order - 1,
                        requiresPremium: !PremiumAccessPolicy.canOpenLesson(
                            lesson,
                            preferredLevel: previewLevel,
                            isPremium: premium.isPremium
                        )
                    )
                }
            }
            .padding()
        }
        .teachingNavigationTitle(module.title)
        .navigationBarTitleDisplayMode(.inline)
        .coachBackground()
    }

    private func record(for lesson: CompleteLessonDTO) -> LessonRecord? {
        lessonRecords.first { $0.lessonId == lesson.id }
    }
}

private struct CourseLessonPathRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let lesson: CompleteLessonDTO
    let number: Int
    let record: LessonRecord?
    let isCurrent: Bool
    let previousNumber: Int
    let requiresPremium: Bool

    private var isComplete: Bool { record?.isCompleted == true }
    private var isUnlocked: Bool { isComplete || isCurrent }
    private var scenarioStyle: LessonScenarioStyle {
        LessonScenarioStyle.resolve(scenario: lesson.scenario)
    }

    var body: some View {
        Group {
            if isUnlocked || requiresPremium {
                NavigationLink {
                    if requiresPremium {
                        PremiumLockedView(feature: .completeCourse)
                    } else {
                        LessonDetailView(lesson: lesson)
                    }
                } label: {
                    card
                }
                .buttonStyle(CoachCardButtonStyle())
            } else {
                card
                    .teachingAccessibilityLabel(
                        "Lesson \(number), \(lesson.title), locked",
                        protectedGerman: [lesson.title]
                    )
                    .teachingAccessibilityHint("Complete lesson \(previousNumber) to unlock")
            }
        }
    }

    private var card: some View {
        HStack(spacing: 12) {
            LessonMemoryVisual(lesson: lesson)
                .frame(width: 62, height: 62)
                .clipShape(RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous))
                .saturation(isUnlocked && !requiresPremium ? 1 : 0.1)
            VStack(alignment: .leading, spacing: 4) {
                TeachingLabel(english: "LESSON \(number)", systemImage: scenarioStyle.icon)
                    .font(.caption2.weight(.heavy).monospacedDigit())
                    .foregroundStyle(isUnlocked ? scenarioStyle.tint : Color.secondary)
                Text(lesson.title)
                    .font(.headline)
                    .foregroundStyle(isUnlocked ? Color.primary : Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                TeachingText(
                    english: isComplete
                        ? "Complete"
                        : requiresPremium
                            ? "Full version"
                        : isCurrent
                            ? (record == nil ? "Next lesson" : "Resume")
                            : "Finish lesson \(previousNumber) first"
                )
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isComplete ? CoachTheme.correct : isCurrent ? scenarioStyle.tint : Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 4)
            if requiresPremium && !isComplete {
                PremiumLockBadge()
            } else {
                Image(systemName: isComplete ? "checkmark.circle.fill" : isCurrent ? "chevron.right" : "lock.fill")
                    .foregroundStyle(isComplete ? CoachTheme.correct : Color.secondary)
            }
        }
        .padding(13)
        .background(
            CoachTheme.surfaceGradient(
                tint: isUnlocked && !requiresPremium ? scenarioStyle.tint : Color.secondary,
                colorScheme: colorScheme
            ),
            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
        )
        .overlay(
            RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
                .stroke((isUnlocked && !requiresPremium ? scenarioStyle.tint : Color.secondary).opacity(isCurrent ? 0.36 : 0.18), lineWidth: isCurrent ? 2 : 1)
        )
        .opacity(isUnlocked && !requiresPremium ? 1 : 0.82)
    }
}

private func courseModuleTint(_ index: Int) -> Color {
    let palette = [CoachTheme.primary, CoachTheme.accent, CoachTheme.listening, CoachTheme.speaking]
    return palette[index % palette.count]
}

private func levelBookTint(_ level: CEFRLevel) -> Color {
    switch level {
    case .a1: CoachTheme.primary
    case .a2: CoachTheme.accent
    case .b1: CoachTheme.listening
    }
}

private func levelBookTitle(_ level: CEFRLevel) -> String {
    switch level {
    case .a1: "Beginner German"
    case .a2: "Everyday German"
    case .b1: "Independent German"
    }
}

private func levelBookSubtitle(_ level: CEFRLevel) -> String {
    switch level {
    case .a1: "Build the foundations for everyday life"
    case .a2: "Handle common situations with confidence"
    case .b1: "Express yourself clearly and prepare for the exam"
    }
}
