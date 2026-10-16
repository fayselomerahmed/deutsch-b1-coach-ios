import Foundation
import UserNotifications

struct StudyReminderService {
    static let requestIdentifier = "daily-german-study"

    func scheduleDailyReminder(hour: Int, minute: Int) async throws {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        guard granted else { throw ReminderError.permissionDenied }

        center.removePendingNotificationRequests(withIdentifiers: [Self.requestIdentifier])
        let content = UNMutableNotificationContent()
        content.title = "Zeit für Deutsch"
        content.body = "A short lesson and review session will keep your B1 path moving."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        try await center.add(UNNotificationRequest(identifier: Self.requestIdentifier, content: content, trigger: trigger))
    }

    func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.requestIdentifier])
    }
}

enum ReminderError: LocalizedError {
    case permissionDenied

    var errorDescription: String? {
        "Notifications are disabled. You can enable them for Deutsch B1 Coach in iPhone Settings."
    }
}
