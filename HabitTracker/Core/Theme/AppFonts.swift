//
//  AppFonts.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

enum AppFont {

    static func largeTitle() -> Font {
        .system(size: 34, weight: .bold)
    }

    static func title() -> Font {
        .system(size: 24, weight: .bold)
    }

    static func headline() -> Font {
        .system(size: 18, weight: .semibold)
    }

    static func body() -> Font {
        .system(size: 16)
    }

    static func caption() -> Font {
        .system(size: 13)
    }
}
