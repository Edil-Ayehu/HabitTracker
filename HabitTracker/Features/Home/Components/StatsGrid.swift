//
//  StatsGrid.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct StatsGrid: View {

    let streak: Int

    let completion: Int

    var body: some View {

        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: AppSpacing.md
        ) {

            StatCard(
                icon: "flame.fill",
                title: "Current Streak",
                value: "\(streak)"
            )

            StatCard(
                icon: "chart.bar.fill",
                title: "Completion",
                value: "\(completion)%"
            )

        }

    }

}
