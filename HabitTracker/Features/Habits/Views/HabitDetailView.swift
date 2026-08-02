//
//  HabitDetailView.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import SwiftUI

struct HabitDetailView: View {


    @StateObject
    var vm: HabitDetailViewModel


    var body: some View {


        AppScaffold(
            title: vm.title
        ) {


            HabitProgressRing(
                current:
                    vm.progress,

                goal:
                    vm.goal
            )
            .frame(
                width:150
            )



            StatCard(
                icon: vm.icon.rawValue,
                
                title:"Current Streak",
                

                value:
                    "\(vm.streak) days"
            )



            SectionHeader(
                title:"History"
            )



            LazyVStack {


                ForEach(
                    vm.entries
                ) { entry in


                    HStack {


                        Text(
                            entry.date.formatted(
                                date:.abbreviated,
                                time:.omitted
                            )
                        )


                        Spacer()



                        Image(
                            systemName:
                                entry.completed
                                ?
                                "checkmark.circle.fill"
                                :
                                "circle"
                        )

                    }

                }

            }


        }
        .onAppear {

            vm.load()

        }

    }
}
