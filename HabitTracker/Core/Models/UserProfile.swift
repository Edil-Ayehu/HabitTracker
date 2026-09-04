//
//  UserProfile.swift
//  HabitTracker
//

import Foundation

struct UserProfile: Codable {
    var xp: Int = 0
    
    static let xpPerLevel: Int = 500
    
    var level: Int {
        return (xp / UserProfile.xpPerLevel) + 1
    }
    
    var currentLevelXP: Int {
        return xp % UserProfile.xpPerLevel
    }
    
    var xpNeededForNextLevel: Int {
        return UserProfile.xpPerLevel
    }
    
    var progressToNextLevel: Double {
        return Double(currentLevelXP) / Double(UserProfile.xpPerLevel)
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
