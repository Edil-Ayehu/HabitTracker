//
//  HabitStatistics.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import Foundation

struct HabitStatistics {
    
    let totalHabits: Int
    let completedHabits: Int
    let completionRate: Double
    let currentStreak: Int
    let bestStreak: Int
    let achievements: [Achievement]
    
    init(
        totalHabits: Int = 0,
        completedHabits: Int = 0,
        completionRate: Double = 0,
        currentStreak: Int = 0,
        bestStreak: Int = 0,
        achievements: [Achievement] = []
    ) {
        self.totalHabits = totalHabits
        self.completedHabits = completedHabits
        self.completionRate = completionRate
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.achievements = achievements
    }
}
