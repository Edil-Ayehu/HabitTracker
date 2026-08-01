//
//  HomeView.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct HomeView: View {

    @StateObject
    private var vm = HomeViewModel()

    var body: some View {

        AppScaffold {

            GreetingHeader(
                greeting: vm.greeting,
                date: formattedDate,
                onAdd: {

                }
            )

            TodayProgressCard(
                completed: vm.completedHabits,
                total: vm.totalHabits
            )

            StatsGrid(
                streak: vm.currentStreak,
                completion: vm.completionRate
            )

            SectionHeader(title: "Today's Habits")

            EmptyStateView(
                image: "figure.walk",
                title: "No Habits",
                subtitle: "Tap + to create your first habit."
            )

        }

    }

    private var formattedDate: String {

        Date.now.formatted(
            date: .complete,
            time: .omitted
        )

    }

}
