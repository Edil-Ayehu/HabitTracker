//
//  ReflectionManager.swift
//  HabitTracker
//

import Foundation
import SwiftUI
import Combine

final class ReflectionManager: ObservableObject {
    static let shared = ReflectionManager()
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    static var todayISOString: String {
        return dateFormatter.string(from: Date())
    }
    
    @Published var reflectionsMap: [String: NightlyReflection] = [:]
    
    private init() {
        loadReflections()
        NotificationManager.shared.scheduleNightlyReflectionReminder()
    }
    
    private func loadReflections() {
        if let data = UserDefaults.standard.data(forKey: "nightlyReflectionsData"),
           let map = try? JSONDecoder().decode([String: NightlyReflection].self, from: data) {
            self.reflectionsMap = map
        }
    }
    
    private func saveReflections() {
        if let data = try? JSONEncoder().encode(reflectionsMap) {
            UserDefaults.standard.set(data, forKey: "nightlyReflectionsData")
            UserDefaults.standard.synchronize()
        }
    }
    
    var todayReflection: NightlyReflection? {
        reflectionsMap[ReflectionManager.todayISOString]
    }
    
    func saveReflection(mood: MoodRating, journalNote: String, gratitudeNote: String, completionRate: Int) {
        objectWillChange.send()
        let reflection = NightlyReflection(
            dateString: ReflectionManager.todayISOString,
            moodScore: mood.rawValue,
            journalNote: journalNote,
            gratitudeNote: gratitudeNote,
            completionRate: completionRate
        )
        reflectionsMap[ReflectionManager.todayISOString] = reflection
        saveReflections()
        
        _ = QuestManager.shared.addXP(25)
        MascotManager.shared.addGrowthPoints(5)
    }
    
    func fetchRecentReflections(days: Int = 7) -> [NightlyReflection] {
        let calendar = Calendar.current
        var list: [NightlyReflection] = []
        for i in (0..<days).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let str = ReflectionManager.dateFormatter.string(from: date)
                if let ref = reflectionsMap[str] {
                    list.append(ref)
                }
            }
        }
        return list
    }
}
