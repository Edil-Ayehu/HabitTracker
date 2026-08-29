//
//  GreetingHeader.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct GreetingHeader: View {

    let greeting: String
    let date: String
    let onAdd: () -> Void
    var onAIGenerator: (() -> Void)? = nil
    var onArchivedHabits: (() -> Void)? = nil
    let navigateToSetting: () -> Void

    var body: some View {

        HStack(alignment: .top) {

            VStack(alignment: .leading, spacing: 6) {

                Text(greeting)
                    .font(AppFont.largeTitle())

                Text(date)
                    .font(AppFont.body())
                    .foregroundStyle(AppColors.textSecondary)

            }

            Spacer()

            if let onAIGenerator {
                AppIconButton(
                    systemImage: "sparkles",
                    action: onAIGenerator
                )
            }

            if let onArchivedHabits {
                AppIconButton(
                    systemImage: "archivebox",
                    action: onArchivedHabits
                )
            }
            
            AppIconButton(
                systemImage: "gearshape",
                action: navigateToSetting
            )
            
            AppIconButton(
                systemImage: "plus",
                action: onAdd
            )

        }

    }

}
