//
//  RootView.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct RootView: View {
    @StateObject private var router = AppRouter()
    
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
                        
                    case .habitDetail(let habit):
                        HabitDetailView(
                            vm: DIContainer.shared.makeHabitDetailViewModel(habit: habit)
                        )
                        
                    case .statistics:
                        StatisticsView()
                        
                    case .settings:
                        SettingsView()
                    }
                }
        }
        .environmentObject(router)
        .task {
            await NotificationManager.shared.requestPermission()
            
        }
    }
}
