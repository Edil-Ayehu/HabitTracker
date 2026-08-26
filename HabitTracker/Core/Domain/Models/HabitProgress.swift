//
//  HabitProgress.swift
//  HabitTracker
//

import SwiftUI

struct HabitProgress: Identifiable {
    let id = UUID()
    let title: String
    let completed: Int
}

struct CategoryBalance: Identifiable {
    let id = UUID()
    let category: HabitCategory
    let habitCount: Int
    let percentage: Int
}
