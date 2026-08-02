//
//  HomeView.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct HomeView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    
    @StateObject
    private var vm = DIContainer.shared.makeHomeViewModel()
    
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
            
            if vm.habits.isEmpty {
                EmptyStateView(
                    image: "figure.walk",
                    title: "No Habits",
                    subtitle: "Tap + to create your first habit."
                )
            } else {
                LazyVStack(spacing: AppSpacing.md) {
                    
                    ForEach(vm.habits) { habit in
                        HabitRow(
                            habit: habit,
                            onIncrement: {
                                vm.increment(habit)
                            },
                            onComplete: {
                                vm.complete(habit)
                            }
                        )
                    }
                }
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
