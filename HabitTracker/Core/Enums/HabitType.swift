//
//  HabitType.swift
//  HabitTracker
//
//  Created by Edil on 03/08/2026.
//

enum HabitType: String, Codable, CaseIterable, Identifiable {
    case binary
    case measurable
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .binary:
            return "Simple"
        case .measurable:
            return "Measurable"
        }
    }
}
