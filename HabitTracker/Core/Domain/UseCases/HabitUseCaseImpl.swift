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
    
    func fetchHabits() throws -> [Habit] {
        try repository.fetchHabits()
    }
    
    func addHabit(_ habit: Habit) throws {
        try repository.save(habit)
    }
    
    func deleteHabit(_ habit: Habit) throws {
        try repository.delete(habit)
    }
    
    func increment(_ habit: Habit) throws {
        
        guard habit.progress < habit.goal else { return }
        
        habit.progress += 1
        
        habit.isCompleted = habit.progress == habit.goal
        
        try repository.update()
    }
    
    func complete(_ habit: Habit) throws {
        
        habit.progress = habit.goal
        
        habit.isCompleted = true
        
        try repository.update()
    }
}
