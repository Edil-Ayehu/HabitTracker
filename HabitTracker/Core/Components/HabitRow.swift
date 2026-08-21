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
    
    let onTap: () -> Void

    var body: some View {

        CardView {

            HStack(spacing: AppSpacing.md) {

                Image(systemName: entry.habit.icon)
                    .font(.title2)
                    .foregroundStyle(entry.habit.habitColor.color)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {

                    HStack(spacing: 6) {
                        Text(entry.habit.title)
                            .font(AppFont.headline())
                        
                        Label(entry.habit.habitCategory.title, systemImage: entry.habit.habitCategory.icon)
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(entry.habit.habitCategory.color.opacity(0.12))
                            .foregroundStyle(entry.habit.habitCategory.color)
                            .clipShape(Capsule())
                    }

//                    Text("\(entry.progress)/\(entry.habit.goal)")
//                        .foregroundStyle(
//                            AppColors.textSecondary
//                        )
                    switch entry.habit.habitType {

                    case .binary:

                        Text(
                            entry.completed
                            ? "Completed"
                            : "Not completed"
                        )

                    case .measurable:

                        Text(
                            "\(entry.progress)/\(entry.habit.goal ?? 0)"
                        )
                    }

                }

                Spacer()

//                HabitProgressRing(
//                    current: entry.progress,
//                    goal: entry.habit.goal
//                )
//                .frame(width: 60)
                
                if entry.habit.habitType == .binary {

                    Image(
                        systemName:
                            entry.completed
                            ? "checkmark.circle.fill"
                            : "circle"
                    )
                    .font(.title2)
                    .foregroundStyle(entry.habit.habitColor.color)

                } else {

                    HabitProgressRing(
                        current: entry.progress,
                        goal: entry.habit.goal ?? 1
                    )
                    .frame(width: 60)
                }
                
                if entry.habit.habitType == .measurable {

                    AppIconButton(systemImage: "plus") {
                        onIncrement()
                    }
                }
                
                AppIconButton(systemImage: "checkmark") {

                    onComplete()

                }

            }

        }
        .onTapGesture {
            onTap()
        }

    }

}
