//
//  CreateHabitViewModel.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import Foundation

@MainActor
final class CreateHabitViewModel: ObservableObject {
    
    @Published var draft = HabitDraft()
    
    @Published var isLoading = false
    
    @Published var errorMessage: String?
    
    private let habitUseCase: HabitUseCase
    
    init(habitUseCase: HabitUseCase) {
        self.habitUseCase = habitUseCase
    }
    
    func createHabit() -> Bool {
        
        guard !draft.title.isEmpty else {
            
            errorMessage = "Habit title is required"
            
            return false
        }
        
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        let habit = Habit(
            title: draft.title,
            icon: draft.icon,
            color: draft.color,
            goal: draft.habitType == HabitType.measurable ? draft.goal : nil,
            unit: draft.habitType == HabitType.measurable ? draft.unit : nil,
            habitType: draft.habitType,
            frequency: draft.frequency
        )
        
        do {
            
            try habitUseCase.addHabit(habit)
            
            return true
        } catch {
            
            errorMessage = error.localizedDescription
            
            return false
        }
    }
}
