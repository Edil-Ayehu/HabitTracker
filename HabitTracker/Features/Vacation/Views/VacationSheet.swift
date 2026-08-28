//
//  VacationSheet.swift
//  HabitTracker
//

import SwiftUI

struct VacationSheet: View {
    @StateObject private var manager = VacationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedReason: VacationReason = .vacation
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()
    @State private var note: String = ""
    
    var body: some View {
        AppScaffold(title: "Vacation & Rest Days 🏖️") {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                let requestedDays = manager.calculateDaysBetween(start: Date(), end: endDate)
                let isExceeded = requestedDays > manager.remainingVacationDaysThisYear
                
                // Intro & Quota Card
                CardView {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Pause & Protect Streaks 🛡️")
                                .font(AppFont.title())
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "calendar.badge.clock")
                                Text("\(manager.remainingVacationDaysThisYear)/\(manager.maxVacationDaysPerYear) Days Left")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(manager.remainingVacationDaysThisYear > 0 ? Color.orange : Color.red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background((manager.remainingVacationDaysThisYear > 0 ? Color.orange : Color.red).opacity(0.15))
                            .clipShape(Capsule())
                        }
                        
                        Text("Limit: \(manager.maxVacationDaysPerYear) days per calendar year. Prevents streak abuse while keeping rest guilt-free.")
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
                
                // End Date Picker & Duration Summary
                SectionHeader(title: "Vacation Duration")
                
                CardView {
                    VStack(alignment: .leading, spacing: 10) {
                        DatePicker(
                            "End Date",
                            selection: $endDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .font(AppFont.body())
                        
                        Divider()
                        
                        HStack {
                            Text("Total Days Requested:")
                                .font(AppFont.caption())
                                .foregroundStyle(AppColors.textSecondary)
                            Spacer()
                            Text("\(requestedDays) \(requestedDays == 1 ? "day" : "days")")
                                .font(AppFont.headline())
                                .foregroundStyle(isExceeded ? Color.red : AppColors.primary)
                        }
                        
                        if isExceeded {
                            Text("⚠️ Exceeds your remaining yearly allowance (\(manager.remainingVacationDaysThisYear) days remaining).")
                                .font(AppFont.caption())
                                .foregroundStyle(Color.red)
                                .fontWeight(.bold)
                        }
                    }
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
                        Text(isExceeded ? "Yearly Limit Exceeded ⚠️" : "Activate Vacation Mode 🛡️")
                    }
                    .font(AppFont.body())
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        isExceeded ? AnyShapeStyle(Color.gray) : AnyShapeStyle(
                            LinearGradient(
                                colors: [selectedReason.themeColor, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .disabled(isExceeded || manager.remainingVacationDaysThisYear <= 0)
            }
        }
    }
}
