//
//  HabitAnalyticsEngine.swift
//  HabitTracker
//

import Foundation

struct WeekdayStat: Identifiable {
    let id = UUID()
    let dayName: String // Mon, Tue, Wed...
    let weekdayIndex: Int // 1=Sun, 2=Mon...
    let totalEntries: Int
    let completedCount: Int
    
    var completionRate: Int {
        guard totalEntries > 0 else { return 0 }
        return Int((Double(completedCount) / Double(totalEntries)) * 100.0)
    }
}

struct AnalyticsInsights {
    let weekdayStats: [WeekdayStat]
    let bestDay: WeekdayStat?
    let weakestDay: WeekdayStat?
    let grade: String
    let gradeColorName: String
    let tips: [String]
}

final class HabitAnalyticsEngine {
    static let shared = HabitAnalyticsEngine()
    
    private init() {}
    
    func analyze(entries: [HabitEntry]) -> AnalyticsInsights {
        let calendar = Calendar.current
        let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        
        // Map entries by weekday (1=Sun, 2=Mon... 7=Sat)
        var totalByDay = [Int: Int]()
        var completedByDay = [Int: Int]()
        
        for entry in entries {
            let weekday = calendar.component(.weekday, from: entry.date)
            totalByDay[weekday, default: 0] += 1
            if entry.completed || entry.isFrozen {
                completedByDay[weekday, default: 0] += 1
            }
        }
        
        // Mon (2) ... Sun (1)
        let weekdayOrder = [2, 3, 4, 5, 6, 7, 1]
        var stats: [WeekdayStat] = []
        
        for (idx, weekday) in weekdayOrder.enumerated() {
            let total = totalByDay[weekday, default: 0]
            let completed = completedByDay[weekday, default: 0]
            stats.append(
                WeekdayStat(
                    dayName: dayNames[idx],
                    weekdayIndex: weekday,
                    totalEntries: total,
                    completedCount: completed
                )
            )
        }
        
        let validStats = stats.filter { $0.totalEntries > 0 }
        let bestDay = validStats.max(by: { $0.completionRate < $1.completionRate })
        let weakestDay = validStats.min(by: { $0.completionRate < $1.completionRate })
        
        let overallCompleted = entries.filter { $0.completed || $0.isFrozen }.count
        let overallTotal = max(1, entries.count)
        let overallRate = Int((Double(overallCompleted) / Double(overallTotal)) * 100.0)
        
        let grade: String
        if overallRate >= 90 {
            grade = "S-Tier 🏆 (Master)"
        } else if overallRate >= 80 {
            grade = "A-Tier ⭐ (Excellent)"
        } else if overallRate >= 70 {
            grade = "B-Tier ⚡️ (Consistent)"
        } else if overallRate >= 50 {
            grade = "C-Tier 💪 (Building)"
        } else {
            grade = "D-Tier 🌱 (Starter)"
        }
        
        var tips: [String] = []
        if let best = bestDay, best.completionRate > 0 {
            tips.append("🔥 \(best.dayName) is your highest performing day (\(best.completionRate)% completion)!")
        }
        
        if let weakest = weakestDay, weakest.completionRate < 60, weakest.totalEntries > 0 {
            tips.append("💡 \(weakest.dayName) is your lowest activity day (\(weakest.completionRate)%). Consider setting extra reminders for \(weakest.dayName).")
        } else {
            tips.append("🎯 Great balance across the week! Keep your daily streak going.")
        }
        
        let weekendTotal = (totalByDay[7] ?? 0) + (totalByDay[1] ?? 0)
        let weekendCompleted = (completedByDay[7] ?? 0) + (completedByDay[1] ?? 0)
        if weekendTotal > 0 {
            let weekendRate = Int((Double(weekendCompleted) / Double(weekendTotal)) * 100.0)
            if weekendRate < 50 {
                tips.append("🏖️ Weekend slump detected (\(weekendRate)% completion on Sat/Sun). Try using Habit Freeze Tokens if taking rest days!")
            } else {
                tips.append("🌟 Strong weekend consistency (\(weekendRate)% completion)!")
            }
        }
        
        return AnalyticsInsights(
            weekdayStats: stats,
            bestDay: bestDay,
            weakestDay: weakestDay,
            grade: grade,
            gradeColorName: overallRate >= 80 ? "green" : (overallRate >= 60 ? "indigo" : "orange"),
            tips: tips
        )
    }
}
