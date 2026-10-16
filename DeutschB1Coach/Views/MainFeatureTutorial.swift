import SwiftUI

enum MainFeatureTutorial: String, CaseIterable, Identifiable {
    case home
    case learn
    case practice
    case review
    case progress

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "Your daily learning home"
        case .learn: "Learn with a clear path"
        case .practice: "Practice real conversations"
        case .review: "Review and play"
        case .progress: "See your progress"
        }
    }

    var message: String {
        switch self {
        case .home:
            "Continue your next lesson, see today's practice, and reach the most useful action without searching."
        case .learn:
            "Follow A1, A2, and B1 course books in order. Lessons unlock as you make progress."
        case .practice:
            "Listen, speak, and repeat in everyday situations. The coach corrects your answer and helps you try again."
        case .review:
            "Use flashcards, matching games, and sentence challenges to bring difficult material back at the right time."
        case .progress:
            "Follow your course journey, streak, mastered words, and B1 readiness as you improve."
        }
    }

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .learn: "books.vertical.fill"
        case .practice: "mic.fill"
        case .review: "rectangle.stack.fill"
        case .progress: "chart.line.uptrend.xyaxis"
        }
    }

    var tint: Color {
        switch self {
        case .home: CoachTheme.primary
        case .learn: CoachTheme.listening
        case .practice: CoachTheme.speaking
        case .review: CoachTheme.accent
        case .progress: CoachTheme.reward
        }
    }

    var mascotMood: CoachMascotMood {
        switch self {
        case .home, .learn: .welcome
        case .practice, .review: .supportive
        case .progress: .achievement
        }
    }
}

private struct MainFeatureTutorialModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(TeachingLanguage.storageKey) private var teachingLanguageCode = TeachingLanguage.defaultLanguage.rawValue
    @AppStorage private var didSeeTutorial: Bool
    @State private var isPresented = false

    let feature: MainFeatureTutorial

    init(feature: MainFeatureTutorial) {
        self.feature = feature
        _didSeeTutorial = AppStorage(
            wrappedValue: false,
            "didSeeMainFeatureTutorial.v2.\(feature.rawValue)"
        )
    }

    private var teachingLanguage: TeachingLanguage {
        TeachingLanguage.resolve(teachingLanguageCode)
    }

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottomTrailing) {
                if isPresented {
                    tutorialBubble
                        .frame(maxWidth: 360)
                        .transition(
                            reduceMotion
                                ? .identity
                                : .opacity.combined(with: .move(edge: .bottom)).combined(with: .scale(scale: 0.96, anchor: .bottomTrailing))
                        )
                        .padding(.horizontal, 12)
                        .padding(.bottom, 10)
                }
            }
            .environment(\.layoutDirection, teachingLanguage.isRightToLeft ? .rightToLeft : .leftToRight)
            .onAppear {
                guard !didSeeTutorial else { return }
                presentTutorial()
            }
            .animation(reduceMotion ? nil : CoachMotion.navigation, value: isPresented)
    }

    private var tutorialBubble: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 11) {
                CoachMascot(mood: feature.mascotMood, size: 46, animates: true)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 7) {
                        Image(systemName: feature.icon)
                            .foregroundStyle(feature.tint)
                            .accessibilityHidden(true)
                        TeachingText(english: feature.title)
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    TeachingText(english: feature.message)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    dismissTutorial()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.bold))
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(CoachIconButtonStyle(tint: feature.tint))
                .teachingAccessibilityLabel("Close feature tutorial")
            }

            Button {
                dismissTutorial()
            } label: {
                HStack(spacing: 8) {
                    Text(teachingLanguage.interfaceText(.done))
                    Image(systemName: "checkmark")
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryCoachButton(tint: feature.tint))
        }
        .padding(.horizontal, 14)
        .padding(.top, 14)
        .padding(.bottom, 23)
        .background {
            FeatureTutorialBubbleShape(tailOnTrailing: !teachingLanguage.isRightToLeft)
                .fill(CoachTheme.surfaceGradient(tint: feature.tint, colorScheme: colorScheme))
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.30 : 0.14),
                    radius: 12,
                    y: 5
                )
        }
        .accessibilityElement(children: .contain)
    }

    private func presentTutorial() {
        if reduceMotion {
            isPresented = true
        } else {
            withAnimation(CoachMotion.navigation) {
                isPresented = true
            }
        }
    }

    private func dismissTutorial() {
        didSeeTutorial = true
        if reduceMotion {
            isPresented = false
        } else {
            withAnimation(CoachMotion.quick) {
                isPresented = false
            }
        }
    }
}

private struct FeatureTutorialBubbleShape: Shape {
    let tailOnTrailing: Bool

    func path(in rect: CGRect) -> Path {
        let tailHeight: CGFloat = 11
        let tailWidth: CGFloat = 20
        let body = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width,
            height: max(0, rect.height - tailHeight)
        )
        let tailCenterX = tailOnTrailing
            ? max(body.minX + 24, body.maxX - 32)
            : min(body.maxX - 24, body.minX + 32)

        var path = Path(roundedRect: body, cornerRadius: CoachTheme.controlRadius)
        path.move(to: CGPoint(x: tailCenterX - tailWidth / 2, y: body.maxY - 1))
        path.addLine(to: CGPoint(x: tailCenterX, y: rect.maxY))
        path.addLine(to: CGPoint(x: tailCenterX + tailWidth / 2, y: body.maxY - 1))
        path.closeSubpath()
        return path
    }
}

extension View {
    func mainFeatureTutorial(_ feature: MainFeatureTutorial) -> some View {
        modifier(MainFeatureTutorialModifier(feature: feature))
    }
}
