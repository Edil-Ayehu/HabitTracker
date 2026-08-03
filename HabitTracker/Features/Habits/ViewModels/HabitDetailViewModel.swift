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
    
    private let habitUseCase: HabitUseCase
    
    private let habit: Habit
    
    init(
        habit: Habit,
        useCase: HabitUseCase
    ) {
        self.habitUseCase = useCase
        self.habit = habit
    }
    
    func load() {
        
        do {
            
            entries = try habitUseCase.fetchEntries(for: habit)
            
            streak = calculateStreak(from: entries)
        } catch {
            
        }
    }
    
    var title: String {
        habit.title
    }
    
    var goal: Int {
        switch habit.habitType {
        case .binary:
            return 1
        case .measurable:
            return habit.goal ?? 1
        }
    }
        
    var icon: HabitIcon {
        habit.habitIcon
    }
    
    var color: HabitColor {
        habit.habitColor
    }
    
    var todayEntry: HabitEntry? {
        entries.first
    }
    
    var progress: Int {
        todayEntry?.progress ?? 0
    }
    
//    private func calculateStreak(
//        from entries: [HabitEntry]
//    ) -> Int {
//        
//        
//        let calendar = Calendar.current
//        
//        
//        let completedDates =
//        entries
//            .filter(\.completed)
//            .map {
//                calendar.startOfDay(
//                    for: $0.date
//                )
//            }
//        
//        
//        
//        var streak = 0
//        
//        
//        var currentDate =
//        calendar.startOfDay(
//            for: Date()
//        )
//        
//        
//        
//        while completedDates.contains(currentDate) {
//            
//            
//            streak += 1
//            
//            
//            guard let previousDay =
//                    calendar.date(
//                        byAdding: .day,
//                        value: -1,
//                        to: currentDate
//                    )
//            else {
//                break
//            }
//            
//            
//            currentDate = previousDay
//        }
//        
//        
//        return streak
//    }
    
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
}
