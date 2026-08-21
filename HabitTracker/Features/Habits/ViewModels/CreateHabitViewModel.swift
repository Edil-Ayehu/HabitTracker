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
    
    private let editingHabit: Habit?
    
    private let habitUseCase: HabitUseCase
    
    var isEditing: Bool {
        editingHabit != nil
    }
    
    init(
        habitUseCase: HabitUseCase,
        habit: Habit? = nil
    ) {
        self.habitUseCase = habitUseCase
        self.editingHabit = habit
        
        if let habit {
            
            draft.title = habit.title
            draft.goal = habit.goal ?? 1
            draft.icon = habit.habitIcon
            draft.color = habit.habitColor
            draft.unit = habit.unit ?? ""
            draft.frequency = habit.frequency
            draft.habitType = habit.habitType
            
            draft.reminderEnabled = habit.reminderEnabled
            
            if let hour = habit.reminderHour,
               let minute = habit.reminderMinute {
                
                var comp = DateComponents()
                
                comp.hour = hour
                comp.minute = minute
                
                draft.reminderTime =
                Calendar.current.date(from: comp) ?? Date()
            }
        }
    }
    
    func saveHabit() -> Bool {
        
        guard !draft.title.isEmpty else {
            
            errorMessage = "Habit title is required"
            
            return false
        }
        
        
        do {
            
            if let habit = editingHabit {
                habit.title = draft.title
                habit.icon = draft.icon.rawValue
                habit.color = draft.color.rawValue
                habit.goal = draft.habitType == .measurable ? draft.goal : nil
                habit.unit = draft.unit
                habit.habitType = draft.habitType
                habit.frequency = draft.frequency
                
                habit.reminderEnabled = draft.reminderEnabled
                
                habit.reminderHour =
                Calendar.current.component(
                    .hour,
                    from: draft.reminderTime
                )
                
                habit.reminderMinute =
                Calendar.current.component(
                    .minute,
                    from: draft.reminderTime
                )
                
                try habitUseCase.updateHabit(habit)
                
                NotificationManager.shared.scheduleHabitReminder(habit: habit)
                
            } else {
                let habit = Habit(
                    title: draft.title,
                    icon: draft.icon,
                    color: draft.color,
                    goal: draft.habitType == .measurable ? draft.goal : nil,
                    unit: draft.unit,
                    habitType: draft.habitType,
                    frequency: draft.frequency,
                    reminderEnabled: draft.reminderEnabled,
                    reminderHour: Calendar.current.component(.hour, from: draft.reminderTime),
                    reminderMinute: Calendar.current.component(.minute, from: draft.reminderTime)
                )
                
                try habitUseCase.addHabit(habit)
                
                NotificationManager.shared.scheduleHabitReminder(habit: habit)
            }
            

            
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
    
    func deleteHabit() -> Bool {
        guard let habit = editingHabit else { return false }
        do {
            try habitUseCase.deleteHabit(habit)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
