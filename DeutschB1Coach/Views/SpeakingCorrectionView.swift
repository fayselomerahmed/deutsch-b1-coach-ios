import SwiftUI

struct SpeakingCorrectionCoach: View {
    let transcript: String
    let correction: SpeechCorrection
    var translation: String?

    var body: some View {
        CoachCard(tint: CoachTheme.speaking) {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    TeachingLabel(english: "What you said", systemImage: "quote.bubble")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text(transcript)
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Divider()

                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        TeachingLabel(english: "Corrected German", systemImage: "checkmark.bubble.fill")
                            .font(.headline)
                            .foregroundStyle(CoachTheme.primary)
                        Spacer()
                        Button {
                            GermanSpeechService.shared.speak(correction.correctedText, style: .model)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .frame(width: 36, height: 36)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(CoachTheme.listening)
                        .teachingAccessibilityLabel("Play corrected German")
                    }
                    Text(correction.correctedText)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(
                            CoachTheme.correct.opacity(0.10),
                            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                                .stroke(CoachTheme.correct.opacity(0.22), lineWidth: 1)
                        }
                    if let translation, !translation.isEmpty {
                        TeachingText(english: translation)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if !correction.issues.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 10) {
                        TeachingText(english: "Corrections")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(CoachTheme.accent)
                        ForEach(correction.issues) { issue in
                            HStack(alignment: .top, spacing: 9) {
                                Image(systemName: icon(for: issue.kind))
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(color(for: issue.kind))
                                    .frame(width: 20, height: 20)
                                VStack(alignment: .leading, spacing: 2) {
                                    TeachingText(english: issue.title)
                                        .font(.callout.weight(.semibold))
                                    TeachingText(english: issue.message)
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }

                if !correction.matchedPhrases.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 7) {
                        TeachingLabel(english: "Phrases used well", systemImage: "checkmark.seal.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(CoachTheme.correct)
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 120), spacing: 7)],
                            alignment: .leading,
                            spacing: 7
                        ) {
                            ForEach(correction.matchedPhrases, id: \.self) { phrase in
                                SkillChip(title: phrase, color: CoachTheme.correct, translatesTitle: false)
                            }
                        }
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    TeachingLabel(english: "Try next", systemImage: "lightbulb.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CoachTheme.reward)
                    ForEach(correction.suggestions, id: \.self) { suggestion in
                        Label {
                            TeachingText(english: suggestion)
                        } icon: {
                            Image(systemName: "arrow.right.circle.fill")
                        }
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private func icon(for kind: SpeechCorrectionIssue.Kind) -> String {
        switch kind {
        case .missingWord: "plus.circle.fill"
        case .wordChoice: "arrow.left.arrow.right.circle.fill"
        case .extraWord: "minus.circle.fill"
        case .grammar: "text.book.closed.fill"
        case .phrase: "quote.bubble.fill"
        }
    }

    private func color(for kind: SpeechCorrectionIssue.Kind) -> Color {
        switch kind {
        case .missingWord, .phrase: CoachTheme.accent
        case .wordChoice, .grammar: CoachTheme.speaking
        case .extraWord: CoachTheme.incorrect
        }
    }
}
