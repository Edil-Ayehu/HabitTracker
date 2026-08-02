//
//  HabitColor.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import SwiftUI

enum HabitColor: String, Codable, CaseIterable {

    case blue
    case green
    case orange
    case purple
    case red

    var color: Color {
        switch self {
        case .blue:
            .blue

        case .green:
            .green

        case .orange:
            .orange

        case .purple:
            .purple

        case .red:
            .red
        }
    }
}
