import SwiftUI

enum LessonTeachingPhase: Int, CaseIterable, Identifiable {
    case context
    case vocabulary
    case grammar
    case practice
    case listening
    case speaking
    case writing
    case recap

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .context: "Context"
        case .vocabulary: "Vocabulary"
        case .grammar: "Grammar"
        case .practice: "Practice"
        case .listening: "Listening"
        case .speaking: "Speaking"
        case .writing: "Writing"
        case .recap: "Recap"
        }
    }

    var prompt: String {
        switch self {
        case .context: "See the real-life goal"
        case .vocabulary: "Picture each word before translating"
        case .grammar: "See how the sentence pattern works"
        case .practice: "Use the visual rule to build an answer"
        case .listening: "Listen for pictures, key words, and meaning"
        case .speaking: "Build the model in short speaking chunks"
        case .writing: "Plan the message before writing sentences"
        case .recap: "Connect the scene, words, rule, and action"
        }
    }

    var continueTitle: String {
        switch self {
        case .context: "Learn the words"
        case .vocabulary: "Understand the grammar"
        case .grammar: "Try guided practice"
        case .practice: "Start listening"
        case .listening: "Practice speaking"
        case .speaking: "Practice writing"
        case .writing: "Review the lesson"
        case .recap: "Complete lesson"
        }
    }

    var icon: String {
        switch self {
        case .context: "photo.fill"
        case .vocabulary: "character.book.closed.fill"
        case .grammar: "square.grid.3x3.fill"
        case .practice: "pencil.and.list.clipboard"
        case .listening: "ear.fill"
        case .speaking: "waveform.and.mic"
        case .writing: "square.and.pencil"
        case .recap: "checkmark.seal.fill"
        }
    }

    var tint: Color {
        switch self {
        case .context: CoachTheme.primary
        case .vocabulary: CoachTheme.accent
        case .grammar: CoachTheme.reward
        case .practice: CoachTheme.primary
        case .listening: CoachTheme.listening
        case .speaking: CoachTheme.speaking
        case .writing: CoachTheme.writing
        case .recap: CoachTheme.correct
        }
    }
}

struct LessonPhaseMap: View {
    let phase: LessonTeachingPhase

    var body: some View {
        HStack(spacing: 4) {
            ForEach(LessonTeachingPhase.allCases) { item in
                VStack(spacing: 4) {
                    Image(systemName: item.rawValue < phase.rawValue ? "checkmark" : item.icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(foreground(for: item))
                        .frame(width: 28, height: 28)
                        .background(background(for: item), in: Circle())
                        .overlay(Circle().stroke(item.tint.opacity(item == phase ? 0.45 : 0.12)))
                    Circle()
                        .fill(item == phase ? item.tint : .clear)
                        .frame(width: 4, height: 4)
                }
                .frame(maxWidth: .infinity)
                .teachingAccessibilityLabel("\(item.title), step \(item.rawValue + 1)")
                .teachingAccessibilityValue(item.rawValue < phase.rawValue ? "completed" : item == phase ? "current" : "upcoming")
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func foreground(for item: LessonTeachingPhase) -> Color {
        item.rawValue <= phase.rawValue ? (item == phase ? .white : item.tint) : .secondary
    }

    private func background(for item: LessonTeachingPhase) -> Color {
        item == phase ? item.tint : item.tint.opacity(item.rawValue < phase.rawValue ? 0.16 : 0.07)
    }
}

struct LessonPracticeVisualPrimer: View {
    let topic: GrammarTopic?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            visualHeading(
                title: "See the rule, then answer",
                subtitle: "Move from meaning to pattern before you type.",
                icon: "eye.fill",
                tint: CoachTheme.primary
            )
            if let topic {
                GrammarVisualExplanation(topic: topic, compact: true)
            } else {
                LessonVisualFlow(items: [
                    .init(icon: "text.bubble.fill", title: "Meaning", detail: "What should it say?", tint: CoachTheme.listening),
                    .init(icon: "square.grid.3x3.fill", title: "Pattern", detail: "Build the German shape", tint: CoachTheme.accent),
                    .init(icon: "checkmark.circle.fill", title: "Check", detail: "Verb and endings", tint: CoachTheme.correct)
                ])
            }
        }
    }
}

struct LessonListeningVisual: View {
    let lesson: CompleteLessonDTO
    let words: [VocabWord]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            visualHeading(
                title: "Listen through the scene",
                subtitle: "Build the situation in your mind before reading the transcript.",
                icon: "ear.fill",
                tint: CoachTheme.listening
            )

            ZStack(alignment: .bottom) {
                LessonMemoryVisual(lesson: lesson, animates: true)
                    .frame(maxWidth: .infinity)
                    .frame(height: 210)
                HStack(spacing: 8) {
                    Image(systemName: "person.wave.2.fill")
                    waveform
                    Image(systemName: "text.bubble.fill")
                }
                .font(.callout.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.black.opacity(0.62), in: Capsule())
                .padding(10)
            }
            .clipShape(RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous))

            LessonVisualFlow(items: listeningCues)
        }
    }

    private var waveform: some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach([8.0, 15.0, 11.0, 20.0, 13.0, 17.0, 8.0], id: \.self) { height in
                Capsule().frame(width: 3, height: height)
            }
        }
        .accessibilityHidden(true)
    }

    private var listeningCues: [LessonVisualFlowItem] {
        let vocabulary = words.prefix(3).map { word in
            LessonVisualFlowItem(
                icon: VocabularyVisualCatalog.symbol(theme: word.theme, german: word.german, english: word.english),
                title: word.ttsText,
                detail: word.english,
                tint: CoachTheme.accent,
                keepsLeftToRight: true
            )
        }
        if vocabulary.isEmpty {
            return [
                .init(icon: "photo.fill", title: "Scene", detail: "Where are they?", tint: CoachTheme.primary),
                .init(icon: "character.book.closed.fill", title: "Key words", detail: "What do you know?", tint: CoachTheme.accent),
                .init(icon: "lightbulb.fill", title: "Meaning", detail: "What is happening?", tint: CoachTheme.listening)
            ]
        }
        return vocabulary
    }
}

struct LessonSpeakingVisual: View {
    let sentence: String
    let phrases: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            visualHeading(
                title: "Rehearse in chunks",
                subtitle: "Say each block slowly, then connect the whole sentence.",
                icon: "waveform.and.mic",
                tint: CoachTheme.speaking
            )

            LessonVisualFlow(items: sentenceChunks.enumerated().map { index, chunk in
                LessonVisualFlowItem(
                    icon: index == sentenceChunks.count - 1 ? "checkmark.bubble.fill" : "text.bubble.fill",
                    title: chunk,
                    detail: "chunk \(index + 1)",
                    tint: speakingTints[index % speakingTints.count],
                    keepsLeftToRight: true
                )
            })

            if !phrases.isEmpty {
                VStack(alignment: .leading, spacing: 7) {
                    TeachingText(english: "Useful words to include")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 7)], alignment: .leading, spacing: 7) {
                        ForEach(phrases.prefix(4), id: \.self) { phrase in
                            Text(phrase)
                                .font(.caption.weight(.semibold))
                                .environment(\.layoutDirection, .leftToRight)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 6)
                                .background(CoachTheme.speaking.opacity(0.12), in: Capsule())
                        }
                    }
                }
            }
        }
    }

    private let speakingTints = [CoachTheme.listening, CoachTheme.speaking, CoachTheme.correct]

    private var sentenceChunks: [String] {
        let words = sentence.split(separator: " ").map(String.init)
        guard !words.isEmpty else { return ["Build your answer"] }
        let targetCount = min(3, max(1, Int(ceil(Double(words.count) / 4.0))))
        let size = Int(ceil(Double(words.count) / Double(targetCount)))
        return stride(from: 0, to: words.count, by: size).map { start in
            words[start..<min(start + size, words.count)].joined(separator: " ")
        }
    }
}

struct LessonWritingVisual: View {
    let checklist: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            visualHeading(
                title: "Draw the message first",
                subtitle: "Give every sentence a job before you start writing.",
                icon: "square.and.pencil",
                tint: CoachTheme.writing
            )
            LessonVisualFlow(items: [
                .init(icon: "1.circle.fill", title: "Open", detail: "Name the situation", tint: CoachTheme.listening),
                .init(icon: "2.circle.fill", title: "Develop", detail: "Add details and the target rule", tint: CoachTheme.writing),
                .init(icon: "3.circle.fill", title: "Finish", detail: "Close clearly, then check", tint: CoachTheme.correct)
            ])

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(Array(checklist.prefix(4).enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 7) {
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(CoachTheme.correct)
                        TeachingText(english: item)
                            .font(.caption)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    .padding(9)
                    .frame(maxWidth: .infinity, minHeight: 62, alignment: .topLeading)
                    .background(CoachTheme.correct.opacity(0.08), in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
                }
            }
        }
    }
}

struct LessonRecapVisual: View {
    let lesson: CompleteLessonDTO
    let wordCount: Int
    let grammarTitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            visualHeading(
                title: "Your lesson memory map",
                subtitle: "One scene now connects the language you can use.",
                icon: "checkmark.seal.fill",
                tint: CoachTheme.correct
            )
            HStack(spacing: 12) {
                LessonMemoryVisual(lesson: lesson)
                    .frame(width: 104, height: 104)
                    .clipShape(RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous))
                VStack(spacing: 7) {
                    recapLine(icon: "character.book.closed.fill", title: "\(wordCount) useful words", tint: CoachTheme.accent)
                    recapLine(icon: "square.grid.3x3.fill", title: grammarTitle, tint: CoachTheme.reward)
                    recapLine(icon: "waveform.and.mic", title: "One spoken model", tint: CoachTheme.speaking)
                }
            }
        }
    }

    private func recapLine(icon: String, title: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            TeachingText(english: title)
                .font(.caption.weight(.semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.75)
            Spacer(minLength: 0)
        }
    }
}

private struct LessonVisualFlowItem {
    let icon: String
    let title: String
    let detail: String
    let tint: Color
    var keepsLeftToRight = false
}

private struct LessonVisualFlow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let items: [LessonVisualFlowItem]

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 7) { nodes }
            } else {
                HStack(spacing: 5) { nodes }
            }
        }
    }

    @ViewBuilder private var nodes: some View {
        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
            VStack(spacing: 5) {
                Image(systemName: item.icon)
                    .font(.body.weight(.bold))
                    .foregroundStyle(item.tint)
                    .frame(width: 32, height: 32)
                    .background(item.tint.opacity(0.12), in: Circle())
                itemTitle(item)
                    .font(.caption.weight(.bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.68)
                TeachingText(english: item.detail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 104)
            .background(item.tint.opacity(0.07), in: RoundedRectangle(cornerRadius: CoachTheme.smallRadius))
            .overlay(RoundedRectangle(cornerRadius: CoachTheme.smallRadius).stroke(item.tint.opacity(0.14)))

            if index < items.count - 1 {
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
        }
    }

    @ViewBuilder private func itemTitle(_ item: LessonVisualFlowItem) -> some View {
        if item.keepsLeftToRight {
            Text(item.title)
                .environment(\.layoutDirection, .leftToRight)
        } else {
            TeachingText(english: item.title)
        }
    }
}

private func visualHeading(title: String, subtitle: String, icon: String, tint: Color) -> some View {
    HStack(alignment: .top, spacing: 10) {
        CoachIconTile(icon: icon, tint: tint, size: 42)
        VStack(alignment: .leading, spacing: 3) {
            TeachingText(english: title)
                .font(.headline)
            TeachingText(english: subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        Spacer(minLength: 0)
    }
}
