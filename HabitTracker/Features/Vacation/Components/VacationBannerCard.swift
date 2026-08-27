//
//  VacationBannerCard.swift
//  HabitTracker
//

import SwiftUI

struct VacationBannerCard: View {
    @StateObject private var manager = VacationManager.shared
    @State private var showVacationSheet = false
    
    var body: some View {
        if manager.isVacationActive, let state = manager.vacationState {
            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        HStack(spacing: 8) {
                            Text(state.reason.emoji)
                                .font(.system(size: 24))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(state.reason.title)
                                    .font(AppFont.headline())
                                    .foregroundStyle(AppColors.textPrimary)
                                
                                Text("Streaks Protected 🛡️ • Until \(formattedDate(state.endDate))")
                                    .font(AppFont.caption())
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            manager.deactivateVacation()
                            AudioManager.shared.playClickSound()
                        } label: {
                            Text("End Vacation")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.red)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.12))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    
                    if !state.note.isEmpty {
                        Text("\"\(state.note)\"")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                            .italic()
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(state.reason.themeColor.opacity(0.4), lineWidth: 1.5)
            )
        } else {
            Button {
                showVacationSheet = true
            } label: {
                CardView {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.teal, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 42, height: 42)
                            Text("🏖️")
                                .font(.system(size: 20))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text("Plan Vacation / Rest Days")
                                    .font(AppFont.headline())
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            
                            Text("Freeze streaks & pause reminders for trips or rest days")
                                .font(AppFont.caption())
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showVacationSheet) {
                VacationSheet()
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
