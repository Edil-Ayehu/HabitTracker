//
//  FloatingActionButton.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct FloatingActionButton: View {

    let action: () -> Void

    var body: some View {

        Button(action: action) {

            Image(systemName: "plus")
                .font(.title2.bold())
                .frame(width: 60, height: 60)
                .foregroundStyle(.white)
                .background(AppColors.primary)
                .clipShape(Circle())
                .shadow(
                    color: AppShadow.card,
                    radius: 6,
                    x: 0,
                    y: 3
                )

        }
        .buttonStyle(.plain)

    }

}
