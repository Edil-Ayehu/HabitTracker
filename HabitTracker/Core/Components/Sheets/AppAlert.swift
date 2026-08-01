//
//  AppAlery.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct AppAlert: View {

    let title: String

    let message: String

    let confirmTitle: String

    var cancelTitle = "Cancel"

    let confirm: () -> Void

    var body: some View {

        VStack(spacing: 24) {

            Text(title)
                .font(AppFont.title())

            Text(message)
                .multilineTextAlignment(.center)

            HStack {

                SecondaryButton(title: cancelTitle) {

                }

                PrimaryButton(title: confirmTitle) {

                    confirm()

                }

            }

        }
        .padding()

    }

}
