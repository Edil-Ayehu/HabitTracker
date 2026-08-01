//
//  SecondaryButton.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct SecondaryButton: View {

    let title: String
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            Text(title)
                .font(AppFont.headline())
                .frame(maxWidth: .infinity)
                .frame(height: 52)

        }
        .buttonStyle(.plain)
        .foregroundStyle(AppColors.primary)
        .overlay {

            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(AppColors.primary, lineWidth: 1)

        }
    }
}
