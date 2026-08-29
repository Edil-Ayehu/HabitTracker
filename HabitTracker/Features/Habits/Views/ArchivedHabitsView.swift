//
//  ArchivedHabitsView.swift
//  HabitTracker
//

import SwiftUI

struct ArchivedHabitsView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var archivedHabits: [Habit] = []
    @State private var isLoading = true
    
    private let habitUseCase = DIContainer.shared.makeHabitUseCase()

    var body: some View {
        AppScaffold(title: "Archived Habits") {
            VStack(alignment: .leading, spacing: 16) {
                
                HStack(spacing: 8) {
                    Image(systemName: "archivebox.fill")
                        .font(.title3)
                        .foregroundStyle(Color.orange)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Seasonal & Paused Habits")
                            .font(AppFont.headline())
                        Text("Archived habits retain all past streak statistics and notes.")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .padding(12)
                .background(Color.orange.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                } else if archivedHabits.isEmpty {
                    EmptyStateView(
                        image: "archivebox",
                        title: "No Archived Habits",
                        subtitle: "Habits you archive will appear here until you choose to unarchive them."
                    )
                    .padding(.top, 40)
                } else {
                    LazyVStack(spacing: AppSpacing.md) {
                        ForEach(archivedHabits) { habit in
                            CardView {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(habit.habitColor.color.opacity(0.18))
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: habit.icon)
                                            .font(.title3)
                                            .foregroundStyle(habit.habitColor.color)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(habit.title)
                                            .font(AppFont.headline())
                                            .foregroundStyle(AppColors.textPrimary)
                                        
                                        HStack(spacing: 6) {
                                            Text(habit.habitCategory.title)
                                                .font(.system(size: 10, weight: .semibold))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(habit.habitCategory.color.opacity(0.12))
                                                .foregroundStyle(habit.habitCategory.color)
                                                .clipShape(Capsule())
                                            
                                            Text(habit.frequency.title)
                                                .font(.system(size: 10, weight: .bold))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.purple.opacity(0.15))
                                                .foregroundStyle(Color.purple)
                                                .clipShape(Capsule())
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        unarchive(habit)
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.uturn.backward.circle.fill")
                                            Text("Restore")
                                        }
                                        .font(AppFont.caption())
                                        .fontWeight(.bold)
                                        .foregroundStyle(AppColors.primary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(AppColors.primary.opacity(0.12))
                                        .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            loadArchived()
        }
    }
    
    private func loadArchived() {
        do {
            archivedHabits = try habitUseCase.fetchArchivedHabits()
        } catch {
            archivedHabits = []
        }
        isLoading = false
    }
    
    private func unarchive(_ habit: Habit) {
        do {
            try habitUseCase.unarchiveHabit(habit)
            loadArchived()
            AudioManager.shared.playClickSound()
        } catch {
            
        }
    }
}
