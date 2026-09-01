//
//  StatisticsView.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI
import Charts

struct StatisticsView: View {

    @EnvironmentObject private var router: AppRouter
    
    @StateObject
    var vm: StatisticsViewModel
    
    @State private var shareItem: IdentifiableImage?

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
                
                // MARK: Story Recap Banners
                HStack(spacing: 12) {
                    Button {
                        router.push(.storyRecap(.weekly))
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.rectangle.fill")
                            Text("Weekly Recap 📊")
                                .fontWeight(.bold)
                        }
                        .font(AppFont.caption())
                        .foregroundStyle(Color.purple)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.purple.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        router.push(.storyRecap(.monthly))
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar.badge.clock")
                            Text("Monthly Recap 🗓️")
                                .fontWeight(.bold)
                        }
                        .font(AppFont.caption())
                        .foregroundStyle(Color.indigo)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.indigo.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }

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

                // MARK: Day of Week Analytics & Insights
                if let insights = vm.analyticsInsights {
                    DayOfWeekChartCard(insights: insights)
                    
                    if !insights.tips.isEmpty {
                        SmartInsightsCard(tips: insights.tips)
                    }
                }
                
                // MARK: Mood & Happiness Analytics
                MoodAnalyticsCard()

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

                // MARK: Category Life Balance

                if !vm.categoryBalance.isEmpty {
                    SectionHeader(title: "Category Life Balance")

                    CardView {
                        Chart(vm.categoryBalance) { item in
                            SectorMark(
                                angle: .value("Habits", item.habitCount),
                                innerRadius: .ratio(0.65),
                                angularInset: 2.0
                            )
                            .foregroundStyle(item.category.color)
                            .cornerRadius(5)
                        }
                        .frame(height: 220)

                        Divider()
                            .padding(.vertical, 8)

                        LazyVStack(spacing: 10) {
                            ForEach(vm.categoryBalance) { item in
                                HStack {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(item.category.color)
                                            .frame(width: 10, height: 10)
                                        
                                        Image(systemName: item.category.icon)
                                            .font(.system(size: 12))
                                            .foregroundStyle(item.category.color)
                                        
                                        Text(item.category.title)
                                            .font(AppFont.body())
                                            .fontWeight(.semibold)
                                    }

                                    Spacer()

                                    Text("\(item.habitCount) habit\(item.habitCount == 1 ? "" : "s") (\(item.percentage)%)")
                                        .font(AppFont.caption())
                                        .foregroundStyle(AppColors.textSecondary)
                                }
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
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.image])
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
            self.shareItem = IdentifiableImage(image: image)
        }
    }
}
