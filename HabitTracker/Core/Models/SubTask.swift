//
//  SubTask.swift
//  HabitTracker
//

import Foundation

struct SubTask: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var title: String
    
    init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }
}
