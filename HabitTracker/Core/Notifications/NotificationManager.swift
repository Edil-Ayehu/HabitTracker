//
//  NotificationManager.swift
//  HabitTracker
//

import UserNotifications
import UIKit

final class NotificationManager {
    
    static let shared = NotificationManager()
    
    private init() {}
    
    private let notificationsEnabledKey = "notificationsEnabled"
    
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
        
        let settings =
            await UNUserNotificationCenter.current()
            .notificationSettings()
        
        return settings.authorizationStatus
    }
    
    // MARK: - Schedule
    
    func scheduleHabitReminder(
        habit: Habit,
        entry: HabitEntry? = nil
    ) {
        
        let enabled =
            UserDefaults.standard.object(
                forKey: notificationsEnabledKey
            ) as? Bool ?? true
        
        guard enabled else {
            return
        }
        
        guard
            habit.reminderEnabled,
            let hour = habit.reminderHour,
            let minute = habit.reminderMinute
        else {
            return
        }
        
        // If today's habit is already completed,
        // don't schedule a reminder.
        if let entry, entry.completed {
            removeReminder(habit: habit)
            return
        }
        
        let content = UNMutableNotificationContent()
        
        content.title = notificationTitle(for: habit)
        
        content.body = notificationBody(
            for: habit,
            entry: entry
        )
        
        content.sound = .default
        
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: habit.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        // Same identifier means an existing request
        // for this habit is replaced.
        UNUserNotificationCenter
            .current()
            .add(request) { error in
                
                if let error {
                    print(
                        "Failed to schedule notification:",
                        error
                    )
                }
            }
    }
    
    // MARK: - Smart Message
    
    private func notificationTitle(
        for habit: Habit
    ) -> String {
        
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
    
    func removeReminder(
        habit: Habit
    ) {
        
        UNUserNotificationCenter
            .current()
            .removePendingNotificationRequests(
                withIdentifiers: [
                    habit.id.uuidString
                ]
            )
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
            
            guard habit.reminderEnabled else {
                continue
            }
            
            let todayEntry = entries.first {
                $0.habit.id == habit.id &&
                calendar.isDate(
                    $0.date,
                    inSameDayAs: today
                )
            }
            
            // Completed → no notification
            if todayEntry?.completed == true {
                continue
            }
            
            scheduleHabitReminder(
                habit: habit,
                entry: todayEntry
            )
        }
    }
    
    func refreshHabitReminder(
        habit: Habit,
        entry: HabitEntry?
    ) {
        
        let enabled =
            UserDefaults.standard.object(
                forKey: notificationsEnabledKey
            ) as? Bool ?? true
        
        guard enabled else {
            removeReminder(habit: habit)
            return
        }
        
        if entry?.completed == true {
            
            removeReminder(habit: habit)
            
        } else {
            
            scheduleHabitReminder(
                habit: habit,
                entry: entry
            )
        }
    }
    
    // MARK: - Remove All
    
    func removeAllReminders() {
        
        UNUserNotificationCenter
            .current()
            .removeAllPendingNotificationRequests()
    }
    
    // MARK: - Refresh All
    
    func refreshAllReminders() async {
        
        do {
            
            try await DIContainer.shared
                .makeHabitUseCase()
                .rescheduleReminders()
            
        } catch {
            
            print(
                "Failed to refresh reminders:",
                error
            )
        }
    }
    
    // MARK: - System Settings
    
    func openSystemSettings() {
        
        guard let url = URL(
            string: UIApplication.openSettingsURLString
        ) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
}
