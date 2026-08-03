//
//  Habit.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
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
    
    var habitType: HabitType

    var goal: Int?
    
    var unit: String?

    var frequency: HabitFrequency

    var createdAt: Date

    init(
        title: String,
        icon: HabitIcon,
        color: HabitColor,
        goal: Int?,
        unit: String?,
        habitType: HabitType,
        frequency: HabitFrequency
    ) {

        self.id = UUID()
        self.title = title
        self.icon = icon.rawValue
        self.color = color.rawValue
        self.goal = goal
        self.unit = unit
        self.habitType = habitType
        self.frequency = frequency
        self.createdAt = .now
    }
}


extension Habit {
    var habitColor: HabitColor {
        HabitColor(rawValue: color) ?? .blue
    }
    
    var habitIcon: HabitIcon {
        HabitIcon(rawValue: icon) ?? .water
    }
}
