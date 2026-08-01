//
//  AppNavigationBar.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct AppNavigationBar<Trailing: View>: View {

    let title: String
    var subtitle: String?

    @ViewBuilder
    var trailing: () -> Trailing

    var body: some View {

        HStack {

            VStack(alignment: .leading, spacing: 4) {

                Text(title)
                    .font(AppFont.largeTitle())

                if let subtitle {
                    Text(subtitle)
                        .font(AppFont.caption())
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Spacer()

            trailing()
        }
    }
}
