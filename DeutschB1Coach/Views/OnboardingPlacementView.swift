import SwiftUI

private struct PlacementQuestionItem {
    let level: CEFRLevel
    let skill: SkillArea
    let germanContext: String?
    let prompt: String
    let choices: [String]
    let answer: String
    let translatesChoices: Bool
}

struct OnboardingPlacementView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var didCompletePlacement: Bool
    @AppStorage("preferredLevel") private var preferredLevel = CEFRLevel.a1.rawValue
    @AppStorage("placementRecommendedLevel") private var placementRecommendedLevel = ""
    @AppStorage("learnerName") private var learnerName = ""
    @AppStorage(TeachingLanguage.storageKey) private var teachingLanguageCode = TeachingLanguage.defaultLanguage.rawValue
    @State private var index = 0
    @State private var selections: [Int: String] = [:]
    @State private var result: PlacementResult?
    @State private var stage: OnboardingStage = .passport
    @FocusState private var isNameFocused: Bool

    private var teachingLanguage: TeachingLanguage { TeachingLanguage.resolve(teachingLanguageCode) }

    private let questions: [PlacementQuestionItem] = [
        .init(level: .a1, skill: .grammar, germanContext: "Ich ___ aus Berlin.", prompt: "Choose the missing German word.", choices: ["komme", "kommt", "kommen"], answer: "komme", translatesChoices: false),
        .init(level: .a1, skill: .vocabulary, germanContext: "die Wohnung", prompt: "What does this German word mean?", choices: ["the apartment", "the weather", "the train"], answer: "the apartment", translatesChoices: true),
        .init(level: .a1, skill: .reading, germanContext: "Die Apotheke ist heute geschlossen.", prompt: "What is closed?", choices: ["the pharmacy", "the school", "the bank"], answer: "the pharmacy", translatesChoices: true),
        .init(level: .a1, skill: .listening, germanContext: nil, prompt: "Which phrase politely orders coffee?", choices: ["Ich möchte einen Kaffee, bitte.", "Kaffee jetzt.", "Du Kaffee."], answer: "Ich möchte einen Kaffee, bitte.", translatesChoices: false),
        .init(level: .a2, skill: .grammar, germanContext: "Ich bleibe zu Hause, ___ ich krank bin.", prompt: "Choose the missing German connector.", choices: ["weil", "aber", "oder"], answer: "weil", translatesChoices: false),
        .init(level: .a2, skill: .reading, germanContext: "Gestern habe ich eingekauft.", prompt: "When did it happen?", choices: ["yesterday", "tomorrow", "now"], answer: "yesterday", translatesChoices: true),
        .init(level: .a2, skill: .vocabulary, germanContext: "die Verspätung", prompt: "What does this German word mean?", choices: ["delay", "departure", "reservation"], answer: "delay", translatesChoices: true),
        .init(level: .a2, skill: .grammar, germanContext: "Das Buch liegt auf ___ Tisch.", prompt: "Choose the correct German article form.", choices: ["dem", "den", "der"], answer: "dem", translatesChoices: false),
        .init(level: .b1, skill: .grammar, germanContext: "Wenn ich mehr Zeit hätte, ___ ich Deutsch üben.", prompt: "Choose the missing German verb.", choices: ["würde", "werde", "war"], answer: "würde", translatesChoices: false),
        .init(level: .b1, skill: .writing, germanContext: nil, prompt: "Choose the best opening for a formal email.", choices: ["Sehr geehrte Damen und Herren,", "Hallo Leute!", "Tschüss,"], answer: "Sehr geehrte Damen und Herren,", translatesChoices: false),
        .init(level: .b1, skill: .reading, germanContext: "Trotz der Verspätung erreichte sie den Termin.", prompt: "Did she reach the appointment?", choices: ["Yes", "No", "The text does not say"], answer: "Yes", translatesChoices: true),
        .init(level: .b1, skill: .grammar, germanContext: "Der Antrag ___ gerade geprüft.", prompt: "Choose the missing German verb.", choices: ["wird", "hat", "würde"], answer: "wird", translatesChoices: false)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    if stage == .passport {
                        passportWelcome
                            .transition(contentTransition)
                    } else {
                        placementHeader
                        if let result {
                            resultView(result)
                                .transition(contentTransition)
                        } else {
                            questionView(questions[index])
                                .id(index)
                                .transition(questionTransition)
                        }
                    }
                }
                .padding()
            }
            .teachingNavigationTitle(stage == .passport ? "Welcome" : "Placement")
            .navigationBarTitleDisplayMode(.inline)
            .coachBackground()
            .toolbar {
                if stage == .placement && result == nil {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            transition(to: .passport)
                        } label: {
                            TeachingLabel(english: "Passport", systemImage: "person.text.rectangle")
                        }
                    }
                }
            }
            .animation(reduceMotion ? nil : CoachMotion.standard, value: stage)
            .animation(reduceMotion ? nil : CoachMotion.standard, value: result != nil)
        }
    }

    private var passportWelcome: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                SkillChip(title: "WELCOME", color: CoachTheme.accent)
                TeachingText(english: "Begin your German journey")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .fixedSize(horizontal: false, vertical: true)
                TeachingText(english: "Create a private learning passport, then find the right place to begin.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            CoachCard(tint: CoachTheme.accent) {
                VStack(alignment: .leading, spacing: 12) {
                    Label {
                        TeachingText(english: "Personalize your passport")
                    } icon: {
                        Image(systemName: "person.crop.circle.badge.plus")
                    }
                    .font(.headline)
                    .foregroundStyle(CoachTheme.accent)

                    TeachingTextField(prompt: "Name (optional)", text: $learnerName)
                        .textFieldStyle(CoachTextFieldStyle(tint: isNameFocused ? CoachTheme.accent : CoachTheme.primary))
                        .textContentType(.name)
                        .focused($isNameFocused)
                        .scaleEffect(isNameFocused && !reduceMotion ? 1.01 : 1)
                        .animation(reduceMotion ? nil : CoachMotion.quick, value: isNameFocused)

                    Divider()

                    Menu {
                        ForEach(TeachingLanguage.allCases) { language in
                            Button {
                                teachingLanguageCode = language.rawValue
                                CoachFeedback.selection()
                            } label: {
                                if language == teachingLanguage {
                                    Label(language.flaggedPickerName, systemImage: "checkmark")
                                } else {
                                    Text(language.flaggedPickerName)
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "globe")
                                .foregroundStyle(CoachTheme.listening)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(teachingLanguage.interfaceText(.teachingLanguage))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                HStack(spacing: 5) {
                                    Text(teachingLanguage.flag)
                                        .accessibilityHidden(true)
                                    Text(teachingLanguage.pickerName)
                                }
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel(teachingLanguage.pickerName)
                            }
                            Spacer(minLength: 4)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                    }

                    TeachingLanguageStatusView()

                    TeachingLabel(english: "Your name, language, and progress stay on this iPhone.", systemImage: "lock.shield.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Button {
                isNameFocused = false
                transition(to: .placement)
            } label: {
                TeachingLabel(english: "Find my starting level", systemImage: "location.magnifyingglass")
            }
            .buttonStyle(PrimaryCoachButton(tint: CoachTheme.primary))

            Button(teachingLanguage.interfaceText(.startFromA1)) {
                completeOnboarding(level: .a1)
            }
            .font(.callout.weight(.semibold))
            .buttonStyle(SecondaryCoachButton(tint: CoachTheme.listening))
            .frame(maxWidth: .infinity)
        }
    }

    private var placementHeader: some View {
        HStack(spacing: 12) {
            CoachMascot(mood: result == nil ? .supportive : .achievement, size: 58, animates: false)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("Deutsch B1 Coach")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                TeachingText(english: result == nil ? "Find your starting level" : "Your learning path is ready")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var contentTransition: AnyTransition {
        reduceMotion ? .identity : .opacity.combined(with: .offset(y: 4))
    }

    private var questionTransition: AnyTransition {
        reduceMotion
            ? .identity
            : .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
    }

    private func questionView(_ question: PlacementQuestionItem) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 9) {
                HStack {
                    TeachingText(english: "Question \(index + 1) of \(questions.count)")
                        .font(.callout.monospacedDigit().weight(.semibold))
                    Spacer()
                    SkillChip(title: question.level.rawValue, color: CoachTheme.primary)
                }
                LessonProgressBar(progress: Double(index + 1) / Double(questions.count))
                    .frame(height: 8)
            }

            CoachCard {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 7) {
                        Image(systemName: icon(for: question.skill))
                            .foregroundStyle(color(for: question.skill))
                        TeachingText(english: question.skill.rawValue.capitalized)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(color(for: question.skill))
                    }

                    if let germanContext = question.germanContext {
                        Text(germanContext)
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .environment(\.layoutDirection, .leftToRight)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    TeachingText(english: question.prompt)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .fixedSize(horizontal: false, vertical: true)

                    ForEach(question.choices, id: \.self) { choice in
                        let isSelected = selections[index] == choice
                        Button {
                            select(choice)
                        } label: {
                            HStack(spacing: 12) {
                                Group {
                                    if question.translatesChoices {
                                        TeachingText(english: choice)
                                    } else {
                                        Text(choice)
                                            .environment(\.layoutDirection, .leftToRight)
                                    }
                                }
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                                Spacer()
                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(isSelected ? CoachTheme.primary : Color.secondary.opacity(0.5))
                                    .contentTransition(.symbolEffect(.replace))
                            }
                            .padding(13)
                            .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                            .background(
                                LinearGradient(
                                    colors: isSelected
                                        ? [CoachTheme.softMint, CoachTheme.primary.opacity(0.16), CoachTheme.rewardGlow.opacity(0.08)]
                                        : [CoachTheme.elevatedSurface, CoachTheme.primary.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
                                    .stroke(isSelected ? CoachTheme.primary.opacity(0.65) : Color.primary.opacity(0.06))
                            )
                        }
                        .buttonStyle(.plain)
                        .teachingAccessibilityValue(isSelected ? "Selected" : "Not selected")
                    }
                }
            }

            HStack(spacing: 10) {
                if index > 0 {
                    Button {
                        withAnimation(CoachMotion.standard) {
                            index -= 1
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .frame(width: 46, height: 46)
                    }
                    .buttonStyle(CoachIconButtonStyle(tint: CoachTheme.primary))
                    .teachingAccessibilityLabel("Previous question")
                }

                Button {
                    advance()
                } label: {
                    HStack {
                        if index + 1 == questions.count {
                            TeachingText(english: "See my level")
                        } else {
                            Text(teachingLanguage.interfaceText(.continueAction))
                        }
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(PrimaryCoachButton())
                .disabled(selections[index] == nil)
            }

            Button(teachingLanguage.interfaceText(.startFromA1)) {
                completeOnboarding(level: .a1)
            }
            .font(.callout.weight(.medium))
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
        }
    }

    private func resultView(_ result: PlacementResult) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            CoachCard(tint: CoachTheme.correct) {
                VStack(alignment: .leading, spacing: 16) {
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 14) {
                            CoachMascot(mood: .achievement, size: 72)
                                .accessibilityHidden(true)
                            resultTitle(result)
                            Spacer(minLength: 6)
                            PassportCompletionStamp(level: result.recommendedLevel)
                        }
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                CoachMascot(mood: .achievement, size: 64)
                                    .accessibilityHidden(true)
                                resultTitle(result)
                            }
                            PassportCompletionStamp(level: result.recommendedLevel)
                        }
                    }

                    TeachingText(english: result.message)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    LessonProgressBar(progress: result.confidence)
                }
            }

            LanguagePassportCard(learnerName: learnerName, teachingLanguage: teachingLanguage)

            CoachCard(tint: CoachTheme.accent) {
                VStack(alignment: .leading, spacing: 8) {
                    TeachingText(english: "Name on your passport")
                        .font(.headline)
                    TeachingTextField(prompt: "Name (optional)", text: $learnerName)
                        .textFieldStyle(CoachTextFieldStyle(tint: isNameFocused ? CoachTheme.accent : CoachTheme.primary))
                        .textContentType(.name)
                        .focused($isNameFocused)
                        .scaleEffect(isNameFocused && !reduceMotion ? 1.01 : 1)
                        .animation(reduceMotion ? nil : CoachMotion.quick, value: isNameFocused)
                }
            }

            Button {
                completeOnboarding(level: result.recommendedLevel)
            } label: {
                TeachingLabel(english: "Start my \(result.recommendedLevel.rawValue) path", systemImage: "flag.checkered")
            }
            .buttonStyle(PrimaryCoachButton(tint: CoachTheme.correct))
        }
    }

    private func resultTitle(_ result: PlacementResult) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            TeachingText(english: "Start at \(result.recommendedLevel.rawValue)")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .fixedSize(horizontal: false, vertical: true)
            Text("\(Int(result.confidence * 100))% confidence")
                .font(.callout.monospacedDigit().weight(.semibold))
                .foregroundStyle(CoachTheme.correct)
        }
    }

    private func advance() {
        if index + 1 < questions.count {
            withAnimation(CoachMotion.standard) {
                index += 1
            }
        } else {
            let answers = questions.indices.compactMap { questionIndex -> PlacementAnswer? in
                guard let choice = selections[questionIndex] else { return nil }
                let question = questions[questionIndex]
                return PlacementAnswer(
                    level: question.level,
                    skill: question.skill,
                    isCorrect: choice == question.answer
                )
            }
            let placementResult = PlacementEngine().place(answers: answers)
            if reduceMotion {
                result = placementResult
            } else {
                withAnimation(CoachMotion.celebration) {
                    result = placementResult
                }
            }
            CoachFeedback.success()
        }
    }

    private func select(_ choice: String) {
        CoachFeedback.selection()
        if reduceMotion {
            selections[index] = choice
        } else {
            withAnimation(CoachMotion.spring) {
                selections[index] = choice
            }
        }
    }

    private func transition(to newStage: OnboardingStage) {
        if reduceMotion {
            stage = newStage
        } else {
            withAnimation(CoachMotion.spring) {
                stage = newStage
            }
        }
    }

    private func completeOnboarding(level: CEFRLevel) {
        isNameFocused = false
        preferredLevel = level.rawValue
        placementRecommendedLevel = level.rawValue
        PrivateProductAnalytics.record(.onboardingCompleted)
        CoachFeedback.success()
        didCompletePlacement = true
    }

    private func icon(for skill: SkillArea) -> String {
        switch skill {
        case .speaking: "mic.fill"
        case .listening: "headphones"
        case .writing: "square.and.pencil"
        case .reading: "doc.text.fill"
        case .vocabulary: "rectangle.stack.fill"
        default: "text.book.closed.fill"
        }
    }

    private func color(for skill: SkillArea) -> Color {
        switch skill {
        case .speaking: CoachTheme.speaking
        case .listening: CoachTheme.listening
        case .writing: CoachTheme.writing
        case .reading: CoachTheme.reading
        case .vocabulary: CoachTheme.accent
        default: CoachTheme.primary
        }
    }
}

private enum OnboardingStage {
    case passport
    case placement
}

struct LearningWeaknessSelectionView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedSkill: SkillArea?
    let onComplete: (SkillArea) -> Void

    init(initialSkill: SkillArea? = nil, onComplete: @escaping (SkillArea) -> Void) {
        _selectedSkill = State(initialValue: initialSkill)
        self.onComplete = onComplete
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    CoachCard(tint: CoachTheme.listening) {
                        HStack(alignment: .top, spacing: 14) {
                            CoachIconTile(icon: "scope", tint: CoachTheme.listening, size: 54)
                            VStack(alignment: .leading, spacing: 6) {
                                TeachingText(english: "Where do you need the most help?")
                                    .font(.system(.title2, design: .rounded, weight: .bold))
                                    .fixedSize(horizontal: false, vertical: true)
                                TeachingText(
                                    english: "Choose one focus. Your practice will adapt, and you can change it later."
                                )
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }

                    VStack(spacing: 10) {
                        ForEach(SkillArea.allCases) { skill in
                            weaknessButton(skill)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .teachingNavigationTitle("Learning focus")
            .coachBackground()
            .safeAreaInset(edge: .bottom, spacing: 0) {
                TeachingButton("Continue") {
                    guard let selectedSkill else { return }
                    CoachFeedback.success()
                    onComplete(selectedSkill)
                }
                .buttonStyle(PrimaryCoachButton(tint: selectedSkill?.learningFocusTint ?? CoachTheme.primary))
                .disabled(selectedSkill == nil)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.regularMaterial)
            }
        }
    }

    private func weaknessButton(_ skill: SkillArea) -> some View {
        let isSelected = selectedSkill == skill
        let tint = skill.learningFocusTint

        return Button {
            CoachFeedback.selection()
            if reduceMotion {
                selectedSkill = skill
            } else {
                withAnimation(CoachMotion.spring) {
                    selectedSkill = skill
                }
            }
        } label: {
            HStack(spacing: 13) {
                Image(systemName: skill.learningFocusIcon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isSelected ? .white : tint)
                    .frame(width: 44, height: 44)
                    .background(isSelected ? tint : tint.opacity(0.14), in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    TeachingText(english: skill.learningFocusTitle)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    TeachingText(english: skill.learningFocusDetail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 6)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? tint : Color.secondary.opacity(0.45))
                    .contentTransition(.symbolEffect(.replace))
            }
            .padding(13)
            .frame(maxWidth: .infinity, minHeight: 74, alignment: .leading)
            .background(
                CoachTheme.surfaceGradient(tint: tint, colorScheme: colorScheme),
                in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                    .stroke(tint.opacity(isSelected ? 0.62 : 0.18), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(CoachCardButtonStyle())
        .teachingAccessibilityLabel(skill.learningFocusTitle)
        .teachingAccessibilityHint(skill.learningFocusDetail)
        .teachingAccessibilityValue(isSelected ? "Selected" : "Not selected")
    }
}
