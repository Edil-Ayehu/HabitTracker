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

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
    }

    var body: some View {

        HStack(alignment: .top) {

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
