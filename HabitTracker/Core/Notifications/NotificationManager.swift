//
//  NotificationManager.swift
//  HabitTracker
//
//  Created by Edil on 03/08/2026.
//

import UserNotifications


final class NotificationManager {


    static let shared = NotificationManager()


    private init(){}


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

            print(error)
        }

    }



    func scheduleHabitReminder(
        habit: Habit
    ) {


        guard
            habit.reminderEnabled,
            let hour = habit.reminderHour,
            let minute = habit.reminderMinute
        else {
            return
        }



        let content = UNMutableNotificationContent()


        content.title = "Habit Reminder"

        content.body =
        "Time to complete \(habit.title)"

        content.sound = .default



        var components = DateComponents()

        components.hour = hour

        components.minute = minute



        let trigger =
        UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )



        let request =
        UNNotificationRequest(
            identifier: habit.id.uuidString,
            content: content,
            trigger: trigger
        )



        UNUserNotificationCenter
            .current()
            .add(request)

    }



    func removeReminder(
        habit: Habit
    ) {


        UNUserNotificationCenter
            .current()
            .removePendingNotificationRequests(
                withIdentifiers:[
                    habit.id.uuidString
                ]
            )

    }
    
    func rescheduleAllReminders(
        habits: [Habit],
        entries: [HabitEntry]
    ) {

        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()

        let calendar = Calendar.current

        let today = calendar.startOfDay(for: Date())

        for habit in habits {

            guard habit.reminderEnabled else {
                continue
            }

            let completedToday = entries.contains {
                $0.habit.id == habit.id &&
                calendar.isDate($0.date, inSameDayAs: today) &&
                $0.completed
            }

            if !completedToday {
                scheduleHabitReminder(habit: habit)
            }
        }
    }

}
