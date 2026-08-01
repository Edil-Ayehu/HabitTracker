//
//  StatCard.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct StatCard: View {

    let icon: String

    let title: String

    let value: String

    var color = AppColors.primary

    var body: some View {

        CardView {

            VStack(
                alignment: .leading,
                spacing: 16
            ) {

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Text(value)
                    .font(.title)
                    .bold()

                Text(title)
                    .font(AppFont.body())
                    .foregroundStyle(
                        AppColors.textSecondary
                    )

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }

    }

}
