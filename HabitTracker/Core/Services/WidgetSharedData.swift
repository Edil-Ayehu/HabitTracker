//
//  WidgetSharedData.swift
//  HabitTracker
//

import Foundation
import WidgetKit

struct HabitWidgetEntryItem: Codable, Identifiable {
    let id: String
    let title: String
    let icon: String
    let category: String
    let completed: Bool
    let progress: Int
    let goal: Int
    let isMeasurable: Bool
}

struct HabitWidgetData: Codable {
    let totalHabits: Int
    let completedHabits: Int
    let completionRate: Int
    let currentStreak: Int
    let items: [HabitWidgetEntryItem]
    var isVacationActive: Bool = false
    var vacationReasonEmoji: String = "🏖️"
}

enum WidgetSharedData {
    static let appGroupID = "group.com.myorganization.HabitTracker"
    static let storageKey = "habit_widget_data"
    
    static var sharedUserDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    static var sharedFileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent("habit_widget_data.json")
    }
    
    static func sync(entries: [HabitEntry], statistics: HabitStatistics) {
        let items = entries.map { entry in
            HabitWidgetEntryItem(
                id: entry.habitID.uuidString,
                title: entry.habit.title,
                icon: entry.habit.icon,
                category: entry.habit.habitCategory.title,
                completed: entry.completed,
                progress: entry.progress,
                goal: entry.habit.goal ?? 1,
                isMeasurable: entry.habit.habitType == .measurable
            )
        }
        
        let widgetData = HabitWidgetData(
            totalHabits: statistics.totalHabits,
            completedHabits: statistics.completedHabits,
            completionRate: Int(statistics.completionRate * 100),
            currentStreak: statistics.currentStreak,
            items: items,
            isVacationActive: VacationManager.shared.isVacationActive,
            vacationReasonEmoji: VacationManager.shared.vacationState?.reason.emoji ?? "🏖️"
        )
        
        if let encoded = try? JSONEncoder().encode(widgetData) {
            sharedUserDefaults?.set(encoded, forKey: storageKey)
            UserDefaults.standard.set(encoded, forKey: storageKey)
            if let fileURL = sharedFileURL {
                try? encoded.write(to: fileURL)
            }
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    static func syncVacationState(isVacationActive: Bool, reasonEmoji: String) {
        let currentData = load()
        let updatedData = HabitWidgetData(
            totalHabits: currentData.totalHabits,
            completedHabits: currentData.completedHabits,
            completionRate: currentData.completionRate,
            currentStreak: currentData.currentStreak,
            items: currentData.items,
            isVacationActive: isVacationActive,
            vacationReasonEmoji: reasonEmoji
        )
        
        if let encoded = try? JSONEncoder().encode(updatedData) {
            sharedUserDefaults?.set(encoded, forKey: storageKey)
            UserDefaults.standard.set(encoded, forKey: storageKey)
            if let fileURL = sharedFileURL {
                try? encoded.write(to: fileURL)
            }
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    static func load() -> HabitWidgetData {
        if let data = sharedUserDefaults?.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(HabitWidgetData.self, from: data) {
            return decoded
        }
        
        if let fileURL = sharedFileURL,
           let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode(HabitWidgetData.self, from: data) {
            return decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(HabitWidgetData.self, from: data) {
            return decoded
        }
        
        return HabitWidgetData(
            totalHabits: 0,
            completedHabits: 0,
            completionRate: 0,
            currentStreak: 0,
            items: []
        )
    }
}
