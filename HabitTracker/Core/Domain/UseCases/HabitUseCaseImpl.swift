//
//  HabitUseCaseImpl.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import Foundation

final class HabitUseCaseImpl: HabitUseCase {
    
    private let repository: HabitRepository
    
    init(repository: HabitRepository) {
        self.repository = repository
    }
    
    func fetchTodayEntries() throws -> [HabitEntry] {
        
        let habits = try repository.fetchHabits()
        
        var entries: [HabitEntry] = []
        
        for habit in habits {
            
            if let existing = try repository.fetchTodayEntry(for: habit) {
                
                entries.append(existing)
                
            } else {
                
                let newEntry = HabitEntry(habit: habit)
                
                try repository.saveEntry(newEntry)
                
                entries.append(newEntry)
            }
        }
        
        return entries
    }
    
    func fetchStatistics() throws -> HabitStatistics {
        
        let entries = try repository.fetchTodayEntries()
        
        let totalHabits = entries.count
        
        let completedHabits = entries.filter(\.completed).count
        
        let completionRate: Double
        
        if totalHabits == 0 {
            
            completionRate = 0
            
        } else {
            
            completionRate = Double(completedHabits) / Double(totalHabits)
            
        }
        
        let allEntries = try repository.fetchAllEntries()
        
        let streak = calculateStreak(from: allEntries)
        
        
        return HabitStatistics(
            totalHabits: totalHabits,
            completedHabits: completedHabits,
            completionRate: completionRate,
            currentStreak: streak
        )
    }
    
    func addHabit(_ habit: Habit) throws {
        try repository.saveHabit(habit)
    }
    
    func deleteHabit(_ habit: Habit) throws {
        try repository.deleteHabit(habit)
    }
    
    func increment(_ entry: HabitEntry) throws {
        
        switch entry.habit.habitType {
        case .binary:
            entry.progress = 1
            entry.completed = true
            
        case .measurable:
            guard let goal = entry.habit.goal else {
                return
            }
            
            guard entry.progress < goal else {
                return
            }
            
            entry.progress += 1
            
            entry.completed = entry.progress >= goal
        }
        
        try repository.update()
        
    }
    
    func decrement(_ entry: HabitEntry) throws {

        switch entry.habit.habitType {

        case .binary:

            entry.progress = 0
            entry.completed = false

        case .measurable:

            guard entry.progress > 0 else { return }

            entry.progress -= 1

            let goal = entry.habit.goal ?? 1

            entry.completed = entry.progress >= goal
        }

        try repository.update()
    }
    
    func complete(_ entry: HabitEntry) throws {
        
        switch entry.habit.habitType {
        case .binary:
            entry.completed = true
            
        case .measurable:
            guard let goal = entry.habit.goal else { return }
            
            entry.progress = goal
            entry.completed = true
        }
        
        
        
        try repository.update()
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
    
    func fetchEntries(
        for habit: Habit
    ) throws -> [HabitEntry] {
        
        try repository.fetchEntries(
            for: habit
        )
    }
    
    func rescheduleReminders() throws {

        let habits = try repository.fetchHabits()

        let entries = try repository.fetchTodayEntries()

        NotificationManager.shared
            .rescheduleAllReminders(
                habits: habits,
                entries: entries
            )
    }
    
    func updateHabit(_ habit: Habit) throws {
        try repository.update()
    }
    
}
