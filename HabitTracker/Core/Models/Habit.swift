//
//  Habit.swift
//  HabitTracker
//

import Foundation
import SwiftData

@Model
final class Habit {

    @Attribute(.unique)
    var id: UUID

    var title: String

    var icon: String

    var color: String
    
    var categoryRaw: String = HabitCategory.health.rawValue
    
    var timeOfDayRaw: String = TimeOfDay.anyTime.rawValue
    
    var habitType: HabitType

    var goal: Int?
    
    var unit: String?

    var frequency: HabitFrequency

    var createdAt: Date
    
    // Reminder
    var reminderEnabled: Bool
    
    var reminderHour: Int?
    
    var reminderMinute: Int?
    
    var subTasksJSON: String?
    
    var isArchived: Bool = false

    init(
        title: String,
        icon: HabitIcon,
        color: HabitColor,
        category: HabitCategory = .health,
        timeOfDay: TimeOfDay = .anyTime,
        goal: Int?,
        unit: String?,
        habitType: HabitType,
        frequency: HabitFrequency,
        reminderEnabled: Bool = false,
        reminderHour: Int? = nil,
        reminderMinute: Int? = nil
    ) {

        self.id = UUID()
        self.title = title
        self.icon = icon.rawValue
        self.color = color.rawValue
        self.categoryRaw = category.rawValue
        self.timeOfDayRaw = timeOfDay.rawValue
        self.goal = goal
        self.unit = unit
        self.habitType = habitType
        self.frequency = frequency
        self.createdAt = .now
        
        self.reminderEnabled = reminderEnabled
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
        self.subTasksJSON = nil
        self.isArchived = false
    }
}


extension Habit {
    var habitColor: HabitColor {
        HabitColor(rawValue: color) ?? .blue
    }
    
    var habitIcon: HabitIcon {
        HabitIcon(rawValue: icon) ?? .water
    }
    
    var habitCategory: HabitCategory {
        get { HabitCategory(rawValue: categoryRaw) ?? .health }
        set { categoryRaw = newValue.rawValue }
    }
    
    var habitTimeOfDay: TimeOfDay {
        get { TimeOfDay(rawValue: timeOfDayRaw) ?? .anyTime }
        set { timeOfDayRaw = newValue.rawValue }
    }
    
    var subTasks: [SubTask] {
        get {
            guard let data = subTasksJSON?.data(using: .utf8),
                  let tasks = try? JSONDecoder().decode([SubTask].self, from: data) else {
                return []
            }
            return tasks
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let json = String(data: data, encoding: .utf8) {
                subTasksJSON = json
            } else {
                subTasksJSON = nil
            }
        }
    }
}
