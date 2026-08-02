//
//  HomeViewModel.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var isLoading = false
    
    @Published var errorMessage: String?

    @Published var greeting = "Good Morning"

    @Published var completedHabits = 3
    
    @Published var habits: [Habit] = []

    @Published var totalHabits = 7

    @Published var currentStreak = 12

    @Published var completionRate = 82
    
    private var habitUseCase: HabitUseCase
    
    init(habitUseCase: HabitUseCase) {
        self.habitUseCase = habitUseCase
    }

    func load() {
        
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            
            habits = try habitUseCase.fetchHabits()
        } catch {
            
            errorMessage = error.localizedDescription
        }
    }
    
    func increment(_ habit: Habit) {
        
        do {
            
            try habitUseCase.increment(habit)
            
        } catch {
            
            errorMessage = error.localizedDescription
            
        }
    }
    
    func complete(_ habit: Habit) {
        
        do {
            
            try habitUseCase.complete(habit)
            
        } catch {
            
            errorMessage = error.localizedDescription
            
        }
    }

}
