//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI
import SwiftData

@main
struct HabitTrackerApp: App {
    
    let container : ModelContainer
    
    @StateObject private var themeManager = ThemeManager()
    
    init() {
        do {
           
            container = try ModelContainer(
                for: Habit.self, HabitEntry.self
            )
            
            DIContainer.shared.configure(container: container)
            
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    var body: some Scene {
        
        WindowGroup {
            RootView()
                .preferredColorScheme(themeManager.colorScheme)
                .environmentObject(themeManager)
        }
        .modelContainer(container)
    }
}
