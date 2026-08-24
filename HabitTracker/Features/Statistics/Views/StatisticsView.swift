//
//  StatisticsView.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI
import Charts

struct StatisticsView: View {

    @StateObject
    var vm: StatisticsViewModel
    
    @State private var shareImage: UIImage?
    @State private var showShareSheet = false

    var body: some View {

        AppScaffold(title: "Statistics") {

            if let statistics = vm.statistics {
                
                // MARK: Share Card Button
                Button {
                    renderAndShare(statistics: statistics)
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text("Share Progress Card")
                            .font(AppFont.body())
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [AppColors.primary, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)

                // MARK: Overview

                SectionHeader(title: "Overview")

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
                        value: "\(statistics.currentStreak)"
                    )

                    StatCard(
                        icon: "trophy.fill",
                        title: "Best Streak",
                        value: "\(statistics.bestStreak)"
                    )

                    StatCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Completion",
                        value: "\(Int(statistics.completionRate * 100))%"
                    )

                    StatCard(
                        icon: "list.bullet",
                        title: "Today's Habits",
                        value: "\(statistics.totalHabits)"
                    )
                }

                // MARK: Achievements & Milestones

                if !statistics.achievements.isEmpty {
                    SectionHeader(title: "Milestones & Badges")

                    LazyVStack(spacing: AppSpacing.sm) {
                        ForEach(statistics.achievements) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                }

                // MARK: Weekly Trend

                SectionHeader(title: "Weekly Completion")

                CardView {

                    Chart(vm.weekly) { day in

                        LineMark(
                            x: .value("Day", day.date, unit: .day),
                            y: .value(
                                "Completion",
                                day.percentage * 100
                            )
                        )

                        PointMark(
                            x: .value("Day", day.date, unit: .day),
                            y: .value(
                                "Completion",
                                day.percentage * 100
                            )
                        )
                    }
                    .frame(height: 220)
                }

                // MARK: Daily Bar Chart

                SectionHeader(title: "Completed Habits")

                CardView {

                    Chart(vm.weekly) { day in

                        BarMark(
                            x: .value(
                                "Day",
                                day.date,
                                unit: .day
                            ),
                            y: .value(
                                "Completed",
                                day.completed
                            )
                        )
                    }
                    .frame(height: 220)
                }

                // MARK: Habit Distribution

                SectionHeader(title: "Habit Distribution")

                CardView {

                    Chart(vm.habits) { habit in

                        SectorMark(
                            angle: .value(
                                "Completed",
                                habit.completed
                            ),
                            innerRadius: .ratio(0.6)
                        )
                    }
                    .frame(height: 260)

                    Divider()
                        .padding(.vertical)

                    LazyVStack(alignment: .leading) {

                        ForEach(vm.habits) { habit in

                            HStack {

                                Circle()
                                    .frame(width: 10, height: 10)

                                Text(habit.title)

                                Spacer()

                                Text("\(habit.completed)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

            } else {

                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            vm.load()
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = shareImage {
                ShareSheet(items: [image])
            }
        }
    }
    
    @MainActor
    private func renderAndShare(statistics: HabitStatistics) {
        let card = ShareableAchievementCard(
            streak: statistics.currentStreak,
            completedCount: statistics.completedHabits,
            totalCount: statistics.totalHabits,
            completionRate: Int(statistics.completionRate * 100),
            quoteText: "Consistency is what transforms average into excellence."
        )
        let renderer = ImageRenderer(content: card)
        renderer.scale = UIScreen.main.scale
        if let image = renderer.uiImage {
            shareImage = image
            showShareSheet = true
        }
    }
}
