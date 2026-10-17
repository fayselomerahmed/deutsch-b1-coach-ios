import SwiftUI
import StoreKit
import UIKit

enum PremiumFeature {
    case completeCourse
    case advancedPractice
    case realLife
    case games
    case exam
    case detailedProgress

    var title: String {
        switch self {
        case .completeCourse: "Unlock the complete A1-B1 course"
        case .advancedPractice: "Unlock advanced practice"
        case .realLife: "Unlock real-life conversations"
        case .games: "Unlock learning games"
        case .exam: "Unlock B1 exam preparation"
        case .detailedProgress: "Unlock detailed progress"
        }
    }

    var message: String {
        switch self {
        case .completeCourse:
            "Continue after the five free A1 starter lessons and open every A1, A2, and B1 chapter."
        case .advancedPractice:
            "Train speaking, listening, reading, writing, and your personal weaknesses without limits."
        case .realLife:
            "Practice guided roleplays, natural voice, corrections, and the complete everyday phrasebook."
        case .games:
            "Build faster recall and German word order with the complete game collection."
        case .exam:
            "Use timed B1 sections, model answers, scoring rubrics, and readiness coaching."
        case .detailedProgress:
            "See skill balance, milestones, history, and advanced recommendations across A1-B1."
        }
    }

    var icon: String {
        switch self {
        case .completeCourse: "books.vertical.fill"
        case .advancedPractice: "slider.horizontal.3"
        case .realLife: "bubble.left.and.bubble.right.fill"
        case .games: "gamecontroller.fill"
        case .exam: "checkmark.seal.fill"
        case .detailedProgress: "chart.bar.fill"
        }
    }

    var entryPoint: PremiumEntryPoint {
        switch self {
        case .completeCourse: .coursePreview
        case .advancedPractice: .advancedPractice
        case .realLife: .realLife
        case .games: .games
        case .exam: .exam
        case .detailedProgress: .progress
        }
    }
}

struct PremiumGate<Content: View>: View {
    @State private var premium = PremiumAccessService.shared
    let feature: PremiumFeature
    let content: Content

    init(feature: PremiumFeature, @ViewBuilder content: () -> Content) {
        self.feature = feature
        self.content = content()
    }

    @ViewBuilder var body: some View {
        if premium.isPremium {
            content
        } else {
            PremiumLockedView(feature: feature)
        }
    }
}

struct PremiumLockBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "lock.fill")
            TeachingText(english: "FULL")
        }
        .font(.caption2.weight(.heavy))
        .foregroundStyle(CoachTheme.accent)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(CoachTheme.accent.opacity(0.14), in: Capsule())
        .accessibilityElement(children: .combine)
        .teachingAccessibilityLabel("Full version required")
    }
}

struct PremiumLockedView: View {
    @State private var showsPremium = false
    let feature: PremiumFeature

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(CoachTheme.accent.opacity(0.14))
                        .frame(width: 108, height: 108)
                    Image(systemName: feature.icon)
                        .font(.system(size: 43, weight: .bold))
                        .foregroundStyle(CoachTheme.accent)
                    Image(systemName: "lock.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(CoachTheme.accent, in: Circle())
                        .offset(x: 38, y: 38)
                }
                .accessibilityHidden(true)

                VStack(spacing: 8) {
                    TeachingText(english: feature.title)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    TeachingText(english: feature.message)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                CoachCard(tint: CoachTheme.primary) {
                    VStack(alignment: .leading, spacing: 12) {
                        lockedBenefit("Complete A1, A2, and B1 learning path", icon: "map.fill")
                        Divider()
                        lockedBenefit("Advanced practice, games, roleplays, and exam coach", icon: "sparkles")
                        Divider()
                        lockedBenefit("Unlock with an active trial, owner grant, or App Store plan", icon: "checkmark.shield.fill")
                    }
                }

                TeachingButton("View full access") {
                    showsPremium = true
                }
                .buttonStyle(PrimaryCoachButton(tint: CoachTheme.accent))

                TeachingText(english: "Your free A1 starter lessons, review queue, and orientation questions remain available.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
        .teachingNavigationTitle("Full Version")
        .navigationBarTitleDisplayMode(.inline)
        .coachBackground()
        .sheet(isPresented: $showsPremium) { PremiumView(entryPoint: feature.entryPoint) }
    }

    private func lockedBenefit(_ text: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: icon)
                .font(.callout.weight(.bold))
                .foregroundStyle(CoachTheme.primary)
                .frame(width: 28, height: 28)
                .background(CoachTheme.primary.opacity(0.12), in: Circle())
                .accessibilityHidden(true)
            TeachingText(english: text)
                .font(.callout.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var premium = PremiumAccessService.shared
    let entryPoint: PremiumEntryPoint

    init(entryPoint: PremiumEntryPoint = .direct) {
        self.entryPoint = entryPoint
    }

    private let benefits = [
        ("Structured A1-B1 Journey", "Continue chronological lessons at the right level instead of searching for what to study next.", "map.fill"),
        ("Real-Life Speaking", "Practise useful situations with corrected German, focused retries, and natural private audio.", "mic.fill"),
        ("B1 Readiness Plan", "Train listening, reading, writing, and speaking with realistic practice checkpoints.", "checkmark.seal.fill"),
        ("Visual Memory", "Remember vocabulary, articles, plurals, and grammar through images and interactive structure.", "photo.on.rectangle.angled"),
        ("Weakness Coach", "Bring difficult words and grammar back at the right time with targeted review.", "target")
    ]

    private var displayedProducts: [Product] {
        premium.products.sorted { lhs, rhs in
            if isAnnual(lhs) != isAnnual(rhs) { return isAnnual(lhs) }
            return lhs.id < rhs.id
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 14) {
                        CoachIconTile(icon: "crown.fill", tint: CoachTheme.accent, size: 58)
                        VStack(alignment: .leading, spacing: 4) {
                            SkillChip(title: premium.isPremium ? "ACTIVE" : "PREMIUM", color: CoachTheme.accent)
                            TeachingText(english: premium.isPremium ? "Your full coach is active" : entryPoint.headline)
                                .font(.system(.title2, design: .rounded, weight: .bold))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    TeachingText(english: entryPoint.detail)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    CoachCard {
                        VStack(spacing: 14) {
                            ForEach(Array(benefits.enumerated()), id: \.offset) { index, benefit in
                                HStack(spacing: 13) {
                                    CoachIconTile(icon: benefit.2, tint: color(for: index), size: 42)
                                    VStack(alignment: .leading, spacing: 3) {
                                        TeachingText(english: benefit.0)
                                            .font(.headline)
                                        TeachingText(english: benefit.1)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                if index < benefits.count - 1 { Divider() }
                            }
                        }
                    }

                    Group {
                        if premium.isLoading {
                            CoachLoadingState(
                                title: "Loading plans",
                                message: "Checking the App Store for current options."
                            )
                            .transition(contentTransition)
                        } else if premium.products.isEmpty {
                            CoachCard {
                                VStack(spacing: 14) {
                                    CoachEmptyState(
                                        icon: "arrow.clockwise",
                                        title: "Plans are unavailable",
                                        message: "The App Store could not load subscription options right now."
                                    )
                                    TeachingButton("Try again") {
                                        Task { await premium.refresh() }
                                    }
                                    .buttonStyle(PrimaryCoachButton())
                                }
                            }
                            .transition(contentTransition)
                        } else {
                            ForEach(displayedProducts, id: \.id) { product in
                                planButton(product)
                            }
                        }
                    }
                    .animation(reduceMotion ? nil : CoachMotion.standard, value: premium.isLoading)
                    .animation(reduceMotion ? nil : CoachMotion.standard, value: premium.products.count)

                    TeachingButton("Restore Purchases") {
                        Task { await premium.restore() }
                    }
                    .buttonStyle(SecondaryCoachButton(tint: CoachTheme.primary))

                    if let purchaseError = premium.purchaseError {
                        CoachFeedbackPanel(
                            isCorrect: false,
                            title: "Purchase needs attention",
                            message: purchaseError
                        )
                    }

                    subscriptionTerms
                }
                .padding()
            }
            .teachingNavigationTitle("Premium")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    TeachingButton("Done") { dismiss() }
                }
            }
            .coachBackground()
            .task {
                PrivateProductAnalytics.record(.paywallViewed)
                await premium.refresh()
            }
        }
    }

    private func color(for index: Int) -> Color {
        [CoachTheme.primary, CoachTheme.listening, CoachTheme.speaking, CoachTheme.accent][index % 4]
    }

    private var contentTransition: AnyTransition {
        reduceMotion ? .identity : .opacity.combined(with: .offset(y: 4))
    }

    @ViewBuilder private func planButton(_ product: Product) -> some View {
        let annual = isAnnual(product)
        Button {
            Task {
                if await premium.purchase(product) {
                    CoachFeedback.success()
                    dismiss()
                }
            }
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 7) {
                        Text(product.displayName)
                            .font(.headline)
                        if annual {
                            Text("BEST VALUE")
                                .font(.caption2.weight(.black))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 4)
                                .background(CoachTheme.correct, in: Capsule())
                        }
                    }
                    Text(annual ? "One payment for 12 months" : "Flexible monthly access")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 6)
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.headline)
                    Text(annual ? "per year" : "per month")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
            .background(
                annual ? CoachTheme.accent.opacity(0.12) : CoachTheme.elevatedSurface,
                in: RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CoachTheme.controlRadius)
                    .stroke(annual ? CoachTheme.accent.opacity(0.55) : CoachTheme.stroke, lineWidth: annual ? 2 : 1)
            )
        }
        .buttonStyle(CoachCardButtonStyle())
        .teachingAccessibilityHint("Apple shows the exact price and renewal terms before confirmation")
    }

    private func isAnnual(_ product: Product) -> Bool {
        product.id == "deutschb1coach.premium.yearly"
    }

    private var subscriptionTerms: some View {
        VStack(spacing: 10) {
            TeachingText(
                english: "If an introductory offer is available for your Apple Account, Apple shows it before confirmation. Apple also shows the exact price and renewal date. Subscriptions renew automatically unless cancelled in Apple Account settings."
            )
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 18) { subscriptionLinks }
                VStack(spacing: 8) { subscriptionLinks }
            }
            .font(.caption.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder private var subscriptionLinks: some View {
        Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
            TeachingText(english: "Terms of Use")
        }
        Link(destination: AppLinks.privacy) {
            TeachingText(english: "Privacy")
        }
        Link(destination: URL(string: "https://apps.apple.com/account/subscriptions")!) {
            TeachingText(english: "Manage Subscription")
        }
    }
}

struct OrganizationAccessView: View {
    @State private var premium = PremiumAccessService.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CoachCard(tint: premium.isPremium ? CoachTheme.correct : CoachTheme.primary) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 12) {
                            CoachIconTile(
                                icon: premium.isPremium ? "checkmark.seal.fill" : "building.2.fill",
                                tint: premium.isPremium ? CoachTheme.correct : CoachTheme.primary,
                                size: 48
                            )
                            VStack(alignment: .leading, spacing: 4) {
                                TeachingText(english: "School or partner access")
                                    .font(.title3.weight(.bold))
                                TeachingText(english: premium.accessSummary)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        Divider()

                        TeachingText(english: "Your private Access ID")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(premium.accessID)
                            .font(.system(.body, design: .monospaced, weight: .bold))
                            .foregroundStyle(CoachTheme.primary)
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)

                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: 10) { organizationAccessButtons }
                            VStack(spacing: 8) { organizationAccessButtons }
                        }

                        TeachingText(
                            english: "Share this random ID only with your participating organization. Your name, progress, answers, and voice recordings are never sent with it. Consumer purchases are handled separately by Apple."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                        if premium.isRefreshingManagedAccess {
                            HStack(spacing: 9) {
                                ProgressView()
                                TeachingText(english: "Checking activation...")
                                    .font(.callout.weight(.semibold))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } else if let error = premium.managedAccessError {
                            CoachFeedbackPanel(
                                isCorrect: false,
                                title: "Activation check failed",
                                message: error
                            )
                        } else if premium.isPremium {
                            CoachFeedbackPanel(
                                isCorrect: true,
                                title: "Full version unlocked",
                                message: "Your access is active. All lessons, practice, games, conversations, and exam preparation are now open."
                            )
                        }

                        if let checkedAt = premium.lastManagedAccessCheck {
                            TeachingText(english: "Last checked \(checkedAt.formatted(date: .omitted, time: .shortened))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding()
        }
        .teachingNavigationTitle("Organization Access")
        .navigationBarTitleDisplayMode(.inline)
        .coachBackground()
        .task {
            await premium.refreshManagedAccess(showsActivity: true)
        }
    }

    @ViewBuilder private var organizationAccessButtons: some View {
        Button {
            UIPasteboard.general.string = premium.accessID
            CoachFeedback.success()
        } label: {
            TeachingLabel(english: "Copy ID", systemImage: "doc.on.doc.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(SecondaryCoachButton(tint: CoachTheme.primary))

        Button {
            Task { await premium.refreshManagedAccess(showsActivity: true) }
        } label: {
            TeachingLabel(
                english: premium.isRefreshingManagedAccess ? "Checking access" : "Check access",
                systemImage: "arrow.clockwise"
            )
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(SecondaryCoachButton(tint: CoachTheme.listening))
        .disabled(premium.isRefreshingManagedAccess)
    }
}
