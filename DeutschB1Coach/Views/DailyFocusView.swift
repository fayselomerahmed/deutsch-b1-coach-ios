import SwiftData
import SwiftUI

enum DailyFocusStep: String, Identifiable {
    case learn
    case recall
    case speak
    case quiz
    case write

    var id: String { rawValue }

    var title: String {
        switch self {
        case .learn: "Learn"
        case .recall: "Recall"
        case .speak: "Speak"
        case .quiz: "Challenge"
        case .write: "Write"
        }
    }

    var detail: String {
        switch self {
        case .learn: "Continue your course path"
        case .recall: "Strengthen words due today"
        case .speak: "Produce one spoken answer"
        case .quiz: "Answer a focused question set"
        case .write: "Create a short German response"
        }
    }

    var icon: String {
        switch self {
        case .learn: "book.fill"
        case .recall: "rectangle.stack.fill"
        case .speak: "mic.fill"
        case .quiz: "checkmark.circle.fill"
        case .write: "square.and.pencil"
        }
    }

    var tint: Color {
        switch self {
        case .learn: CoachTheme.primary
        case .recall: CoachTheme.accent
        case .speak: CoachTheme.speaking
        case .quiz: CoachTheme.listening
        case .write: CoachTheme.writing
        }
    }
}

enum DailyFocusPlan {
    static func steps(minutes: Int, prioritizesReview: Bool) -> [DailyFocusStep] {
        switch minutes {
        case 5:
            return prioritizesReview ? [.recall, .speak] : [.learn, .speak]
        case 15:
            return prioritizesReview
                ? [.recall, .learn, .speak, .quiz]
                : [.learn, .quiz, .speak, .write]
        default:
            return prioritizesReview
                ? [.recall, .learn, .speak]
                : [.learn, .quiz, .speak]
        }
    }
}

struct DailyFocusView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Query private var lessonRecords: [LessonRecord]
    @Query private var activities: [LearningActivity]
    @Query(sort: \ReviewItem.dueDate) private var reviewItems: [ReviewItem]
    @Query private var quizQuestions: [QuizQuestion]
    @AppStorage("focusSessionMinutes") private var sessionMinutes = 10
    @State private var lessons: [CompleteLessonDTO] = []
    @State private var prioritizesReview: Bool?
    @State private var premium = PremiumAccessService.shared

    let level: CEFRLevel

    private var levelLessons: [CompleteLessonDTO] {
        lessons.filter { $0.level == level }.sorted { $0.order < $1.order }
    }

    private var nextLesson: CompleteLessonDTO? {
        levelLessons.first { lesson in
            lessonRecords.first { $0.lessonId == lesson.id }?.isCompleted != true
        }
    }

    private var dueCount: Int {
        reviewItems.filter { $0.isActive && $0.dueDate <= .now }.count
    }

    private var shouldPrioritizeReview: Bool {
        prioritizesReview ?? (dueCount > 0)
    }

    private var steps: [DailyFocusStep] {
        DailyFocusPlan.steps(minutes: sessionMinutes, prioritizesReview: shouldPrioritizeReview)
    }

    private var completedCount: Int {
        steps.filter(isComplete).count
    }

    private var progress: Double {
        steps.isEmpty ? 0 : Double(completedCount) / Double(steps.count)
    }

    private var nextStep: DailyFocusStep? {
        steps.first { !isComplete($0) }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                focusHeader.coachReveal(index: 0)
                durationPicker.coachReveal(index: 1)

                if let nextStep {
                    NavigationLink {
                        destination(for: nextStep)
                    } label: {
                        nextActionCard(nextStep)
                    }
                    .buttonStyle(CoachCardButtonStyle())
                    .coachReveal(index: 2)
                } else {
                    completionCard.coachReveal(index: 2)
                }

                CoachSectionHeader(
                    title: "Your session",
                    subtitle: "A short plan shaped by what needs attention now"
                )

                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    NavigationLink {
                        destination(for: step)
                    } label: {
                        DailyFocusStepRow(
                            number: index + 1,
                            step: step,
                            isComplete: isComplete(step),
                            isNext: nextStep == step
                        )
                    }
                    .buttonStyle(CoachCardButtonStyle())
                    .coachReveal(index: index + 3)
                }
            }
            .padding()
        }
        .teachingNavigationTitle("Focus Session")
        .navigationBarTitleDisplayMode(.inline)
        .coachBackground()
        .task {
            lessons = (try? ContentLoader.shared.loadLessons()) ?? []
            if prioritizesReview == nil {
                prioritizesReview = dueCount > 0
            }
        }
        .onChange(of: sessionMinutes) { _, _ in
            prioritizesReview = dueCount > 0
            CoachFeedback.selection()
        }
    }

    private var focusHeader: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        CoachMascot(
                            mood: completedCount == steps.count ? .achievement : .welcome,
                            size: 54,
                            animates: true
                        )
                        Spacer()
                        DailyFocusRing(progress: progress, tint: nextStep?.tint ?? CoachTheme.correct, size: 66)
                    }
                    TeachingText(english: sessionTitle)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    TeachingText(english: "\(completedCount) of \(steps.count) activities complete")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                }
            } else {
                HStack(spacing: 16) {
                    CoachMascot(
                        mood: completedCount == steps.count ? .achievement : .welcome,
                        size: 66,
                        animates: true
                    )
                    VStack(alignment: .leading, spacing: 4) {
                        TeachingText(english: sessionTitle)
                            .font(.system(.title2, design: .rounded, weight: .bold))
                        TeachingText(english: "\(completedCount) of \(steps.count) activities complete")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .contentTransition(.numericText())
                    }
                    Spacer(minLength: 4)
                    DailyFocusRing(progress: progress, tint: nextStep?.tint ?? CoachTheme.correct)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var durationPicker: some View {
        Picker(selection: $sessionMinutes) {
            Text("5 min").tag(5)
            Text("10 min").tag(10)
            Text("15 min").tag(15)
        } label: {
            TeachingText(english: "Session length")
        }
        .pickerStyle(.segmented)
        .teachingAccessibilityLabel("Focus session length")
    }

    private func nextActionCard(_ step: DailyFocusStep) -> some View {
        CoachCard(tint: step.tint) {
            HStack(spacing: 14) {
                CoachIconTile(icon: step.icon, tint: step.tint, size: 54)
                VStack(alignment: .leading, spacing: 3) {
                    TeachingText(english: "UP NEXT")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(step.tint)
                    TeachingText(english: step.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(CoachTheme.ink)
                    TeachingText(english: step.detail)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 4)
                Image(systemName: "play.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(step.tint, in: Circle())
            }
        }
    }

    private var completionCard: some View {
        CoachCard(tint: CoachTheme.correct) {
            VStack(spacing: 12) {
                CoachCelebrationMark()
                TeachingText(english: "Focus complete")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                TeachingText(english: "You finished today’s \(sessionMinutes)-minute plan.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                ShareLink(item: shareMessage) {
                    TeachingLabel(english: "Share this win", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(PrimaryCoachButton(tint: CoachTheme.correct))
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func isComplete(_ step: DailyFocusStep) -> Bool {
        switch step {
        case .learn:
            return lessonRecords.contains {
                $0.level == level.rawValue && $0.completedAt.map(Calendar.current.isDateInToday) == true
            }
        case .recall:
            return dueCount == 0 || activities.contains {
                $0.level == level.rawValue
                    && [SkillArea.vocabulary.rawValue, SkillArea.grammar.rawValue].contains($0.skill)
                    && Calendar.current.isDateInToday($0.createdAt)
            }
        case .speak:
            return completedActivity(skill: .speaking)
        case .quiz:
            let questionIDs = Set(quizQuestions.filter { $0.level == level.rawValue }.map(\.id))
            return activities.contains {
                questionIDs.contains($0.sourceId) && Calendar.current.isDateInToday($0.createdAt)
            }
        case .write:
            return completedActivity(skill: .writing)
        }
    }

    private func completedActivity(skill: SkillArea) -> Bool {
        activities.contains {
            $0.level == level.rawValue
                && $0.skill == skill.rawValue
                && Calendar.current.isDateInToday($0.createdAt)
        }
    }

    @ViewBuilder private func destination(for step: DailyFocusStep) -> some View {
        switch step {
        case .learn:
            if let nextLesson {
                if PremiumAccessPolicy.canOpenLesson(nextLesson, isPremium: premium.isPremium) {
                    LessonDetailView(lesson: nextLesson)
                } else {
                    PremiumLockedView(feature: .completeCourse)
                }
            } else {
                GrammarFlashcardsView(level: level)
            }
        case .recall:
            VocabularyFlashcardsView(level: level)
        case .speak:
            SpeakingPracticeView(level: level)
        case .quiz:
            QuizView(level: level)
        case .write:
            WritingPracticeView(level: level)
        }
    }

    private var sessionTitle: String {
        switch sessionMinutes {
        case 5: "Quick reset"
        case 15: "Deep practice"
        default: "Balanced boost"
        }
    }

    private var shareMessage: String {
        "I completed a \(sessionMinutes)-minute German focus session in Deutsch B1 Coach."
    }
}

struct DailyFocusRing: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var displayedProgress = 0.0
    let progress: Double
    let tint: Color
    var size: CGFloat = 72

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(.primary.opacity(0.09), lineWidth: 8)
            Circle()
                .trim(from: 0, to: displayedProgress)
                .stroke(
                    LinearGradient(
                        colors: [tint, CoachTheme.rewardGlow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Text("\(Int(clampedProgress * 100))%")
                .font(.system(.caption, design: .rounded, weight: .bold).monospacedDigit())
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.48)
                .padding(4)
        }
        .frame(width: size, height: size)
        .teachingAccessibilityLabel("Focus progress")
        .accessibilityValue("\(Int(clampedProgress * 100)) percent")
        .onAppear { updateProgress() }
        .onChange(of: progress) { _, _ in updateProgress() }
    }

    private func updateProgress() {
        if reduceMotion {
            displayedProgress = clampedProgress
        } else {
            withAnimation(CoachMotion.spring) {
                displayedProgress = clampedProgress
            }
        }
    }
}

private struct DailyFocusStepRow: View {
    let number: Int
    let step: DailyFocusStep
    let isComplete: Bool
    let isNext: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill((isComplete ? CoachTheme.correct : step.tint).opacity(0.13))
                Image(systemName: isComplete ? "checkmark" : step.icon)
                    .font(.callout.weight(.bold))
                    .foregroundStyle(isComplete ? CoachTheme.correct : step.tint)
            }
            .frame(width: 46, height: 46)

            VStack(alignment: .leading, spacing: 2) {
                TeachingText(english: step.title)
                    .font(.headline)
                    .foregroundStyle(CoachTheme.ink)
                TeachingText(english: isComplete ? "Complete today" : step.detail)
                    .font(.caption)
                    .foregroundStyle(isComplete ? CoachTheme.correct : .secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 4)
            if isNext && !isComplete {
                TeachingText(english: "NEXT")
                    .font(.caption2.bold())
                    .foregroundStyle(step.tint)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(step.tint.opacity(0.11), in: Capsule())
            } else {
                Image(systemName: isComplete ? "checkmark.circle.fill" : "chevron.right")
                    .foregroundStyle(isComplete ? CoachTheme.correct : Color.secondary)
            }
        }
        .padding(13)
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .background(
            LinearGradient(
                colors: [CoachTheme.elevatedSurface.opacity(0.92), step.tint.opacity(isNext ? 0.15 : 0.07)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
        )
        .overlay(
            RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
                .stroke(step.tint.opacity(isNext ? 0.28 : 0.14), lineWidth: isNext ? 1.5 : 1)
        )
        .accessibilityElement(children: .combine)
        .teachingAccessibilityLabel("Step \(number), \(step.title), \(isComplete ? "complete" : "not complete")")
    }
}
