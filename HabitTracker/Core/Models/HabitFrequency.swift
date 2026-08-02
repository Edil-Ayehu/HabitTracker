//
//  HabitFrequency.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import Foundation

enum HabitFrequency: String, Codable, CaseIterable, Identifiable {

    case daily
    case weekly
    case monthly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .daily: "Daily"
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        }
    }
}
