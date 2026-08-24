//
//  WidgetSharedModels.swift
//  HabitTrackerWidget
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
        UserDefaults(suiteName: appGroupID)
    }
    
    static var sharedFileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent("habit_widget_data.json")
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
