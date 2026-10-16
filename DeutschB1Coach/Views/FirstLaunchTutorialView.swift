import SwiftUI

struct FirstLaunchTutorialView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage(TeachingLanguage.storageKey) private var teachingLanguageCode = TeachingLanguage.defaultLanguage.rawValue
    @Binding var didCompleteTutorial: Bool
    @State private var selectedPage = 0

    private var teachingLanguage: TeachingLanguage {
        TeachingLanguage.resolve(teachingLanguageCode)
    }

    private var pages: [FirstLaunchTutorialPage] {
        [
            .init(
                title: "Welcome to your German journey",
                message: "Learn, practice, review, and track progress from one clear home.",
                icon: "sparkles",
                tint: CoachTheme.primary,
                mood: .welcome,
                artwork: .home
            ),
            .init(
                title: "Learn with a clear path",
                message: "Follow A1, A2, and B1 course books in order. Lessons unlock as you make progress.",
                icon: "books.vertical.fill",
                tint: CoachTheme.listening,
                mood: .supportive,
                artwork: .coursePath
            ),
            .init(
                title: "Practice real conversations",
                message: "Listen, speak, and repeat in everyday situations. The coach corrects your answer and helps you try again.",
                icon: "bubble.left.and.bubble.right.fill",
                tint: CoachTheme.speaking,
                mood: .supportive,
                artwork: .conversation
            ),
        ]
    }

    private var isLastPage: Bool {
        selectedPage == pages.count - 1
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            TabView(selection: $selectedPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    tutorialPage(page, index: index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            bottomBar
        }
        .background(CoachTheme.pageGradient.ignoresSafeArea())
        .environment(\.layoutDirection, teachingLanguage.isRightToLeft ? .rightToLeft : .leftToRight)
        .animation(reduceMotion ? nil : CoachMotion.navigation, value: selectedPage)
        .onChange(of: selectedPage) { _, _ in
            CoachFeedback.selection()
        }
    }

    private var topBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                SkillChip(title: "DEUTSCH A1-B1", color: pages[selectedPage].tint, translatesTitle: false)
                Spacer(minLength: 8)
                Button {
                    completeTutorial()
                } label: {
                    TeachingText(english: "Skip tutorial")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(CoachTheme.primary)
                        .padding(.horizontal, 8)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 6) {
                ForEach(pages.indices, id: \.self) { index in
                    Capsule()
                        .fill(index <= selectedPage ? pages[index].tint : Color.secondary.opacity(0.20))
                        .frame(maxWidth: .infinity, minHeight: 5, maxHeight: 5)
                }
            }
            .accessibilityElement(children: .ignore)
            .teachingAccessibilityLabel("Tutorial progress")
            .teachingAccessibilityValue("\(selectedPage + 1) of \(pages.count)")
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func tutorialPage(_ page: FirstLaunchTutorialPage, index: Int) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                FirstLaunchTutorialArtwork(
                    artwork: page.artwork,
                    tint: page.tint,
                    mood: page.mood,
                    teachingLanguage: teachingLanguage
                )
                .id(page.artwork)
                .transition(reduceMotion ? .identity : .opacity.combined(with: .scale(scale: 0.98)))

                VStack(alignment: .leading, spacing: 9) {
                    HStack(spacing: 9) {
                        Image(systemName: page.icon)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(page.tint, in: Circle())
                            .accessibilityHidden(true)
                        Text("\(index + 1) / \(pages.count)")
                            .font(.caption.monospacedDigit().weight(.heavy))
                            .foregroundStyle(page.tint)
                    }

                    TeachingText(english: page.title)
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .fixedSize(horizontal: false, vertical: true)

                    TeachingText(english: page.message)
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: 620, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 18)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            if selectedPage > 0 {
                Button {
                    move(to: selectedPage - 1)
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.headline.weight(.bold))
                        .frame(width: 52, height: 52)
                }
                .buttonStyle(CoachIconButtonStyle(tint: pages[selectedPage].tint))
                .teachingAccessibilityLabel("Previous tutorial page")
            }

            Button {
                if isLastPage {
                    completeTutorial()
                } else {
                    move(to: selectedPage + 1)
                }
            } label: {
                HStack(spacing: 9) {
                    TeachingText(english: isLastPage ? "Start" : "Next")
                    Image(systemName: isLastPage ? "checkmark" : "arrow.forward")
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryCoachButton(tint: pages[selectedPage].tint))
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }

    private func move(to page: Int) {
        if reduceMotion {
            selectedPage = page
        } else {
            withAnimation(CoachMotion.navigation) {
                selectedPage = page
            }
        }
    }

    private func completeTutorial() {
        didCompleteTutorial = true
        CoachFeedback.success()
    }
}

private struct FirstLaunchTutorialPage {
    let title: String
    let message: String
    let icon: String
    let tint: Color
    let mood: CoachMascotMood
    let artwork: FirstLaunchTutorialArtworkKind
}

private enum FirstLaunchTutorialArtworkKind: Hashable {
    case home
    case coursePath
    case visualVocabulary
    case grammar
    case conversation
    case review
    case progress
    case exam
    case orientation
    case focus
}

private struct FirstLaunchTutorialArtwork: View {
    let artwork: FirstLaunchTutorialArtworkKind
    let tint: Color
    let mood: CoachMascotMood
    let teachingLanguage: TeachingLanguage

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [CoachTheme.elevatedSurface, tint.opacity(0.14), CoachTheme.rewardGlow.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                .stroke(tint.opacity(0.24), lineWidth: 1)

            artworkContent
                .padding(20)

            CoachMascot(mood: mood, size: 58, animates: true)
                .padding(12)
        }
        .frame(maxWidth: .infinity, minHeight: 240)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder private var artworkContent: some View {
        switch artwork {
        case .home:
            home
        case .coursePath:
            coursePath
        case .visualVocabulary:
            visualVocabulary
        case .grammar:
            grammar
        case .conversation:
            conversation
        case .review:
            review
        case .progress:
            progress
        case .exam:
            exam
        case .orientation:
            orientation
        case .focus:
            focus
        }
    }

    private var home: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(CoachTheme.reward)
                Text("Heute")
                    .font(.system(.title2, design: .rounded, weight: .bold))
            }

            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Image(systemName: "book.fill")
                    Text("A1 · Lektion 4")
                        .font(.callout.weight(.bold))
                    Spacer(minLength: 8)
                    Text("64%")
                        .font(.caption.monospacedDigit().weight(.bold))
                }
                .foregroundStyle(CoachTheme.primary)
                ProgressView(value: 0.64)
                    .tint(CoachTheme.primary)
            }

            HStack(spacing: 9) {
                Image(systemName: "play.fill")
                Text("Weiterlernen")
                    .font(.callout.weight(.bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 13)
            .frame(minHeight: 44)
            .background(CoachTheme.primary, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
            .padding(.trailing, 68)
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    private var coursePath: some View {
        VStack(alignment: .leading, spacing: 22) {
            Image(systemName: "map.fill")
                .font(.system(size: 38, weight: .bold))
                .foregroundStyle(tint)

            HStack(spacing: 0) {
                ForEach(Array(CEFRLevel.allCases.enumerated()), id: \.element) { index, level in
                    VStack(spacing: 7) {
                        Image(systemName: index == 0 ? "book.fill" : "lock.open.fill")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(levelTint(level), in: Circle())
                        Text(level.rawValue)
                            .font(.headline.weight(.heavy))
                            .foregroundStyle(levelTint(level))
                    }
                    if index < CEFRLevel.allCases.count - 1 {
                        Capsule()
                            .fill(CoachTheme.progressGradient(tint: levelTint(level)))
                            .frame(maxWidth: .infinity, minHeight: 5, maxHeight: 5)
                            .padding(.horizontal, 5)
                            .offset(y: -13)
                    }
                }
            }
            .environment(\.layoutDirection, .leftToRight)
            .padding(.trailing, 54)
        }
    }

    private var visualVocabulary: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 78, height: 78)
                    .background(tint.opacity(0.12), in: Circle())

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 7) {
                        Text("die")
                            .font(.headline.weight(.heavy))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(CoachTheme.accent, in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
                        Text("Tasse")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "speaker.wave.2.fill")
                        Text("die Tassen")
                    }
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(CoachTheme.listening)
                }
            }

            Text("Ich trinke Tee aus einer Tasse.")
                .font(.system(.callout, design: .rounded, weight: .semibold))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.trailing, 62)
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    private var conversation: some View {
        VStack(alignment: .leading, spacing: 11) {
            chatBubble("Guten Morgen! Wie kann ich Ihnen helfen?", tint: CoachTheme.listening)
                .padding(.trailing, 42)
            chatBubble("Ich möchte einen Termin vereinbaren.", tint: CoachTheme.speaking)
                .padding(.leading, 28)
                .padding(.trailing, 62)

            HStack(spacing: 9) {
                Image(systemName: "waveform")
                Image(systemName: "mic.fill")
                Text("Sprechen")
                    .font(.caption.weight(.bold))
            }
            .foregroundStyle(CoachTheme.speaking)
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    private var grammar: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 7) {
                grammarToken("Der Mann", label: "NOM", tint: CoachTheme.listening)
                grammarToken("kauft", label: "VERB", tint: CoachTheme.primary)
            }
            grammarToken("den Apfel.", label: "AKK", tint: CoachTheme.accent)

            HStack(spacing: 8) {
                Image(systemName: "arrow.right")
                Text("Position 1 · Position 2 · Ende")
                    .font(.caption.weight(.bold))
            }
            .foregroundStyle(CoachTheme.primary)
            .padding(.trailing, 62)
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    private func grammarToken(_ text: String, label: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption2.weight(.heavy))
                .foregroundStyle(tint)
            Text(text)
                .font(.system(.callout, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)
        }
        .padding(10)
        .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.smallRadius).stroke(tint.opacity(0.24)))
    }

    private var review: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                reviewTile("rectangle.stack.fill", tint: CoachTheme.accent)
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundStyle(.secondary)
                reviewTile("cup.and.saucer.fill", tint: CoachTheme.listening)
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(CoachTheme.correct)
            }

            HStack(spacing: 7) {
                Text("Ich")
                Text("lerne")
                Text("Deutsch.")
            }
            .font(.system(.callout, design: .rounded, weight: .bold))
            .padding(11)
            .background(CoachTheme.accent.opacity(0.10), in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
            .padding(.trailing, 66)
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    private func reviewTile(_ icon: String, tint: Color) -> some View {
        Image(systemName: icon)
            .font(.title2.weight(.bold))
            .foregroundStyle(tint)
            .frame(width: 54, height: 58)
            .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
    }

    private var progress: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 13) {
                ZStack {
                    ProgressView(value: 0.72)
                        .progressViewStyle(.circular)
                        .tint(CoachTheme.listening)
                        .scaleEffect(1.5)
                    Text("72%")
                        .font(.caption2.monospacedDigit().weight(.heavy))
                }
                .frame(width: 64, height: 64)

                VStack(alignment: .leading, spacing: 5) {
                    Label("12 Tage", systemImage: "flame.fill")
                        .foregroundStyle(CoachTheme.reward)
                    Label("148 Wörter", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(CoachTheme.correct)
                }
                .font(.callout.weight(.bold))
            }

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.secondary.opacity(0.18))
                    .frame(height: 8)
                Capsule()
                    .fill(CoachTheme.progressGradient(tint: CoachTheme.listening))
                    .frame(maxWidth: 190, minHeight: 8, maxHeight: 8)
                Image(systemName: "car.side.fill")
                    .font(.title2)
                    .foregroundStyle(CoachTheme.accent)
                    .offset(x: 166, y: -14)
            }
            .padding(.trailing, 68)
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    private var exam: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(CoachTheme.correct)
                Text("B1")
                    .font(.system(.largeTitle, design: .rounded, weight: .heavy))
            }

            HStack(spacing: 10) {
                examSkill("book.fill", tint: CoachTheme.reading)
                examSkill("headphones", tint: CoachTheme.listening)
                examSkill("square.and.pencil", tint: CoachTheme.writing)
                examSkill("mic.fill", tint: CoachTheme.speaking)
            }
            .padding(.trailing, 66)
        }
    }

    private func examSkill(_ icon: String, tint: Color) -> some View {
        Image(systemName: icon)
            .font(.headline.weight(.bold))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
    }

    private var orientation: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(CoachTheme.reward)
                Text("300 + 10")
                    .font(.system(.title, design: .rounded, weight: .heavy))
                    .foregroundStyle(CoachTheme.reward)
            }

            HStack(spacing: 9) {
                ForEach(["A", "B", "C", "D"], id: \.self) { choice in
                    Text(choice)
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(choice == "B" ? .white : CoachTheme.reward)
                        .frame(width: 42, height: 42)
                        .background(choice == "B" ? CoachTheme.reward : CoachTheme.reward.opacity(0.10), in: Circle())
                }
            }
            .environment(\.layoutDirection, .leftToRight)
            .padding(.trailing, 64)
        }
    }

    private func chatBubble(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.callout.weight(.semibold))
            .fixedSize(horizontal: false, vertical: true)
            .padding(11)
            .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
            .overlay(RoundedRectangle(cornerRadius: CoachTheme.smallRadius).stroke(tint.opacity(0.22)))
    }

    private var focus: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "scope")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(CoachTheme.listening)
                VStack(alignment: .leading, spacing: 3) {
                    TeachingText(english: "My focus")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                    TeachingText(english: "Listening")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                }
            }

            HStack(spacing: 8) {
                focusIcon("rectangle.stack.fill", tint: CoachTheme.accent)
                focusIcon("mic.fill", tint: CoachTheme.speaking)
                focusIcon("doc.text.magnifyingglass", tint: CoachTheme.reading)
            }
            .padding(.trailing, 64)
        }
    }

    private func focusIcon(_ icon: String, tint: Color) -> some View {
        Image(systemName: icon)
            .font(.headline.weight(.bold))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
    }

    private func levelTint(_ level: CEFRLevel) -> Color {
        switch level {
        case .a1: CoachTheme.primary
        case .a2: CoachTheme.listening
        case .b1: CoachTheme.speaking
        }
    }
}
