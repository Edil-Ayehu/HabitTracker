//
//  SectionHeader.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct SectionHeader: View {

    let title: String
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {

        HStack {

            Text(title)
                .font(AppFont.title())

            Spacer()

            if let buttonTitle {

                Button(buttonTitle) {
                    action?()
                }
                .foregroundStyle(AppColors.primary)

            }

        }
    }
}

