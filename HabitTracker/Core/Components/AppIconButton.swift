//
//  AppIconButton.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct AppIconButton: View {

    let systemImage: String

    var size: CGFloat = 44

    var background = AppColors.surface

    var foreground = AppColors.primary

    let action: () -> Void

    var body: some View {

        Button(action: action) {

            Image(systemName: systemImage)
                .font(.title3)
                .frame(width: size, height: size)

        }
        .buttonStyle(.plain)
        .foregroundStyle(foreground)
        .background(background)
        .clipShape(Circle())
        .shadow(
            color: AppShadow.card,
            radius: 4,
            x: 0,
            y: 2
        )

    }

}
