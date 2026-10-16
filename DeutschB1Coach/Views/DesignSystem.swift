import SwiftUI

enum CoachMotion {
    static let quickDuration = 0.16
    static let standardDuration = 0.22
    static let springDuration = 0.26
    static let celebrationDuration = 0.30

    static let quick = Animation.timingCurve(0.2, 0.8, 0.2, 1, duration: quickDuration)
    static let standard = Animation.timingCurve(0.16, 1, 0.3, 1, duration: standardDuration)
    static let spring = Animation.spring(duration: springDuration, bounce: 0.14)
    static let navigation = Animation.spring(duration: 0.24, bounce: 0.12)
    static let flip = Animation.spring(duration: 0.28, bounce: 0.08)
    static let celebration = Animation.spring(duration: celebrationDuration, bounce: 0.22)

    static func reveal(index: Int) -> Animation {
        spring.delay(min(Double(index) * 0.025, 0.12))
    }
}

enum CoachTheme {
    static let cardRadius: CGFloat = 16
    static let controlRadius: CGFloat = 12
    static let smallRadius: CGFloat = 8
    static let background = Color(uiColor: .systemGroupedBackground)
    static let surface = Color(uiColor: .secondarySystemGroupedBackground)
    static let elevatedSurface = Color(uiColor: .systemBackground)
    static let primary = Color(red: 0.02, green: 0.48, blue: 0.40)
    static let accent = Color(red: 0.88, green: 0.30, blue: 0.22)
    static let reward = Color(red: 0.74, green: 0.43, blue: 0.00)
    static let rewardGlow = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.88, green: 0.62, blue: 0.18, alpha: 1)
            : UIColor(red: 0.98, green: 0.70, blue: 0.20, alpha: 1)
    })
    static let ink = Color.primary
    static let mutedInk = Color.secondary
    static let stroke = Color.primary.opacity(0.10)
    static let correct = Color(red: 0.04, green: 0.51, blue: 0.31)
    static let incorrect = Color(red: 0.76, green: 0.20, blue: 0.28)
    static let listening = Color(red: 0.13, green: 0.41, blue: 0.76)
    static let speaking = Color(red: 0.62, green: 0.25, blue: 0.49)
    static let reading = Color(red: 0.00, green: 0.46, blue: 0.54)
    static let writing = Color(red: 0.73, green: 0.34, blue: 0.12)
    static let warmWash = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.14, green: 0.11, blue: 0.10, alpha: 1)
            : UIColor(red: 1.00, green: 0.94, blue: 0.92, alpha: 1)
    })
    static let softMint = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.08, green: 0.18, blue: 0.14, alpha: 1)
            : UIColor(red: 0.89, green: 0.97, blue: 0.93, alpha: 1)
    })
    static let softRose = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.20, green: 0.10, blue: 0.12, alpha: 1)
            : UIColor(red: 0.99, green: 0.91, blue: 0.92, alpha: 1)
    })

    private static let gradientTop = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.11, green: 0.09, blue: 0.12, alpha: 1)
            : UIColor(red: 1.00, green: 0.96, blue: 0.93, alpha: 1)
    })
    private static let gradientMiddle = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.05, green: 0.14, blue: 0.12, alpha: 1)
            : UIColor(red: 0.91, green: 0.98, blue: 0.94, alpha: 1)
    })
    private static let gradientBottom = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.06, green: 0.08, blue: 0.17, alpha: 1)
            : UIColor(red: 0.91, green: 0.94, blue: 1.00, alpha: 1)
    })

    static let pageGradient = LinearGradient(
        stops: [
            .init(color: gradientTop, location: 0),
            .init(color: gradientMiddle, location: 0.48),
            .init(color: gradientBottom, location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static func surfaceGradient(tint: Color, colorScheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            stops: [
                .init(color: elevatedSurface.opacity(colorScheme == .dark ? 0.98 : 1), location: 0),
                .init(color: tint.opacity(colorScheme == .dark ? 0.055 : 0.025), location: 0.56),
                .init(color: tint.opacity(colorScheme == .dark ? 0.11 : 0.065), location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func controlGradient(tint: Color) -> LinearGradient {
        LinearGradient(
            stops: [
                .init(color: tint.opacity(0.88), location: 0),
                .init(color: tint, location: 0.52),
                .init(color: tint.opacity(0.90), location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func controlDepthGradient(tint: Color) -> LinearGradient {
        LinearGradient(
            colors: [tint.opacity(0.96), tint.opacity(0.72)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static func premiumBorder(tint: Color, colorScheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(colorScheme == .dark ? 0.18 : 0.82),
                tint.opacity(colorScheme == .dark ? 0.30 : 0.18),
                Color.primary.opacity(colorScheme == .dark ? 0.13 : 0.07)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func progressGradient(tint: Color = accent) -> LinearGradient {
        LinearGradient(
            colors: [tint, primary, rewardGlow],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static func actionGradient(tint: Color, companion: Color) -> LinearGradient {
        LinearGradient(
            stops: [
                .init(color: tint, location: 0),
                .init(color: tint.opacity(0.94), location: 0.38),
                .init(color: companion, location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct CoachCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let padding: CGFloat
    let tint: Color?
    let content: Content

    init(padding: CGFloat = 16, tint: Color? = nil, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
                    .fill(
                        tint.map {
                            AnyShapeStyle(CoachTheme.surfaceGradient(tint: $0, colorScheme: colorScheme))
                        } ?? AnyShapeStyle(CoachTheme.elevatedSurface)
                    )
                    .shadow(
                        color: colorScheme == .dark ? .black.opacity(0.20) : .black.opacity(0.055),
                        radius: 5,
                        x: 0,
                        y: 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
                    .stroke((tint ?? Color.primary).opacity(colorScheme == .dark ? 0.18 : 0.10), lineWidth: 1)
            )
    }
}

struct CoachSpotlightCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    let tint: Color
    let companion: Color
    let padding: CGFloat
    let content: Content

    init(
        tint: Color,
        companion: Color,
        padding: CGFloat = 18,
        @ViewBuilder content: () -> Content
    ) {
        self.tint = tint
        self.companion = companion
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                CoachTheme.actionGradient(tint: tint, companion: companion),
                in: RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: CoachTheme.cardRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.30 : 0.54),
                                Color.white.opacity(0.10),
                                companion.opacity(0.34)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .overlay(alignment: .top) {
                Capsule()
                    .fill(Color.white.opacity(0.30))
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                    .offset(y: 1)
                    .accessibilityHidden(true)
            }
            .shadow(
                color: tint.opacity(colorScheme == .dark ? 0.22 : 0.18),
                radius: 12,
                x: 0,
                y: 6
            )
    }
}

struct CoachSpotlightBadge: View {
    let title: String
    var icon: String?

    var body: some View {
        HStack(spacing: 5) {
            if let icon {
                Image(systemName: icon)
                    .accessibilityHidden(true)
            }
            TeachingText(english: title)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.system(.footnote, design: .rounded, weight: .bold))
        .foregroundStyle(.white)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.16), in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.24), lineWidth: 0.8))
        .accessibilityElement(children: .combine)
    }
}

struct CoachSpotlightProgress: View {
    let progress: Double

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.20))
                Capsule()
                    .fill(Color.white.opacity(0.96))
                    .frame(width: proxy.size.width * clampedProgress)
            }
        }
        .frame(height: 7)
        .teachingAccessibilityLabel("Course progress")
        .teachingAccessibilityValue("\(Int(clampedProgress * 100)) percent")
    }
}

struct PrimaryCoachButton: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    var tint: Color = CoachTheme.primary
    var foreground: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.callout, design: .rounded, weight: .bold))
            .frame(maxWidth: .infinity)
            .frame(minHeight: 54)
            .padding(.horizontal, 14)
            .foregroundStyle(foreground.opacity(isEnabled ? 1 : 0.70))
            .background(
                RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                    .fill(
                        isEnabled
                            ? AnyShapeStyle(CoachTheme.controlGradient(tint: tint))
                            : AnyShapeStyle(Color.secondary.opacity(colorScheme == .dark ? 0.30 : 0.38))
                    )
            )
            .background {
                RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                    .fill(
                        isEnabled
                            ? AnyShapeStyle(CoachTheme.controlDepthGradient(tint: tint))
                            : AnyShapeStyle(Color.secondary.opacity(0.24))
                    )
                    .offset(y: configuration.isPressed ? 1 : 3)
            }
            .overlay(
                RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isEnabled ? 0.46 : 0.08),
                                Color.white.opacity(isEnabled ? 0.10 : 0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .overlay(alignment: .top) {
                Capsule()
                    .fill(Color.white.opacity(isEnabled ? 0.34 : 0.08))
                    .frame(height: 1)
                    .padding(.horizontal, 15)
                    .offset(y: 1)
                    .accessibilityHidden(true)
            }
            .shadow(
                color: isEnabled ? tint.opacity(configuration.isPressed ? 0.08 : 0.18) : .clear,
                radius: configuration.isPressed ? 1 : 5,
                x: 0,
                y: configuration.isPressed ? 0 : 2
            )
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .offset(y: configuration.isPressed && !reduceMotion ? 2 : 0)
            .brightness(configuration.isPressed ? -0.035 : 0)
            .contentShape(RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous))
            .animation(reduceMotion ? nil : CoachMotion.quick, value: configuration.isPressed)
    }
}

struct SecondaryCoachButton: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    var tint: Color = CoachTheme.primary

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.callout, design: .rounded, weight: .semibold))
            .frame(minHeight: 46)
            .padding(.horizontal, 13)
            .foregroundStyle(isEnabled ? tint : Color.secondary)
            .background(
                RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                    .fill(CoachTheme.elevatedSurface)
                    .overlay {
                        RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                            .fill(tint.opacity(configuration.isPressed ? 0.14 : 0.075))
                    }
            )
            .overlay(
                RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                    .stroke(
                        isEnabled
                            ? LinearGradient(colors: [tint.opacity(0.28)], startPoint: .top, endPoint: .bottom)
                            : LinearGradient(colors: [CoachTheme.stroke], startPoint: .top, endPoint: .bottom),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.10 : 0.035), radius: 3, y: 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .opacity(isEnabled ? 1 : 0.66)
            .contentShape(RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous))
            .animation(reduceMotion ? nil : CoachMotion.quick, value: configuration.isPressed)
    }
}

struct CoachCardButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .offset(y: configuration.isPressed && !reduceMotion ? 1 : 0)
            .brightness(configuration.isPressed ? -0.025 : 0)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(reduceMotion ? nil : CoachMotion.quick, value: configuration.isPressed)
    }
}

struct CoachIconButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    var tint: Color = CoachTheme.primary

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(tint)
            .frame(width: 44, height: 44)
            .background(
                LinearGradient(
                    colors: [
                        Color.white.opacity(colorScheme == .dark ? 0.10 : 0.88),
                        tint.opacity(configuration.isPressed ? 0.25 : 0.16)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Circle()
            )
            .background(Circle().fill(tint.opacity(colorScheme == .dark ? 0.20 : 0.12)).offset(y: 2))
            .overlay(Circle().stroke(CoachTheme.premiumBorder(tint: tint, colorScheme: colorScheme)))
            .shadow(
                color: tint.opacity(configuration.isPressed ? 0.05 : 0.16),
                radius: configuration.isPressed ? 1 : 4,
                y: configuration.isPressed ? 0 : 1
            )
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
            .offset(y: configuration.isPressed && !reduceMotion ? 1 : 0)
            .animation(reduceMotion ? nil : CoachMotion.quick, value: configuration.isPressed)
    }
}

struct CoachSectionHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            TeachingText(english: title)
                .font(.system(.title3, design: .rounded, weight: .bold))
            if let subtitle {
                TeachingText(english: subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct CoachCategoryOption<Value: Hashable>: Identifiable {
    let value: Value
    let title: String
    let icon: String?
    let tint: Color

    init(
        value: Value,
        title: String,
        icon: String? = nil,
        tint: Color = CoachTheme.primary
    ) {
        self.value = value
        self.title = title
        self.icon = icon
        self.tint = tint
    }

    var id: Value { value }
}

struct CoachNavigationItem: Identifiable, Hashable {
    let id: Int
    let title: String
    let icon: String
    let selectedIcon: String

    init(id: Int, title: String, icon: String, selectedIcon: String? = nil) {
        self.id = id
        self.title = title
        self.icon = icon
        self.selectedIcon = selectedIcon ?? "\(icon).fill"
    }
}

struct CoachNavigationBar: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var selection: Int
    let items: [CoachNavigationItem]

    @Namespace private var selectionNamespace

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(items) { item in
                    navigationButton(item)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(.bar)
        .overlay(alignment: .top) {
            Divider()
        }
        .accessibilityElement(children: .contain)
    }

    private func navigationButton(_ item: CoachNavigationItem) -> some View {
        let isSelected = selection == item.id

        return Button {
            guard !isSelected else { return }
            CoachFeedback.selection()
            if reduceMotion {
                selection = item.id
            } else {
                withAnimation(CoachMotion.navigation) {
                    selection = item.id
                }
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: isSelected ? item.selectedIcon : item.icon)
                    .font(.system(size: 17, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                TeachingText(english: item.title)
                    .font(.footnote.weight(isSelected ? .bold : .semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(isSelected ? CoachTheme.primary : Color.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .frame(minHeight: 52)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: CoachTheme.smallRadius, style: .continuous)
                        .fill(CoachTheme.primary.opacity(0.12))
                        .matchedGeometryEffect(id: "navigation-background", in: selectionNamespace)
                }
            }
            .overlay(alignment: .top) {
                if isSelected {
                    Capsule()
                        .fill(CoachTheme.primary)
                        .frame(width: 28, height: 3)
                        .matchedGeometryEffect(id: "navigation-indicator", in: selectionNamespace)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(CoachNavigationButtonStyle())
        .teachingAccessibilityLabel(item.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct CoachNavigationButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(reduceMotion ? nil : CoachMotion.quick, value: configuration.isPressed)
    }
}

struct CoachCategoryPicker<Value: Hashable>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String?
    @Binding var selection: Value
    let options: [CoachCategoryOption<Value>]

    @Namespace private var selectionNamespace

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            if let title {
                TeachingText(english: title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if dynamicTypeSize.isAccessibilitySize {
                categoryMenu
            } else if options.count <= 3 {
                HStack(spacing: 7) {
                    ForEach(options) { option in
                        categoryButton(option, expands: true)
                    }
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(options) { option in
                            categoryButton(option, expands: false)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollClipDisabled()
            }
        }
        .onChange(of: selection) { _, _ in
            CoachFeedback.selection()
        }
    }

    private var selectedTitle: String {
        options.first { $0.value == selection }?.title ?? options.first?.title ?? "Choose"
    }

    private var selectedOption: CoachCategoryOption<Value>? {
        options.first { $0.value == selection }
    }

    private var categoryMenu: some View {
        Menu {
            ForEach(options) { option in
                Button {
                    select(option)
                } label: {
                    HStack {
                        if let icon = option.icon {
                            Image(systemName: icon)
                        }
                        TeachingText(english: option.title)
                        if selection == option.value {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: selectedOption?.icon ?? "line.3.horizontal.decrease")
                    .foregroundStyle(selectedOption?.tint ?? CoachTheme.primary)
                    .accessibilityHidden(true)
                TeachingText(english: selectedTitle)
                    .font(.callout.weight(.bold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
            .background(
                CoachTheme.elevatedSurface,
                in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                    .stroke(CoachTheme.stroke)
            )
        }
        .teachingAccessibilityLabel(title ?? "Category")
        .teachingAccessibilityValue(selectedTitle)
    }

    private func categoryButton(_ option: CoachCategoryOption<Value>, expands: Bool) -> some View {
        let isSelected = selection == option.value

        return Button {
            guard !isSelected else { return }
            select(option)
        } label: {
            VStack(spacing: option.icon == nil ? 0 : 5) {
                if let icon = option.icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .symbolRenderingMode(.hierarchical)
                        .accessibilityHidden(true)
                }
                TeachingText(english: option.title)
                    .font(.callout.weight(isSelected ? .bold : .semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .padding(.horizontal, expands ? 8 : 14)
                .padding(.vertical, 9)
                .frame(
                    minWidth: expands ? nil : 96,
                    maxWidth: expands ? .infinity : nil,
                    minHeight: option.icon == nil ? 44 : 58
                )
                .background {
                    RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                        .fill(
                            isSelected
                                ? AnyShapeStyle(CoachTheme.controlGradient(tint: option.tint))
                                : AnyShapeStyle(CoachTheme.elevatedSurface)
                        )
                        .matchedGeometryEffect(
                            id: isSelected ? "category-selection" : "category-\(String(describing: option.id))",
                            in: selectionNamespace
                        )
                }
                .overlay(
                    RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                        .stroke(
                            isSelected
                                ? LinearGradient(
                                    colors: [Color.white.opacity(0.42), option.tint.opacity(0.38)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : CoachTheme.premiumBorder(
                                    tint: option.tint,
                                    colorScheme: colorScheme
                                ),
                            lineWidth: isSelected ? 1 : 0.8
                        )
                )
        }
        .buttonStyle(CoachCardButtonStyle())
        .teachingAccessibilityLabel(option.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func select(_ option: CoachCategoryOption<Value>) {
        guard selection != option.value else { return }
        if reduceMotion {
            selection = option.value
        } else {
            withAnimation(CoachMotion.navigation) {
                selection = option.value
            }
        }
    }
}

struct CoachIconTile: View {
    @Environment(\.colorScheme) private var colorScheme
    let icon: String
    let tint: Color
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: icon)
            .symbolRenderingMode(.hierarchical)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(
                LinearGradient(
                    colors: [
                        Color.white.opacity(colorScheme == .dark ? 0.08 : 0.82),
                        tint.opacity(colorScheme == .dark ? 0.20 : 0.14)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Circle()
            )
            .overlay(Circle().stroke(CoachTheme.premiumBorder(tint: tint, colorScheme: colorScheme)))
            .shadow(color: tint.opacity(0.13), radius: 5, y: 2)
            .accessibilityHidden(true)
    }
}

struct CoachTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) private var colorScheme
    var tint: Color = CoachTheme.primary

    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                CoachTheme.surfaceGradient(tint: tint, colorScheme: colorScheme),
                in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                    .stroke(tint.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: tint.opacity(colorScheme == .dark ? 0.03 : 0.07), radius: 5, x: 0, y: 2)
    }
}

struct CoachTextEditor: View {
    @Environment(\.colorScheme) private var colorScheme
    let placeholder: String
    @Binding var text: String
    var minHeight: CGFloat = 140
    var tint: Color = CoachTheme.primary

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .padding(8)
                .scrollContentBackground(.hidden)
                .germanKeyboardAccessory(text: $text)

            if text.isEmpty {
                TeachingText(english: placeholder)
                    .font(.body)
                    .foregroundStyle(.secondary.opacity(0.80))
                    .padding(.horizontal, 13)
                    .padding(.vertical, 16)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .frame(minHeight: minHeight)
        .background(
            CoachTheme.surfaceGradient(tint: tint, colorScheme: colorScheme),
            in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous)
                .stroke(tint.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: tint.opacity(colorScheme == .dark ? 0.03 : 0.07), radius: 5, x: 0, y: 2)
        .teachingAccessibilityLabel(placeholder)
    }
}

struct CoachMetric: View {
    let value: String
    let label: String
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.callout.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(.headline, design: .rounded, weight: .bold).monospacedDigit())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                TeachingText(english: label)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

struct CoachEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var tint: Color = CoachTheme.primary

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                CoachMascot(mood: .empty, size: 76)
                    .accessibilityHidden(true)
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(
                        LinearGradient(
                            colors: [tint, tint.opacity(0.82), CoachTheme.rewardGlow.opacity(0.88)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: Circle()
                    )
                    .overlay(Circle().stroke(Color.white.opacity(0.32)))
            }
            VStack(alignment: .leading, spacing: 5) {
                TeachingText(english: title)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                TeachingText(english: message)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

struct CoachLoadingState: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String
    var message: String?

    var body: some View {
        VStack(spacing: 12) {
            CoachMascot(mood: .loading, size: 92)
                .accessibilityHidden(true)
            Group {
                if reduceMotion {
                    Image(systemName: "hourglass")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(CoachTheme.primary)
                } else {
                    ProgressView()
                        .controlSize(.large)
                        .tint(CoachTheme.primary)
                }
            }
            .frame(minWidth: 44, minHeight: 44)
            .background(CoachTheme.primary.opacity(0.10), in: Circle())
            TeachingText(english: title)
                .font(.system(.headline, design: .rounded, weight: .bold))
            if let message {
                TeachingText(english: message)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .teachingAccessibilityLabel([title, message].compactMap { $0 }.joined(separator: ". "))
        .accessibilityAddTraits(.updatesFrequently)
    }
}

struct CoachActionLabel: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    let successTitle: String
    let icon: String
    let isComplete: Bool

    var body: some View {
        HStack(spacing: 8) {
            if isComplete {
                CoachAnimatedCheckmark(size: 19)
                    .transition(reduceMotion ? .identity : .opacity.combined(with: .scale(scale: 0.86)))
            } else {
                Image(systemName: icon)
                    .transition(reduceMotion ? .identity : .opacity.combined(with: .scale(scale: 0.92)))
            }
            TeachingText(english: isComplete ? successTitle : title)
                .multilineTextAlignment(.center)
        }
        .animation(reduceMotion ? nil : CoachMotion.spring, value: isComplete)
        .teachingAccessibilityLabel(isComplete ? successTitle : title)
    }
}

struct CoachAnimatedCheckmark: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress = 0.0

    var size: CGFloat = 22
    var tint: Color = .white

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.30), lineWidth: 1.8)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(tint, style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            CoachCheckmarkShape()
                .trim(from: 0, to: max(0, (progress - 0.42) / 0.58))
                .stroke(tint, style: StrokeStyle(lineWidth: 2.1, lineCap: .round, lineJoin: .round))
                .padding(size * 0.22)
        }
        .frame(width: size, height: size)
        .onAppear {
            if reduceMotion {
                progress = 1
            } else {
                withAnimation(CoachMotion.spring) {
                    progress = 1
                }
            }
        }
        .onChange(of: reduceMotion) { _, shouldReduce in
            if shouldReduce { progress = 1 }
        }
        .accessibilityHidden(true)
    }
}

private struct CoachCheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.38, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}

struct CoachFeedbackPanel: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false
    @State private var horizontalNudge: CGFloat = 0

    let isCorrect: Bool
    let title: String
    let message: String
    var translatesMessage = true
    var protectedGerman: [String] = []

    private var tint: Color { isCorrect ? CoachTheme.correct : CoachTheme.incorrect }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            CoachMascot(mood: isCorrect ? .correct : .supportive, size: 62)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 7) {
                    if isCorrect {
                        CoachAnimatedCheckmark(size: 21, tint: tint)
                    } else {
                        Image(systemName: "lightbulb.fill")
                            .scaleEffect(reduceMotion || isVisible ? 1 : 0.72)
                            .rotationEffect(.degrees(reduceMotion || isVisible ? 0 : -12))
                    }
                    TeachingText(english: title, protectedGerman: protectedGerman)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(tint)
                Group {
                    if translatesMessage {
                        TeachingText(english: message, protectedGerman: protectedGerman)
                    } else {
                        Text(message)
                    }
                }
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isCorrect ? CoachTheme.softMint : CoachTheme.softRose, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(tint.opacity(0.18)))
        .overlay(alignment: .topTrailing) {
            if isCorrect {
                CoachConfettiBurst()
                    .offset(x: 8, y: -18)
            } else {
                CoachTryAgainNudge()
                    .offset(x: 4, y: -12)
            }
        }
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(reduceMotion || isVisible ? 1 : 0.97)
        .offset(x: horizontalNudge)
        .onAppear {
            if reduceMotion {
                isVisible = true
            } else {
                withAnimation(CoachMotion.spring) { isVisible = true }
            }
        }
        .task {
            guard !isCorrect, !reduceMotion else { return }
            for offset in [-5.0, 4.0, -2.0, 0.0] {
                try? await Task.sleep(nanoseconds: 55_000_000)
                guard !Task.isCancelled else { return }
                withAnimation(.timingCurve(0.16, 1, 0.3, 1, duration: 0.055)) {
                    horizontalNudge = offset
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct CoachConfettiBurst: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isBursting = false

    private let offsets: [CGSize] = [
        .init(width: -68, height: -20), .init(width: -48, height: -46),
        .init(width: -24, height: -58), .init(width: 2, height: -62),
        .init(width: 28, height: -54), .init(width: 54, height: -35),
        .init(width: 70, height: -9), .init(width: -58, height: 12),
        .init(width: -30, height: 24), .init(width: 35, height: 20),
        .init(width: 62, height: 12), .init(width: 4, height: 30)
    ]

    private let colors = [
        CoachTheme.correct, CoachTheme.accent, CoachTheme.rewardGlow,
        CoachTheme.listening, CoachTheme.speaking
    ]

    var body: some View {
        ZStack {
            ForEach(offsets.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(colors[index % colors.count])
                    .frame(width: index.isMultiple(of: 3) ? 5 : 4, height: index.isMultiple(of: 2) ? 9 : 6)
                    .rotationEffect(.degrees(isBursting ? Double(index * 47) : 0))
                    .offset(isBursting && !reduceMotion ? offsets[index] : .zero)
                    .scaleEffect(isBursting && !reduceMotion ? 1 : 0.25)
                    .opacity(reduceMotion ? 0 : isBursting ? 0 : 1)
            }
        }
        .frame(width: 150, height: 90)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(CoachMotion.celebration) {
                isBursting = true
            }
        }
    }
}

private struct CoachTryAgainNudge: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    var body: some View {
        Image(systemName: "arrow.uturn.backward.circle.fill")
            .font(.title3.weight(.bold))
            .symbolRenderingMode(.palette)
            .foregroundStyle(CoachTheme.incorrect, CoachTheme.softRose)
            .scaleEffect(reduceMotion || isVisible ? 1 : 0.55)
            .rotationEffect(.degrees(reduceMotion || isVisible ? 0 : 18))
            .opacity(isVisible ? 1 : 0)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .onAppear {
                if reduceMotion {
                    isVisible = true
                } else {
                    withAnimation(CoachMotion.spring) { isVisible = true }
                }
            }
    }
}

struct SkillChip: View {
    let title: String
    let color: Color
    var translatesTitle = true

    var body: some View {
        Group {
            if translatesTitle {
                TeachingText(english: title)
            } else {
                Text(title)
            }
        }
            .font(.system(.footnote, design: .rounded, weight: .semibold))
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(color.opacity(0.16), in: Capsule())
            .overlay(Capsule().stroke(color.opacity(0.20), lineWidth: 0.8))
            .foregroundStyle(color)
            .modifier(
                ConditionalTeachingAccessibilityLabel(
                    title: title,
                    translatesTitle: translatesTitle
                )
            )
    }
}

enum LearningMoment {
    case observe
    case recall
    case understand
    case repeatAloud

    var title: String {
        switch self {
        case .observe: "Look and listen"
        case .recall: "Recall first"
        case .understand: "Check the why"
        case .repeatAloud: "Say it again"
        }
    }

    var detail: String {
        switch self {
        case .observe: "Connect the picture, sound, and German before translating."
        case .recall: "Use the picture or rule, then tap the card to check."
        case .understand: "Study the answer, listen once, then rate your recall."
        case .repeatAloud: "Replay the model and repeat it in one natural phrase."
        }
    }

    var icon: String {
        switch self {
        case .observe: "eye.fill"
        case .recall: "brain.head.profile.fill"
        case .understand: "lightbulb.fill"
        case .repeatAloud: "waveform.and.mic"
        }
    }

    var tint: Color {
        switch self {
        case .observe: CoachTheme.listening
        case .recall: CoachTheme.accent
        case .understand: CoachTheme.reward
        case .repeatAloud: CoachTheme.speaking
        }
    }
}

struct LearningMomentPrompt: View {
    let moment: LearningMoment

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: moment.icon)
                .font(.callout.weight(.bold))
                .foregroundStyle(moment.tint)
                .frame(width: 34, height: 34)
                .background(moment.tint.opacity(0.12), in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                TeachingText(english: moment.title)
                    .font(.callout.weight(.bold))
                TeachingText(english: moment.detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(moment.tint.opacity(0.075), in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius, style: .continuous).stroke(moment.tint.opacity(0.16)))
        .accessibilityElement(children: .combine)
    }
}

extension SkillArea {
    var learningFocusTitle: String {
        switch self {
        case .grammar: "Grammar"
        case .vocabulary: "Vocabulary"
        case .listening: "Listening"
        case .reading: "Reading"
        case .writing: "Writing"
        case .speaking: "Speaking"
        }
    }

    var learningFocusDetail: String {
        switch self {
        case .grammar: "Strengthen grammar"
        case .vocabulary: "Wake up the words and rules you already know."
        case .listening: "Connect natural German audio to meaning."
        case .reading: "Practice finding the main point before translating every word."
        case .writing: "Give every sentence a job before you start writing."
        case .speaking: "Build confidence with one spoken answer"
        }
    }

    var learningFocusIcon: String {
        switch self {
        case .grammar: "text.book.closed.fill"
        case .vocabulary: "rectangle.stack.fill"
        case .listening: "headphones"
        case .reading: "doc.text.magnifyingglass"
        case .writing: "square.and.pencil"
        case .speaking: "mic.fill"
        }
    }

    var learningFocusTint: Color {
        switch self {
        case .grammar: CoachTheme.primary
        case .vocabulary: CoachTheme.accent
        case .listening: CoachTheme.listening
        case .reading: CoachTheme.reading
        case .writing: CoachTheme.writing
        case .speaking: CoachTheme.speaking
        }
    }

    var learningFocusOutcome: String {
        learningFocusDetail
    }

    var supportingImprovementSkills: [SkillArea] {
        switch self {
        case .grammar:
            [.writing, .speaking, .vocabulary]
        case .vocabulary:
            [.listening, .speaking, .reading]
        case .listening:
            [.vocabulary, .speaking, .reading]
        case .reading:
            [.vocabulary, .grammar, .writing]
        case .writing:
            [.grammar, .vocabulary, .reading]
        case .speaking:
            [.listening, .vocabulary, .grammar]
        }
    }
}

private struct ConditionalTeachingAccessibilityLabel: ViewModifier {
    let title: String
    let translatesTitle: Bool

    @ViewBuilder func body(content: Content) -> some View {
        if translatesTitle {
            content.teachingAccessibilityLabel(title)
        } else {
            content.accessibilityLabel(title)
        }
    }
}

struct GermanSpeechButton: View {
    let text: String
    var style: GermanSpeechStyle = .sentence
    var label = "Play German audio"
    @ObservedObject private var speech = GermanSpeechService.shared

    private var isActive: Bool { speech.isActive(text) }

    private var icon: String {
        guard isActive else { return "speaker.wave.2.fill" }
        switch speech.playbackState {
        case .idle: return "speaker.wave.2.fill"
        case .preparing: return "xmark"
        case .playing: return "pause.fill"
        case .paused: return "play.fill"
        }
    }

    private var accessibilityLabel: String {
        guard isActive else { return label }
        switch speech.playbackState {
        case .idle: return label
        case .preparing: return "Cancel German audio"
        case .playing: return "Pause German audio"
        case .paused: return "Resume German audio"
        }
    }

    var body: some View {
        Button {
            speech.toggle(text, style: style)
        } label: {
            Image(systemName: icon)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(CoachIconButtonStyle(tint: CoachTheme.listening))
        .teachingAccessibilityLabel(accessibilityLabel, protectedGerman: [text])
    }
}

struct GermanSpeechPlaybackBar: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ObservedObject private var speech = GermanSpeechService.shared

    var body: some View {
        if speech.playbackState != .idle {
            HStack(spacing: 10) {
                Image(systemName: "waveform")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CoachTheme.listening)
                    .frame(width: 34, height: 34)
                    .background(CoachTheme.listening.opacity(0.15), in: Circle())
                    .symbolEffect(
                        .variableColor.iterative,
                        options: reduceMotion || speech.playbackState != .playing ? .nonRepeating : .repeating
                    )
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 1) {
                    TeachingText(english: "German audio")
                        .font(.caption.weight(.bold))
                    Text(speech.activeText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Menu {
                    ForEach(GermanSpeechSpeed.allCases) { speed in
                        Button {
                            speech.setPlaybackSpeed(speed)
                        } label: {
                            Label(
                                speed.title,
                                systemImage: speed == speech.playbackSpeed ? "checkmark" : "speedometer"
                            )
                        }
                    }
                } label: {
                    Text(speech.playbackSpeed.title)
                        .font(.caption.monospacedDigit().weight(.bold))
                        .foregroundStyle(CoachTheme.listening)
                        .frame(minWidth: 42, minHeight: 38)
                        .background(CoachTheme.listening.opacity(0.13), in: Capsule())
                }
                .teachingAccessibilityLabel("Playback speed")

                Button {
                    togglePlayback()
                } label: {
                    Group {
                        if speech.playbackState == .preparing {
                            ProgressView()
                        } else {
                            Image(systemName: speech.playbackState == .playing ? "pause.fill" : "play.fill")
                                .contentTransition(.symbolEffect(.replace))
                        }
                    }
                    .frame(width: 38, height: 38)
                }
                .buttonStyle(CoachIconButtonStyle(tint: CoachTheme.listening))
                .teachingAccessibilityLabel(speech.playbackState == .playing ? "Pause German audio" : "Resume German audio")

                Button {
                    speech.stop()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.bold))
                        .frame(width: 30, height: 38)
                }
                .buttonStyle(.plain)
                .teachingAccessibilityLabel("Stop German audio")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.regularMaterial)
            .overlay(alignment: .top) { Divider() }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(reduceMotion ? nil : CoachMotion.quick, value: speech.playbackState)
        }
    }

    private func togglePlayback() {
        switch speech.playbackState {
        case .playing:
            speech.pause()
        case .paused:
            speech.resume()
        case .preparing:
            speech.stop()
        case .idle:
            break
        }
    }
}

struct LessonProgressBar: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var displayedProgress = 0.0
    let progress: Double

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(.primary.opacity(0.10))
                Capsule()
                    .fill(CoachTheme.progressGradient())
                    .frame(width: proxy.size.width * displayedProgress)
            }
        }
        .frame(height: 10)
        .teachingAccessibilityLabel("Lesson progress")
        .teachingAccessibilityValue("\(Int(clampedProgress * 100)) percent")
        .onAppear { updateProgress(animated: !reduceMotion) }
        .onChange(of: progress) { _, _ in updateProgress(animated: !reduceMotion) }
        .onChange(of: reduceMotion) { _, _ in updateProgress(animated: false) }
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

struct CoachRoadProgress: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let progress: Double
    var tint: Color = CoachTheme.primary

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        CoachRoadJourneyView(progress: clampedProgress, tint: tint, reduceMotion: reduceMotion)
            .frame(height: 108)
            .clipShape(RoundedRectangle(cornerRadius: CoachTheme.smallRadius, style: .continuous))
            .overlay(alignment: .topLeading) {
                Text("\(Int(clampedProgress * 100))%")
                    .font(.caption.monospacedDigit().weight(.bold))
                    .foregroundStyle(tint)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(8)
            }
        .accessibilityElement(children: .ignore)
        .teachingAccessibilityLabel("Daily learning progress")
        .teachingAccessibilityValue("\(Int(clampedProgress * 100)) percent")
    }
}

struct MetricRing: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var displayedValue = 0.0
    let value: Double
    let label: String
    let tint: Color

    private var clampedValue: Double {
        min(max(value, 0), 1)
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().stroke(.primary.opacity(0.10), lineWidth: 9)
                Circle()
                    .trim(from: 0, to: displayedValue)
                    .stroke(tint, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(value * 100))%")
                    .font(.system(.callout, design: .rounded, weight: .bold).monospacedDigit())
            }
            .frame(width: 72, height: 72)
            TeachingText(english: label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .onAppear { updateValue(animated: !reduceMotion) }
        .onChange(of: value) { _, _ in updateValue(animated: !reduceMotion) }
        .onChange(of: reduceMotion) { _, _ in updateValue(animated: false) }
    }

    private func updateValue(animated: Bool) {
        if animated {
            withAnimation(CoachMotion.spring) {
                displayedValue = clampedValue
            }
        } else {
            displayedValue = clampedValue
        }
    }
}

struct CoachFlipCard<Front: View, Back: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let isFlipped: Bool
    let front: Front
    let back: Back

    init(
        isFlipped: Bool,
        @ViewBuilder front: () -> Front,
        @ViewBuilder back: () -> Back
    ) {
        self.isFlipped = isFlipped
        self.front = front()
        self.back = back()
    }

    private var angle: Double { isFlipped ? 180 : 0 }

    var body: some View {
        ZStack {
            front
                .opacity(angle < 90 ? 1 : 0)
                .rotation3DEffect(.degrees(reduceMotion ? 0 : angle), axis: (x: 0, y: 1, z: 0), perspective: 0.55)
                .allowsHitTesting(angle < 90)
                .accessibilityHidden(angle >= 90)

            back
                .opacity(angle >= 90 ? 1 : 0)
                .rotation3DEffect(.degrees(reduceMotion ? 0 : angle - 180), axis: (x: 0, y: 1, z: 0), perspective: 0.55)
                .allowsHitTesting(angle >= 90)
                .accessibilityHidden(angle < 90)
        }
        .animation(reduceMotion ? nil : CoachMotion.flip, value: isFlipped)
    }
}

struct CoachCelebrationMark: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isCelebrating = false

    private let offsets: [CGSize] = [
        CGSize(width: -48, height: -30),
        CGSize(width: -56, height: 14),
        CGSize(width: -28, height: 42),
        CGSize(width: 34, height: 40),
        CGSize(width: 58, height: 8),
        CGSize(width: 45, height: -34),
        CGSize(width: 3, height: -51)
    ]
    private let symbols = ["sparkles", "diamond.fill", "star.fill", "sparkles", "diamond.fill", "star.fill", "sparkles"]

    var body: some View {
        ZStack {
            ForEach(offsets.indices, id: \.self) { index in
                Image(systemName: symbols[index])
                    .font(.system(size: index.isMultiple(of: 2) ? 13 : 9, weight: .bold))
                    .foregroundStyle(index.isMultiple(of: 2) ? CoachTheme.accent : CoachTheme.correct)
                    .offset(isCelebrating && !reduceMotion ? offsets[index] : .zero)
                    .scaleEffect(isCelebrating && !reduceMotion ? 1 : 0.2)
                    .opacity(reduceMotion ? 0 : isCelebrating ? 0 : 1)
            }

            CoachMascot(mood: .achievement, size: 92, animates: false)
                .scaleEffect(reduceMotion ? 1 : isCelebrating ? 1 : 0.82)
                .accessibilityHidden(true)
        }
        .frame(width: 150, height: 132)
        .onAppear {
            if reduceMotion {
                isCelebrating = true
            } else {
                withAnimation(CoachMotion.celebration) {
                    isCelebrating = true
                }
            }
        }
        .accessibilityHidden(true)
    }
}

struct CoachAchievementToast: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    let title: String
    let detail: String
    var tint = CoachTheme.correct

    var body: some View {
        HStack(spacing: 11) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.16))
                Image(systemName: "star.fill")
                    .font(.callout.weight(.bold))
                    .foregroundStyle(tint)
                    .rotationEffect(.degrees(isVisible && !reduceMotion ? 360 : 0))
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 2) {
                TeachingText(english: title)
                    .font(.callout.weight(.bold))
                    .lineLimit(1)
                TeachingText(english: detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 4)
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(tint)
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius))
        .overlay(RoundedRectangle(cornerRadius: CoachTheme.controlRadius).stroke(tint.opacity(0.22)))
        .shadow(color: .black.opacity(0.12), radius: 14, y: 6)
        .scaleEffect(isVisible || reduceMotion ? 1 : 0.86)
        .offset(y: isVisible || reduceMotion ? 0 : -16)
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
        .accessibilityElement(children: .combine)
    }
}

private struct CoachRevealModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false
    let index: Int

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible || reduceMotion ? 0 : 6)
            .onAppear {
                if reduceMotion {
                    isVisible = true
                } else {
                    withAnimation(CoachMotion.reveal(index: index)) {
                        isVisible = true
                    }
                }
            }
            .onChange(of: reduceMotion) { _, shouldReduce in
                if shouldReduce {
                    isVisible = true
                }
            }
    }
}

struct CoachBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(CoachTheme.pageGradient.ignoresSafeArea())
    }
}

enum CoachFeedback {
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}

extension View {
    func coachBackground() -> some View {
        modifier(CoachBackground())
    }

    func coachReveal(index: Int = 0) -> some View {
        modifier(CoachRevealModifier(index: index))
    }
}
