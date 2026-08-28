//
//  HabitIcon.swift
//  HabitTracker
//

import Foundation

enum HabitIcon: String, Codable, CaseIterable, Identifiable {
    case water = "drop.fill"
    case book = "book.fill"
    case walk = "figure.walk"
    case workout = "figure.strengthtraining.traditional"
    case moon = "moon.fill"
    case pills = "pills.fill"
    case heart = "heart.fill"
    case brain = "brain.head.profile"
    case leaf = "leaf.fill"
    case flame = "flame.fill"
    case music = "music.note"
    case coffee = "cup.and.saucer.fill"
    case target = "target"
    case star = "star.fill"

    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .water: return "Water"
        case .book: return "Read"
        case .walk: return "Walk"
        case .workout: return "Workout"
        case .moon: return "Sleep"
        case .pills: return "Health"
        case .heart: return "Fitness"
        case .brain: return "Mind"
        case .leaf: return "Zen"
        case .flame: return "Streak"
        case .music: return "Music"
        case .coffee: return "Focus"
        case .target: return "Goal"
        case .star: return "Special"
        }
    }
}
