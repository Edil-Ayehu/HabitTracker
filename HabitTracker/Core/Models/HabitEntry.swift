//
//  HabitEntry.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import Foundation
import SwiftData

@Model
final class HabitEntry {
    
    @Attribute(.unique)
    var id: UUID
    
    var habitID: UUID
    
    var date: Date
    
    var progress: Int
    
    var completed: Bool
    
    @Relationship(deleteRule: .cascade)
    var habit: Habit
    
    init(
        habit: Habit,
        date: Date = .now
    ) {
        
        id = UUID()
        self.habitID = habit.id
        
        self.habit = habit
        
        self.date = Calendar.current.startOfDay(for: date)
        
        progress = 0
        
        completed = false
    }
}
