//
//  OnboardingSlide.swift
//  HabitTracker
//

import SwiftUI

struct OnboardingSlide: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let iconName: String
    let gradientColors: [Color]
    let badgeText: String
}

struct OnboardingData {
    static let slides: [OnboardingSlide] = [
        OnboardingSlide(
            id: 0,
            title: "Build Lasting Habits",
            subtitle: "Track daily binary & measurable habits with custom target goals, smart reminders, and AI routine builders.",
            iconName: "sparkles",
            gradientColors: [Color.indigo, Color.blue],
            badgeText: "Core Tracking 🌱"
        ),
        OnboardingSlide(
            id: 1,
            title: "Grow Your Mascot Tree",
            subtitle: "Every habit completed waters your tree! Watch it evolve from a Seedling 🌱 to a Zen Blossom 🌸 and unlock royal accessories.",
            iconName: "tree.fill",
            gradientColors: [Color.teal, Color.green],
            badgeText: "Gamification 🌳"
        ),
        OnboardingSlide(
            id: 2,
            title: "Bootcamps & Mood Log",
            subtitle: "Enroll in 30-day guided bootcamps, log daily gratitude & mood reflections at 9:00 PM, and earn +25 XP rewards.",
            iconName: "trophy.fill",
            gradientColors: [Color.purple, Color.indigo],
            badgeText: "Challenges & Mood 🏆"
        ),
        OnboardingSlide(
            id: 3,
            title: "Vacation Mode & Widgets",
            subtitle: "Freeze streaks guilt-free with 14 annual Vacation Days 🏖️, and view live progress on your Home & Lock Screen widgets.",
            iconName: "sun.max.fill",
            gradientColors: [Color.orange, Color.pink],
            badgeText: "Rest & Widgets 🏖️"
        )
    ]
}
