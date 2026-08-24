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
    
    var filteredEntries: [HabitEntry] {
        guard let filter = selectedCategoryFilter else { return entries }
        return entries.filter { $0.habit.habitCategory == filter }
    }
    
    @Published var showQuote: Bool = false
    @Published var quote: Quote?
    @Published var showConfetti: Bool = false
    @Published var showCelebrationBanner: Bool = false
    
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
            
            checkDailyCompletion()
            
        } catch {
            
            errorMessage = error.localizedDescription
        }
    }
    
    private func reloadStatistics() {
        
        do {
            
            statistics = try habitUseCase.fetchStatistics()
            
            checkDailyCompletion()
            
        } catch {
            
            errorMessage = error.localizedDescription
            
        }
    }
    
    func increment(_ entry: HabitEntry) {
        
        do {
            
            try habitUseCase.increment(entry)
            
            entries = try habitUseCase.fetchTodayEntries()
            
            reloadStatistics()
            
            AudioManager.shared.playClickSound()
            
        } catch {
            
            errorMessage = error.localizedDescription
            
        }
    }
    
    func complete(_ entry: HabitEntry) {
        
        do {
            
            try habitUseCase.complete(entry)
            
            entries = try habitUseCase.fetchTodayEntries()
            
            reloadStatistics()
            
            AudioManager.shared.playCompletionSound()
            
        } catch {
            
            errorMessage = error.localizedDescription
            
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
