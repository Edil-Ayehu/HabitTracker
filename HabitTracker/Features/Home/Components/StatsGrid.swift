//
//  StatsGrid.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct StatsGrid: View {

    let streak: Int
    let bestStreak: Int
    let completion: Int

    init(
        streak: Int,
        bestStreak: Int = 0,
        completion: Int
    ) {
        self.streak = streak
        self.bestStreak = bestStreak
        self.completion = completion
    }

    var body: some View {

        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: AppSpacing.md
        ) {

            StatCard(
                icon: "flame.fill",
                title: "Streak",
                value: "\(streak)d"
            )

            StatCard(
                icon: "trophy.fill",
                title: "Best",
                value: "\(bestStreak)d"
            )

            StatCard(
                icon: "chart.bar.fill",
                title: "Rate",
                value: "\(completion)%"
            )

        }

    }

}
