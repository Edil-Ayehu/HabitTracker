//
//  HomeViewModel.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var greeting = "Good Morning"

    @Published var completedHabits = 3
    
    @Published var habits: [Habit] = []

    @Published var totalHabits = 7

    @Published var currentStreak = 12

    @Published var completionRate = 82
    
    private var habitRepository: HabitRepository
    
    init(habitRepository: HabitRepository) {
        self.habitRepository = habitRepository
    }

    func load() {

    }
    
    func increment(_ habit: Habit) {
        
        guard habit.progress < habit.goal else { return }
        
        habit.progress += 1
        
        habit.isCompleted = habit.progress == habit.goal
        
        try? habitRepository.update()
    }
    
    func complete(_ habit: Habit) {
        
        habit.progress = habit.goal
        
        habit.isCompleted = true
        
        try? habitRepository.update()
    }

}
