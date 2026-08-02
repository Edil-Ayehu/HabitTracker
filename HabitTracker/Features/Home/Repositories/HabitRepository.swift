//
//  HabitRepository.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import Foundation

protocol HabitRepository {
    // MARK: Habits
    func fetchHabits() throws -> [Habit]
    
    func saveHabit(_ habit: Habit) throws
    
    func deleteHabit(_ habit: Habit) throws
    
    // MARK: Entries
    
    func fetchTodayEntries() throws -> [HabitEntry]
    
    func fetchEntries(for habit: Habit) throws -> [HabitEntry]
    
    func fetchTodayEntry(for habit: Habit) throws -> HabitEntry?
    
    func fetchAllEntries() throws -> [HabitEntry]
    
    func saveEntry(_ entry: HabitEntry) throws
    
    func deleteEntry(_ entry: HabitEntry) throws
    
    func update() throws
}
