//
//  SquadModels.swift
//  HabitTracker
//

import Foundation

struct Squad: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let code: String
    let icon: String
    let creatorName: String
    let combinedStreak: Int
    let memberCount: Int
    let createdAt: Date
}

struct SquadMember: Identifiable, Codable, Hashable {
    let id: UUID
    let squadID: UUID
    let username: String
    let avatarIcon: String
    let streakCount: Int
    let weeklyCheckIns: Int
    let totalXP: Int
    let isCurrentAccount: Bool
}

struct SquadActivity: Identifiable, Codable, Hashable {
    let id: UUID
    let squadID: UUID
    let username: String
    let habitTitle: String
    let habitIcon: String
    let timestamp: Date
    var clapCount: Int
}

struct SquadNudge: Identifiable, Codable, Hashable {
    let id: UUID
    let squadID: UUID
    let senderUsername: String
    let receiverUsername: String
    let nudgeMessage: String
    let nudgeType: String
    let timestamp: Date
    
    var typeIcon: String {
        switch nudgeType {
        case "high_five": return "hand.raised.fill"
        case "flex": return "figure.arms.open"
        case "streak_saver": return "flame.fill"
        case "lightning": return "bolt.fill"
        default: return "sparkles"
        }
    }
}
