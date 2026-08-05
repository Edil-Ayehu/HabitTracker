//
//  HabitDetailView.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import SwiftUI

struct HabitDetailView: View {
    
    
    @StateObject
    var vm: HabitDetailViewModel
    
    @EnvironmentObject private var router: AppRouter
    
    @State private var showDeleteDialog: Bool = false
    
    
    
    var body: some View {
        
        
        AppScaffold(
            title: vm.title
        ) {
            
            
            
            VStack(spacing: 20) {
                
                HabitProgressRing(
                    current: vm.progress,
                    goal: vm.goal
                )
                .frame(width: 160)
                
                if vm.isMeasurable {
                    HStack(spacing: 20) {
                        
                        AppIconButton(systemImage: "minus") {
                            vm.decrement()
                        }
                        .disabled(!vm.canDecrement)
                        
                        Text("\(vm.progress) / \(vm.goal)")
                            .font(AppFont.title())
                        
                        AppIconButton(systemImage: "plus") {
                            vm.increment()
                        }
                        .disabled(!vm.canIncrement)
                        
                    }
                }
                
                if vm.canComplete {
                    PrimaryButton(
                        title: vm.isBinary ? "Complete Habit" : "Mark Complete"
                    ) {
                        vm.complete()
                    }
                } else {
                    Label("Completed Today", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(AppColors.success)
                        .font(AppFont.headline())
                }
                
                
            }
            
            
            
            StatCard(
                icon: vm.icon.rawValue,
                
                title:"Current Streak",
                
                
                value: vm.streak == 1 ? "1 day" :
                    "\(vm.streak) days"
            )
            
            ReminderSection(
                enabled: vm.reminderEnabled,
                time: vm.reminderTime
            ) { enabled, time in

                vm.updateReminder(
                    enabled: enabled,
                    time: time
                )

            }
            
            HabitCalendarView(
                entries: vm.entries
            )
            
            
            
            SectionHeader(
                title:"History"
            )
            
            
            
            LazyVStack {
                
                
                ForEach(
                    vm.entries
                ) { entry in
                    
                    
                    HStack {
                        
                        
                        Text(
                            entry.date.formatted(
                                date:.abbreviated,
                                time:.omitted
                            )
                        )
                        
                        
                        Spacer()
                        
                        
                        
                        Image(
                            systemName:
                                entry.completed
                            ?
                            "checkmark.circle.fill"
                            :
                                "circle"
                        )
                        
                    }
                    
                }
                
            }
            
            
        }
        .onAppear {
            
            vm.load()
            
        }
        
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Edit") {
                        router.push(.editHabit(vm.habit))
                    }
                    
                    Button("Delete", role: .destructive) {
                        showDeleteDialog = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        
        .confirmationDialog("Delete habit?", isPresented: $showDeleteDialog) {
            Button("Delete", role: .destructive) {
//                do {
//                    try vm.deleteHabit()
//                    
//                    router.pop()
//                    
//                } catch {
//                    
//                    print(error)
//                    
//                }
            }
            
            Button("Cancel", role: .cancel) {
                
            }
        }
        
    }
}
