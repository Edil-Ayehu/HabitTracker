//
//  HabitRepositoryImpl.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import Foundation
import SwiftData

final class HabitRepositoryImpl: HabitRepository {
    
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func fetchHabits() throws -> [Habit] {
        
        try context.fetch(FetchDescriptor<Habit>())
        
    }
    
    func save(_ habit: Habit) throws {
        
        context.insert(habit)
        
        try context.save()
    }
    
    func delete(_ habit: Habit) throws {
        
        context.delete(habit)
        
        try context.save()
    }
    
    func update() throws {
        
        try context.save()
        
    }
    
    
}
