//
//  HabitRepositoryImpl.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import Foundation
import SwiftData

final class HabitRepositoryImpl: HabitRepository {
    
    private let context: ModelContext
    private let calendar = Calendar.current
    
    init(context: ModelContext) {
        self.context = context
    }
    
    // MARK: Habit
    
    func fetchHabits() throws -> [Habit] {
        
        try context.fetch(FetchDescriptor<Habit>())
        
    }
    
    func saveHabit(_ habit: Habit) throws {
        
        context.insert(habit)
        
        try context.save()
    }
    
    func deleteHabit(_ habit: Habit) throws {
        
        context.delete(habit)
        
        try context.save()
    }
    
    // MARK: Entry
    
    func fetchTodayEntries() throws -> [HabitEntry] {
        
        let today = calendar.startOfDay(for: Date())
        
        let descriptor = FetchDescriptor<HabitEntry>(
            predicate: #Predicate {
                $0.date == today
            }
        )
        
        return try context.fetch(descriptor)
    }
    
    func fetchEntries(for habit: Habit) throws -> [HabitEntry] {
        
        let habitID = habit.id
        
        let descriptor = FetchDescriptor<HabitEntry>(
            predicate: #Predicate {
                $0.habitID == habitID
            },
            sortBy: [
                SortDescriptor(
                    \.date,
                     order: .reverse
                )
            ]
        )
        
        return try context.fetch(descriptor)
    }
    
    func fetchTodayEntry(for habit: Habit) throws -> HabitEntry? {
        
        let today = calendar.startOfDay(for: Date())
        
        let habitID = habit.id
        
        let descriptor = FetchDescriptor<HabitEntry>(
            predicate: #Predicate {
                $0.habitID == habitID &&
                $0.date == today
            }
        )
        
        return try context.fetch(descriptor).first
    }
    
    func fetchAllEntries() throws -> [HabitEntry] {
        
        let descriptor = FetchDescriptor<HabitEntry>(
            sortBy: [
                SortDescriptor(
                    \.date,
                     order: .reverse
                )
            ]
        )
        
        return try context.fetch(descriptor)
    }
    
    func saveEntry(_ entry: HabitEntry) throws {
        
        context.insert(entry)
        
        try context.save()
        
    }
    
    func deleteEntry(_ entry: HabitEntry) throws {
        
        context.delete(entry)
        
        try context.save()
    }
    
    func update() throws {
        
        try context.save()
        
    }
    
    
}
