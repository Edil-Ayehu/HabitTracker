//
//  AppScaffold.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct AppScaffold<Content: View>: View {

    var title: String? = nil

    var isLoading = false

    var showsScrollIndicators = false

    @ViewBuilder
    let content: () -> Content

    var body: some View {

        ZStack {

            AppColors.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: showsScrollIndicators) {

                VStack(spacing: AppSpacing.lg) {

                    if let title {

                        AppNavigationBar(title: title)

                    }

                    content()

                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.lg)

            }

            if isLoading {

                Color.black.opacity(0.15)
                    .ignoresSafeArea()

                LoadingView()

            }

        }

    }

}
