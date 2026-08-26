//
//  ChallengesView.swift
//  HabitTracker
//

import SwiftUI

struct ChallengesView: View {
    @StateObject private var manager = ChallengeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showCompletionAlert = false
    @State private var challengeToUnenroll: HabitChallenge?
    
    var body: some View {
        AppScaffold(title: "30-Day Challenges 🏆") {
            VStack(spacing: AppSpacing.lg) {
                // Active Challenges Section
                if !manager.activeChallenges.isEmpty {
                    SectionHeader(title: "Active Bootcamps (\(manager.activeChallenges.count))")
                    
                    VStack(spacing: AppSpacing.md) {
                        ForEach(manager.activeChallenges) { active in
                            if let state = manager.progress(for: active.id) {
                                CardView {
                                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                                        HStack {
                                            Label(active.title, systemImage: active.icon)
                                                .font(AppFont.headline())
                                                .foregroundStyle(AppColors.primary)
                                            
                                            Spacer()
                                            
                                            Text("Day \(state.completedDays) of 30")
                                                .font(AppFont.caption())
                                                .fontWeight(.bold)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(AppColors.primary.opacity(0.15))
                                                .foregroundStyle(AppColors.primary)
                                                .clipShape(Capsule())
                                            
                                            Button {
                                                challengeToUnenroll = active
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundStyle(.red.opacity(0.7))
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        
                                        Text("\(active.goalPerDay) \(active.unit) daily target")
                                            .font(AppFont.caption())
                                            .foregroundStyle(AppColors.textSecondary)
                                        
                                        // 30-Day Checkbox Grid
                                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 6), spacing: 6) {
                                            ForEach(1...30, id: \.self) { day in
                                                let isDone = day <= state.completedDays
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(isDone ? Color.green : Color.gray.opacity(0.12))
                                                    
                                                    VStack(spacing: 2) {
                                                        if isDone {
                                                            Image(systemName: "checkmark")
                                                                .font(.system(size: 10, weight: .bold))
                                                                .foregroundStyle(.white)
                                                        } else {
                                                            Text("\(day)")
                                                                .font(.system(size: 10, weight: .bold))
                                                                .foregroundStyle(AppColors.textSecondary)
                                                        }
                                                    }
                                                }
                                                .frame(height: 32)
                                            }
                                        }
                                        .padding(.vertical, 4)
                                        
                                        // Check-in Button
                                        let todayChecked = state.lastCheckInDate == ChallengeManager.todayISOString
                                        Button {
                                            let finished = manager.checkInToday(for: active.id)
                                            AudioManager.shared.playCompletionSound()
                                            if finished {
                                                showCompletionAlert = true
                                            }
                                        } label: {
                                            HStack(spacing: 6) {
                                                Image(systemName: todayChecked ? "checkmark.circle.fill" : "plus.circle.fill")
                                                Text(todayChecked ? "Checked-In Today ✓" : "Check-In Day \(state.completedDays + 1)")
                                            }
                                            .font(AppFont.body())
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(todayChecked ? Color.green : AppColors.primary)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(todayChecked)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Challenge Catalog Section
                SectionHeader(title: "Explore 30-Day Bootcamps")
                
                VStack(spacing: AppSpacing.md) {
                    ForEach(HabitChallenge.prebuiltChallenges) { challenge in
                        ChallengeCard(
                            challenge: challenge,
                            isEnrolled: manager.isEnrolled(in: challenge.id),
                            isCompleted: manager.isChallengeCompleted(challenge.id)
                        ) {
                            manager.enroll(in: challenge)
                            AudioManager.shared.playClickSound()
                        }
                    }
                }
            }
        }
        .alert("30-Day Bootcamp Completed! 🎉", isPresented: $showCompletionAlert) {
            Button("Awesome!") {}
        } message: {
            Text("Congratulations! You completed the 30-day challenge and earned +500 XP & an exclusive trophy badge!")
        }
        .confirmationDialog(
            "Unenroll from Challenge?",
            isPresented: Binding(
                get: { challengeToUnenroll != nil },
                set: { if !$0 { challengeToUnenroll = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Unenroll", role: .destructive) {
                if let target = challengeToUnenroll {
                    manager.unenroll(challengeID: target.id)
                    AudioManager.shared.playClickSound()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let target = challengeToUnenroll {
                Text("Are you sure you want to unenroll from '\(target.title)'? Your current 30-day progress for this bootcamp will be reset.")
            }
        }
    }
}
