//
//  AppBadge.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct AppBadge: View {

    let title: String

    var color = AppColors.primary

    var body: some View {

        Text(title)
            .font(AppFont.caption())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())

    }

}
