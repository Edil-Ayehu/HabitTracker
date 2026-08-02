//
//  HabitRepository.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import Foundation

protocol HabitRepository {
    func fetchHabits() throws -> [Habit]
    
    func save(_ habit: Habit) throws
    
    func delete(_ habit: Habit) throws
    
    func update() throws
}
