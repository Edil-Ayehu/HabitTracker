//
//  HabitDetailViewModel.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import Foundation
import UIKit

@MainActor
final class HabitDetailViewModel: ObservableObject {
    
    @Published var entries: [HabitEntry] = []
    
    @Published var streak = 0
    @Published var bestStreak = 0
    
    @Published var isLoading = false
    
    @Published var errorMessage: String?
    
    @Published var note = ""
    @Published var selectedImage: UIImage? = nil
    
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

            if let data = todayEntry?.imageData, let img = UIImage(data: data) {
                selectedImage = img
            } else {
                selectedImage = nil
            }

            if note.isEmpty && todayEntry?.imageData == nil {
                isEditingNote = true
            }
            
            streak = calculateStreak(from: entries)
            bestStreak = calculateBestStreak(from: entries)
        } catch {
            
        }
    }
    
    var isCompletedToday: Bool {
        todayEntry?.completed ?? false
    }
    
    var isFrozenToday: Bool {
        todayEntry?.isFrozen ?? false
    }
    
    var canIncrement: Bool {
        isMeasurable && progress < goal && !isCompletedToday && !isFrozenToday
    }
    
    var canDecrement: Bool {
        isMeasurable && progress > 0 && !isFrozenToday
    }
    
    var canComplete: Bool {
        !isCompletedToday && !isFrozenToday
    }
    
    var todayEntry: HabitEntry? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        switch habit.frequency {
        case .daily:
            return entries.first { calendar.isDate($0.date, inSameDayAs: today) }
            
        case .weekly:
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else {
                return entries.first { calendar.isDate($0.date, inSameDayAs: today) }
            }
            return entries.first { $0.date >= weekInterval.start && $0.date < weekInterval.end }
            
        case .monthly:
            guard let monthInterval = calendar.dateInterval(of: .month, for: today) else {
                return entries.first { calendar.isDate($0.date, inSameDayAs: today) }
            }
            return entries.first { $0.date >= monthInterval.start && $0.date < monthInterval.end }
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
            
            AudioManager.shared.playCompletionSound()
            
        } catch {
            
            errorMessage = error.localizedDescription
            
        }
    }
    
    func freezeHabit() {
        guard let entry = todayEntry else { return }
        do {
            try habitUseCase.freezeHabit(entry)
            load()
            AudioManager.shared.playClickSound()
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
    
    private func calculateBestStreak(from entries: [HabitEntry]) -> Int {
        let calendar = Calendar.current
        let completedDates = Array(Set(
            entries
                .filter(\.completed)
                .map { calendar.startOfDay(for: $0.date) }
        )).sorted()
        
        guard !completedDates.isEmpty else { return 0 }
        
        var maxStreak = 1
        var currentContiguous = 1
        
        for i in 0..<(completedDates.count - 1) {
            let day1 = completedDates[i]
            let day2 = completedDates[i + 1]
            let diff = calendar.dateComponents([.day], from: day1, to: day2).day ?? 0
            
            if diff == 1 {
                currentContiguous += 1
                maxStreak = max(maxStreak, currentContiguous)
            } else if diff > 1 {
                currentContiguous = 1
            }
        }
        
        let activeStreak = calculateStreak(from: entries)
        return max(maxStreak, activeStreak)
    }
    
    
    func saveNote() {

        guard let entry = todayEntry else {
            return
        }

        do {
            let data = selectedImage?.jpegData(compressionQuality: 0.8)

            try habitUseCase.updateCheckIn(
                note: note,
                imageData: data,
                for: entry
            )

            isEditingNote = false

        } catch {

            errorMessage = error.localizedDescription
        }
    }
    
    func removeImage() {
        selectedImage = nil
        saveNote()
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
