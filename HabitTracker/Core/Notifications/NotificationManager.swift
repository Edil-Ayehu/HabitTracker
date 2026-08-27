//
//  NotificationManager.swift
//  HabitTracker
//

import UserNotifications
import UIKit

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    private let notificationsEnabledKey = "notificationsEnabled"
    
    // MARK: - UNUserNotificationCenterDelegate (Foreground Presentation)
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner and play sound even if app is in foreground during testing
        completionHandler([.banner, .sound, .badge, .list])
    }
    
    // MARK: - Permission
    
    func requestPermission() async {
        do {
            try await UNUserNotificationCenter
                .current()
                .requestAuthorization(
                    options: [
                        .alert,
                        .badge,
                        .sound
                    ]
                )
        } catch {
            print("Notification permission error:", error)
        }
    }
    
    func authorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Schedule
    
    func scheduleHabitReminder(
        habit: Habit,
        entry: HabitEntry? = nil
    ) {
        let enabled = UserDefaults.standard.object(forKey: notificationsEnabledKey) as? Bool ?? true
        guard enabled else { return }
        
        guard
            habit.reminderEnabled,
            let hour = habit.reminderHour,
            let minute = habit.reminderMinute
        else {
            return
        }
        
        if let entry, entry.completed {
            removeReminder(habit: habit)
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = notificationTitle(for: habit)
        content.body = notificationBody(for: habit, entry: entry)
        content.sound = .default
        
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: habit.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Failed to schedule notification:", error)
            }
        }
    }
    
    // MARK: - Smart Message
    
    private func notificationTitle(for habit: Habit) -> String {
        if habit.habitType == .measurable {
            return "Keep Going 💪"
        }
        return "Habit Reminder 🔔"
    }
    
    private func notificationBody(
        for habit: Habit,
        entry: HabitEntry?
    ) -> String {
        switch habit.habitType {
        case .binary:
            return """
            You haven't completed \(habit.title) yet.
            Take a moment to finish it today.
            """
        case .measurable:
            let progress = entry?.progress ?? 0
            let goal = habit.goal ?? 1
            return """
            \(habit.title): \(progress) / \(goal).
            Keep going until you reach your goal.
            """
        }
    }
    
    // MARK: - Remove
    
    func removeReminder(habit: Habit) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])
    }
    
    // MARK: - Refresh
    
    func rescheduleAllReminders(
        habits: [Habit],
        entries: [HabitEntry]
    ) {
        removeAllReminders()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        for habit in habits {
            guard habit.reminderEnabled else { continue }
            let todayEntry = entries.first {
                $0.habit.id == habit.id && calendar.isDate($0.date, inSameDayAs: today)
            }
            if todayEntry?.completed == true { continue }
            scheduleHabitReminder(habit: habit, entry: todayEntry)
        }
        
        scheduleNightlyReflectionReminder()
    }
    
    func refreshHabitReminder(
        habit: Habit,
        entry: HabitEntry?
    ) {
        let enabled = UserDefaults.standard.object(forKey: notificationsEnabledKey) as? Bool ?? true
        guard enabled else {
            removeReminder(habit: habit)
            return
        }
        
        if entry?.completed == true {
            removeReminder(habit: habit)
        } else {
            scheduleHabitReminder(habit: habit, entry: entry)
        }
    }
    
    // MARK: - Nightly Reflection Reminder
    
    private func isTodayReflectionCompleted() -> Bool {
        guard let data = UserDefaults.standard.data(forKey: "nightlyReflectionsData"),
              let map = try? JSONDecoder().decode([String: NightlyReflection].self, from: data) else {
            return false
        }
        let todayStr = ReflectionManager.todayISOString
        return map[todayStr] != nil
    }
    
    func scheduleNightlyReflectionReminder(hour: Int? = nil, minute: Int? = nil) {
        let isReflectionEnabled = UserDefaults.standard.object(forKey: "reflectionReminderEnabled") as? Bool ?? true
        guard isReflectionEnabled else {
            removeNightlyReflectionReminder()
            return
        }
        
        // If today's reflection is already completed, do not schedule reminder
        guard !isTodayReflectionCompleted() else {
            removeNightlyReflectionReminder()
            return
        }
        
        Task {
            let status = await authorizationStatus()
            if status == .notDetermined {
                await requestPermission()
            }
            
            let enabled = UserDefaults.standard.object(forKey: notificationsEnabledKey) as? Bool ?? true
            guard enabled else { return }
            
            let targetHour = hour ?? UserDefaults.standard.object(forKey: "reflectionReminderHour") as? Int ?? 21
            let targetMinute = minute ?? UserDefaults.standard.object(forKey: "reflectionReminderMinute") as? Int ?? 0
            
            // Save configured time
            UserDefaults.standard.set(targetHour, forKey: "reflectionReminderHour")
            UserDefaults.standard.set(targetMinute, forKey: "reflectionReminderMinute")
            
            let content = UNMutableNotificationContent()
            content.title = "Nightly Reflection 🌙"
            content.body = "How was your day? Take a moment to log your mood & gratitude for +25 XP."
            content.sound = .default
            
            var components = DateComponents()
            components.hour = targetHour
            components.minute = targetMinute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: "nightly_reflection_reminder",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error {
                    print("Failed to schedule nightly reflection reminder:", error)
                }
            }
        }
    }
    
    func removeNightlyReflectionReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["nightly_reflection_reminder"])
    }
    
    // MARK: - Remove All
    
    func removeAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Refresh All
    
    func refreshAllReminders() async {
        do {
            try await DIContainer.shared.makeHabitUseCase().rescheduleReminders()
        } catch {
            print("Failed to refresh reminders:", error)
        }
    }
    
    // MARK: - System Settings
    
    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
