import Foundation

enum PremiumEntryPoint: String, Codable {
    case direct
    case coursePreview
    case lessonCompleted
    case speakingCorrection
    case readinessResult
    case advancedPractice
    case realLife
    case games
    case exam
    case progress
    case settings

    var headline: String {
        switch self {
        case .lessonCompleted:
            "Keep your momentum"
        case .speakingCorrection:
            "Turn feedback into confident speech"
        case .readinessResult:
            "Follow your personal B1 plan"
        case .realLife:
            "Practice German for real life"
        case .exam:
            "Prepare for B1 with a clear plan"
        default:
            "Pass B1. Handle real life in Germany."
        }
    }

    var detail: String {
        switch self {
        case .coursePreview, .lessonCompleted:
            "Continue the structured A1-B1 course in order, with visual grammar, memorable vocabulary, and active practice."
        case .speakingCorrection:
            "Get unlimited private speaking practice, corrected German, natural model audio, and focused retry coaching."
        case .readinessResult, .exam:
            "Train all four skills, revisit your weakest area, and use realistic practice checkpoints without a pass guarantee."
        case .advancedPractice:
            "Build a repeatable plan around listening, speaking, reading, writing, vocabulary, and grammar."
        case .realLife:
            "Rehearse work, housing, shopping, appointments, and public-office conversations with natural offline voice."
        case .games:
            "Strengthen recall and German word order through short, purposeful learning games."
        case .progress:
            "See your skill balance, recent results, weak areas, and next recommended action."
        case .direct, .settings:
            "Learn visually, practise real conversations, and prepare for independent daily life and the B1 exam in your teaching language."
        }
    }
}

enum ProductFunnelEvent: String, CaseIterable, Codable {
    case onboardingCompleted
    case lessonStarted
    case lessonCompleted
    case speakingCorrectionReceived
    case readinessCheckCompleted
    case paywallViewed
    case purchaseStarted
    case purchaseCompleted
    case purchaseRestored
}

struct ProductFunnelSnapshot: Equatable {
    let counts: [ProductFunnelEvent: Int]

    func count(_ event: ProductFunnelEvent) -> Int {
        counts[event, default: 0]
    }
}

/// Stores aggregate product milestones locally. No answers, transcripts, names, or lesson text are recorded.
@MainActor
enum PrivateProductAnalytics {
    private static let countsStorageKey = "productFunnel.aggregateCounts.v1"
    static let sharingStorageKey = "privacy.shareAnonymousImprovementData"

    static func record(_ event: ProductFunnelEvent) {
        var counts = UserDefaults.standard.dictionary(forKey: countsStorageKey) as? [String: Int] ?? [:]
        counts[event.rawValue, default: 0] += 1
        UserDefaults.standard.set(counts, forKey: countsStorageKey)

        guard UserDefaults.standard.bool(forKey: sharingStorageKey) else { return }
        Task { await ProductMetricReporter.send(event) }
    }

    static var snapshot: ProductFunnelSnapshot {
        let stored = UserDefaults.standard.dictionary(forKey: countsStorageKey) as? [String: Int] ?? [:]
        let counts = Dictionary(uniqueKeysWithValues: ProductFunnelEvent.allCases.map {
            ($0, stored[$0.rawValue, default: 0])
        })
        return ProductFunnelSnapshot(counts: counts)
    }

    static func reset() {
        UserDefaults.standard.removeObject(forKey: countsStorageKey)
    }
}

private enum ProductMetricReporter {
    private static let endpoint = URL(
        string: "https://example.invalid/api/analytics/event"
    )!

    private struct Payload: Encodable {
        let event: String
        let appBuild: Int
    }

    static func send(_ event: ProductFunnelEvent) async {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 8
        let build = Int(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1") ?? 1
        request.httpBody = try? JSONEncoder().encode(Payload(event: event.rawValue, appBuild: build))
        guard request.httpBody != nil else { return }
        _ = try? await URLSession.shared.data(for: request)
    }
}

enum FreeExperienceStore {
    static let speakingSampleCompletedKey = "freeExperience.speakingSampleCompleted.v1"
    static let readinessCheckCompletedKey = "freeExperience.readinessCheckCompleted.v1"

    static var speakingSampleCompleted: Bool {
        UserDefaults.standard.bool(forKey: speakingSampleCompletedKey)
    }

    static var readinessCheckCompleted: Bool {
        UserDefaults.standard.bool(forKey: readinessCheckCompletedKey)
    }

    @MainActor
    static func completeSpeakingSample() {
        guard !speakingSampleCompleted else { return }
        UserDefaults.standard.set(true, forKey: speakingSampleCompletedKey)
        PrivateProductAnalytics.record(.speakingCorrectionReceived)
    }

    @MainActor
    static func completeReadinessCheck() {
        guard !readinessCheckCompleted else { return }
        UserDefaults.standard.set(true, forKey: readinessCheckCompletedKey)
        PrivateProductAnalytics.record(.readinessCheckCompleted)
    }
}
