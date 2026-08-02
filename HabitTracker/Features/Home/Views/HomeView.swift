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
    
    
    @StateObject
    private var vm = DIContainer.shared.makeHomeViewModel()
    
    var body: some View {
        
        AppScaffold {
            
            GreetingHeader(
                greeting: vm.greeting,
                date: formattedDate,
                onAdd: {
                    router.push(.createHabit)
                }
            )
//            .sheet(isPresented: $showCreateHabit) {
//                CreateHabitView(
//                    vm: DIContainer.shared.makeCreateHabitViewModel()
//                )
//            }
//            .onChange(of: showCreateHabit) {
//                oldValue, newValue in
//                
//                if oldValue == true && newValue == false {
//                    vm.load()
//                }
//            }
            
            TodayProgressCard(
                completed: vm.statistics.completedHabits,
                total: vm.statistics.totalHabits
            )
            
            StatsGrid(
                streak: vm.statistics.currentStreak,
                completion: Int(vm.statistics.completionRate * 100)
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
                            }
                        )
                    }
                }
            }
            
            
            
            
            
        }
        .onAppear {
            vm.load()
        }
        
    }
    
    private var formattedDate: String {
        
        Date.now.formatted(
            date: .complete,
            time: .omitted
        )
        
    }
    
}
