//
//  CardView.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct CardView<Content: View>: View {

    @ViewBuilder
    let content: () -> Content

    var body: some View {

        content()
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

