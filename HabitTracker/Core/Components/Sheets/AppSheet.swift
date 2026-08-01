//
//  AppSheet.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct AppSheet<Content: View>: View {

    @ViewBuilder
    let content: () -> Content

    var body: some View {

        VStack(spacing: AppSpacing.lg) {

            Capsule()
                .fill(AppColors.border)
                .frame(width: 50, height: 5)

            content()

        }
        .padding()
        .presentationCornerRadius(28)

    }

}
