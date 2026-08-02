//
//  HabitIconPicker.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import SwiftUI


struct HabitIconPicker: View {


    @Binding
    var selected: HabitIcon



    let icons = HabitIcon.allCases



    var body: some View {


        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 60))
            ]
        ) {


            ForEach(
                icons,
                id: \.self
            ) { icon in


                Image(
                    systemName: icon.rawValue
                )
                .font(.title)
                .frame(
                    width: 50,
                    height: 50
                )
                .background(
                    selected == icon
                    ?
                    Color.blue.opacity(0.2)
                    :
                    Color.clear
                )
                .clipShape(
                    Circle()
                )
                .onTapGesture {

                    selected = icon

                }

            }

        }

    }
}
