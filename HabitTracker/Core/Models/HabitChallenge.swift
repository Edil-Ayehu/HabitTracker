//
//  HabitChallenge.swift
//  HabitTracker
//

import Foundation

struct HabitChallenge: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let categoryTitle: String
    let goalPerDay: Int
    let unit: String
    let xpReward: Int
    let badgeTitle: String
    let badgeIcon: String
    
    static let prebuiltChallenges: [HabitChallenge] = [
        HabitChallenge(
            id: "hydration_30",
            title: "30-Day Hydration Hero",
            description: "Drink 8 glasses of water every day for 30 consecutive days to build unstoppable hydration habits.",
            icon: "drop.fill",
            categoryTitle: "Health",
            goalPerDay: 8,
            unit: "glasses",
            xpReward: 500,
            badgeTitle: "Hydration Master 🏆",
            badgeIcon: "drop.circle.fill"
        ),
        HabitChallenge(
            id: "meditation_30",
            title: "30-Day Mindfulness Journey",
            description: "Practice 15 minutes of meditation daily for 30 days to reduce stress and sharpen mental clarity.",
            icon: "moon.fill",
            categoryTitle: "Mind & Focus",
            goalPerDay: 15,
            unit: "mins",
            xpReward: 500,
            badgeTitle: "Zen Master 🧘",
            badgeIcon: "sparkles"
        ),
        HabitChallenge(
            id: "reading_30",
            title: "30-Day Reading Sprint",
            description: "Read 20 pages of a book every day for 30 days to expand your knowledge and focus.",
            icon: "book.fill",
            categoryTitle: "Work & Learn",
            goalPerDay: 20,
            unit: "pages",
            xpReward: 500,
            badgeTitle: "Scholar Crown 👑",
            badgeIcon: "book.circle.fill"
        ),
        HabitChallenge(
            id: "walking_30",
            title: "30-Day Morning Walk",
            description: "Walk every morning for 30 consecutive days to boost energy and daily physical activity.",
            icon: "figure.walk",
            categoryTitle: "Fitness",
            goalPerDay: 1,
            unit: "session",
            xpReward: 500,
            badgeTitle: "Trailblazer 🏃",
            badgeIcon: "figure.walk.circle.fill"
        )
    ]
}
