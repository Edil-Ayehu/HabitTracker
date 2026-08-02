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

    func deleteHabit(_ habit: Habit) throws

    func increment(_ entry: HabitEntry) throws

    func complete(_ entry: HabitEntry) throws
}
