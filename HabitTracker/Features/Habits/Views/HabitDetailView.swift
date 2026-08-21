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
                
                if !vm.canComplete {

                    CardView {

                        VStack(alignment: .leading, spacing: 16) {

                            Text("Today's Reflection")
                                .font(AppFont.headline())

                            if vm.isEditingNote {

                                TextEditor(text: $vm.note)
                                    .frame(height: 120)

                                PrimaryButton(title: "Save Note") {
                                    vm.saveNote()
                                }

                            } else {

                                Text(vm.note)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(.gray.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                Button("Edit Note") {
                                    vm.isEditingNote = true
                                }
                            }
                        }
                    }
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
                
                
                ForEach(vm.entries) { entry in

                    VStack(alignment: .leading, spacing: 6) {

                        HStack {

                            Text(
                                entry.date.formatted(
                                    date: .abbreviated,
                                    time: .omitted
                                )
                            )

                            Spacer()

                            Image(
                                systemName: entry.completed
                                ? "checkmark.circle.fill"
                                : "circle"
                            )
                        }

                        if !entry.note.isEmpty {

                            Text(entry.note)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
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
                if vm.deleteHabit() {
                    router.pop()
                }
            }
            
            Button("Cancel", role: .cancel) {
                
            }
        } message: {
            Text("Are you sure you want to delete '\(vm.title)'? This will remove all tracked progress for this habit.")
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { if !$0 { vm.errorMessage = nil } }
            )
        ) {
            Button("OK") {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}
