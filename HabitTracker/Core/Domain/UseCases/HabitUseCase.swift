//
//  HabitUseCase.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import Foundation

protocol HabitUseCase {

    func fetchHabits() throws -> [Habit]
    
    func fetchStatistics() throws -> HabitStatistics

    func addHabit(_ habit: Habit) throws

    func deleteHabit(_ habit: Habit) throws

    func increment(_ habit: Habit) throws

    func complete(_ habit: Habit) throws
}
