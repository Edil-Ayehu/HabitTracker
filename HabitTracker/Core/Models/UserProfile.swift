//
//  UserProfile.swift
//  HabitTracker
//

import Foundation

struct UserProfile: Codable {
    var xp: Int = 0
    
    var level: Int {
        return (xp / 100) + 1
    }
    
    var currentLevelXP: Int {
        return xp % 100
    }
    
    var progressToNextLevel: Double {
        return Double(currentLevelXP) / 100.0
    }
    
    var levelTitle: String {
        switch level {
        case 1: return "Novice"
        case 2: return "Beginner"
        case 3: return "Apprentice"
        case 4: return "Consistent Achiever"
        case 5: return "Habit Champion"
        case 6: return "Habit Master"
        case 7: return "Unstoppable"
        case 8: return "Grandmaster"
        case 9: return "Hero"
        default: return "Habit Legend 👑"
        }
    }
    
    var levelIcon: String {
        switch level {
        case 1...2: return "leaf.fill"
        case 3...4: return "bolt.fill"
        case 5...6: return "star.fill"
        case 7...8: return "trophy.fill"
        default: return "crown.fill"
        }
    }
}
