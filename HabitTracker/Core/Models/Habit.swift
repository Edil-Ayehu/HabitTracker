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

    var goal: Int

    var progress: Int

    var frequency: HabitFrequency

    var isCompleted: Bool

    var createdAt: Date

    init(
        title: String,
        icon: HabitIcon,
        color: HabitColor,
        goal: Int,
        frequency: HabitFrequency
    ) {

        self.id = UUID()
        self.title = title
        self.icon = icon.rawValue
        self.color = color.rawValue
        self.goal = goal
        self.progress = 0
        self.frequency = frequency
        self.isCompleted = false
        self.createdAt = .now
    }
}


extension Habit {
    var habitColor: HabitColor {
        HabitColor(rawValue: color) ?? .blue
    }
    
    var habitIcon: HabitIcon {
        HabitIcon(rawValue: color) ?? .water
    }
}
