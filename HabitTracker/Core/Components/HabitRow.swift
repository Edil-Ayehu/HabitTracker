//
//  HabitRow.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct HabitRow: View {
    
    let habit: Habit
    
    let onIncrement: () -> Void
    
    let onComplete: () -> Void

    var body: some View {

        CardView {

            HStack(spacing: AppSpacing.md) {

                Image(systemName: habit.icon)
                    .font(.title2)
                    .foregroundStyle(habit.habitColor.color)
                    .frame(width: 40)

                VStack(alignment: .leading) {

                    Text(habit.title)
                        .font(AppFont.headline())

                    Text("\(habit.progress)/\(habit.goal)")
                        .foregroundStyle(
                            AppColors.textSecondary
                        )

                }

                Spacer()

                HabitProgressRing(
                    current: habit.progress,
                    goal: habit.goal
                )
                .frame(width: 60)
                
                AppIconButton(
                    systemImage: "plus"
                ) {
                    onIncrement()
                }
                
                AppIconButton(systemImage: "checkmark") {

                    onComplete()

                }

            }

        }

    }

}
