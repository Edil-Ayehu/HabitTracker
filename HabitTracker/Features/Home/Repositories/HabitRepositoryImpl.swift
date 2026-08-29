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
        let all = try context.fetch(FetchDescriptor<Habit>())
        return all.filter { !$0.isArchived }
    }
    
    func fetchArchivedHabits() throws -> [Habit] {
        let all = try context.fetch(FetchDescriptor<Habit>())
        return all.filter { $0.isArchived }
    }
    
    func saveHabit(_ habit: Habit) throws {
        
        context.insert(habit)
        
        try context.save()
    }
    
    func deleteHabit(_ habit: Habit) throws {
        let habitID = habit.id
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.id == habitID }
        )
        let targetHabit = try context.fetch(descriptor).first ?? habit
        
        let entries = try fetchEntries(for: habit)
        for entry in entries {
            context.delete(entry)
        }
        
        context.delete(targetHabit)
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
        
        let entries = try context.fetch(descriptor)
        return entries.filter { !$0.habit.isArchived }
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
        
        switch habit.frequency {
        case .daily:
            let descriptor = FetchDescriptor<HabitEntry>(
                predicate: #Predicate {
                    $0.habitID == habitID &&
                    $0.date == today
                }
            )
            return try context.fetch(descriptor).first
            
        case .weekly:
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else {
                let descriptor = FetchDescriptor<HabitEntry>(
                    predicate: #Predicate { $0.habitID == habitID && $0.date == today }
                )
                return try context.fetch(descriptor).first
            }
            let startOfWeek = weekInterval.start
            let endOfWeek = weekInterval.end
            let descriptor = FetchDescriptor<HabitEntry>(
                predicate: #Predicate {
                    $0.habitID == habitID &&
                    $0.date >= startOfWeek &&
                    $0.date < endOfWeek
                },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            return try context.fetch(descriptor).first
            
        case .monthly:
            guard let monthInterval = calendar.dateInterval(of: .month, for: today) else {
                let descriptor = FetchDescriptor<HabitEntry>(
                    predicate: #Predicate { $0.habitID == habitID && $0.date == today }
                )
                return try context.fetch(descriptor).first
            }
            let startOfMonth = monthInterval.start
            let endOfMonth = monthInterval.end
            let descriptor = FetchDescriptor<HabitEntry>(
                predicate: #Predicate {
                    $0.habitID == habitID &&
                    $0.date >= startOfMonth &&
                    $0.date < endOfMonth
                },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            return try context.fetch(descriptor).first
        }
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
