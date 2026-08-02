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
        
        
        return HabitStatistics(
            totalHabits: totalHabits,
            completedHabits: completedHabits,
            completionRate: completionRate,
            currentStreak: 0
        )
    }
    
    func addHabit(_ habit: Habit) throws {
        try repository.saveHabit(habit)
    }
    
    func deleteHabit(_ habit: Habit) throws {
        try repository.deleteHabit(habit)
    }
    
    func increment(_ entry: HabitEntry) throws {

        guard entry.progress < entry.habit.goal else { return }

        entry.progress += 1

        entry.completed = entry.progress >= entry.habit.goal

        try repository.update()
    }
    
    func complete(_ entry: HabitEntry) throws {

        entry.progress = entry.habit.goal

        entry.completed = true

        try repository.update()
    }
}
