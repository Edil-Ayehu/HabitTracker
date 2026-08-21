//
//  HabitDetailViewModel.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import Foundation

@MainActor
final class HabitDetailViewModel: ObservableObject {
    
    @Published var entries: [HabitEntry] = []
    
    @Published var streak = 0
    
    @Published var isLoading = false
    
    @Published var errorMessage: String?
    
    @Published var note = ""
    
    @Published var isEditingNote = false
    
    @Published private(set) var statistics = HabitStatistics(
        totalHabits: 0,
        completedHabits: 0,
        completionRate: 0,
        currentStreak: 0
    )
    
    private let habitUseCase: HabitUseCase
    
    let habit: Habit
    
    let title: String
    let goal: Int
    let isMeasurable: Bool
    let isBinary: Bool
    let icon: HabitIcon
    let color: HabitColor
    
    @Published var reminderEnabled: Bool
    @Published var reminderTime: Date
    
    init(
        habit: Habit,
        useCase: HabitUseCase
    ) {
        self.habitUseCase = useCase
        self.habit = habit
        self.title = habit.title
        self.icon = habit.habitIcon
        self.color = habit.habitColor
        self.isMeasurable = habit.habitType == .measurable
        self.isBinary = habit.habitType == .binary
        
        switch habit.habitType {
        case .binary:
            self.goal = 1
        case .measurable:
            self.goal = habit.goal ?? 1
        }
        
        self.reminderEnabled = habit.reminderEnabled
        
        var components = DateComponents()
        components.hour = habit.reminderHour ?? 9
        components.minute = habit.reminderMinute ?? 0
        self.reminderTime = Calendar.current.date(from: components) ?? Date()
    }
    
    func updateReminder(
        enabled: Bool,
        time: Date
    ) {
        let calendar = Calendar.current
        
        habit.reminderEnabled = enabled
        reminderEnabled = enabled
        reminderTime = time
        
        if enabled {
            
            habit.reminderHour =
                calendar.component(
                    .hour,
                    from: time
                )
            
            habit.reminderMinute =
                calendar.component(
                    .minute,
                    from: time
                )
            
        } else {
            
            NotificationManager.shared
                .removeReminder(
                    habit: habit
                )
        }
        
        do {
            
            try habitUseCase.updateHabit(habit)
            
            if enabled {
                
                let entry = todayEntry
                
                NotificationManager.shared
                    .refreshHabitReminder(
                        habit: habit,
                        entry: entry
                    )
            }
            
            load()
            
        } catch {
            
            errorMessage =
                error.localizedDescription
        }
    }
    
    
    func load() {
        
        do {
            
            entries = try habitUseCase.fetchEntries(for: habit)

            note = todayEntry?.note ?? ""

            isEditingNote = note.isEmpty
            
            streak = calculateStreak(from: entries)
        } catch {
            
        }
    }
    
    var isCompletedToday: Bool {
        todayEntry?.completed ?? false
    }
    
    var canIncrement: Bool {
        isMeasurable && progress < goal && !isCompletedToday
    }
    
    var canDecrement: Bool {
        isMeasurable && progress > 0
    }
    
    var canComplete: Bool {
        !isCompletedToday
    }
    
    var todayEntry: HabitEntry? {

        let today = Calendar.current.startOfDay(for: Date())

        return entries.first {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }
    }
    
    var progress: Int {
        todayEntry?.progress ?? 0
    }
    
    
    func increment() {
        
        guard let entry = todayEntry else { return }
        
        do {
            
            try habitUseCase.increment(entry)
            
            load()
            
            
        } catch {
            
            errorMessage = error.localizedDescription
            
        }
    }
    
    func decrement() {
        
        guard let entry = todayEntry else { return }
        
        do {
            
            try habitUseCase.decrement(entry)
            
            load()
            
            
        } catch {
            
            errorMessage = error.localizedDescription
            
        }
    }
    
    func complete() {
        
        guard let entry = todayEntry else { return }
        
        do {
            
            try habitUseCase.complete(entry)
            
            load()
            
        } catch {
            
            errorMessage = error.localizedDescription
            
        }
    }
    
    
    private func calculateStreak(from entries: [HabitEntry]) -> Int {

        let calendar = Calendar.current

        let completedDates = Set(
            entries
                .filter(\.completed)
                .map {
                    calendar.startOfDay(for: $0.date)
                }
        )

        var streak = 0

        let today = calendar.startOfDay(for: Date())

        var currentDate = today

        // If today's habit isn't completed, start counting from yesterday.
        if !completedDates.contains(today) {
            guard let yesterday = calendar.date(
                byAdding: .day,
                value: -1,
                to: today
            ) else {
                return 0
            }

            currentDate = yesterday
        }

        while completedDates.contains(currentDate) {

            streak += 1

            guard let previousDay = calendar.date(
                byAdding: .day,
                value: -1,
                to: currentDate
            ) else {
                break
            }

            currentDate = previousDay
        }

        return streak
    }
    
    
    func saveNote() {

        guard let entry = todayEntry else {
            return
        }

        do {

            try habitUseCase.saveNote(
                note,
                for: entry
            )

            isEditingNote = false

        } catch {

            errorMessage = error.localizedDescription
        }
    }

    func deleteHabit() -> Bool {
        entries = []
        do {
            try habitUseCase.deleteHabit(habit)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
