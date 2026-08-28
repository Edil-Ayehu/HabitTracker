//
//  TimeOfDay.swift
//  HabitTracker
//

import SwiftUI

enum TimeOfDay: String, Codable, CaseIterable, Identifiable {
    case anyTime = "Anytime"
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .anyTime: return "Anytime ⏰"
        case .morning: return "Morning 🌅"
        case .afternoon: return "Afternoon ☀️"
        case .evening: return "Evening 🌙"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .anyTime: return "Anytime"
        case .morning: return "Morning"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        }
    }
    
    var emoji: String {
        switch self {
        case .anyTime: return "⏰"
        case .morning: return "🌅"
        case .afternoon: return "☀️"
        case .evening: return "🌙"
        }
    }
    
    var icon: String {
        switch self {
        case .anyTime: return "clock.fill"
        case .morning: return "sun.max.fill"
        case .afternoon: return "sun.haze.fill"
        case .evening: return "moon.stars.fill"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .anyTime: return Color.blue
        case .morning: return Color.orange
        case .afternoon: return Color.yellow
        case .evening: return Color.indigo
        }
    }
    
    static func current() -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 5 && hour < 12 {
            return .morning
        } else if hour >= 12 && hour < 17 {
            return .afternoon
        } else {
            return .evening
        }
    }
}

enum TimeFilterOption: Hashable, Identifiable {
    case all
    case timeOfDay(TimeOfDay)
    
    var id: String {
        switch self {
        case .all: return "all"
        case .timeOfDay(let time): return time.rawValue
        }
    }
    
    var title: String {
        switch self {
        case .all: return "All 📋"
        case .timeOfDay(let time): return time.title
        }
    }
}
