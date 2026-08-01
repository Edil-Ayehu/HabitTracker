//
//  AppToast.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//
import SwiftUI

struct AppToast: View {

    let message: String

    let style: ToastStyle

    var body: some View {

        HStack {

            Image(systemName: style.icon)

            Text(message)

        }
        .foregroundStyle(.white)
        .padding()
        .background(style.color)
        .clipShape(Capsule())

    }

}
