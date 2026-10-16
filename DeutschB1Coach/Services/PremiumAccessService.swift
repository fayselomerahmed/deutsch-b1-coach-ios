import Foundation
import Observation
import Security
import StoreKit

private enum ManagedAccessLevel: String, Codable {
    case free
    case trial
    case full
}

private struct ManagedAccessResponse: Decodable {
    let accessLevel: ManagedAccessLevel
    let status: String
    let isActive: Bool
    let expiresAt: String?
}

private enum PremiumAccessIdentity {
    private static let service = "com.faysel.DeutschB1Coach.premium-access"
    private static let account = "learner-access-id"
    private static let fallbackKey = "premiumAccess.fallbackID"

    static func loadOrCreate() -> String {
        if let stored = keychainValue(), isValid(stored) {
            return stored
        }
        if let fallback = UserDefaults.standard.string(forKey: fallbackKey), isValid(fallback) {
            saveToKeychain(fallback)
            return fallback
        }

        let characters = UUID().uuidString.replacingOccurrences(of: "-", with: "").uppercased()
        let groups = stride(from: 0, to: 16, by: 4).map { offset -> String in
            let start = characters.index(characters.startIndex, offsetBy: offset)
            let end = characters.index(start, offsetBy: 4)
            return String(characters[start..<end])
        }
        let accessID = "DC-" + groups.joined(separator: "-")
        UserDefaults.standard.set(accessID, forKey: fallbackKey)
        saveToKeychain(accessID)
        return accessID
    }

    private static func keychainValue() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func saveToKeychain(_ value: String) {
        let base: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(base as CFDictionary)
        var entry = base
        entry[kSecValueData as String] = Data(value.utf8)
        entry[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(entry as CFDictionary, nil)
    }

    private static func isValid(_ value: String) -> Bool {
        value.range(of: #"^DC-[A-F0-9]{4}(?:-[A-F0-9]{4}){3}$"#, options: .regularExpression) != nil
    }
}

@Observable
@MainActor
final class PremiumAccessService {
    static let shared = PremiumAccessService()

    private let offeredProductIds = [
        "deutschb1coach.premium.monthly",
        "deutschb1coach.premium.yearly"
    ]
    private let entitlementProductIds = [
        "deutschb1coach.premium.monthly",
        "deutschb1coach.premium.yearly",
        "deutschb1coach.premium.lifetime"
    ]
    private let managedCacheLevelKey = "premiumAccess.managed.level"
    private let managedCacheExpiryKey = "premiumAccess.managed.expiry"
    private let managedCacheVerifiedKey = "premiumAccess.managed.verified"
    private let offlineGrace: TimeInterval = 72 * 60 * 60

    let accessID = PremiumAccessIdentity.loadOrCreate()
    var products: [Product] = []
    var isPremium = false
    var purchaseError: String?
    var isLoading = false
    var managedAccessStatus = "not_found"
    var managedAccessExpiresAt: Date?
    var managedAccessError: String?
    var isRefreshingManagedAccess = false
    var isMonitoringManagedAccess = false
    var lastManagedAccessCheck: Date?
    private(set) var accessRevision = UUID()
    private(set) var managedAccessLevel: String = ManagedAccessLevel.free.rawValue

    private var appStoreAccessIsActive = false
    private var managedAccessIsActive = false
    private var managedRefreshInFlight = false
    private var updatesTask: Task<Void, Never>?

    var accessBadgeTitle: String {
        if appStoreAccessIsActive { return "APP STORE ACTIVE" }
        if managedAccessIsActive && managedAccessLevel == ManagedAccessLevel.full.rawValue { return "FULL ACCESS" }
        if managedAccessIsActive && managedAccessLevel == ManagedAccessLevel.trial.rawValue { return "TRIAL ACTIVE" }
        if managedAccessStatus == "expired" { return "TRIAL EXPIRED" }
        if managedAccessStatus == "disabled" { return "ACCESS PAUSED" }
        return "FREE VERSION"
    }

    var accessSummary: String {
        if appStoreAccessIsActive {
            return "Your verified App Store plan unlocks the full coach."
        }
        if managedAccessIsActive && managedAccessLevel == ManagedAccessLevel.full.rawValue {
            return "The app owner activated the full version for this iPhone."
        }
        if managedAccessIsActive, let managedAccessExpiresAt {
            return "Your full trial is active until \(managedAccessExpiresAt.formatted(date: .long, time: .omitted))."
        }
        if managedAccessStatus == "expired" {
            return "Your managed trial has ended. Your learning history remains available."
        }
        if managedAccessStatus == "disabled" {
            return "Managed access is currently paused. App Store purchases remain available."
        }
        return "Use this private Access ID only when a participating school, employer, or support organization provides access."
    }

    private init() {
        restoreManagedCacheIfEligible()
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    self.appStoreAccessIsActive = await self.currentEntitlementIsActive()
                    self.recomputeAccess()
                }
            }
        }
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        await refreshEntitlements()

        do {
            products = try await Product.products(for: offeredProductIds)
            purchaseError = nil
        } catch {
            purchaseError = "The App Store could not load plans. Managed access can still be used."
        }
    }

    func refreshEntitlements() async {
        appStoreAccessIsActive = await currentEntitlementIsActive()
        await refreshManagedAccess()
        recomputeAccess()
    }

    func refreshManagedAccess(showsActivity: Bool = false) async {
        guard !managedRefreshInFlight else { return }
        managedRefreshInFlight = true
        if showsActivity { isRefreshingManagedAccess = true }
        defer {
            managedRefreshInFlight = false
            if showsActivity { isRefreshingManagedAccess = false }
        }

        guard let configuration = LiveContentConfiguration.current() else {
            managedAccessError = "This app build cannot reach the access service."
            lastManagedAccessCheck = .now
            restoreManagedCacheIfEligible()
            recomputeAccess()
            return
        }

        do {
            let components = URLComponents(
                url: configuration.baseURL.appendingPathComponent("api/access/entitlement"),
                resolvingAgainstBaseURL: false
            )
            guard let url = components?.url else { return }

            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 12)
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(["accessId": accessID])
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode)
            else { throw URLError(.badServerResponse) }

            let payload = try JSONDecoder().decode(ManagedAccessResponse.self, from: data)
            managedAccessLevel = payload.accessLevel.rawValue
            managedAccessStatus = payload.status
            managedAccessExpiresAt = payload.expiresAt.flatMap(Self.parseISODate)
            managedAccessIsActive = payload.isActive
            managedAccessError = nil
            lastManagedAccessCheck = .now
            cacheManagedAccess(payload)
        } catch {
            managedAccessError = "Access could not be verified. Check the internet connection and try again."
            lastManagedAccessCheck = .now
            restoreManagedCacheIfEligible()
        }
        recomputeAccess()
    }

    func monitorManagedAccess() async {
        guard !isMonitoringManagedAccess else { return }
        isMonitoringManagedAccess = true
        defer { isMonitoringManagedAccess = false }

        while !Task.isCancelled {
            await refreshManagedAccess()
            do {
                try await Task.sleep(for: .seconds(3))
            } catch {
                return
            }
        }
    }

    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        PrivateProductAnalytics.record(.purchaseStarted)
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    appStoreAccessIsActive = transactionIsActive(transaction)
                    recomputeAccess()
                    await transaction.finish()
                    if appStoreAccessIsActive {
                        PrivateProductAnalytics.record(.purchaseCompleted)
                    }
                    return appStoreAccessIsActive
                } else {
                    purchaseError = "The purchase could not be verified."
                }
            case .userCancelled:
                break
            case .pending:
                purchaseError = "Purchase is pending approval."
            @unknown default:
                purchaseError = "The purchase could not be completed."
            }
        } catch {
            purchaseError = error.localizedDescription
        }
        return false
    }

    func restore() async {
        do {
            try await AppStore.sync()
            appStoreAccessIsActive = await currentEntitlementIsActive()
            await refreshManagedAccess()
            recomputeAccess()
            if appStoreAccessIsActive {
                PrivateProductAnalytics.record(.purchaseRestored)
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    private func currentEntitlementIsActive() async -> Bool {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transactionIsActive(transaction) { return true }
        }
        return false
    }

    private func transactionIsActive(_ transaction: Transaction) -> Bool {
        guard entitlementProductIds.contains(transaction.productID), transaction.revocationDate == nil else { return false }
        if let expirationDate = transaction.expirationDate { return expirationDate > .now }
        return true
    }

    private func recomputeAccess() {
        let newValue = appStoreAccessIsActive || managedAccessIsActive
        guard newValue != isPremium else { return }
        isPremium = newValue
        accessRevision = UUID()
    }

    private func cacheManagedAccess(_ payload: ManagedAccessResponse) {
        let defaults = UserDefaults.standard
        guard payload.isActive else {
            defaults.removeObject(forKey: managedCacheLevelKey)
            defaults.removeObject(forKey: managedCacheExpiryKey)
            defaults.removeObject(forKey: managedCacheVerifiedKey)
            return
        }
        defaults.set(payload.accessLevel.rawValue, forKey: managedCacheLevelKey)
        defaults.set(payload.expiresAt.flatMap(Self.parseISODate)?.timeIntervalSince1970, forKey: managedCacheExpiryKey)
        defaults.set(Date.now.timeIntervalSince1970, forKey: managedCacheVerifiedKey)
    }

    private func restoreManagedCacheIfEligible() {
        let defaults = UserDefaults.standard
        guard let levelValue = defaults.string(forKey: managedCacheLevelKey),
              let level = ManagedAccessLevel(rawValue: levelValue),
              level != .free
        else {
            managedAccessIsActive = false
            return
        }

        let verifiedAt = defaults.double(forKey: managedCacheVerifiedKey)
        guard verifiedAt > 0, Date.now.timeIntervalSince1970 - verifiedAt <= offlineGrace else {
            managedAccessIsActive = false
            return
        }

        let expiryValue = defaults.double(forKey: managedCacheExpiryKey)
        let expiry = expiryValue > 0 ? Date(timeIntervalSince1970: expiryValue) : nil
        guard level == .full || (expiry.map { $0 > .now } ?? false) else {
            managedAccessIsActive = false
            managedAccessStatus = "expired"
            managedAccessExpiresAt = expiry
            return
        }

        managedAccessLevel = level.rawValue
        managedAccessStatus = "active"
        managedAccessExpiresAt = expiry
        managedAccessIsActive = true
    }

    private static func parseISODate(_ value: String) -> Date? {
        let fractionalFormatter = ISO8601DateFormatter()
        fractionalFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = fractionalFormatter.date(from: value) { return date }
        return ISO8601DateFormatter().date(from: value)
    }
}

enum PremiumAccessPolicy {
    static let freeA1LessonCount = 5

    static func canOpenLevel(_ level: CEFRLevel, isPremium: Bool) -> Bool {
        isPremium || level == .a1
    }

    static func canOpenLesson(_ lesson: CompleteLessonDTO, isPremium: Bool) -> Bool {
        isPremium || (lesson.level == .a1 && lesson.order <= freeA1LessonCount)
    }

    static func canOpenCourseBook(
        _ level: CEFRLevel,
        preferredLevel: CEFRLevel,
        isPremium: Bool
    ) -> Bool {
        isPremium || level == .a1 || level == preferredLevel
    }

    static func canOpenLesson(
        _ lesson: CompleteLessonDTO,
        preferredLevel: CEFRLevel,
        isPremium: Bool
    ) -> Bool {
        canOpenLesson(lesson, isPremium: isPremium)
            || (!isPremium && lesson.level == preferredLevel && lesson.order == 1)
    }
}
