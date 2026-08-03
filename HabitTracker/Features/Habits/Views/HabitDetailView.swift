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
                        .foregroundStyle(.green)
                        .font(AppFont.headline())
                }
                
                
            }
            
            
            
            StatCard(
                icon: vm.icon.rawValue,
                
                title:"Current Streak",
                
                
                value: vm.streak == 1 ? "1 day" :
                    "\(vm.streak) days"
            )
            
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
        
    }
}
