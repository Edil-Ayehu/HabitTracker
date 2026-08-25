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
    
    func fetchTodayEntries() throws -> [HabitEntry] {
        
        let habits = try repository.fetchHabits()
        
        var entries: [HabitEntry] = []
        
        for habit in habits {
            
            if let existing = try repository.fetchTodayEntry(for: habit) {
                
                entries.append(existing)
                
            } else {
                
                let newEntry = HabitEntry(habit: habit)
                
                try repository.saveEntry(newEntry)
                
                entries.append(newEntry)
            }
        }
        
        syncWidgetData()
        
        return entries
    }
    
    func fetchStatistics() throws -> HabitStatistics {
        
        let entries = try repository.fetchTodayEntries()
        
        let totalHabits = entries.count
        
        let completedHabits = entries.filter { $0.completed || $0.isFrozen }.count
        
        let completionRate: Double
        
        if totalHabits == 0 {
            
            completionRate = 0
            
        } else {
            
            completionRate = Double(completedHabits) / Double(totalHabits)
            
        }
        
        let allEntries = try repository.fetchAllEntries()
        
        let streak = calculateStreak(from: allEntries)
        let best = calculateBestStreak(from: allEntries)
        let achievementsList = calculateAchievements(
            allEntries: allEntries,
            todayEntries: entries,
            currentStreak: streak
        )
        
        return HabitStatistics(
            totalHabits: totalHabits,
            completedHabits: completedHabits,
            completionRate: completionRate,
            currentStreak: streak,
            bestStreak: best,
            achievements: achievementsList
        )
    }
    
    func addHabit(_ habit: Habit) throws {
        try repository.saveHabit(habit)
        syncWidgetData()
    }
    
    func deleteHabit(_ habit: Habit) throws {
        NotificationManager.shared.removeReminder(habit: habit)
        try repository.deleteHabit(habit)
        syncWidgetData()
    }
    
    
    func increment(_ entry: HabitEntry) throws {
        
        switch entry.habit.habitType {
            
        case .binary:
            
            entry.progress = 1
            entry.completed = true
            
        case .measurable:
            
            guard let goal = entry.habit.goal else {
                return
            }
            
            guard entry.progress < goal else {
                return
            }
            
            entry.progress += 1
            
            entry.completed =
                entry.progress >= goal
        }
        
        try repository.update()
        
        NotificationManager.shared
            .refreshHabitReminder(
                habit: entry.habit,
                entry: entry
            )
        syncWidgetData()
    }
    
    
    func decrement(_ entry: HabitEntry) throws {
        
        switch entry.habit.habitType {
            
        case .binary:
            
            entry.progress = 0
            entry.completed = false
            
        case .measurable:
            
            guard entry.progress > 0 else {
                return
            }
            
            entry.progress -= 1
            
            let goal = entry.habit.goal ?? 1
            
            entry.completed =
                entry.progress >= goal
        }
        
        try repository.update()
        
        NotificationManager.shared
            .refreshHabitReminder(
                habit: entry.habit,
                entry: entry
            )
        syncWidgetData()
    }
    
    
    func complete(_ entry: HabitEntry) throws {
        
        switch entry.habit.habitType {
            
        case .binary:
            
            entry.progress = 1
            entry.completed = true
            
        case .measurable:
            
            guard let goal = entry.habit.goal else {
                return
            }
            
            entry.progress = goal
            entry.completed = true
        }
        
        try repository.update()
        
        // Habit is completed.
        // Remove its pending reminder.
        NotificationManager.shared
            .refreshHabitReminder(
                habit: entry.habit,
                entry: entry
            )
        syncWidgetData()
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
        
        let frozenDates = Set(
            entries
                .filter(\.isFrozen)
                .map {
                    calendar.startOfDay(for: $0.date)
                }
        )
        
        var streak = 0
        
        let today = calendar.startOfDay(for: Date())
        
        var currentDate = today
        
        // If today's habit isn't completed or frozen, start counting from yesterday.
        if !completedDates.contains(today) && !frozenDates.contains(today) {
            guard let yesterday = calendar.date(
                byAdding: .day,
                value: -1,
                to: today
            ) else {
                return 0
            }
            
            currentDate = yesterday
        }
        
        while completedDates.contains(currentDate) || frozenDates.contains(currentDate) {
            if completedDates.contains(currentDate) {
                streak += 1
            }
            
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
    
    private func calculateAchievements(
        allEntries: [HabitEntry],
        todayEntries: [HabitEntry],
        currentStreak: Int
    ) -> [Achievement] {
        let totalCompletedCount = allEntries.filter(\.completed).count
        
        let firstStepUnlocked = totalCompletedCount >= 1
        let onFireUnlocked = currentStreak >= 3
        let weekWarriorUnlocked = currentStreak >= 7
        let consistencyKingUnlocked = currentStreak >= 14
        let monthlyMasterUnlocked = currentStreak >= 30
        let unstoppableUnlocked = currentStreak >= 100
        
        let perfectDayUnlocked = !todayEntries.isEmpty && todayEntries.allSatisfy { $0.completed || $0.isFrozen }
        let perfectDayProgress: Double = {
            guard !todayEntries.isEmpty else { return 0.0 }
            let completedCount = todayEntries.filter { $0.completed || $0.isFrozen }.count
            return Double(completedCount) / Double(todayEntries.count)
        }()
        
        return [
            Achievement(
                id: "first_step",
                title: "First Step",
                description: "Completed your first habit entry",
                icon: "star.fill",
                requiredCount: 1,
                isUnlocked: firstStepUnlocked,
                progress: min(1.0, Double(totalCompletedCount) / 1.0)
            ),
            Achievement(
                id: "on_fire",
                title: "On Fire",
                description: "Achieved a 3-day streak",
                icon: "flame.fill",
                requiredCount: 3,
                isUnlocked: onFireUnlocked,
                progress: min(1.0, Double(currentStreak) / 3.0)
            ),
            Achievement(
                id: "week_warrior",
                title: "Week Warrior",
                description: "Maintained a 7-day streak",
                icon: "bolt.fill",
                requiredCount: 7,
                isUnlocked: weekWarriorUnlocked,
                progress: min(1.0, Double(currentStreak) / 7.0)
            ),
            Achievement(
                id: "consistency_king",
                title: "Consistency King",
                description: "Kept a 14-day streak alive",
                icon: "trophy.fill",
                requiredCount: 14,
                isUnlocked: consistencyKingUnlocked,
                progress: min(1.0, Double(currentStreak) / 14.0)
            ),
            Achievement(
                id: "monthly_master",
                title: "Monthly Master",
                description: "Reached a 30-day streak",
                icon: "diamond.fill",
                requiredCount: 30,
                isUnlocked: monthlyMasterUnlocked,
                progress: min(1.0, Double(currentStreak) / 30.0)
            ),
            Achievement(
                id: "unstoppable",
                title: "Unstoppable",
                description: "Achieved 100 days of consistency",
                icon: "crown.fill",
                requiredCount: 100,
                isUnlocked: unstoppableUnlocked,
                progress: min(1.0, Double(currentStreak) / 100.0)
            ),
            Achievement(
                id: "perfect_day",
                title: "Perfect Day",
                description: "Completed 100% of today's habits",
                icon: "checkmark.seal.fill",
                requiredCount: 1,
                isUnlocked: perfectDayUnlocked,
                progress: perfectDayProgress
            )
        ]
    }
    
    func fetchEntries(
        for habit: Habit
    ) throws -> [HabitEntry] {
        
        try repository.fetchEntries(
            for: habit
        )
    }
    
    func rescheduleReminders() throws {

        let habits = try repository.fetchHabits()

        let entries = try repository.fetchTodayEntries()

        NotificationManager.shared
            .rescheduleAllReminders(
                habits: habits,
                entries: entries
            )
    }
    
    func updateHabit(_ habit: Habit) throws {
        try repository.update()
    }
    
    func weeklyCompletion() throws -> [DailyCompletion] {

        let calendar = Calendar.current

        let entries = try repository.fetchAllEntries()

        var result: [DailyCompletion] = []

        for offset in (0..<7).reversed() {

            let day = calendar.date(
                byAdding: .day,
                value: -offset,
                to: Date()
            )!

            let start = calendar.startOfDay(for: day)

            let todaysEntries = entries.filter {
                calendar.isDate($0.date, inSameDayAs: start)
            }

            result.append(
                DailyCompletion(
                    date: start,
                    completed: todaysEntries.filter { $0.completed || $0.isFrozen }.count,
                    total: todaysEntries.count
                )
            )
        }

        return result
    }
    
    func habitProgress() throws -> [HabitProgress] {

        let habits = try repository.fetchHabits()

        var progress: [HabitProgress] = []

        for habit in habits {

            let entries = try repository.fetchEntries(for: habit)

            progress.append(

                HabitProgress(

                    title: habit.title,

                    completed: entries.filter { $0.completed || $0.isFrozen }.count
                )
            )
        }

        return progress
    }
    
    func saveNote(_ note: String, for entry: HabitEntry) throws {
        
        entry.note = note
        
        try repository.update()
    }
    
    func updateCheckIn(note: String, imageData: Data?, for entry: HabitEntry) throws {
        entry.note = note
        entry.imageData = imageData
        try repository.update()
        syncWidgetData()
    }
    
    func freezeHabit(_ entry: HabitEntry) throws {
        guard StreakFreezeManager.shared.canUseToken() else { return }
        if StreakFreezeManager.shared.useToken() {
            entry.isFrozen = true
            try repository.update()
            syncWidgetData()
        }
    }
    
    private func syncWidgetData() {
        if let entries = try? repository.fetchTodayEntries(),
           let statistics = try? fetchStatistics() {
            WidgetSharedData.sync(entries: entries, statistics: statistics)
        }
    }
}
