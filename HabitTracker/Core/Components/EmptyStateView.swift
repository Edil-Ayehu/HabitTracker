//
//  EmptyStateView.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct EmptyStateView: View {

    let image: String
    let title: String
    let subtitle: String

    var body: some View {

        VStack(spacing: 16) {

            Image(systemName: image)
                .font(.system(size: 60))
                .foregroundStyle(AppColors.primary)

            Text(title)
                .font(AppFont.title())

            Text(subtitle)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.textSecondary)

        }
        .padding()
    }
}

