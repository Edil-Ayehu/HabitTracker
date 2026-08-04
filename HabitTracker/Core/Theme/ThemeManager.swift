//
//  ThemeManager.swift
//  HabitTracker
//
//  Created by Edil on 04/08/2026.
//

import SwiftUI

@MainActor
final class ThemeManager: ObservableObject {

    @AppStorage("app_theme")
    private var storedTheme = AppTheme.system.rawValue

    @Published var theme: AppTheme = .system {
        didSet {
            storedTheme = theme.rawValue
        }
    }

    init() {
        theme = AppTheme(rawValue: storedTheme) ?? .system
    }

    var colorScheme: ColorScheme? {
        theme.colorScheme
    }
}
