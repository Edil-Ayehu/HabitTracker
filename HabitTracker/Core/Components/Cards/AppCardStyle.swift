//
//  AppCardStyle.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct AppCardStyle: ViewModifier {

    func body(content: Content) -> some View {

        content
            .padding()
            .background(AppColors.card)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppRadius.lg
                )
            )
            .shadow(
                color: AppShadow.card,
                radius: 6,
                x: 0,
                y: 2
            )

    }

}

extension View {

    func appCardStyle() -> some View {
        modifier(AppCardStyle())
    }

}
