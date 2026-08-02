//
//  CreateHabitView.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import SwiftUI


struct CreateHabitView: View {
    
    @EnvironmentObject private var router: AppRouter


    @StateObject
    private var vm: CreateHabitViewModel


    init(
        vm: CreateHabitViewModel
    ) {
        _vm = StateObject(
            wrappedValue: vm
        )
    }


    var body: some View {


        AppScaffold {


            VStack(
                spacing: AppSpacing.lg
            ) {


                AppTextField(
                    title: "Habit Name",
                    text: $vm.draft.title
                )


                VStack(alignment: .leading) {


                    Text("Goal")

                    Stepper(
                        "\(vm.draft.goal)",
                        value: $vm.draft.goal,
                        in: 1...100
                    )

                }



                VStack(alignment: .leading) {


                    Text("Frequency")


                    Picker(
                        "Frequency",
                        selection: $vm.draft.frequency
                    ) {


                        ForEach(
                            HabitFrequency.allCases
                        ) { frequency in


                            Text(
                                frequency.title
                            )
                            .tag(frequency)

                        }

                    }
                    .pickerStyle(
                        .segmented
                    )

                }



                HabitIconPicker(
                    selected: $vm.draft.icon
                )



                PrimaryButton(
                    title: "Create Habit",
                    isLoading: vm.isLoading
                ) {


                    if vm.createHabit() {

                        router.pop()

                    }

                }


            }

        }
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil},
            set: { _ in vm.errorMessage = nil }
        )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "Something went wrong.")
        }

        .navigationTitle(
            "Create Habit"
        )

    }
}
