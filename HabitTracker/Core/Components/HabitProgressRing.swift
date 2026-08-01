//
//  HabitProgressRing.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct HabitProgressRing: View {

    let current: Int

    let goal: Int

    var lineWidth: CGFloat = 8

    private var progress: Double {

        guard goal > 0 else { return 0 }

        return min(Double(current) / Double(goal), 1)

    }

    var body: some View {

        ZStack {

            Circle()
                .stroke(
                    AppColors.border,
                    lineWidth: lineWidth
                )

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AppColors.primary,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {

                Text("\(current)")
                    .font(.title3)
                    .bold()

                Text("/ \(goal)")
                    .font(AppFont.caption())
                    .foregroundStyle(
                        AppColors.textSecondary
                    )

            }

        }

    }

}
