//
//  HabitRow.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct HabitRow: View {
    
//    let habit: Habit
    let entry: HabitEntry
    
    let onIncrement: () -> Void
    
    let onComplete: () -> Void

    var body: some View {

        CardView {

            HStack(spacing: AppSpacing.md) {

                Image(systemName: entry.habit.icon)
                    .font(.title2)
                    .foregroundStyle(entry.habit.habitColor.color)
                    .frame(width: 40)

                VStack(alignment: .leading) {

                    Text(entry.habit.title)
                        .font(AppFont.headline())

                    Text("\(entry.progress)/\(entry.habit.goal)")
                        .foregroundStyle(
                            AppColors.textSecondary
                        )

                }

                Spacer()

                HabitProgressRing(
                    current: entry.progress,
                    goal: entry.habit.goal
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
