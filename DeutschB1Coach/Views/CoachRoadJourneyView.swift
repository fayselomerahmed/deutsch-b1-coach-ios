import SwiftUI

struct CoachRoadJourneyView: View {
    @State private var displayedProgress = 0.0

    let progress: Double
    let tint: Color
    let reduceMotion: Bool

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { timeline in
            GeometryReader { proxy in
                let size = proxy.size
                let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
                let startX: CGFloat = 34
                let endX = max(startX, size.width - 40)
                let carX = startX + ((endX - startX) * displayedProgress)
                let bounce: CGFloat = reduceMotion ? 0 : CGFloat(abs(sin(time * 4.2)) * -1.6)
                let pitch = reduceMotion ? 0 : sin(time * 2.4) * 0.7

                ZStack {
                    journeySky

                    sun
                        .position(x: max(34, size.width - 82), y: 22)

                    RoadsideLandscape()
                        .frame(height: 35)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .offset(y: -39)

                    road(width: max(size.width - 32, 0), time: time)
                        .position(x: size.width / 2, y: size.height - 24)

                    RoadFinishMarker(
                        isComplete: displayedProgress >= 0.995,
                        time: time,
                        reduceMotion: reduceMotion
                    )
                    .position(x: endX + 2, y: size.height - 66)

                    CarIllustration(tint: tint, time: time, reduceMotion: reduceMotion)
                        .rotationEffect(.degrees(pitch), anchor: .bottom)
                        .position(x: carX, y: size.height - 52 + bounce)
                        .shadow(color: .black.opacity(0.18), radius: 3, y: 2)
                }
                .clipped()
            }
        }
        .background(Color(red: 0.78, green: 0.92, blue: 0.98))
        .onAppear { updateProgress(animated: !reduceMotion) }
        .onChange(of: progress) { _, _ in updateProgress(animated: !reduceMotion) }
        .onChange(of: reduceMotion) { _, value in updateProgress(animated: !value) }
    }

    private var journeySky: some View {
        LinearGradient(
            stops: [
                .init(color: Color(red: 0.76, green: 0.91, blue: 0.98), location: 0),
                .init(color: Color(red: 0.91, green: 0.97, blue: 0.96), location: 0.62),
                .init(color: Color(red: 1.00, green: 0.92, blue: 0.72), location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var sun: some View {
        ZStack {
            Circle()
                .fill(CoachTheme.rewardGlow.opacity(0.18))
                .frame(width: 38, height: 38)
            Circle()
                .fill(CoachTheme.rewardGlow)
                .frame(width: 20, height: 20)
        }
        .accessibilityHidden(true)
    }

    private func road(width: CGFloat, time: TimeInterval) -> some View {
        let progressWidth = max(0, width * CGFloat(displayedProgress))
        let dashOffset = reduceMotion ? 0 : CGFloat(time.truncatingRemainder(dividingBy: 1.2) * 10)

        return ZStack(alignment: .leading) {
            Capsule()
                .fill(Color(uiColor: .secondarySystemFill))
                .frame(width: width, height: 36)

            Capsule()
                .fill(tint.opacity(0.27))
                .frame(width: progressWidth, height: 36)

            HStack(spacing: 12) {
                ForEach(0..<14, id: \.self) { _ in
                    Capsule()
                        .fill(.white.opacity(0.88))
                        .frame(width: 14, height: 3)
                }
            }
            .offset(x: -dashOffset)
            .frame(width: width, alignment: .leading)
            .clipped()

            ForEach(Array([0.0, 1.0 / 3.0, 2.0 / 3.0, 1.0].enumerated()), id: \.offset) { index, milestone in
                let reached = displayedProgress + 0.001 >= milestone
                ZStack {
                    Circle()
                        .fill(reached ? Color.white : Color(uiColor: .tertiarySystemFill))
                    if reached {
                        Image(systemName: index == 3 ? "flag.checkered" : "checkmark")
                            .font(.system(size: 7, weight: .black))
                            .foregroundStyle(tint)
                    }
                }
                .frame(width: reached ? 14 : 11, height: reached ? 14 : 11)
                .overlay {
                    Circle()
                        .stroke(reached ? tint : Color.white.opacity(0.72), lineWidth: 2)
                }
                .shadow(color: reached ? tint.opacity(0.24) : .clear, radius: 3)
                .position(x: width * CGFloat(milestone), y: 31)
            }
        }
        .frame(width: width, height: 42)
        .accessibilityHidden(true)
    }

    private func updateProgress(animated: Bool) {
        if animated {
            withAnimation(CoachMotion.spring) {
                displayedProgress = clampedProgress
            }
        } else {
            displayedProgress = clampedProgress
        }
    }
}

private struct CarIllustration: View {
    let tint: Color
    let time: TimeInterval
    let reduceMotion: Bool

    private var wheelRotation: Angle {
        reduceMotion ? .zero : .degrees(time * 180)
    }

    var body: some View {
        ZStack {
            if !reduceMotion {
                HStack(spacing: 4) {
                    Capsule().frame(width: 10, height: 2)
                    Capsule().frame(width: 6, height: 2)
                }
                .foregroundStyle(.white.opacity(0.76))
                .offset(x: -32, y: 8)
            }

            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(tint)
                .frame(width: 50, height: 19)
                .offset(y: 5)

            UnevenRoundedRectangle(
                topLeadingRadius: 8,
                bottomLeadingRadius: 2,
                bottomTrailingRadius: 2,
                topTrailingRadius: 11,
                style: .continuous
            )
            .fill(tint.opacity(0.92))
            .frame(width: 31, height: 17)
            .offset(x: -4, y: -5)

            HStack(spacing: 3) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(red: 0.78, green: 0.92, blue: 0.98))
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(red: 0.78, green: 0.92, blue: 0.98))
            }
            .frame(width: 24, height: 9)
            .offset(x: -4, y: -6)

            Capsule()
                .fill(Color(red: 1.00, green: 0.86, blue: 0.34))
                .frame(width: 5, height: 3)
                .offset(x: 24, y: 3)

            Capsule()
                .fill(Color(red: 0.82, green: 0.18, blue: 0.18))
                .frame(width: 4, height: 3)
                .offset(x: -24, y: 3)

            Capsule()
                .fill(Color(red: 0.32, green: 0.35, blue: 0.39))
                .frame(width: 6, height: 2)
                .offset(x: 27, y: 10)

            HStack(spacing: 22) {
                roadWheel
                roadWheel
            }
            .offset(y: 13)
        }
        .frame(width: 72, height: 48)
        .accessibilityHidden(true)
    }

    private var roadWheel: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.10, green: 0.11, blue: 0.13))
            Circle()
                .fill(Color(red: 0.72, green: 0.75, blue: 0.78))
                .frame(width: 6, height: 6)
            Rectangle()
                .fill(Color.white.opacity(0.82))
                .frame(width: 2, height: 8)
            Rectangle()
                .fill(Color.white.opacity(0.82))
                .frame(width: 8, height: 2)
        }
        .frame(width: 12, height: 12)
        .rotationEffect(wheelRotation)
    }
}

private struct RoadFinishMarker: View {
    let isComplete: Bool
    let time: TimeInterval
    let reduceMotion: Bool

    var body: some View {
        let pulse: CGFloat = reduceMotion ? 1 : CGFloat(1 + (sin(time * 4.2) * 0.06))

        ZStack {
            if isComplete {
                Circle()
                    .stroke(CoachTheme.rewardGlow.opacity(0.55), lineWidth: 2)
                    .frame(width: 35, height: 35)
                    .scaleEffect(pulse)
            }

            Circle()
                .fill(.regularMaterial)
                .frame(width: 29, height: 29)
                .shadow(color: .black.opacity(0.12), radius: 2, y: 1)

            Image(systemName: isComplete ? "checkmark" : "flag.checkered")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(isComplete ? CoachTheme.correct : CoachTheme.accent)
        }
        .accessibilityHidden(true)
    }
}

private struct RoadsideLandscape: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            DistantHillShape()
                .fill(Color(red: 0.31, green: 0.67, blue: 0.49).opacity(0.72))

            HStack(alignment: .bottom, spacing: 24) {
                Image(systemName: "tree.fill")
                Image(systemName: "house.fill")
                Spacer(minLength: 20)
                Image(systemName: "building.2.fill")
                Image(systemName: "tree.fill")
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(Color(red: 0.15, green: 0.48, blue: 0.39).opacity(0.82))
            .padding(.horizontal, 30)
            .padding(.bottom, 2)
        }
        .accessibilityHidden(true)
    }
}

private struct DistantHillShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addCurve(
            to: CGPoint(x: rect.maxX * 0.54, y: rect.maxY * 0.58),
            control1: CGPoint(x: rect.maxX * 0.18, y: rect.maxY * 0.12),
            control2: CGPoint(x: rect.maxX * 0.36, y: rect.maxY * 0.92)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY * 0.70),
            control1: CGPoint(x: rect.maxX * 0.70, y: rect.maxY * 0.18),
            control2: CGPoint(x: rect.maxX * 0.86, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
