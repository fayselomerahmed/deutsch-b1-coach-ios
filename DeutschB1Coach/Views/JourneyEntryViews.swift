import SwiftUI

struct CourseJourneyLoadingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let phase: ContentPreparationPhase

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .center, spacing: 14) {
                CoachMascot(mood: phase == .ready ? .achievement : .loading, size: 76)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    SkillChip(title: "YOUR GERMAN JOURNEY", color: CoachTheme.primary)
                    TeachingText(english: "Preparing your path")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            journeyRoute

            CoachCard(tint: tint) {
                HStack(alignment: .top, spacing: 12) {
                    CoachIconTile(icon: phase.icon, tint: tint, size: 48)
                    VStack(alignment: .leading, spacing: 5) {
                        TeachingText(english: phase.title)
                            .font(.headline)
                        TeachingText(english: phase.message)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 4)
                    if !reduceMotion && phase != .ready {
                        ProgressView()
                            .tint(tint)
                            .accessibilityHidden(true)
                    } else {
                        Image(systemName: phase == .ready ? "checkmark.circle.fill" : "hourglass")
                            .foregroundStyle(tint)
                            .accessibilityHidden(true)
                    }
                }
                .id(phase)
                .transition(reduceMotion ? .identity : .opacity.combined(with: .offset(y: 4)))
            }

            ProgressView(value: phase.progress)
                .tint(tint)
                .teachingAccessibilityLabel("Course preparation progress")
                .teachingAccessibilityValue("\(Int(phase.progress * 100)) percent")
            Text("\(Int(phase.progress * 100))%")
                .font(.caption.monospacedDigit().weight(.bold))
                .foregroundStyle(tint)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .contentTransition(.numericText())
        }
        .padding(24)
        .frame(maxWidth: 620)
        .animation(reduceMotion ? nil : CoachMotion.standard, value: phase)
        .accessibilityElement(children: .combine)
        .teachingAccessibilityLabel("\(phase.title). \(phase.message). \(Int(phase.progress * 100)) percent complete.")
        .accessibilityAddTraits(.updatesFrequently)
    }

    private var journeyRoute: some View {
        HStack(spacing: 0) {
            ForEach(Array(CEFRLevel.allCases.enumerated()), id: \.element) { index, level in
                routeNode(level)
                if index < CEFRLevel.allCases.count - 1 {
                    Capsule()
                        .fill(phase.includes(level) ? CoachTheme.progressGradient() : LinearGradient(colors: [Color.secondary.opacity(0.18)], startPoint: .leading, endPoint: .trailing))
                        .frame(maxWidth: .infinity, minHeight: 4, maxHeight: 4)
                        .padding(.horizontal, 5)
                        .accessibilityHidden(true)
                }
            }
        }
    }

    private func routeNode(_ level: CEFRLevel) -> some View {
        let isComplete = phase.includes(level)
        let levelTint: Color = switch level {
        case .a1: CoachTheme.primary
        case .a2: CoachTheme.listening
        case .b1: CoachTheme.speaking
        }

        return VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isComplete ? levelTint : CoachTheme.elevatedSurface)
                Circle()
                    .stroke(isComplete ? levelTint : Color.secondary.opacity(0.24), lineWidth: 2)
                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(.white)
                        .transition(reduceMotion ? .identity : .scale.combined(with: .opacity))
                } else {
                    Text(level.rawValue)
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 42, height: 42)
            Text(level.rawValue)
                .font(.caption.weight(.bold))
                .foregroundStyle(isComplete ? levelTint : Color.secondary)
        }
        .teachingAccessibilityLabel("\(level.rawValue) \(isComplete ? "ready" : "preparing")")
    }

    private var tint: Color {
        switch phase {
        case .checking, .grammar: CoachTheme.primary
        case .vocabularyA1: CoachTheme.primary
        case .vocabularyA2: CoachTheme.listening
        case .vocabularyB1: CoachTheme.speaking
        case .practice: CoachTheme.accent
        case .saving: CoachTheme.reward
        case .ready: CoachTheme.correct
        }
    }
}

struct LanguagePassportCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let learnerName: String
    let teachingLanguage: TeachingLanguage

    private var displayName: String {
        let trimmed = learnerName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Your name" : trimmed
    }

    private var hasName: Bool {
        !learnerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        CoachCard(tint: CoachTheme.primary) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    CoachIconTile(icon: "person.text.rectangle.fill", tint: CoachTheme.primary, size: 52)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("DEUTSCH LERNPASS")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(CoachTheme.primary)
                        TeachingText(english: "Your language passport")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                    }
                    Spacer(minLength: 4)
                    CoachMascot(mood: hasName ? .correct : .welcome, size: 54, animates: hasName)
                        .id(hasName)
                        .transition(reduceMotion ? .identity : .opacity.combined(with: .scale(scale: 0.9)))
                        .accessibilityHidden(true)
                }

                Divider()

                passportRow(icon: "person.fill", label: "Learner", value: displayName)
                passportRow(icon: "globe.europe.africa.fill", label: "Teaching language", value: teachingLanguage.nativeName)

                FirstSentenceBuilder(learnerName: learnerName)
            }
        }
        .animation(reduceMotion ? nil : CoachMotion.celebration, value: hasName)
    }

    private func passportRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(CoachTheme.primary)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                TeachingText(english: label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

struct FirstSentenceBuilder: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let learnerName: String

    private var trimmedName: String {
        learnerName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Label {
                TeachingText(english: "Your first German sentence")
            } icon: {
                Image(systemName: "sparkles")
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(CoachTheme.accent)

            sentenceLayout

            if !trimmedName.isEmpty {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 6) {
                        wordTile("Ich", tint: CoachTheme.listening)
                        wordTile("bin", tint: CoachTheme.speaking)
                        wordTile("\(trimmedName).", tint: CoachTheme.reward)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            wordTile("Ich", tint: CoachTheme.listening)
                            wordTile("bin", tint: CoachTheme.speaking)
                        }
                        wordTile("\(trimmedName).", tint: CoachTheme.reward)
                    }
                }
                .transition(reduceMotion ? .identity : .opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(13)
        .background(CoachTheme.warmWash, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(CoachTheme.accent.opacity(0.16)))
        .animation(reduceMotion ? nil : CoachMotion.spring, value: trimmedName.isEmpty)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(trimmedName.isEmpty ? "Ich lerne Deutsch." : "Ich lerne Deutsch. Ich bin \(trimmedName).")
    }

    private var sentenceLayout: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 6) {
                wordTile("Ich", tint: CoachTheme.primary)
                wordTile("lerne", tint: CoachTheme.listening)
                wordTile("Deutsch.", tint: CoachTheme.accent)
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    wordTile("Ich", tint: CoachTheme.primary)
                    wordTile("lerne", tint: CoachTheme.listening)
                }
                wordTile("Deutsch.", tint: CoachTheme.accent)
            }
        }
    }

    private func wordTile(_ word: String, tint: Color) -> some View {
        Text(word)
            .font(.system(.callout, design: .rounded, weight: .bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
            .overlay(RoundedRectangle(cornerRadius: CoachTheme.smallRadius).stroke(tint.opacity(0.18)))
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct PassportCompletionStamp: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    var level: CEFRLevel

    var body: some View {
        ZStack {
            Circle()
                .stroke(CoachTheme.correct, style: StrokeStyle(lineWidth: 3, dash: [5, 3]))
            VStack(spacing: 3) {
                CoachAnimatedCheckmark(size: 28, tint: CoachTheme.correct)
                Text("\(level.rawValue) READY")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(CoachTheme.correct)
            }
        }
        .frame(width: 82, height: 82)
        .rotationEffect(.degrees(-7))
        .scaleEffect(isVisible || reduceMotion ? 1 : 0.72)
        .opacity(isVisible || reduceMotion ? 1 : 0)
        .onAppear {
            guard !reduceMotion else {
                isVisible = true
                return
            }
            withAnimation(CoachMotion.celebration) {
                isVisible = true
            }
        }
        .teachingAccessibilityLabel("\(level.rawValue) learning path ready")
    }
}
