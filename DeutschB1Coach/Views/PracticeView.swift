import SwiftData
import SwiftUI

struct PracticeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("preferredLevel") private var preferredLevel = CEFRLevel.a1.rawValue
    @AppStorage(TeachingLanguage.storageKey) private var teachingLanguageCode = TeachingLanguage.defaultLanguage.rawValue
    @AppStorage("selectedLearningWeakness") private var selectedLearningWeakness = SkillArea.listening.rawValue
    @AppStorage("didChooseLearningWeakness.v1") private var didChooseLearningWeakness = false
    @Query private var activities: [LearningActivity]
    @State private var selectedLevel: CEFRLevel = .a1
    @State private var appliedPreferredLevel = false
    @State private var selectedCategory = PracticeCategory.daily
    @State private var loopStart = Calendar.current.startOfDay(for: .now)
    @State private var loopRound = 1
    @State private var showsFocusPicker = false
    @State private var showsImprovementRecommendations = false
    @State private var showsPracticeTypes = false
    @State private var premium = PremiumAccessService.shared
    @State private var showsPremium = false

    @Namespace private var practiceModeNamespace

    private var teachingLanguage: TeachingLanguage {
        TeachingLanguage.resolve(teachingLanguageCode)
    }

    private var learningFocus: SkillArea {
        SkillArea(rawValue: selectedLearningWeakness) ?? .listening
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    levelPicker.coachReveal(index: 0)
                    practiceModeChooser.coachReveal(index: 1)
                    practiceCategoryContent.coachReveal(index: 2)
                }
                .padding(.horizontal)
                .padding(.top, 4)
                .padding(.bottom, 24)
            }
            .navigationTitle(teachingLanguage.interfaceText(.practice))
            .teachingLanguageSwitcher()
            .coachBackground()
            .onAppear {
                if !appliedPreferredLevel {
                    let storedLevel = CEFRLevel(rawValue: preferredLevel) ?? .a1
                    selectedLevel = PremiumAccessPolicy.canOpenLevel(storedLevel, isPremium: premium.isPremium)
                        ? storedLevel
                        : .a1
                    appliedPreferredLevel = true
                }
                loadPracticeLoop(for: selectedLevel)
            }
            .onChange(of: selectedLevel) { _, level in
                guard PremiumAccessPolicy.canOpenLevel(level, isPremium: premium.isPremium) else {
                    selectedLevel = .a1
                    showsPremium = true
                    return
                }
                preferredLevel = level.rawValue
                loadPracticeLoop(for: level)
                CoachFeedback.selection()
            }
            .onChange(of: premium.isPremium) { _, isPremium in
                if !isPremium, selectedCategory.requiresPremium {
                    selectedCategory = .daily
                }
            }
            .sheet(isPresented: $showsFocusPicker) {
                LearningWeaknessSelectionView(initialSkill: learningFocus) { skill in
                    selectedLearningWeakness = skill.rawValue
                    didChooseLearningWeakness = true
                    showsFocusPicker = false
                }
            }
            .sheet(isPresented: $showsPremium) { PremiumView() }
        }
    }

    private var learningFocusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            CoachSectionHeader(
                title: "Your focused path",
                subtitle: "Practice the skill that needs the most attention"
            )

            CoachCard(padding: 15, tint: learningFocus.learningFocusTint) {
                VStack(alignment: .leading, spacing: 13) {
                    HStack(alignment: .top, spacing: 12) {
                        CoachIconTile(
                            icon: learningFocus.learningFocusIcon,
                            tint: learningFocus.learningFocusTint,
                            size: 50
                        )
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 7) {
                                SkillChip(title: selectedLevel.rawValue, color: CoachTheme.primary, translatesTitle: false)
                                SkillChip(title: "My focus", color: learningFocus.learningFocusTint)
                            }
                            TeachingText(english: learningFocus.learningFocusTitle)
                                .font(.system(.title3, design: .rounded, weight: .bold))
                            TeachingText(english: learningFocus.learningFocusOutcome)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 10) {
                            changeFocusButton
                            startFocusLink
                        }
                        VStack(spacing: 8) {
                            startFocusLink
                            changeFocusButton
                        }
                    }
                }
            }
        }
    }

    private var changeFocusButton: some View {
        Button {
            showsFocusPicker = true
        } label: {
            TeachingLabel(english: "Change focus", systemImage: "slider.horizontal.3")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(SecondaryCoachButton(tint: learningFocus.learningFocusTint))
    }

    private var startFocusLink: some View {
        NavigationLink {
            focusedPracticeDestination
        } label: {
            TeachingLabel(english: "Start focused practice", systemImage: "play.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryCoachButton(tint: learningFocus.learningFocusTint))
    }

    @ViewBuilder private var focusedPracticeDestination: some View {
        skillPracticeDestination(learningFocus)
    }

    private var improvementSkills: [SkillArea] {
        learningFocus.supportingImprovementSkills
    }

    private var moreImprovementsSection: some View {
        DisclosureGroup(isExpanded: $showsImprovementRecommendations) {
            CoachCard(padding: 8, tint: CoachTheme.reward) {
                VStack(spacing: 0) {
                    ForEach(Array(improvementSkills.enumerated()), id: \.element) { offset, skill in
                        NavigationLink {
                            skillPracticeDestination(skill)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: skill.learningFocusIcon)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(skill.learningFocusTint)
                                    .frame(width: 40, height: 40)
                                    .background(skill.learningFocusTint.opacity(0.14), in: Circle())

                                VStack(alignment: .leading, spacing: 2) {
                                    TeachingText(english: skill.learningFocusTitle)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    TeachingText(english: skill.learningFocusDetail)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.tertiary)
                                    .accessibilityHidden(true)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(CoachCardButtonStyle())
                        .teachingAccessibilityHint(skill.learningFocusDetail)

                        if offset < improvementSkills.count - 1 {
                            Divider().padding(.leading, 58)
                        }
                    }
                }
            }
            .padding(.top, 10)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .foregroundStyle(CoachTheme.reward)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    TeachingText(english: "More improvements for you")
                        .font(.callout.weight(.bold))
                        .foregroundStyle(.primary)
                    TeachingText(english: "Recommended practice")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .tint(CoachTheme.reward)
        .padding(13)
        .background(
            CoachTheme.elevatedSurface,
            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                .stroke(CoachTheme.reward.opacity(0.18))
        )
        .onChange(of: showsImprovementRecommendations) { _, _ in
            CoachFeedback.selection()
        }
    }

    @ViewBuilder private func skillPracticeDestination(_ skill: SkillArea) -> some View {
        switch skill {
        case .grammar:
            GrammarFlashcardsView(level: selectedLevel)
        case .vocabulary:
            VocabularyFlashcardsView(level: selectedLevel)
        case .listening:
            ListeningDrillView(level: selectedLevel)
        case .reading:
            ReadingDrillView(level: selectedLevel)
        case .writing:
            WritingPracticeView(level: selectedLevel)
        case .speaking:
            SpeakingPracticeView(level: selectedLevel)
        }
    }

    private var practiceCategoryPicker: some View {
        VStack(alignment: .leading, spacing: 9) {
            TeachingText(english: "Practice type")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)

            LazyVGrid(columns: practiceModeColumns, spacing: 10) {
                ForEach(PracticeCategory.allCases, id: \.self) { category in
                    practiceModeButton(category)
                }
            }
        }
    }

    private var practiceModeChooser: some View {
        DisclosureGroup(isExpanded: $showsPracticeTypes) {
            practiceCategoryPicker
                .padding(.top, 12)
        } label: {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    CoachIconTile(icon: selectedCategory.icon, tint: selectedCategory.tint, size: 46)
                    practiceModeIdentity
                    Spacer(minLength: 6)
                    SkillChip(
                        title: selectedLevel.rawValue,
                        color: selectedCategory.tint,
                        translatesTitle: false
                    )
                }
                VStack(alignment: .leading, spacing: 9) {
                    HStack(spacing: 10) {
                        CoachIconTile(icon: selectedCategory.icon, tint: selectedCategory.tint, size: 42)
                        SkillChip(
                            title: selectedLevel.rawValue,
                            color: selectedCategory.tint,
                            translatesTitle: false
                        )
                    }
                    practiceModeIdentity
                }
            }
        }
        .tint(selectedCategory.tint)
        .padding(14)
        .background(
            CoachTheme.surfaceGradient(tint: selectedCategory.tint, colorScheme: colorScheme),
            in: RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
        )
        .overlay(alignment: .leading) {
            Capsule()
                .fill(selectedCategory.tint)
                .frame(width: 4)
                .padding(.vertical, 14)
                .accessibilityHidden(true)
        }
        .overlay(
            RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
                .stroke(selectedCategory.tint.opacity(0.18))
        )
        .shadow(color: selectedCategory.tint.opacity(colorScheme == .dark ? 0.08 : 0.06), radius: 7, y: 3)
        .onChange(of: showsPracticeTypes) { _, _ in CoachFeedback.selection() }
    }

    private var practiceModeIdentity: some View {
        VStack(alignment: .leading, spacing: 3) {
            TeachingText(english: selectedCategory.rawValue)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)
            TeachingText(english: practiceModeSummary)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var practiceModeSummary: String {
        switch selectedCategory {
        case .daily: "A balanced session based on your learning focus"
        case .skills: "Focused listening, speaking, reading, and writing"
        case .memory: "Visual vocabulary and grammar recall"
        case .game: "Fast matching and sentence challenges"
        case .realLife: "Guided voice role-play for everyday situations"
        case .exam: "Timed B1 tasks with readiness feedback"
        }
    }

    private var practiceModeColumns: [GridItem] {
        let count: Int
        if dynamicTypeSize.isAccessibilitySize {
            count = 1
        } else if horizontalSizeClass == .regular {
            count = 3
        } else {
            count = 2
        }
        return Array(
            repeating: GridItem(.flexible(), spacing: 10, alignment: .top),
            count: count
        )
    }

    private func practiceModeButton(_ category: PracticeCategory) -> some View {
        let isSelected = selectedCategory == category

        return Button {
            guard premium.isPremium || !category.requiresPremium else {
                CoachFeedback.selection()
                showsPremium = true
                return
            }
            guard !isSelected else { return }
            CoachFeedback.selection()
            if reduceMotion {
                selectedCategory = category
            } else {
                withAnimation(CoachMotion.navigation) {
                    selectedCategory = category
                }
            }
            showsPracticeTypes = false
        } label: {
            VStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 19, weight: .bold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isSelected ? Color.white : category.tint)
                    .frame(width: 36, height: 36)
                    .background(
                        isSelected ? Color.white.opacity(0.18) : category.tint.opacity(0.13),
                        in: Circle()
                    )
                    .accessibilityHidden(true)

                TeachingText(english: category.rawValue)
                    .font(.system(.callout, design: .rounded, weight: .bold))
                    .foregroundStyle(isSelected ? Color.white : Color.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, minHeight: 90)
            .background {
                RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                    .fill(
                        isSelected
                            ? AnyShapeStyle(CoachTheme.controlGradient(tint: category.tint))
                            : AnyShapeStyle(
                                CoachTheme.elevatedSurface
                            )
                    )
                    .matchedGeometryEffect(
                        id: isSelected ? "selected-practice-mode" : category.rawValue,
                        in: practiceModeNamespace
                    )
            }
            .background {
                RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                    .fill(category.tint.opacity(isSelected ? 0.32 : 0.14))
                    .offset(y: isSelected ? 5 : 2.5)
            }
            .overlay(
                RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                    .stroke(
                        CoachTheme.premiumBorder(tint: category.tint, colorScheme: colorScheme),
                        lineWidth: isSelected ? 1.4 : 1
                    )
            )
            .overlay(alignment: .topTrailing) {
                if category.requiresPremium && !premium.isPremium {
                    PremiumLockBadge()
                        .padding(6)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.94))
                        .padding(8)
                        .accessibilityHidden(true)
                }
            }
            .shadow(
                color: category.tint.opacity(isSelected ? 0.24 : 0.10),
                radius: isSelected ? 7 : 3,
                y: isSelected ? 4 : 2
            )
            .contentShape(RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous))
        }
        .buttonStyle(CoachCardButtonStyle())
        .teachingAccessibilityLabel(category.rawValue)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder private var practiceCategoryContent: some View {
        Group {
            switch selectedCategory {
            case .daily:
                practiceLoop
            case .realLife:
                realLifePractice
            case .skills:
                skillsHub
            case .memory:
                recallAndAccuracy
            case .game:
                gamePractice
            case .exam:
                examMode
            }
        }
        .id(selectedCategory)
        .transition(.opacity)
        .animation(CoachMotion.quick, value: selectedCategory)
    }

    private var skillsHub: some View {
        VStack(alignment: .leading, spacing: 16) {
            learningFocusCard
            activeSkills
            moreImprovementsSection
        }
    }

    private var levelPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            TeachingText(english: "Practice level")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
            Picker(selection: $selectedLevel) {
                ForEach(CEFRLevel.allCases) { level in
                    Text(level.rawValue).tag(level)
                }
            } label: {
                TeachingText(english: "Practice level")
            }
            .pickerStyle(.segmented)
        }
    }

    private var practiceLoop: some View {
        VStack(alignment: .leading, spacing: 11) {
            CoachSectionHeader(title: "Practice Loop", subtitle: "Three short steps you can repeat")

            CoachCard(padding: 14, tint: nextLoopStage?.tint ?? CoachTheme.correct) {
                VStack(alignment: .leading, spacing: 11) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .stroke(CoachTheme.stroke, lineWidth: 7)
                            Circle()
                                .trim(from: 0, to: loopProgress)
                                .stroke(
                                    CoachTheme.progressGradient(tint: nextLoopStage?.tint ?? CoachTheme.correct),
                                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                            Text("\(completedLoopStages.count)/3")
                                .font(.caption.monospacedDigit().weight(.bold))
                        }
                        .frame(width: 54, height: 54)
                        .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 7) {
                                SkillChip(title: selectedLevel.rawValue, color: CoachTheme.primary)
                                SkillChip(title: "Round \(loopRound)", color: CoachTheme.reward)
                            }
                            TeachingText(english: loopStatusTitle)
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .fixedSize(horizontal: false, vertical: true)
                            TeachingText(english: loopStatusDetail)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 4)
                    }

                    LessonProgressBar(progress: loopProgress)
                }
            }
            .accessibilityElement(children: .combine)
            .teachingAccessibilityLabel("Practice loop, round \(loopRound)")
            .teachingAccessibilityValue("\(completedLoopStages.count) of 3 steps complete")

            VStack(spacing: 8) {
                ForEach(PracticeLoopStage.allCases) { stage in
                    practiceLoopLink(stage)
                }
            }

            if nextLoopStage == nil {
                Button {
                    repeatPracticeLoop()
                } label: {
                    TeachingLabel(english: "Start round \(loopRound + 1)", systemImage: "arrow.clockwise")
                }
                .buttonStyle(PrimaryCoachButton(tint: CoachTheme.correct))
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(CoachMotion.standard, value: completedLoopStages.count)
    }

    private func practiceLoopLink(_ stage: PracticeLoopStage) -> some View {
        let isComplete = completedLoopStages.contains(stage)
        let isNext = nextLoopStage == stage
        let tint = isComplete ? CoachTheme.correct : stage.tint

        return NavigationLink {
            practiceLoopDestination(stage)
        } label: {
            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 10) {
                        practiceLoopIdentity(stage, isComplete: isComplete, isNext: isNext, tint: tint)
                        HStack {
                            Spacer()
                            practiceLoopAccessory(isComplete: isComplete, tint: tint)
                        }
                    }
                } else {
                    HStack(spacing: 12) {
                        practiceLoopIdentity(stage, isComplete: isComplete, isNext: isNext, tint: tint)
                        Spacer(minLength: 6)
                        practiceLoopAccessory(isComplete: isComplete, tint: tint)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
            .background(
                CoachTheme.surfaceGradient(tint: tint, colorScheme: colorScheme),
                in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
            )
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(tint)
                    .frame(width: 4)
                    .padding(.vertical, 10)
            }
            .overlay(
                RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                    .stroke(tint.opacity(isNext ? 0.42 : 0.18), lineWidth: isNext ? 1.5 : 1)
            )
        }
        .buttonStyle(CoachCardButtonStyle())
        .teachingAccessibilityHint(isComplete ? "Repeat this practice step" : "Start this practice step")
    }

    private func practiceLoopIdentity(
        _ stage: PracticeLoopStage,
        isComplete: Bool,
        isNext: Bool,
        tint: Color
    ) -> some View {
        HStack(spacing: 11) {
            Image(systemName: isComplete ? "checkmark" : stage.icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(isComplete ? .white : tint)
                .frame(width: 38, height: 38)
                .background(isComplete ? CoachTheme.correct : tint.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    TeachingText(english: stage.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if isNext {
                        TeachingText(english: "NEXT")
                            .font(.caption2.weight(.black))
                            .foregroundStyle(tint)
                    }
                }
                TeachingText(english: stage.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func practiceLoopAccessory(isComplete: Bool, tint: Color) -> some View {
        Image(systemName: isComplete ? "arrow.clockwise.circle.fill" : "play.circle.fill")
            .font(.title2)
            .foregroundStyle(tint)
            .accessibilityHidden(true)
    }

    @ViewBuilder private func practiceLoopDestination(_ stage: PracticeLoopStage) -> some View {
        switch stage {
        case .recall:
            QuizView(level: selectedLevel)
        case .listen:
            ListeningDrillView(level: selectedLevel)
        case .speak:
            SpeakingPracticeView(level: selectedLevel)
        }
    }

    private var loopActivities: [LearningActivity] {
        activities.filter {
            $0.level == selectedLevel.rawValue && $0.createdAt >= loopStart
        }
    }

    private var completedLoopStages: Set<PracticeLoopStage> {
        Set(PracticeLoopStage.allCases.filter { $0.isComplete(in: loopActivities) })
    }

    private var nextLoopStage: PracticeLoopStage? {
        PracticeLoopStage.allCases.first { !completedLoopStages.contains($0) }
    }

    private var loopProgress: Double {
        Double(completedLoopStages.count) / Double(PracticeLoopStage.allCases.count)
    }

    private var loopStatusTitle: String {
        nextLoopStage == nil ? "Round complete" : "Next: \(nextLoopStage?.title ?? "Practice")"
    }

    private var loopStatusDetail: String {
        if nextLoopStage == nil {
            return "You used recall, listening, and speaking together."
        }
        return nextLoopStage?.outcome ?? "Keep your German active."
    }

    private func loadPracticeLoop(for level: CEFRLevel) {
        let defaults = UserDefaults.standard
        let interval = defaults.double(forKey: loopStartKey(for: level))
        let storedStart = Date(timeIntervalSince1970: interval)

        if interval > 0, Calendar.current.isDateInToday(storedStart) {
            loopStart = storedStart
            loopRound = max(defaults.integer(forKey: loopRoundKey(for: level)), 1)
        } else {
            loopStart = Calendar.current.startOfDay(for: .now)
            loopRound = 1
            persistPracticeLoop(for: level)
        }
    }

    private func repeatPracticeLoop() {
        loopStart = .now
        loopRound += 1
        persistPracticeLoop(for: selectedLevel)
        CoachFeedback.success()
    }

    private func persistPracticeLoop(for level: CEFRLevel) {
        let defaults = UserDefaults.standard
        defaults.set(loopStart.timeIntervalSince1970, forKey: loopStartKey(for: level))
        defaults.set(loopRound, forKey: loopRoundKey(for: level))
    }

    private func loopStartKey(for level: CEFRLevel) -> String {
        "practiceLoop.start.\(level.rawValue)"
    }

    private func loopRoundKey(for level: CEFRLevel) -> String {
        "practiceLoop.round.\(level.rawValue)"
    }

    private var activeSkills: some View {
        VStack(alignment: .leading, spacing: 11) {
            CoachSectionHeader(title: "Train a skill", subtitle: "Choose how you want to use German")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                skillLink("Speaking", detail: "Record & score", icon: "mic.fill", tint: CoachTheme.speaking) {
                    SpeakingPracticeView(level: selectedLevel)
                }
                skillLink("Listening", detail: "Hear & respond", icon: "headphones", tint: CoachTheme.listening) {
                    ListeningDrillView(level: selectedLevel)
                }
                skillLink("Reading", detail: "Read for meaning", icon: "doc.text.magnifyingglass", tint: CoachTheme.reading) {
                    ReadingDrillView(level: selectedLevel)
                }
                skillLink("Writing", detail: "Draft & reflect", icon: "square.and.pencil", tint: CoachTheme.writing) {
                    WritingPracticeView(level: selectedLevel)
                }
            }
        }
    }

    private var realLifePractice: some View {
        VStack(alignment: .leading, spacing: 11) {
            CoachSectionHeader(title: "Real-life missions", subtitle: "Listen, respond, and write through essential situations")
            NavigationLink {
                PracticalMissionsView(level: selectedLevel)
            } label: {
                CoachCard(tint: CoachTheme.speaking) {
                    HStack(spacing: 14) {
                        CoachIconTile(icon: "bubble.left.and.bubble.right.fill", tint: CoachTheme.speaking, size: 52)
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 7) {
                                SkillChip(title: selectedLevel.rawValue, color: CoachTheme.primary)
                                TeachingText(english: selectedLevel == .b1 ? "13 scenarios" : "6 scenarios")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                            TeachingText(english: "Practical conversation")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.primary)
                            TeachingText(english: "Natural offline voice, live corrections, translations, text mode, and written follow-up.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 4)
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundStyle(CoachTheme.speaking)
                    }
                }
            }
            .buttonStyle(CoachCardButtonStyle())

            NavigationLink {
                EverydayPhrasebookView(focusLevel: selectedLevel)
            } label: {
                CoachCard(tint: CoachTheme.listening) {
                    HStack(spacing: 14) {
                        CoachIconTile(icon: "quote.bubble.fill", tint: CoachTheme.listening, size: 52)
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 7) {
                                SkillChip(title: "240 phrases", color: CoachTheme.listening)
                                SkillChip(title: "A1–B1", color: CoachTheme.primary)
                            }
                            TeachingText(english: "Everyday phrasebook")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.primary)
                            TeachingText(english: "Search, hear, translate, and save the German you need most often.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 4)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .buttonStyle(CoachCardButtonStyle())
        }
    }

    private var recallAndAccuracy: some View {
        VStack(alignment: .leading, spacing: 11) {
            CoachSectionHeader(title: "Recall & accuracy", subtitle: "Strengthen memory and sentence control")
            VStack(spacing: 10) {
                practiceRow(
                    "Vocabulary cards",
                    detail: "Words, examples, articles, and plurals",
                    icon: "rectangle.stack.fill",
                    tint: CoachTheme.accent
                ) {
                    VocabularyFlashcardsView(level: selectedLevel)
                }
                practiceRow(
                    "Grammar cards",
                    detail: "Rules, examples, and common mistakes",
                    icon: "text.book.closed.fill",
                    tint: CoachTheme.primary
                ) {
                    GrammarFlashcardsView(level: selectedLevel)
                }
                practiceRow(
                    "Quiz trainer",
                    detail: "Choose a specific question category",
                    icon: "checklist",
                    tint: CoachTheme.reading
                ) {
                    QuizView(level: selectedLevel)
                }
            }
        }
    }

    private var examMode: some View {
        VStack(alignment: .leading, spacing: 11) {
            CoachSectionHeader(title: "Exam mode", subtitle: "Build confidence under realistic conditions")
            NavigationLink {
                ExamPrepView()
            } label: {
                CoachCard(tint: CoachTheme.listening) {
                    HStack(spacing: 14) {
                        CoachIconTile(icon: "checkmark.seal.fill", tint: CoachTheme.listening, size: 50)
                        VStack(alignment: .leading, spacing: 4) {
                            TeachingText(english: "B1 Mock Exam")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.primary)
                            TeachingText(english: "Timed sections, model answers, and scoring rubrics")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 4)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .buttonStyle(CoachCardButtonStyle())
        }
    }

    private var gamePractice: some View {
        VStack(alignment: .leading, spacing: 11) {
            CoachSectionHeader(
                title: "Learn by playing",
                subtitle: "Fast rounds for vocabulary recall and German sentence control"
            )
            NavigationLink {
                VocabularyMatchGameView(level: selectedLevel)
            } label: {
                CoachCard(tint: CoachTheme.reward) {
                    HStack(spacing: 14) {
                        CoachIconTile(icon: "square.grid.2x2.fill", tint: CoachTheme.reward, size: 52)
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 7) {
                                SkillChip(title: selectedLevel.rawValue, color: CoachTheme.primary)
                                SkillChip(title: "4 pairs", color: CoachTheme.correct)
                            }
                            TeachingText(english: "Word Match")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.primary)
                            TeachingText(english: "Pair German words with their meanings, build combos, and hear every match.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 4)
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundStyle(CoachTheme.reward)
                    }
                }
            }
            .buttonStyle(CoachCardButtonStyle())

            NavigationLink {
                SentenceBuilderGameView(level: selectedLevel)
            } label: {
                CoachCard(tint: CoachTheme.accent) {
                    HStack(spacing: 14) {
                        CoachIconTile(icon: "rectangle.3.group.fill", tint: CoachTheme.accent, size: 52)
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 7) {
                                SkillChip(title: selectedLevel.rawValue, color: CoachTheme.primary)
                                SkillChip(title: "8 sentences", color: CoachTheme.correct)
                            }
                            TeachingText(english: "Sentence Builder")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.primary)
                            TeachingText(english: "Build real German word order, earn combos, and learn how and why every sentence works.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 4)
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundStyle(CoachTheme.accent)
                    }
                }
            }
            .buttonStyle(CoachCardButtonStyle())
        }
    }

    private func skillLink<Destination: View>(
        _ title: String,
        detail: String,
        icon: String,
        tint: Color,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            VStack(alignment: .leading, spacing: 11) {
                CoachIconTile(icon: icon, tint: tint)
                VStack(alignment: .leading, spacing: 2) {
                    TeachingText(english: title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    TeachingText(english: detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 108, alignment: .leading)
            .background(
                CoachTheme.elevatedSurface,
                in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
            )
            .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(Color.primary.opacity(0.08)))
        }
        .buttonStyle(CoachCardButtonStyle())
    }

    private func practiceRow<Destination: View>(
        _ title: String,
        detail: String,
        icon: String,
        tint: Color,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            CoachCard(padding: 15, tint: tint) {
                HStack(spacing: 12) {
                    CoachIconTile(icon: icon, tint: tint)
                    VStack(alignment: .leading, spacing: 3) {
                        TeachingText(english: title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        TeachingText(english: detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer(minLength: 4)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .buttonStyle(CoachCardButtonStyle())
    }
}

private enum PracticeCategory: String, CaseIterable, Hashable {
    case daily = "Loop"
    case realLife = "Real life"
    case skills = "Skills"
    case memory = "Memory"
    case game = "Game"
    case exam = "Exam"

    var icon: String {
        switch self {
        case .daily: "repeat.circle.fill"
        case .realLife: "bubble.left.and.bubble.right.fill"
        case .skills: "slider.horizontal.3"
        case .memory: "rectangle.stack.fill"
        case .game: "gamecontroller.fill"
        case .exam: "checkmark.seal.fill"
        }
    }

    var tint: Color {
        switch self {
        case .daily: CoachTheme.primary
        case .realLife: CoachTheme.speaking
        case .skills: CoachTheme.listening
        case .memory: CoachTheme.accent
        case .game: CoachTheme.reward
        case .exam: CoachTheme.reading
        }
    }

    var requiresPremium: Bool {
        switch self {
        case .daily, .memory: false
        case .realLife, .skills, .game, .exam: true
        }
    }
}

private enum PracticeLoopStage: String, CaseIterable, Identifiable {
    case recall
    case listen
    case speak

    var id: String { rawValue }

    var title: String {
        switch self {
        case .recall: "Daily Mix"
        case .listen: "Listen"
        case .speak: "Speak"
        }
    }

    var detail: String {
        switch self {
        case .recall: "Complete one mixed recall check"
        case .listen: "Understand one real audio prompt"
        case .speak: "Record and improve one response"
        }
    }

    var outcome: String {
        switch self {
        case .recall: "Wake up the words and rules you already know."
        case .listen: "Connect natural German audio to meaning."
        case .speak: "Turn recognition into confident production."
        }
    }

    var icon: String {
        switch self {
        case .recall: "sparkles"
        case .listen: "headphones"
        case .speak: "mic.fill"
        }
    }

    var tint: Color {
        switch self {
        case .recall: CoachTheme.accent
        case .listen: CoachTheme.listening
        case .speak: CoachTheme.speaking
        }
    }

    func isComplete(in activities: [LearningActivity]) -> Bool {
        switch self {
        case .recall:
            activities.contains { $0.sourceId.hasPrefix("quiz-") }
        case .listen:
            activities.contains { $0.sourceId.hasPrefix("listening-") }
        case .speak:
            activities.contains { $0.sourceId.hasPrefix("speaking-") }
        }
    }
}
