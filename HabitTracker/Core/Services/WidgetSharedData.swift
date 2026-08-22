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
}

enum WidgetSharedData {
    static let appGroupID = "group.com.myorganization.HabitTracker"
    static let storageKey = "habit_widget_data"
    
    static var sharedUserDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID) ?? UserDefaults.standard
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
            items: items
        )
        
        if let encoded = try? JSONEncoder().encode(widgetData) {
            sharedUserDefaults?.set(encoded, forKey: storageKey)
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    static func load() -> HabitWidgetData {
        guard let data = sharedUserDefaults?.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(HabitWidgetData.self, from: data) else {
            return HabitWidgetData(
                totalHabits: 3,
                completedHabits: 1,
                completionRate: 33,
                currentStreak: 5,
                items: [
                    HabitWidgetEntryItem(id: "1", title: "Morning Walk", icon: "figure.walk", category: "Fitness", completed: true, progress: 1, goal: 1, isMeasurable: false),
                    HabitWidgetEntryItem(id: "2", title: "Drink Water", icon: "drop.fill", category: "Health", completed: false, progress: 3, goal: 8, isMeasurable: true),
                    HabitWidgetEntryItem(id: "3", title: "Read Book", icon: "book.fill", category: "Mind & Focus", completed: false, progress: 10, goal: 20, isMeasurable: true)
                ]
            )
        }
        return decoded
    }
}
