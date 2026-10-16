import Foundation
import SwiftUI
import UIKit

enum CoachMascotMood: Int, CaseIterable, Hashable {
    case welcome
    case loading
    case correct
    case supportive
    case empty
    case achievement

    var accessibilityDescription: String {
        switch self {
        case .welcome: "Your learning guide is ready to help"
        case .loading: "Your learning guide is preparing a map"
        case .correct: "Your learning guide celebrates a correct answer"
        case .supportive: "Your learning guide points to a helpful explanation"
        case .empty: "Your learning guide looks for the next activity"
        case .achievement: "Your learning guide holds an achievement badge"
        }
    }

    var accent: Color {
        switch self {
        case .welcome: CoachTheme.primary
        case .loading: CoachTheme.listening
        case .correct: CoachTheme.correct
        case .supportive: CoachTheme.accent
        case .empty: CoachTheme.reading
        case .achievement: CoachTheme.rewardGlow
        }
    }

    var celebrates: Bool {
        self == .correct || self == .achievement
    }
}

struct CoachAvatarMotionValues: Equatable {
    let verticalOffset: CGFloat
    let rotation: Double
    let scale: CGFloat

    static let still = CoachAvatarMotionValues(verticalOffset: 0, rotation: 0, scale: 1)
}

struct CoachAvatarMotionProfile: Equatable {
    let verticalAmplitude: CGFloat
    let rotationAmplitude: Double
    let scaleAmplitude: CGFloat
    let period: TimeInterval
    let phaseOffset: Double

    static func profile(for mood: CoachMascotMood) -> CoachAvatarMotionProfile {
        switch mood {
        case .welcome:
            CoachAvatarMotionProfile(verticalAmplitude: 1.4, rotationAmplitude: 0.8, scaleAmplitude: 0.006, period: 2.8, phaseOffset: 0)
        case .loading:
            CoachAvatarMotionProfile(verticalAmplitude: 2.0, rotationAmplitude: 1.4, scaleAmplitude: 0.005, period: 1.8, phaseOffset: 0.6)
        case .correct:
            CoachAvatarMotionProfile(verticalAmplitude: 0.9, rotationAmplitude: 0.5, scaleAmplitude: 0.008, period: 2.4, phaseOffset: 1.2)
        case .supportive:
            CoachAvatarMotionProfile(verticalAmplitude: 1.1, rotationAmplitude: 1.0, scaleAmplitude: 0.005, period: 2.6, phaseOffset: 2.0)
        case .empty:
            CoachAvatarMotionProfile(verticalAmplitude: 0.8, rotationAmplitude: 1.1, scaleAmplitude: 0.004, period: 3.0, phaseOffset: 2.6)
        case .achievement:
            CoachAvatarMotionProfile(verticalAmplitude: 1.2, rotationAmplitude: 0.6, scaleAmplitude: 0.009, period: 2.5, phaseOffset: 3.2)
        }
    }

    func values(at time: TimeInterval) -> CoachAvatarMotionValues {
        guard period > 0 else { return .still }
        let angle = ((time / period) * 2 * Double.pi) + phaseOffset
        return CoachAvatarMotionValues(
            verticalOffset: CGFloat(sin(angle)) * verticalAmplitude,
            rotation: sin(angle * 0.72) * rotationAmplitude,
            scale: 1 + (CGFloat(cos(angle)) * scaleAmplitude)
        )
    }
}

struct CoachMascot: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var didEnter = false
    @State private var reactionToken = 0
    @State private var entranceTask: Task<Void, Never>?

    let mood: CoachMascotMood
    var size: CGFloat = 82
    var animates = true

    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: 1.0 / 24.0,
                paused: !idleMotionIsActive
            )
        ) { context in
            let motion = idleMotionIsActive
                ? motionProfile.values(at: context.date.timeIntervalSinceReferenceDate)
                : .still

            avatarSurface
                .scaleEffect(entranceScale * motion.scale)
                .rotationEffect(.degrees(entranceRotation + motion.rotation))
                .offset(y: entranceOffset + motion.verticalOffset)
        }
        .frame(width: size, height: size * 1.24)
        .onAppear { performEntranceReaction() }
        .onChange(of: mood) { _, _ in performEntranceReaction() }
        .onChange(of: reduceMotion) { _, _ in performEntranceReaction() }
        .onDisappear { entranceTask?.cancel() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(mood.accessibilityDescription)
    }

    private var avatarSurface: some View {
        ZStack {
            Group {
                if let image = CoachMascotCatalog.image(for: mood) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: "location.fill")
                        .font(.system(size: size * 0.46, weight: .bold))
                        .foregroundStyle(CoachTheme.primary)
                }
            }
            .id(mood)
            .transition(.opacity.combined(with: .scale(scale: 0.96)))

            if mood.celebrates && animates && !reduceMotion {
                CoachAvatarSparkleReaction(trigger: reactionToken, size: size)
            }
        }
        .animation(reduceMotion ? nil : CoachMotion.standard, value: mood)
    }

    private var motionProfile: CoachAvatarMotionProfile {
        CoachAvatarMotionProfile.profile(for: mood)
    }

    private var idleMotionIsActive: Bool {
        animates && !reduceMotion && scenePhase == .active
    }

    private var entranceScale: CGFloat {
        guard animates, !reduceMotion else { return 1 }
        return didEnter ? 1 : mood.celebrates ? 0.82 : 0.94
    }

    private var entranceRotation: Double {
        guard animates, !reduceMotion, !didEnter else { return 0 }
        return mood == .supportive ? -4 : mood == .loading ? 3 : -2
    }

    private var entranceOffset: CGFloat {
        guard animates, !reduceMotion, !didEnter else { return 0 }
        return mood.celebrates ? 5 : 3
    }

    private func performEntranceReaction() {
        entranceTask?.cancel()
        guard animates, !reduceMotion else {
            didEnter = true
            return
        }

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            didEnter = false
            reactionToken += 1
        }

        entranceTask = Task { @MainActor in
            await Task.yield()
            guard !Task.isCancelled else { return }
            withAnimation(mood.celebrates ? CoachMotion.celebration : CoachMotion.spring) {
                didEnter = true
            }
        }
    }
}

private struct CoachAvatarSparkleReaction: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress = 0.0
    @State private var animationTask: Task<Void, Never>?

    let trigger: Int
    let size: CGFloat

    private let directions: [CGSize] = [
        CGSize(width: -0.28, height: -0.30),
        CGSize(width: 0.30, height: -0.22),
        CGSize(width: 0.34, height: 0.12)
    ]

    var body: some View {
        let visualProgress = CGFloat(progress)
        ZStack {
            ForEach(directions.indices, id: \.self) { index in
                Image(systemName: index == 1 ? "star.fill" : "sparkles")
                    .font(.system(size: max(8, size * (index == 1 ? 0.14 : 0.11)), weight: .bold))
                    .foregroundStyle(index == 1 ? CoachTheme.rewardGlow : CoachTheme.correct)
                    .offset(
                        x: directions[index].width * size * visualProgress,
                        y: directions[index].height * size * visualProgress
                    )
                    .scaleEffect(0.45 + (visualProgress * 0.65))
                    .opacity(reduceMotion ? 0 : 1 - progress)
            }
        }
        .onAppear { animateBurst() }
        .onChange(of: trigger) { _, _ in animateBurst() }
        .onDisappear { animationTask?.cancel() }
        .accessibilityHidden(true)
    }

    private func animateBurst() {
        animationTask?.cancel()
        guard !reduceMotion else {
            progress = 1
            return
        }

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) { progress = 0 }
        animationTask = Task { @MainActor in
            await Task.yield()
            guard !Task.isCancelled else { return }
            withAnimation(CoachMotion.celebration) {
                progress = 1
            }
        }
    }
}

#if DEBUG
struct CoachAvatarShowcaseView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedMood = CoachMascotMood.welcome
    @State private var reactionID = 0

    private let columns = [
        GridItem(.adaptive(minimum: 104), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CoachCard(tint: selectedMood.accent) {
                    HStack(spacing: 16) {
                        CoachMascot(mood: selectedMood, size: 104)
                            .id(reactionID)
                        VStack(alignment: .leading, spacing: 7) {
                            TeachingText(english: "Animated coach")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                            Text(selectedMood.accessibilityDescription)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Button {
                                reactionID += 1
                                CoachFeedback.selection()
                            } label: {
                                TeachingLabel(english: "Play reaction", systemImage: "play.fill")
                            }
                            .buttonStyle(SecondaryCoachButton(tint: selectedMood.accent))
                        }
                    }
                }

                Picker("Coach mood", selection: $selectedMood) {
                    ForEach(CoachMascotMood.allCases, id: \.self) { mood in
                        Text(String(describing: mood).capitalized).tag(mood)
                    }
                }
                .pickerStyle(.menu)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(CoachMascotMood.allCases, id: \.self) { mood in
                        VStack(spacing: 7) {
                            CoachMascot(mood: mood, size: 64)
                            Text(String(describing: mood).capitalized)
                                .font(.caption.weight(.semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(CoachTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
                        .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(CoachTheme.stroke))
                    }
                }

                Label(
                    reduceMotion ? "Reduce Motion fallback active" : "Native idle and reaction motion active",
                    systemImage: reduceMotion ? "figure.walk.motion" : "sparkles"
                )
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: 620)
            .padding()
            .frame(maxWidth: .infinity)
        }
        .teachingNavigationTitle("Coach Avatar")
        .coachBackground()
    }
}
#endif

enum CoachMascotCatalog {
    private static let tileCache = NSCache<NSNumber, UIImage>()

    static func image(for mood: CoachMascotMood) -> UIImage? {
        let key = NSNumber(value: mood.rawValue)
        if let cached = tileCache.object(forKey: key) {
            return cached
        }

        guard let source = UIImage(named: "CoachMascotAtlas")?.cgImage else { return nil }
        let tileWidth = source.width / 3
        let tileHeight = source.height / 2
        let column = mood.rawValue % 3
        let row = mood.rawValue / 3
        let crop = CGRect(
            x: column * tileWidth,
            y: row * tileHeight,
            width: tileWidth,
            height: tileHeight
        )
        guard let cropped = source.cropping(to: crop) else { return nil }

        let image = UIImage(cgImage: cropped, scale: 1, orientation: .up)
        tileCache.setObject(image, forKey: key)
        return image
    }
}
