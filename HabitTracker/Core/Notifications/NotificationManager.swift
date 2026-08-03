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

}
