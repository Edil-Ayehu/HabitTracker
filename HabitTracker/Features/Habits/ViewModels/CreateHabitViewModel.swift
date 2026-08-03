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
            frequency: draft.frequency,
            reminderEnabled: draft.reminderEnabled,
            reminderHour: Calendar.current.component(.hour, from: draft.reminderTime),
            reminderMinute: Calendar.current.component(.minute, from: draft.reminderTime)
        )
        
        do {
            
            try habitUseCase.addHabit(habit)
            
            NotificationManager.shared.scheduleHabitReminder(habit: habit)
                        
            return true
        } catch {
            
            errorMessage = error.localizedDescription
            
            return false
        }
    }
    
    var reminderDate: Date {

        var components = DateComponents()

        components.hour =
        Calendar.current.component(.hour, from: draft.reminderTime)

        components.minute =
        Calendar.current.component(.minute, from: draft.reminderTime)


        return Calendar.current.date(
            from: components
        ) ?? Date()
    }
    
    func updateReminderDate(_ date: Date) {
        draft.reminderTime = date
    }
}
