//
//  Achievement.swift
//  HabitTracker
//

import Foundation

struct Achievement: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let requiredCount: Int
    let isUnlocked: Bool
    let progress: Double // 0.0 to 1.0
}
