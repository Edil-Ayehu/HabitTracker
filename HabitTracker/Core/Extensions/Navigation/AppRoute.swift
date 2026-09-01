//
//  AppRoute.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

enum AppRoute: Hashable {
    case home
    case createHabit
    case editHabit(Habit)
    case habitDetail(Habit)
    case statistics
    case settings
    case notification
    case aiRoutineGenerator
    case widgetPreview
    case reflectionJournal
    case archivedHabits
    case storyRecap(RecapPeriod)
    case squads
}
