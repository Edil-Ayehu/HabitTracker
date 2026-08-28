//
//  RootView.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct RootView: View {
    @StateObject private var router = AppRouter()
    
    @StateObject private var vm = AppViewModel(habitUseCase: DIContainer.shared.makeHabitUseCase())
    
    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .home:
                        HomeView()
                        
                    case .createHabit:
                        CreateHabitView(
                            vm: DIContainer.shared.makeCreateHabitViewModel()
                        )
                        
                    case .editHabit(let habit):
                        CreateHabitView(
                            vm: DIContainer.shared.makeEditHabitViewModel(habit: habit)
                        )
                        
                    case .habitDetail(let habit):
                        HabitDetailView(
                            vm: DIContainer.shared.makeHabitDetailViewModel(habit: habit)
                        )
                        
                    case .statistics:
                        StatisticsView(
                            vm: DIContainer.shared.makeStatisticsViewModel()
                        )
                        
                    case .settings:
                        SettingsView()
                        
                    case .notification:
                        NotificationSettingsView()
                        
                    case .aiRoutineGenerator:
                        AIRoutineGeneratorView(
                            vm: DIContainer.shared.makeAIRoutineGeneratorViewModel()
                        )
                        
                    case .widgetPreview:
                        WidgetPreviewView()
                        
                    case .reflectionJournal:
                        ReflectionJournalView()
                    }
                }
        }
        .environmentObject(router)
        .task {
            await NotificationManager.shared.requestPermission()
            
            
            await vm.start()
            
        }
    }
}
