//
//  AppTextField.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct AppTextField: View {

    let title: String

    @Binding
    var text: String

    var keyboard: UIKeyboardType = .default

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .font(AppFont.caption())
                .foregroundStyle(AppColors.textSecondary)

            TextField(title, text: $text)
                .keyboardType(keyboard)
                .padding()
                .background(AppColors.surface)
                .overlay {

                    RoundedRectangle(
                        cornerRadius: AppRadius.md
                    )
                    .stroke(
                        AppColors.border,
                        lineWidth: 1
                    )

                }

        }
    }
}

