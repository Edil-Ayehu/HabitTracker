//
//  CircularProgressView.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct CircularProgressView: View {

    var progress: Double
    var lineWidth: CGFloat = 8

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

            Text("\(Int(progress * 100))%")
                .font(AppFont.caption())
                .fontWeight(.bold)

        }
    }
}

