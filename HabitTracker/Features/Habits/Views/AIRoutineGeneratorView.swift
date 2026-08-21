//
//  AIRoutineGeneratorView.swift
//  HabitTracker
//

import SwiftUI

struct AIRoutineGeneratorView: View {
    
    @EnvironmentObject private var router: AppRouter
    @StateObject var vm: AIRoutineGeneratorViewModel
    @AppStorage("geminiApiKey") private var geminiApiKey: String = ""
    
    var body: some View {
        AppScaffold(title: "AI Routine Builder") {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                
                headerCard
                
                promptInputSection
                
                presetTemplatesSection
                
                if vm.isLoading {
                    loadingView
                } else if !vm.generatedHabits.isEmpty {
                    generatedHabitsSection
                }
            }
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { if !$0 { vm.errorMessage = nil } }
            )
        ) {
            Button("OK") {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .alert(
            "🎉 Habits Added!",
            isPresented: Binding(
                get: { vm.importedCount != nil },
                set: { if !$0 { vm.importedCount = nil } }
            )
        ) {
            Button("View My Habits") {
                router.popToRoot()
            }
        } message: {
            if let count = vm.importedCount {
                Text("Successfully added \(count) AI-crafted habit\(count == 1 ? "" : "s") to your routine!")
            }
        }
    }
}

private extension AIRoutineGeneratorView {
    
    var headerCard: some View {
        CardView {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(AppColors.primary.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(AppColors.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("AI Habit Architect")
                            .font(AppFont.headline())
                        
                        Spacer()
                        
                        let hasSecretsKey = !Secrets.geminiApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        let hasSettingsKey = !geminiApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        let isActive = hasSecretsKey || hasSettingsKey
                        Text(isActive ? "Gemini 3.6 ✨" : "Smart Engine")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(isActive ? AppColors.primary.opacity(0.15) : Color.gray.opacity(0.15))
                            .foregroundStyle(isActive ? AppColors.primary : AppColors.textSecondary)
                            .clipShape(Capsule())
                    }
                    
                    Text("Describe your goal in plain text or pick a template to auto-generate customized habits.")
                        .font(AppFont.caption())
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
    }
    
    var promptInputSection: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Label("What is your goal?", systemImage: "target")
                    .font(AppFont.headline())
                
                HStack(spacing: AppSpacing.sm) {
                    TextField("e.g. Prepare for 10k, Improve Sleep...", text: $vm.prompt)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color.gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Button {
                        vm.generateRoutine()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                            Text("Build")
                        }
                        .font(AppFont.headline())
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            vm.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? AppColors.border
                            : AppColors.primary
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .disabled(vm.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    var presetTemplatesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Popular Routines")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(vm.templates) { template in
                        Button {
                            vm.selectTemplate(template)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: template.icon)
                                    .foregroundStyle(AppColors.primary)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(template.title)
                                        .font(AppFont.caption())
                                        .fontWeight(.semibold)
                                        .foregroundStyle(AppColors.textPrimary)
                                    
                                    Text(template.category)
                                        .font(.system(size: 10))
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(AppColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
    }
    
    var loadingView: some View {
        CardView {
            VStack(spacing: AppSpacing.md) {
                ProgressView()
                    .scaleEffect(1.2)
                
                Text("AI is crafting your routine...")
                    .font(AppFont.headline())
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
    }
    
    var generatedHabitsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Suggested Habits (\(vm.selectedIndices.count)/\(vm.generatedHabits.count))")
            
            LazyVStack(spacing: AppSpacing.sm) {
                ForEach(Array(vm.generatedHabits.enumerated()), id: \.offset) { index, draft in
                    let isSelected = vm.selectedIndices.contains(index)
                    
                    CardView {
                        HStack(spacing: AppSpacing.md) {
                            Button {
                                vm.toggleSelection(at: index)
                            } label: {
                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .font(.title2)
                                    .foregroundStyle(isSelected ? AppColors.primary : Color.gray.opacity(0.4))
                            }
                            
                            Image(systemName: draft.icon.rawValue)
                                .font(.title3)
                                .foregroundStyle(draft.color.color)
                                .frame(width: 36)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(draft.title)
                                    .font(AppFont.headline())
                                    .foregroundStyle(AppColors.textPrimary)
                                
                                HStack(spacing: 8) {
                                    if draft.habitType == .measurable {
                                        Text("\(draft.goal) \(draft.unit) / day")
                                            .font(AppFont.caption())
                                            .foregroundStyle(AppColors.textSecondary)
                                    } else {
                                        Text("Daily Completion")
                                            .font(AppFont.caption())
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                    
                                    Text("•")
                                        .font(AppFont.caption())
                                        .foregroundStyle(AppColors.textSecondary)
                                    
                                    Label(
                                        draft.reminderTime.formatted(date: .omitted, time: .shortened),
                                        systemImage: "bell.fill"
                                    )
                                    .font(AppFont.caption())
                                    .foregroundStyle(AppColors.textSecondary)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .onTapGesture {
                        vm.toggleSelection(at: index)
                    }
                }
            }
            
            PrimaryButton(
                title: "Add Selected Habits (\(vm.selectedIndices.count))",
                isLoading: false
            ) {
                _ = vm.importSelectedHabits()
            }
            .disabled(vm.selectedIndices.isEmpty)
        }
    }
}
