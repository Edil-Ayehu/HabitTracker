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
    
    @Published var entries: [HabitEntry] = []
    
    @Published var selectedCategoryFilter: HabitCategory? = nil
    @Published var selectedTimeFilter: TimeFilterOption = .all
    
    var filteredEntries: [HabitEntry] {
        var result = entries
        
        if let category = selectedCategoryFilter {
            result = result.filter { $0.habit.habitCategory == category }
        }
        
        switch selectedTimeFilter {
        case .all:
            return result
        case .timeOfDay(let time):
            return result.filter { $0.habit.habitTimeOfDay == time || $0.habit.habitTimeOfDay == .anyTime }
        }
    }
    
    @Published var showQuote: Bool = false
    @Published var quote: Quote?
    @Published var showConfetti: Bool = false
    @Published var showCelebrationBanner: Bool = false
    @Published var userProfile: UserProfile = QuestManager.shared.getUserProfile()
    @Published var dailyQuests: [DailyQuest] = []
    @Published var showLevelUpBanner: Bool = false
    
    private let quoteDateKey = "quote.date"
    private let quoteCompletedKey = "quote.completed"

    
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
    
    private var quoteUseCase: QuoteUseCase
    
    init(
        habitUseCase: HabitUseCase,
        quoteUseCase: QuoteUseCase,
    ) {
        self.habitUseCase = habitUseCase
        self.quoteUseCase = quoteUseCase
    }

    func load() {
        
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            
            entries = try habitUseCase.fetchTodayEntries()
            
            statistics = try habitUseCase.fetchStatistics()
            
            refreshGamification()
            
            checkDailyCompletion()
            
        } catch {
            
            errorMessage = error.localizedDescription
        }
    }
    
    private func refreshGamification() {
        userProfile = QuestManager.shared.getUserProfile()
        QuestManager.shared.updateQuestProgress(completedHabits: statistics.completedHabits, streak: statistics.currentStreak)
        dailyQuests = QuestManager.shared.getDailyQuests(totalHabits: statistics.totalHabits, completedHabits: statistics.completedHabits, streak: statistics.currentStreak)
    }
    
    private func reloadStatistics() {
        
        do {
            
            statistics = try habitUseCase.fetchStatistics()
            
            refreshGamification()
            
            checkDailyCompletion()
            
        } catch {
            
            errorMessage = error.localizedDescription
            
        }
    }
    
    func increment(_ entry: HabitEntry) {
        let wasCompletedBefore = entry.completed
        do {
            try habitUseCase.increment(entry)
            entries = try habitUseCase.fetchTodayEntries()
            reloadStatistics()
            
            if let updated = entries.first(where: { $0.id == entry.id }), !wasCompletedBefore && updated.completed {
                awardXP(25)
                AudioManager.shared.playCompletionSound()
            } else {
                AudioManager.shared.playClickSound()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func complete(_ entry: HabitEntry) {
        let wasCompletedBefore = entry.completed
        do {
            try habitUseCase.complete(entry)
            entries = try habitUseCase.fetchTodayEntries()
            reloadStatistics()
            
            if !wasCompletedBefore {
                awardXP(25)
                SquadService.shared.broadcastCheckIn(habitTitle: entry.habit.title, habitIcon: entry.habit.icon)
                AudioManager.shared.playCompletionSound()
            } else {
                AudioManager.shared.playClickSound()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func toggleSubTask(_ subTaskID: UUID, for entry: HabitEntry) {
        let wasCompletedBefore = entry.completed
        do {
            try habitUseCase.toggleSubTask(subTaskID, for: entry)
            entries = try habitUseCase.fetchTodayEntries()
            reloadStatistics()
            
            if let updated = entries.first(where: { $0.id == entry.id }), !wasCompletedBefore && updated.completed {
                awardXP(25)
                AudioManager.shared.playCompletionSound()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func archiveHabit(_ habit: Habit) {
        do {
            try habitUseCase.archiveHabit(habit)
            entries = try habitUseCase.fetchTodayEntries()
            reloadStatistics()
            AudioManager.shared.playClickSound()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func claimQuest(_ quest: DailyQuest) {
        let result = QuestManager.shared.claimQuest(quest)
        userProfile = result.profile
        dailyQuests = QuestManager.shared.getDailyQuests(totalHabits: statistics.totalHabits, completedHabits: statistics.completedHabits, streak: statistics.currentStreak)
        if result.leveledUp {
            showLevelUpBanner = true
            AudioManager.shared.playCelebrationSound()
        }
    }
    
    private func awardXP(_ amount: Int) {
        let result = QuestManager.shared.addXP(amount)
        userProfile = result.profile
        if result.leveledUp {
            showLevelUpBanner = true
            AudioManager.shared.playCelebrationSound()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        entries.removeAll { $0.habitID == habit.id }
        do {
            try habitUseCase.deleteHabit(habit)
            entries = try habitUseCase.fetchTodayEntries()
            reloadStatistics()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func checkDailyCompletion() {

        guard statistics.totalHabits > 0 else { return }

        guard statistics.completedHabits == statistics.totalHabits else {
            return
        }

        if alreadyShownForCurrentCompletion() {
            return
        }

        showConfetti = true
        showCelebrationBanner = true
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        AudioManager.shared.playCelebrationSound()

        quote = quoteUseCase.randomQuote()

        markQuoteShown()

        showQuote = true
    }
    
    private func alreadyShownForCurrentCompletion() -> Bool {

        guard
            let date = UserDefaults.standard.object(forKey: quoteDateKey) as? Date,
            Calendar.current.isDateInToday(date)
        else {
            return false
        }

        let lastCompleted = UserDefaults.standard.integer(
            forKey: quoteCompletedKey
        )

        return lastCompleted >= statistics.completedHabits
    }
    
    private func markQuoteShown() {

        UserDefaults.standard.set(
            Date(),
            forKey: quoteDateKey
        )

        UserDefaults.standard.set(
            statistics.completedHabits,
            forKey: quoteCompletedKey
        )
    }
    
    
    var greeting: String {

        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {

        case 5..<12:
            return "Good Morning"

        case 12..<17:
            return "Good Afternoon"

        case 17..<21:
            return "Good Evening"

        default:
            return "Good Night"
        }
    }

}
