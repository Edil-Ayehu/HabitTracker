//
//  PrimaryButton.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct PrimaryButton: View {

    let title: String
    var isLoading: Bool = false
    var isEnabled: Bool = true
    var width: CGFloat? = nil
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            ZStack {

                if isLoading {

                    ProgressView()
                        .tint(.white)

                } else {

                    Text(title)
                        .font(AppFont.headline())
                        .fontWeight(.semibold)
                }

            }
            .frame(maxWidth: width ?? .infinity)
            .frame(height: 52)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(
            isEnabled
            ? AppColors.primary
            : AppColors.border
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .disabled(!isEnabled || isLoading)
    }
}
