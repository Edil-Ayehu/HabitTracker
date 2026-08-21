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
    
    @StateObject
    private var vm = DIContainer.shared.makeHomeViewModel()
    
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
            
            TodayProgressCard(
                completed: vm.statistics.completedHabits,
                total: vm.statistics.totalHabits
            )
            
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
            
            SectionHeader(title: "Today's Habits")
            
            if vm.entries.isEmpty {
                EmptyStateView(
                    image: "figure.walk",
                    title: "No Habits",
                    subtitle: "Tap + to create your first habit."
                )
            } else {
                LazyVStack(spacing: AppSpacing.md) {
                    
                    ForEach(vm.entries) { entry in
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
        .alert(
            "🎉 Daily Goal Complete!",
            isPresented: $vm.showQuote
        ) {
            Button("Keep Going") {}
        } message: {
            if let quote = vm.quote {
                Text("\"\(quote.text)\"\n\n— \(quote.author)")
            }
        }
        
    }
    
    private var formattedDate: String {
        
        Date.now.formatted(
            date: .complete,
            time: .omitted
        )
        
    }
    
}
