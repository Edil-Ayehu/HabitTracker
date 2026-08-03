//
//  CreateHabitView.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import SwiftUI


import SwiftUI

struct CreateHabitView: View {
    
    @EnvironmentObject private var router: AppRouter
    
    @StateObject
    private var vm: CreateHabitViewModel
    
    
    init(vm: CreateHabitViewModel) {
        _vm = StateObject(
            wrappedValue: vm
        )
    }
    
    
    var body: some View {
        
        ZStack {
            
            AppColors.background
                .ignoresSafeArea()
            
            
            VStack(spacing: AppSpacing.lg) {
                
                
                ScrollView {
                    
                    VStack(spacing: 20) {
                        
                        
                        header
                        
                        
                        habitNameCard
                        
                        
                        typeCard
                        
                        
                        if vm.draft.habitType == .measurable {
                            
                            goalCard
                        }
                        
                        
                        frequencyCard
                        
                        
                        iconCard
                        
                        
                        previewCard
                        
                        
                    }
                    .padding()
                }
                
                
                
                createButton
                    .padding()
            }
            
        }
        .navigationTitle("Create Habit")
        .navigationBarTitleDisplayMode(.inline)
        
        
        .alert(
            "Error",
            isPresented: Binding(
                get: {
                    vm.errorMessage != nil
                },
                set: {
                    _ in vm.errorMessage = nil
                }
            )
        ) {
            
            Button("OK") {}
            
        } message: {
            
            Text(
                vm.errorMessage ?? ""
            )
        }
        
    }
}

private extension CreateHabitView {
    
    
    var header: some View {
        
        VStack(alignment:.leading, spacing:8) {
            
            Text("Create a habit")
                .font(AppFont.title())
            
            
            Text(
                "Small actions create big changes."
            )
            .foregroundStyle(
                AppColors.textSecondary
            )
            
        }
        .frame(
            maxWidth:.infinity,
            alignment:.leading
        )
    }
    
}


private extension CreateHabitView {
    
    
    var habitNameCard: some View {
        
        VStack(alignment:.leading, spacing:12) {
            
            Label(
                "Habit Name",
                systemImage:"pencil"
            )
            .font(.headline)
            
            
            AppTextField(
                title:"",
                text:$vm.draft.title
            )
            
        }
        .cardStyle()
        
    }
    
}


private extension CreateHabitView {
    
    
    var typeCard: some View {
        
        VStack(
            alignment:.leading,
            spacing:12
        ) {
            
            Label(
                "Tracking Type",
                systemImage:"chart.bar"
            )
            .font(.headline)
            
            
            
            Picker(
                "",
                selection:$vm.draft.habitType
            ){
                
                ForEach(
                    HabitType.allCases
                ){ type in
                    
                    Text(
                        type.title
                    )
                    .tag(type)
                    
                }
                
            }
            .pickerStyle(
                .segmented
            )
            
        }
        .cardStyle()
        
    }
    
}

private extension CreateHabitView {
    
    
    var goalCard: some View {
        
        
        VStack(spacing:16) {
            
            
            Label(
                "Daily Goal",
                systemImage:"target"
            )
            .font(.headline)
            
            
            
            Text(
                "\(vm.draft.goal ?? 1)"
            )
            .font(
                .system(
                    size:50,
                    weight:.bold
                )
            )
            
            
            
            Text("times per day")
                .foregroundStyle(
                    AppColors.textSecondary
                )
            
            
            
            Stepper(
                "",
                value: Binding(
                    get:{
                        vm.draft.goal ?? 1
                    },
                    set:{
                        vm.draft.goal = $0
                    }
                ),
                in:1...100
            )
            
            
        }
        .frame(
            maxWidth:.infinity
        )
        .cardStyle()
        
    }
    
}


private extension CreateHabitView {
    
    
    var frequencyCard: some View {
        
        
        VStack(
            alignment:.leading,
            spacing:12
        ){
            
            Label(
                "Frequency",
                systemImage:"calendar"
            )
            .font(.headline)
            
            
            
            Picker(
                "",
                selection:$vm.draft.frequency
            ){
                
                ForEach(
                    HabitFrequency.allCases
                ){ item in
                    
                    Text(
                        item.title
                    )
                    .tag(item)
                    
                }
                
            }
            .pickerStyle(
                .segmented
            )
            
        }
        .cardStyle()
        
        
    }
    
}

private extension CreateHabitView {
    
    
    var iconCard: some View {
        
        
        VStack(
            alignment:.leading
        ){
            
            Label(
                "Choose Icon",
                systemImage:"star"
            )
            .font(.headline)
            
            
            
            HabitIconPicker(
                selected:$vm.draft.icon
            )
            
            
        }
        .cardStyle()
        
        
    }
    
}

private extension CreateHabitView {
    
    
    var previewCard: some View {
        
        
        CardView {
            
            
            HStack {
                
                
                Image(
                    systemName:
                        vm.draft.icon.rawValue
                )
                .font(.largeTitle)
                
                
                VStack(
                    alignment:.leading
                ){
                    
                    Text(
                        vm.draft.title.isEmpty
                        ?
                        "Your Habit"
                        :
                            vm.draft.title
                    )
                    .font(.headline)
                    
                    
                    
                    Text(
                        vm.draft.habitType == .binary
                        ?
                        "Complete once daily"
                        :
                            "\(vm.draft.goal ?? 1) times daily"
                    )
                    .foregroundStyle(
                        AppColors.textSecondary
                    )
                    
                    
                }
                
                
                
                Spacer()
                
                
            }
            
            
        }
        
        
    }
    
}


private extension CreateHabitView {
    
    
    var createButton: some View {
        
        
        PrimaryButton(
            title:"Create Habit",
            isLoading:vm.isLoading
        ){
            
            if vm.createHabit(){
                
                router.pop()
            }
            
        }
        
        
    }
    
}

extension View {
    
    func cardStyle() -> some View {
        
        self
            .padding()
            .background(
                RoundedRectangle(
                    cornerRadius:20
                )
                .fill(
                    Color.white
                )
            )
//            .shadow(
//                radius:2,
//                y:2
//            )
        
    }
    
}
