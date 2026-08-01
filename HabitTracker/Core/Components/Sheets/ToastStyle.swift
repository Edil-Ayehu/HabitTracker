//
//  ToastStyle.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

enum ToastStyle {

    case success
    case error
    case info

    var color: Color {

        switch self {

        case .success:
            AppColors.success

        case .error:
            AppColors.error

        case .info:
            AppColors.primary

        }

    }

    var icon: String {

        switch self {

        case .success:
            "checkmark.circle.fill"

        case .error:
            "xmark.circle.fill"

        case .info:
            "info.circle.fill"

        }

    }

}
