//
//  NightlyReflection.swift
//  HabitTracker
//

import Foundation
import SwiftUI

enum MoodRating: Int, CaseIterable, Codable, Identifiable {
    case rough = 1
    case difficult = 2
    case balanced = 3
    case good = 4
    case ecstatic = 5
    
    var id: Int { rawValue }
    
    var emoji: String {
        switch self {
        case .rough: return "😫"
        case .difficult: return "😔"
        case .balanced: return "😐"
        case .good: return "🙂"
        case .ecstatic: return "🤩"
        }
    }
    
    var title: String {
        switch self {
        case .rough: return "Rough"
        case .difficult: return "Difficult"
        case .balanced: return "Balanced"
        case .good: return "Good"
        case .ecstatic: return "Great"
        }
    }
    
    var color: Color {
        switch self {
        case .rough: return .red
        case .difficult: return .orange
        case .balanced: return .cyan
        case .good: return .green
        case .ecstatic: return .yellow
        }
    }
}

struct NightlyReflection: Identifiable, Codable {
    var id: String { dateString }
    let dateString: String // yyyy-MM-dd
    let moodScore: Int
    let journalNote: String
    let gratitudeNote: String
    let completionRate: Int
    
    var mood: MoodRating {
        MoodRating(rawValue: moodScore) ?? .balanced
    }
}
