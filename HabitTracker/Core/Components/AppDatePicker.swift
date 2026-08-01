//
//  AppDatePicker.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct AppDatePicker: View {

    let title: String

    @Binding
    var date: Date

    var body: some View {

        VStack(alignment: .leading) {

            Text(title)
                .font(AppFont.caption())

            DatePicker(
                "",
                selection: $date,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()

        }

    }

}
