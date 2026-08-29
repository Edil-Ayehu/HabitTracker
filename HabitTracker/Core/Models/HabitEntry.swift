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
    
    var note: String
    
    @Attribute(.externalStorage)
    var imageData: Data?
    
    var isFrozen: Bool
    
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
        
        note = ""
        imageData = nil
        isFrozen = false
    }
    
    var completedSubTaskIDsJSON: String?
    
    var completedSubTaskIDs: Set<UUID> {
        get {
            guard let data = completedSubTaskIDsJSON?.data(using: .utf8),
                  let ids = try? JSONDecoder().decode(Set<UUID>.self, from: data) else {
                return []
            }
            return ids
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let json = String(data: data, encoding: .utf8) {
                completedSubTaskIDsJSON = json
            } else {
                completedSubTaskIDsJSON = nil
            }
        }
    }
}
