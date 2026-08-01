//
//  AppAvatar.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct AppAvatar: View {

    var image: String = "person.fill"

    var size: CGFloat = 60

    var body: some View {

        Circle()
            .fill(AppColors.primary.opacity(0.15))
            .frame(width: size, height: size)
            .overlay {

                Image(systemName: image)
                    .font(.system(size: size * 0.4))
                    .foregroundStyle(AppColors.primary)

            }

    }

}
