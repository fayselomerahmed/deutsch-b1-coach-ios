import Foundation

/// Remote services are opt-in: a fresh checkout stays on the bundled offline course.
struct LiveContentConfiguration: Equatable {
    let baseURL: URL
    let publicAPIKey: String

    static func current(bundle: Bundle = .main) -> LiveContentConfiguration? {
        parse(
            rawURL: bundle.object(forInfoDictionaryKey: "LiveContentBaseURL") as? String,
            publicAPIKey: bundle.object(forInfoDictionaryKey: "LiveContentAnonKey") as? String ?? ""
        )
    }

    static func parse(rawURL: String?, publicAPIKey: String = "") -> LiveContentConfiguration? {
        let value = rawURL?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !value.isEmpty,
              let url = URL(string: value),
              url.scheme?.lowercased() == "https",
              let host = url.host, !host.isEmpty,
              url.user == nil, url.password == nil,
              url.query == nil, url.fragment == nil else { return nil }
        return LiveContentConfiguration(
            baseURL: url,
            publicAPIKey: publicAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}

enum AppLinks {
    static var dashboard: URL {
        LiveContentConfiguration.current()?.baseURL
            ?? URL(string: "https://github.com/fayselomerahmed/deutsch-b1-coach-studio")!
    }

    static var privacy: URL {
        LiveContentConfiguration.current()?.baseURL.appendingPathComponent("privacy")
            ?? URL(string: "https://github.com/fayselomerahmed/deutsch-b1-coach-ios/blob/main/PRIVACY.md")!
    }

    static var support: URL {
        LiveContentConfiguration.current()?.baseURL.appendingPathComponent("support")
            ?? URL(string: "https://github.com/fayselomerahmed/deutsch-b1-coach-ios/blob/main/SUPPORT.md")!
    }
}

/// Pure timing rules shared by managed access monitoring and its regression tests.
enum ManagedAccessRefreshPolicy {
    static let foregroundInterval: TimeInterval = 15 * 60
    static let initialRetryInterval: TimeInterval = 30
    static let maximumRetryInterval: TimeInterval = 15 * 60
    static let offlineGrace: TimeInterval = 72 * 60 * 60

    static func refreshInterval(consecutiveFailures: Int) -> TimeInterval {
        guard consecutiveFailures > 0 else { return foregroundInterval }
        let exponent = min(consecutiveFailures - 1, 5)
        return min(maximumRetryInterval, initialRetryInterval * pow(2, Double(exponent)))
    }

    static func remainingDelay(lastCheck: Date?, consecutiveFailures: Int, now: Date = .now) -> TimeInterval {
        guard let lastCheck else { return 0 }
        let interval = refreshInterval(consecutiveFailures: consecutiveFailures)
        let elapsed = now.timeIntervalSince(lastCheck)
        guard elapsed.isFinite else { return interval }
        return min(interval, max(0, interval - elapsed))
    }

    static func isCacheFresh(verifiedAt: TimeInterval, now: Date = .now) -> Bool {
        let age = now.timeIntervalSince1970 - verifiedAt
        return verifiedAt.isFinite && verifiedAt > 0 && age.isFinite && age >= 0 && age <= offlineGrace
    }
}
