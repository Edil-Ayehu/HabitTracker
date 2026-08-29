//
//  HomeView.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct HomeView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var showCreateHabit = false
    
    @EnvironmentObject private var router: AppRouter
    
    
    @State private var habitToDelete: Habit?
    @State private var showDeleteConfirmation = false
    
    @State private var shareItem: IdentifiableImage?
    @State private var showChallengesSheet = false
    
    @StateObject
    private var vm = DIContainer.shared.makeHomeViewModel()
    @StateObject private var vacationManager = VacationManager.shared
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showOnboardingSheet: Bool = false
    
    var body: some View {
        
        AppScaffold {
            
            GreetingHeader(
                greeting: vm.greeting,
                date: formattedDate,
                onAdd: {
                    router.push(.createHabit)
                },
                onAIGenerator: {
                    router.push(.aiRoutineGenerator)
                },
                navigateToSetting: {
                    router.push(.settings)
                }
            )
            
            LevelProgressCard(
                profile: vm.userProfile,
                quests: vm.dailyQuests,
                onClaimQuest: { quest in
                    vm.claimQuest(quest)
                }
            )
            
            // MARK: 30-Day Challenges Banner
            Button {
                showChallengesSheet = true
            } label: {
                CardView {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 42, height: 42)
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text("30-Day Challenges & Bootcamps")
                                    .font(AppFont.headline())
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            
                            Text("Enroll in 30-day bootcamps & earn +500 XP trophies")
                                .font(AppFont.caption())
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showChallengesSheet) {
                ChallengesView()
            }
            
            // MARK: Nightly Reflection Card
            ReflectionPromptCard(completionRate: Int(vm.statistics.completionRate * 100))
            
            // MARK: Vacation & Rest Days Banner
            VacationBannerCard()
            
            if !vacationManager.isVacationActive {
                TodayProgressCard(
                    completed: vm.statistics.completedHabits,
                    total: vm.statistics.totalHabits
                )
            }
            
            StatsGrid(
                streak: vm.statistics.currentStreak,
                bestStreak: vm.statistics.bestStreak,
                completion: Int(vm.statistics.completionRate * 100)
            )
            
            HomeBadgesSection(
                achievements: vm.statistics.achievements,
                onSeeAll: {
                    router.push(.statistics)
                }
            )
            
            // MARK: Time of Day Filter Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    let allOption = TimeFilterOption.all
                    let isAllSelected = vm.selectedTimeFilter == allOption
                    Button {
                        vm.selectedTimeFilter = allOption
                        AudioManager.shared.playClickSound()
                    } label: {
                        HStack(spacing: 4) {
                            Text("All Habits 📋")
                                .font(AppFont.caption())
                                .fontWeight(isAllSelected ? .bold : .medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isAllSelected ? AppColors.primary.opacity(0.18) : AppColors.card)
                        .foregroundStyle(isAllSelected ? AppColors.primary : AppColors.textSecondary)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(isAllSelected ? AppColors.primary : Color.clear, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    ForEach(TimeOfDay.allCases.filter { $0 != .anyTime }) { time in
                        let option = TimeFilterOption.timeOfDay(time)
                        let isSelected = vm.selectedTimeFilter == option
                        Button {
                            vm.selectedTimeFilter = option
                            AudioManager.shared.playClickSound()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: time.icon)
                                    .font(.system(size: 11))
                                Text(time.title)
                                    .font(AppFont.caption())
                                    .fontWeight(isSelected ? .bold : .medium)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isSelected ? time.themeColor.opacity(0.18) : AppColors.card)
                            .foregroundStyle(isSelected ? time.themeColor : AppColors.textSecondary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(isSelected ? time.themeColor : Color.clear, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            SectionHeader(title: "Today's Habits")
            
            if !vm.entries.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button {
                            vm.selectedCategoryFilter = nil
                        } label: {
                            Text("All (\(vm.entries.count))")
                                .font(AppFont.caption())
                                .fontWeight(vm.selectedCategoryFilter == nil ? .bold : .medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(vm.selectedCategoryFilter == nil ? AppColors.primary.opacity(0.18) : Color.gray.opacity(0.1))
                                .foregroundStyle(vm.selectedCategoryFilter == nil ? AppColors.primary : AppColors.textSecondary)
                                .clipShape(Capsule())
                        }
                        
                        ForEach(HabitCategory.allCases) { category in
                            let isSelected = vm.selectedCategoryFilter == category
                            let count = vm.entries.filter { $0.habit.habitCategory == category }.count
                            
                            Button {
                                vm.selectedCategoryFilter = isSelected ? nil : category
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: category.icon)
                                    Text("\(category.title) (\(count))")
                                }
                                .font(AppFont.caption())
                                .fontWeight(isSelected ? .bold : .medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isSelected ? category.color.opacity(0.18) : Color.gray.opacity(0.1))
                                .foregroundStyle(isSelected ? category.color : AppColors.textSecondary)
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            
            if vm.filteredEntries.isEmpty {
                EmptyStateView(
                    image: "figure.walk",
                    title: vm.selectedCategoryFilter == nil ? "No Habits" : "No \(vm.selectedCategoryFilter?.title ?? "") Habits",
                    subtitle: vm.selectedCategoryFilter == nil ? "Tap + to create your first habit." : "No habits in this category for today."
                )
            } else {
                LazyVStack(spacing: AppSpacing.md) {
                    
                    ForEach(vm.filteredEntries) { entry in
                        HabitRow(
                            entry: entry,
                            onIncrement: {
                                vm.increment(entry)
                            },
                            onComplete: {
                                vm.complete(entry)
                            },
                            onTap: {
                                router.push(.habitDetail(entry.habit))
                            }
                        )
                        .contextMenu {
                            Button {
                                router.push(.editHabit(entry.habit))
                            } label: {
                                Label("Edit Habit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                habitToDelete = entry.habit
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete Habit", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            
        }
        .onAppear {
            vm.load()
        }
        .confirmationDialog(
            "Delete Habit?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let habit = habitToDelete {
                    vm.deleteHabit(habit)
                    habitToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) {
                habitToDelete = nil
            }
        } message: {
            if let habit = habitToDelete {
                Text("Are you sure you want to delete '\(habit.title)'? This will remove all recorded entries for this habit.")
            }
        }
        .overlay {
            if vm.showConfetti {
                ConfettiView()
            }
        }
        .overlay {
            if vm.showCelebrationBanner {
                ZStack {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation { vm.showCelebrationBanner = false }
                        }
                    
                    CelebrationBanner(
                        title: "🎉 All Habits Completed!",
                        subtitle: "Fantastic work! You've completed 100% of your daily habits for today.",
                        quoteText: vm.quote?.text,
                        quoteAuthor: vm.quote?.author,
                        onShare: {
                            renderAndShareCelebration()
                        }
                    ) {
                        withAnimation { vm.showCelebrationBanner = false }
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .overlay {
            if vm.showLevelUpBanner {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation { vm.showLevelUpBanner = false }
                        }
                    
                    LevelUpBanner(profile: vm.userProfile) {
                        withAnimation { vm.showLevelUpBanner = false }
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.image])
        }
        .onAppear {
            if !hasCompletedOnboarding {
                showOnboardingSheet = true
            }
        }
        .fullScreenCover(isPresented: $showOnboardingSheet) {
            OnboardingView()
        }
        
    }
    
    @MainActor
    private func renderAndShareCelebration() {
        let card = ShareableAchievementCard(
            streak: vm.statistics.currentStreak,
            completedCount: vm.statistics.completedHabits,
            totalCount: vm.statistics.totalHabits,
            completionRate: Int(vm.statistics.completionRate * 100),
            quoteText: vm.quote?.text
        )
        let renderer = ImageRenderer(content: card)
        renderer.scale = UIScreen.main.scale
        if let image = renderer.uiImage {
            self.shareItem = IdentifiableImage(image: image)
        }
    }
    
    private var formattedDate: String {
        
        Date.now.formatted(
            date: .complete,
            time: .omitted
        )
        
    }
    
}
