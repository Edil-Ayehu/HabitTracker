//
//  CardView.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct CardView<Content: View>: View {

    @ViewBuilder
    var content: () -> Content

    var body: some View {

        content()
            .appCardStyle()

    }

}
