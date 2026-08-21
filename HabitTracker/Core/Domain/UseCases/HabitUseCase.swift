//
//  HabitUseCase.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import Foundation

protocol HabitUseCase {

    func fetchTodayEntries() throws -> [HabitEntry]
    
    func fetchStatistics() throws -> HabitStatistics

    func addHabit(_ habit: Habit) throws
    
    func fetchEntries(for habit: Habit) throws -> [HabitEntry]

    func deleteHabit(_ habit: Habit) throws

    func increment(_ entry: HabitEntry) throws
    
    func decrement(_ entry: HabitEntry) throws

    func complete(_ entry: HabitEntry) throws
    
    func rescheduleReminders() throws
    
    func updateHabit(_ habit: Habit) throws
    
    func weeklyCompletion() throws -> [DailyCompletion]
    
    func habitProgress() throws -> [HabitProgress]
    
    func saveNote(_ note: String, for entry: HabitEntry) throws
    
    func updateCheckIn(note: String, imageData: Data?, for entry: HabitEntry) throws
}
