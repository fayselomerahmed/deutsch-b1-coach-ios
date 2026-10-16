import SwiftUI

enum SimplifiedExplanationLanguageMode {
    case teachingLanguage
    case german
}

struct SimplifiedExplanationButton: View {
    let explanation: SimplifiedExplanation
    var tint = CoachTheme.primary
    var languageMode = SimplifiedExplanationLanguageMode.teachingLanguage

    @State private var showsExplanation = false

    var body: some View {
        Button {
            CoachFeedback.selection()
            showsExplanation = true
        } label: {
            Label {
                localizedText(english: "Explain more simply", german: "Einfacher erklären")
            } icon: {
                Image(systemName: "lightbulb.max.fill")
            }
        }
        .buttonStyle(SecondaryCoachButton(tint: tint))
        .simplifiedExplanationAccessibilityHint(languageMode)
        .sheet(isPresented: $showsExplanation) {
            SimplifiedExplanationSheet(explanation: explanation, tint: tint, languageMode: languageMode)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder private func localizedText(english: String, german: String) -> some View {
        if languageMode == .german {
            Text(german)
        } else {
            TeachingText(english: english)
        }
    }
}

private struct SimplifiedExplanationSheet: View {
    @Environment(\.dismiss) private var dismiss
    let explanation: SimplifiedExplanation
    let tint: Color
    let languageMode: SimplifiedExplanationLanguageMode

    @State private var showsAnswer = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    CoachCard(tint: tint) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top, spacing: 12) {
                                CoachMascot(mood: .supportive, size: 58, animates: true)
                                    .accessibilityHidden(true)
                                VStack(alignment: .leading, spacing: 5) {
                                    SkillChip(
                                        title: languageMode == .german ? "EINE IDEE" : "ONE IDEA",
                                        color: tint,
                                        translatesTitle: languageMode != .german
                                    )
                                    localizedText(explanation.title)
                                        .font(.title2.weight(.bold))
                                }
                            }
                            localizedText(explanation.oneLine)
                                .font(.title3.weight(.semibold))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    VStack(alignment: .leading, spacing: 7) {
                        Label {
                            localizedText(
                                languageMode == .german ? "Stell es dir so vor" : "Think of it like this"
                            )
                        } icon: {
                            Image(systemName: "brain.head.profile.fill")
                        }
                        .font(.headline)
                        .foregroundStyle(tint)
                        localizedText(explanation.analogy)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .background(tint.opacity(0.09), in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
                    .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(tint.opacity(0.16)))

                    CoachSectionHeader(
                        title: languageMode == .german ? "Drei kleine Schritte" : "Three tiny steps",
                        subtitle: languageMode == .german ? "Mache immer nur einen Schritt" : "Do only one step at a time"
                    )
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(Array(explanation.steps.enumerated()), id: \.offset) { index, step in
                            simpleStep(index + 1, step: step)
                        }
                    }

                    if let german = explanation.modelGerman,
                       let meaning = explanation.modelMeaning {
                        VStack(alignment: .leading, spacing: 8) {
                            TeachingLabel(english: "One safe model", systemImage: "quote.bubble.fill")
                                .font(.headline)
                                .foregroundStyle(CoachTheme.listening)
                            HStack(alignment: .top, spacing: 10) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(german)
                                        .font(.headline)
                                        .environment(\.layoutDirection, .leftToRight)
                                    TeachingText(english: meaning)
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 6)
                                GermanSpeechButton(text: german, label: "Play simple model")
                            }
                        }
                        .padding(14)
                        .background(CoachTheme.listening.opacity(0.09), in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
                        .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(CoachTheme.listening.opacity(0.16)))
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Label {
                            localizedText(languageMode == .german ? "Kurzer Check" : "Quick check")
                        } icon: {
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .font(.headline)
                        .foregroundStyle(CoachTheme.correct)
                        localizedText(explanation.checkQuestion)
                            .font(.body.weight(.semibold))

                        if showsAnswer {
                            localizedText(explanation.checkAnswer)
                                .font(.callout)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(CoachTheme.correct.opacity(0.10), in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        } else {
                            Button {
                                CoachFeedback.selection()
                                withAnimation(CoachMotion.spring) { showsAnswer = true }
                            } label: {
                                Label {
                                    localizedText(
                                        languageMode == .german ? "Einfache Antwort zeigen" : "Show the simple answer"
                                    )
                                } icon: {
                                    Image(systemName: "eye.fill")
                                }
                            }
                            .buttonStyle(PrimaryCoachButton(tint: CoachTheme.correct))
                        }
                    }
                    .padding(14)
                    .background(CoachTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
                    .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(CoachTheme.correct.opacity(0.16)))
                }
                .padding()
            }
            .simplifiedExplanationNavigationTitle(languageMode)
            .navigationBarTitleDisplayMode(.inline)
            .coachBackground()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .simplifiedExplanationCloseLabel(languageMode)
                }
            }
        }
    }

    private func simpleStep(_ number: Int, step: SimplifiedExplanationStep) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption.weight(.heavy).monospacedDigit())
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(stepTint(number), in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                localizedText(step.title)
                    .font(.headline)
                localizedText(step.detail)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder private func localizedText(_ text: String) -> some View {
        if languageMode == .german {
            Text(text)
        } else {
            TeachingText(
                english: text,
                protectedGerman: explanation.protectedGerman
            )
        }
    }

    private func stepTint(_ number: Int) -> Color {
        switch number {
        case 1: CoachTheme.listening
        case 2: CoachTheme.accent
        default: CoachTheme.speaking
        }
    }
}

private extension View {
    @ViewBuilder
    func simplifiedExplanationNavigationTitle(
        _ languageMode: SimplifiedExplanationLanguageMode
    ) -> some View {
        switch languageMode {
        case .german:
            navigationTitle("Einfache Erklärung")
                .teachingLanguageSwitcher()
        case .teachingLanguage:
            teachingNavigationTitle("Simple explanation")
        }
    }

    @ViewBuilder
    func simplifiedExplanationAccessibilityHint(
        _ languageMode: SimplifiedExplanationLanguageMode
    ) -> some View {
        switch languageMode {
        case .german:
            accessibilityHint("Öffnet eine kürzere Erklärung mit Beispiel und Selbstkontrolle")
        case .teachingLanguage:
            teachingAccessibilityHint(
                "Opens a shorter explanation with one example and a self-check"
            )
        }
    }

    @ViewBuilder
    func simplifiedExplanationCloseLabel(
        _ languageMode: SimplifiedExplanationLanguageMode
    ) -> some View {
        switch languageMode {
        case .german:
            accessibilityLabel("Einfache Erklärung schließen")
        case .teachingLanguage:
            teachingAccessibilityLabel("Close simple explanation")
        }
    }
}
