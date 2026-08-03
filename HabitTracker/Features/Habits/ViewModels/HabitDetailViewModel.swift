//
//  HabitDetailViewModel.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import Foundation

@MainActor
final class HabitDetailViewModel: ObservableObject {
    
    @Published var entries: [HabitEntry] = []
    
    @Published var streak = 0
    
    @Published var isLoading = false
    
    @Published var errorMessage: String?
    
    @Published private(set) var statistics = HabitStatistics(
        totalHabits: 0,
        completedHabits: 0,
        completionRate: 0,
        currentStreak: 0
    )
    
    private let habitUseCase: HabitUseCase
    
    private let habit: Habit
    
    init(
        habit: Habit,
        useCase: HabitUseCase
    ) {
        self.habitUseCase = useCase
        self.habit = habit
    }
    
    var reminderEnabled: Bool {
        habit.reminderEnabled
    }
    
    var reminderTime: Date {

        var components = DateComponents()

        components.hour =
            habit.reminderHour ?? 9

        components.minute =
            habit.reminderMinute ?? 0


        return Calendar.current.date(
            from: components
        ) ?? Date()
    }
    
    func updateReminder(
        enabled: Bool,
        time: Date
    ) {


        let calendar = Calendar.current


        habit.reminderEnabled = enabled


        if enabled {

            habit.reminderHour =
            calendar.component(
                .hour,
                from: time
            )


            habit.reminderMinute =
            calendar.component(
                .minute,
                from: time
            )


            NotificationManager.shared
                .scheduleHabitReminder(
                    habit: habit
                )


        } else {


            NotificationManager.shared
                .removeReminder(
                    habit: habit
                )
        }


        do {

            load()

        } catch {

            errorMessage =
            error.localizedDescription
        }

    }
    
    
    func load() {
        
        do {
            
            entries = try habitUseCase.fetchEntries(for: habit)
            
            streak = calculateStreak(from: entries)
        } catch {
            
        }
    }
    
    var isMeasurable: Bool {
        habit.habitType == .measurable
    }
    
    var isBinary: Bool {
        habit.habitType == .binary
    }
    
    var isCompletedToday: Bool {
        todayEntry?.completed ?? false
    }
    
    var canIncrement: Bool {
        isMeasurable && progress < goal && !isCompletedToday
    }
    
    var canDecrement: Bool {
        isMeasurable && progress > 0
    }
    
    var canComplete: Bool {
        !isCompletedToday
    }
    
    var title: String {
        habit.title
    }
    
    var goal: Int {
        switch habit.habitType {
        case .binary:
            return 1
        case .measurable:
            return habit.goal ?? 1
        }
    }
        
    var icon: HabitIcon {
        habit.habitIcon
    }
    
    var color: HabitColor {
        habit.habitColor
    }
    
    var todayEntry: HabitEntry? {

        let today = Calendar.current.startOfDay(for: Date())

        return entries.first {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }
    }
    
    var progress: Int {
        todayEntry?.progress ?? 0
    }
    
    
    func increment() {
        
        guard let entry = todayEntry else { return }
        
        do {
            
            try habitUseCase.increment(entry)
            
            load()
            
            
        } catch {
            
            errorMessage = error.localizedDescription
            
        }
    }
    
    func decrement() {
        
        guard let entry = todayEntry else { return }
        
        do {
            
            try habitUseCase.decrement(entry)
            
            load()
            
            
        } catch {
            
            errorMessage = error.localizedDescription
            
        }
    }
    
    func complete() {
        
        guard let entry = todayEntry else { return }
        
        do {
            
            try habitUseCase.complete(entry)
            
            load()
            
        } catch {
            
            errorMessage = error.localizedDescription
            
        }
    }
    
    
    private func calculateStreak(from entries: [HabitEntry]) -> Int {

        let calendar = Calendar.current

        let completedDates = Set(
            entries
                .filter(\.completed)
                .map {
                    calendar.startOfDay(for: $0.date)
                }
        )

        var streak = 0

        let today = calendar.startOfDay(for: Date())

        var currentDate = today

        // If today's habit isn't completed, start counting from yesterday.
        if !completedDates.contains(today) {
            guard let yesterday = calendar.date(
                byAdding: .day,
                value: -1,
                to: today
            ) else {
                return 0
            }

            currentDate = yesterday
        }

        while completedDates.contains(currentDate) {

            streak += 1

            guard let previousDay = calendar.date(
                byAdding: .day,
                value: -1,
                to: currentDate
            ) else {
                break
            }

            currentDate = previousDay
        }

        return streak
    }
}
