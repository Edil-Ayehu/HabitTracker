//
//  VacationSheet.swift
//  HabitTracker
//

import SwiftUI

struct VacationSheet: View {
    @StateObject private var manager = VacationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedReason: VacationReason = .vacation
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    @State private var note: String = ""
    
    var body: some View {
        AppScaffold(title: "Vacation & Rest Days 🏖️") {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Intro Banner
                CardView {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pause & Protect Streaks 🛡️")
                            .font(AppFont.title())
                            .fontWeight(.bold)
                        Text("Pause habit reminders and protect your active streaks during trips, rest days, or illness.")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                
                // Reason Selection
                SectionHeader(title: "Select Reason")
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(VacationReason.allCases) { reason in
                        let isSelected = selectedReason == reason
                        HStack(spacing: 8) {
                            Text(reason.emoji)
                                .font(.system(size: 24))
                            Text(reason.title)
                                .font(AppFont.body())
                                .fontWeight(isSelected ? .bold : .medium)
                                .foregroundStyle(isSelected ? reason.themeColor : AppColors.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isSelected ? reason.themeColor.opacity(0.15) : AppColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? reason.themeColor : Color.clear, lineWidth: 1.5)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedReason = reason
                            AudioManager.shared.playClickSound()
                        }
                    }
                }
                
                // End Date Picker
                SectionHeader(title: "Vacation Until")
                
                CardView {
                    DatePicker(
                        "End Date",
                        selection: $endDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .font(AppFont.body())
                }
                
                // Optional Note
                SectionHeader(title: "Trip Note (Optional)")
                
                CardView {
                    TextField("e.g. Hawaii beach vacation, flu recovery...", text: $note)
                        .font(AppFont.body())
                        .textFieldStyle(.plain)
                }
                
                // Activate Button
                Button {
                    manager.activateVacation(endDate: endDate, reason: selectedReason, note: note)
                    AudioManager.shared.playCompletionSound()
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "shield.fill")
                        Text("Activate Vacation Mode 🛡️")
                    }
                    .font(AppFont.body())
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [selectedReason.themeColor, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
