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
    
    
    
    @State private var showDeleteConfirmation = false
    @State private var newSubTaskTitle: String = ""
    
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
                
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(spacing: 20) {
                        
                        
                        header
                        
                        
                        habitNameCard
                        
                        VStack(alignment:.leading, spacing:12) {


                            Toggle(
                                "Reminder",
                                isOn: $vm.draft.reminderEnabled
                            )


                            if vm.draft.reminderEnabled {


                                DatePicker(
                                    "Reminder Time",
                                    selection: Binding(
                                        get: { vm.reminderDate },
                                        set: { vm.updateReminderDate($0)}
                                    ),
                                    displayedComponents:.hourAndMinute
                                )

                            }

                        }
                        
                        
                        typeCard
                        
                        categoryCard
                        
                        timeOfDayCard
                        
                        subTasksCard
                        
                        if vm.draft.habitType == .measurable {
                            
                            goalCard
                        }
                        
                        
                        frequencyCard
                        
                        
                        iconCard
                        
                        
                        previewCard
                        
                        
                        
                        
                    }
                    .padding()
                }
                
                
                
                actionButtons
                    .padding()
            }
            
        }
        .navigationTitle(vm.isEditing ? "Edit Habit" : "Create Habit")
        .navigationBarTitleDisplayMode(.inline)
        
        .confirmationDialog(
            "Delete Habit?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if vm.deleteHabit() {
                    router.popToRoot()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this habit? All recorded entries will be removed.")
        }
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
            
            Text(vm.isEditing ? "Edit your habit" : "Create a habit")
                .font(AppFont.title())
            
            
            Text(
                vm.isEditing ? "Update your habit details" : "Small actions create big changes."
            )
            .foregroundStyle(
                AppColors.textSecondary
            )
            
            if !vm.isEditing {
                Button {
                    router.push(.aiRoutineGenerator)
                } label: {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(AppColors.primary.opacity(0.15))
                                .frame(width: 36, height: 36)
                            Image(systemName: "sparkles")
                                .foregroundStyle(AppColors.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Build Routine with AI ✨")
                                .font(AppFont.headline())
                                .foregroundStyle(AppColors.textPrimary)
                            Text("Auto-generate habits for your goals")
                                .font(AppFont.caption())
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(12)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.primary.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            
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
    
    var categoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Category", systemImage: "folder.fill")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(HabitCategory.allCases) { category in
                        let isSelected = vm.draft.category == category
                        
                        Button {
                            vm.draft.category = category
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                Text(category.title)
                            }
                            .font(.subheadline)
                            .fontWeight(isSelected ? .bold : .regular)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isSelected ? category.color.opacity(0.18) : Color.gray.opacity(0.1))
                            .foregroundStyle(isSelected ? category.color : AppColors.textPrimary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(isSelected ? category.color : Color.clear, lineWidth: 1.5)
                            )
                        }
                    }
                }
            }
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
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(
                    "Choose Icon",
                    systemImage: "star"
                )
                .font(.headline)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "arrow.left.and.right")
                        .font(.system(size: 10, weight: .bold))
                    Text("Swipe")
                        .font(AppFont.caption())
                        .fontWeight(.semibold)
                }
                .foregroundStyle(AppColors.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(AppColors.primary.opacity(0.12))
                .clipShape(Capsule())
            }
            
            HabitIconPicker(
                selected: $vm.draft.icon
            )
        }
        .cardStyle()
    }
    
    var subTasksCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Checklist Sub-tasks (Optional)", systemImage: "checklist")
                .font(.headline)
            
            Text("Break complex habits into smaller checklist items.")
                .font(AppFont.caption())
                .foregroundStyle(AppColors.textSecondary)
            
            HStack(spacing: 8) {
                TextField("Add sub-task (e.g. Make Bed)", text: $newSubTaskTitle)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(Color.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button {
                    vm.addSubTask(title: newSubTaskTitle)
                    newSubTaskTitle = ""
                    AudioManager.shared.playClickSound()
                } label: {
                    Text("+ Add")
                        .font(AppFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .disabled(newSubTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            
            if !vm.draft.subTasks.isEmpty {
                VStack(spacing: 8) {
                    ForEach(vm.draft.subTasks) { subTask in
                        HStack {
                            Image(systemName: "circle")
                                .font(.system(size: 14))
                                .foregroundStyle(AppColors.textSecondary)
                            
                            Text(subTask.title)
                                .font(AppFont.body())
                                .foregroundStyle(AppColors.textPrimary)
                            
                            Spacer()
                            
                            Button {
                                vm.removeSubTask(id: subTask.id)
                                AudioManager.shared.playClickSound()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.red.opacity(0.7))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(10)
                        .background(Color.gray.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
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
    
    var actionButtons: some View {
        VStack(spacing: AppSpacing.sm) {
            PrimaryButton(
                title: vm.isEditing ? "Save Changes" : "Create Habit",
                isLoading: vm.isLoading
            ) {
                if vm.saveHabit() {
                    router.pop()
                }
            }
            
            if vm.isEditing {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Text("Delete Habit")
                        .font(AppFont.headline())
                        .foregroundStyle(AppColors.error)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            }
        }
    }
    
    var timeOfDayCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(
                "Time of Day",
                systemImage: "clock.fill"
            )
            .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(TimeOfDay.allCases) { time in
                    let isSelected = vm.draft.timeOfDay == time
                    HStack(spacing: 6) {
                        Image(systemName: time.icon)
                            .font(.system(size: 14))
                        Text(time.title)
                            .font(AppFont.caption())
                            .fontWeight(isSelected ? .bold : .medium)
                    }
                    .foregroundStyle(isSelected ? time.themeColor : AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(isSelected ? time.themeColor.opacity(0.15) : AppColors.background)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? time.themeColor : Color.clear, lineWidth: 1.5)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        vm.draft.timeOfDay = time
                        AudioManager.shared.playClickSound()
                    }
                }
            }
        }
        .cardStyle()
    }
}

extension View {

    func cardStyle() -> some View {

        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppColors.border, lineWidth: 1)
            )
    }
}
