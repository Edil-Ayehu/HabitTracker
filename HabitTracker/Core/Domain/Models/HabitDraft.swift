//
//  HabitDraft.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import Foundation

struct HabitDraft {

    var title: String = ""

    var goal: Int = 1

    var icon: HabitIcon = .water
    
    var habitType: HabitType = .binary

    var color: HabitColor = .blue
    
    var unit = ""

    var frequency: HabitFrequency = .daily

}
