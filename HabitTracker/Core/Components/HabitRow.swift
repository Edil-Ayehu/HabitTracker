//
//  HabitRow.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct HabitRow: View {

    let title: String

    let icon: String

    let current: Int

    let goal: Int

    let color: Color

    var body: some View {

        CardView {

            HStack(spacing: AppSpacing.md) {

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 40)

                VStack(alignment: .leading) {

                    Text(title)
                        .font(AppFont.headline())

                    Text("\(current)/\(goal)")
                        .foregroundStyle(
                            AppColors.textSecondary
                        )

                }

                Spacer()

                HabitProgressRing(
                    current: current,
                    goal: goal
                )
                .frame(width: 60)

            }

        }

    }

}
