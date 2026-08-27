//
//  VacationMode.swift
//  HabitTracker
//

import Foundation
import SwiftUI

enum VacationReason: String, CaseIterable, Codable, Identifiable {
    case vacation = "Vacation 🏖️"
    case sickLeave = "Sick Leave 🤒"
    case restDay = "Rest Day 🛌"
    case travel = "Travel ✈️"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .vacation: return "🏖️"
        case .sickLeave: return "🤒"
        case .restDay: return "🛌"
        case .travel: return "✈️"
        }
    }
    
    var title: String {
        switch self {
        case .vacation: return "Vacation"
        case .sickLeave: return "Sick Leave"
        case .restDay: return "Rest Day"
        case .travel: return "Travel"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .vacation: return .orange
        case .sickLeave: return .mint
        case .restDay: return .purple
        case .travel: return .cyan
        }
    }
}

struct VacationMode: Codable {
    var isActive: Bool
    var startDate: Date
    var endDate: Date
    var reason: VacationReason
    var note: String
}
