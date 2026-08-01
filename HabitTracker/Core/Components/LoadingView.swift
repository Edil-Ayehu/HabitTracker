//
//  LoadingView.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct LoadingView: View {

    var body: some View {

        VStack(spacing: 12) {

            ProgressView()

            Text("Loading...")
                .font(AppFont.body())
                .foregroundStyle(AppColors.textSecondary)

        }
        .padding()
    }
}

