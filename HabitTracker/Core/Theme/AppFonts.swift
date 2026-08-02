//
//  AppFonts.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

enum AppFont {

    static func largeTitle() -> Font {
        .custom("Outfit-Bold", size: 34)
    }

    static func title() -> Font {
        .custom("Outfit-Bold", size: 24)
    }

    static func headline() -> Font {
        .custom("Outfit-SemiBold", size: 18)
    }

    static func body() -> Font {
        .custom("Outfit-Regular", size: 16)
    }

    static func caption() -> Font {
        .custom("Outfit-Regular", size: 13)
    }
}
