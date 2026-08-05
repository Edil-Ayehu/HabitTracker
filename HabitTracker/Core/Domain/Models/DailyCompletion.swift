//
//  DailyCompletion.swift
//  HabitTracker
//
//  Created by Edil on 05/08/2026.
//
import SwiftUI

struct DailyCompletion: Identifiable {
    let id = UUID()
    let date: Date
    let completed: Int
    let total: Int

    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }
}
