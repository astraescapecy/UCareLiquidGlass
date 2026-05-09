import Foundation
import UserNotifications

/// Phase 5 — local notifications: water interval, routine times, streak rescue (no ads, no remote payload).
@MainActor
enum UCareNotificationScheduler {
    private static let prefix = "com.ucare.notify."

    private static var managedIdentifiers: [String] {
        [
            prefix + "water",
            prefix + "morning",
            prefix + "evening",
            prefix + "bedtime",
            prefix + "streakRescue",
        ]
    }

    /// Removes pending UCare notifications, then re-schedules from profile + current completion/streak.
    static func refresh(appState: AppState) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: managedIdentifiers)

        guard appState.phase == .main, let profile = appState.userProfile else { return }

        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
            guard granted else { return }
        case .authorized, .provisional, .ephemeral:
            break
        case .denied:
            return
        @unknown default:
            return
        }

        let intervalSec = TimeInterval(max(60, profile.waterReminderIntervalMinutes) * 60)
        if profile.wantsWaterReminders, intervalSec >= 60 {
            let content = UNMutableNotificationContent()
            content.title = "Water rhythm"
            content.body = "A small sip now keeps breath, skin, and energy steadier later."
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: intervalSec, repeats: true)
            let req = UNNotificationRequest(identifier: prefix + "water", content: content, trigger: trigger)
            try? await center.add(req)
        }

        if profile.wantsMorningNudge {
            await scheduleDaily(
                minutesFromMidnight: profile.reminderMorningMinutes,
                id: "morning",
                title: "Morning ritual",
                body: "Open Today — your stack is easier when you start early.",
                center: center
            )
        }

        if profile.wantsEveningNudge {
            await scheduleDaily(
                minutesFromMidnight: profile.reminderEveningMinutes,
                id: "evening",
                title: "Evening reset",
                body: "Skincare, breath care, lights down a notch — pick one gentle step.",
                center: center
            )
        }

        if profile.wantsBedtimeNudge {
            await scheduleDaily(
                minutesFromMidnight: profile.reminderBedtimeMinutes,
                id: "bedtime",
                title: "Wind-down",
                body: "Sip water, dim screens, set out tomorrow’s clothes — tiny anchors.",
                center: center
            )
        }

        await scheduleStreakRescue(appState: appState, profile: profile, center: center)
    }

    /// Clears all pending UCare notification requests (e.g. on log out).
    static func cancelAll() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: managedIdentifiers)
    }

    private static func scheduleDaily(
        minutesFromMidnight: Int,
        id: String,
        title: String,
        body: String,
        center: UNUserNotificationCenter
    ) async {
        let clamped = min(23 * 60 + 59, max(0, minutesFromMidnight))
        let h = clamped / 60
        let m = clamped % 60
        var dc = DateComponents()
        dc.calendar = Calendar.current
        dc.timeZone = Calendar.current.timeZone
        dc.hour = h
        dc.minute = m
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        let req = UNNotificationRequest(identifier: prefix + id, content: content, trigger: trigger)
        try? await center.add(req)
    }

    /// One-shot nudge before evening if you have a streak and today isn’t finished yet.
    private static func scheduleStreakRescue(appState: AppState, profile: UserProfile, center: UNUserNotificationCenter) async {
        let streak = appState.routineStreakDays()
        let todayProgress = appState.completionFraction(on: .now)
        guard streak >= 1, todayProgress < 0.999 else { return }

        let eveningBase = profile.wantsEveningNudge ? profile.reminderEveningMinutes : (18 * 60 + 30)
        let rescueMinutes = min(23 * 60 + 59, max(0, eveningBase - 45))
        let hour = rescueMinutes / 60
        let minute = rescueMinutes % 60

        let cal = Calendar.current
        let now = Date()
        guard let anchorToday = cal.date(bySettingHour: hour, minute: minute, second: 0, of: now) else { return }
        let fireDate: Date
        if anchorToday > now {
            fireDate = anchorToday
        } else if let tomorrow = cal.date(byAdding: .day, value: 1, to: anchorToday) {
            fireDate = tomorrow
        } else {
            return
        }

        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let content = UNMutableNotificationContent()
        content.title = "Streak rescue"
        content.body = "You’re on a \(streak)-day rhythm — one small Today step keeps the chain honest. No guilt, just the next tap."
        content.sound = .default
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let req = UNNotificationRequest(identifier: prefix + "streakRescue", content: content, trigger: trigger)
        try? await center.add(req)
    }
}
