//
//  AppFonts.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

enum AppFont {

    static func largeTitle() -> Font {
        .custom("Outfit-SemiBold", size: 28)
    }

    static func title() -> Font {
        .custom("Outfit-SemiBold", size: 20)
    }

    static func headline() -> Font {
        .custom("Outfit-Medium", size: 16)
    }

    static func body() -> Font {
        .custom("Outfit-Regular", size: 14)
    }

    static func caption() -> Font {
        .custom("Outfit-Regular", size: 11)
    }
}
