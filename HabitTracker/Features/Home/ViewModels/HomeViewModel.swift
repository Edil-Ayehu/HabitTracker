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
    
    @Published var entries: [HabitEntry] = []

    
    @Published private(set) var statistics = HabitStatistics(
        totalHabits: 0,
        completedHabits: 0,
        completionRate: 0,
        currentStreak: 0
    )
    
//    private(set) means:
//
//    the View can read it
//    only the ViewModel can change it
    
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
            
            entries = try habitUseCase.fetchTodayEntries()
            
            statistics = try habitUseCase.fetchStatistics()
            
        } catch {
            
            errorMessage = error.localizedDescription
        }
    }
    
    private func reloadStatistics() {
        
        do {
            
            statistics = try habitUseCase.fetchStatistics()
            
        } catch {
            
            errorMessage = error.localizedDescription
            
        }
    }
    
    func increment(_ entry: HabitEntry) {
        
        do {
            
            try habitUseCase.increment(entry)
            
            reloadStatistics()
            
            
        } catch {
            
            errorMessage = error.localizedDescription
            
        }
    }
    
    func complete(_ entry: HabitEntry) {
        
        do {
            
            try habitUseCase.complete(entry)
            
            reloadStatistics()
            
        } catch {
            
            errorMessage = error.localizedDescription
            
        }
    }

}
