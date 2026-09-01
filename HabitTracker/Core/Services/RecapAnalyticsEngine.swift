//
//  RecapAnalyticsEngine.swift
//  HabitTracker
//

import Foundation

enum RecapPeriod: String, Hashable, Codable {
    case weekly = "Weekly"
    case monthly = "Monthly"
}

struct StoryRecapData: Identifiable {
    let id = UUID()
    let period: RecapPeriod
    let title: String
    let dateRangeString: String
    let totalCheckIns: Int
    let completionRate: Int
    let championHabitTitle: String?
    let championHabitIcon: String?
    let championHabitCount: Int
    let peakDayName: String
    let peakDayCount: Int
    let dominantMoodEmoji: String
    let dominantMoodTitle: String
    let xpEarned: Int
}

@MainActor
final class RecapAnalyticsEngine {
    static let shared = RecapAnalyticsEngine()
    private init() {}
    
    func generateRecap(
        period: RecapPeriod,
        habits: [Habit],
        entries: [HabitEntry],
        reflections: [NightlyReflection]
    ) -> StoryRecapData {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let startDate: Date
        let endDate: Date
        let dateRangeStr: String
        
        if period == .weekly {
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) ?? DateInterval(start: today.addingTimeInterval(-7*86400), duration: 7*86400)
            startDate = weekInterval.start
            endDate = weekInterval.end
            let endOfWeek = calendar.date(byAdding: .day, value: -1, to: weekInterval.end) ?? today
            let startStr = startDate.formatted(.dateTime.month(.abbreviated).day())
            let endStr = endOfWeek.formatted(.dateTime.month(.abbreviated).day().year())
            dateRangeStr = "\(startStr) – \(endStr)"
        } else {
            let monthInterval = calendar.dateInterval(of: .month, for: today) ?? DateInterval(start: today.addingTimeInterval(-30*86400), duration: 30*86400)
            startDate = monthInterval.start
            endDate = monthInterval.end
            dateRangeStr = today.formatted(.dateTime.month(.wide).year())
        }
        
        let periodEntries = entries.filter { $0.date >= startDate && $0.date < endDate }
        let completedEntries = periodEntries.filter { $0.completed }
        let totalCheckIns = completedEntries.count
        
        let totalPossible = max(1, periodEntries.count)
        let rate = Int((Double(totalCheckIns) / Double(totalPossible)) * 100.0)
        
        // Champion Habit
        var habitCounts: [UUID: Int] = [:]
        for entry in completedEntries {
            habitCounts[entry.habitID, default: 0] += 1
        }
        let championHabitID = habitCounts.max(by: { $0.value < $1.value })?.key
        let championHabit = habits.first(where: { $0.id == championHabitID }) ?? completedEntries.first?.habit
        let championCount = habitCounts[championHabitID ?? UUID()] ?? (championHabit != nil ? 1 : 0)
        
        // Peak Day
        var dayCounts: [Int: Int] = [:]
        let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        for entry in completedEntries {
            let weekday = calendar.component(.weekday, from: entry.date)
            dayCounts[weekday, default: 0] += 1
        }
        let peakDayComponent = dayCounts.max(by: { $0.value < $1.value })?.key ?? calendar.component(.weekday, from: today)
        let peakDayName = dayNames[(peakDayComponent - 1) % 7]
        let peakDayCount = dayCounts[peakDayComponent] ?? 0
        
        // Dominant Mood
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let periodReflections = reflections.filter { ref in
            if let date = dateFormatter.date(from: ref.dateString) {
                return date >= startDate && date < endDate
            }
            return false
        }
        var moodCounts: [String: Int] = [:]
        for ref in periodReflections {
            moodCounts[ref.mood.emoji, default: 0] += 1
        }
        let dominantEmoji = moodCounts.max(by: { $0.value < $1.value })?.key ?? "🙂"
        let moodTitle = moodTitleForEmoji(dominantEmoji)
        
        let xpEarned = totalCheckIns * 25 + (periodReflections.count * 15)
        
        return StoryRecapData(
            period: period,
            title: period == .weekly ? "Weekly Story Recap" : "Monthly Story Recap",
            dateRangeString: dateRangeStr,
            totalCheckIns: totalCheckIns,
            completionRate: rate,
            championHabitTitle: championHabit?.title ?? "Daily Consistency",
            championHabitIcon: championHabit?.icon ?? "star.fill",
            championHabitCount: championCount,
            peakDayName: peakDayName,
            peakDayCount: peakDayCount,
            dominantMoodEmoji: dominantEmoji,
            dominantMoodTitle: moodTitle,
            xpEarned: xpEarned
        )
    }
    
    private func moodTitleForEmoji(_ emoji: String) -> String {
        switch emoji {
        case "🤩": return "Ecstatic & Energized"
        case "🙂": return "Happy & Satisfied"
        case "😐": return "Calm & Neutral"
        case "😔": return "Reflective"
        case "😫": return "Challenging"
        default: return "Balanced"
        }
    }
}
