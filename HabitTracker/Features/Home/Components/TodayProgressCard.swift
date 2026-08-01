//
//  TodayProgressCard.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct TodayProgressCard: View {

    let completed: Int

    let total: Int

    var body: some View {

        CardView {

            HStack {

                VStack(alignment: .leading, spacing: 12) {

                    Text("Today's Progress")
                        .font(AppFont.headline())

                    Text("\(completed) / \(total)")
                        .font(.system(size: 32, weight: .bold))

                    Text("Habits Completed")
                        .foregroundStyle(AppColors.textSecondary)

                }

                Spacer()

                HabitProgressRing(
                    current: completed,
                    goal: total
                )
                .frame(width: 90, height: 90)

            }

        }

    }

}
