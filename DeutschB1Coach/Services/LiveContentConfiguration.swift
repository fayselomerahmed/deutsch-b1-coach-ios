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
