//
//  AIRoutineGeneratorViewModel.swift
//  HabitTracker
//

import SwiftUI

@MainActor
final class AIRoutineGeneratorViewModel: ObservableObject {
    
    @Published var prompt: String = ""
    @Published var isLoading: Bool = false
    @Published var generatedHabits: [HabitDraft] = []
    @Published var selectedIndices: Set<Int> = []
    @Published var templates: [AIRoutineTemplate] = []
    @Published var errorMessage: String?
    @Published var importedCount: Int?
    
    private let habitUseCase: HabitUseCase
    private let aiService: AIRoutineGeneratorService
    
    init(
        habitUseCase: HabitUseCase,
        aiService: AIRoutineGeneratorService
    ) {
        self.habitUseCase = habitUseCase
        self.aiService = aiService
        self.templates = aiService.availableTemplates()
    }
    
    func generateRoutine(withCustomPrompt customPrompt: String? = nil) {
        let query = customPrompt ?? prompt
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a goal or select a template."
            return
        }
        
        isLoading = true
        errorMessage = nil
        importedCount = nil
        
        Task {
            let habits = await aiService.generateRoutine(for: query)
            self.generatedHabits = habits
            self.selectedIndices = Set(0..<habits.count)
            self.isLoading = false
        }
    }
    
    func selectTemplate(_ template: AIRoutineTemplate) {
        prompt = template.title
        generateRoutine(withCustomPrompt: template.title)
    }
    
    func toggleSelection(at index: Int) {
        if selectedIndices.contains(index) {
            selectedIndices.remove(index)
        } else {
            selectedIndices.insert(index)
        }
    }
    
    func importSelectedHabits() -> Bool {
        guard !selectedIndices.isEmpty else {
            errorMessage = "Please select at least one habit to import."
            return false
        }
        
        var count = 0
        do {
            for index in selectedIndices {
                guard index < generatedHabits.count else { continue }
                let draft = generatedHabits[index]
                
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
                count += 1
            }
            
            importedCount = count
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
