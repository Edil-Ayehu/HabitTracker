//
//  HabitCategory.swift
//  HabitTracker
//

import SwiftUI

enum HabitCategory: String, Codable, CaseIterable, Identifiable {
    case health = "health"
    case fitness = "fitness"
    case mindfulness = "mindfulness"
    case spiritual = "spiritual"
    case productivity = "productivity"
    case lifestyle = "lifestyle"
    case other = "other"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .health: return "Health"
        case .fitness: return "Fitness"
        case .mindfulness: return "Mind & Focus"
        case .spiritual: return "Spiritual"
        case .productivity: return "Work & Learn"
        case .lifestyle: return "Lifestyle"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .fitness: return "figure.walk"
        case .mindfulness: return "brain.head.profile"
        case .spiritual: return "hands.sparkles.fill"
        case .productivity: return "briefcase.fill"
        case .lifestyle: return "sun.max.fill"
        case .other: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .health: return .red
        case .fitness: return .orange
        case .mindfulness: return .purple
        case .spiritual: return .indigo
        case .productivity: return .blue
        case .lifestyle: return .green
        case .other: return .gray
        }
    }
}
