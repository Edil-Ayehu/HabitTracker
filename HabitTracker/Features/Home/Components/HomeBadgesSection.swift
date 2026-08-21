//
//  HomeBadgesSection.swift
//  HabitTracker
//

import SwiftUI

struct HomeBadgesSection: View {
    
    let achievements: [Achievement]
    let onSeeAll: () -> Void
    
    var body: some View {
        if !achievements.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                
                SectionHeader(
                    title: "Milestones",
                    buttonTitle: "See All",
                    action: onSeeAll
                )
                
                // Next Milestone Motivational Banner
                if let nextMilestone = achievements.first(where: { !$0.isUnlocked }) {
                    nextMilestoneBanner(nextMilestone)
                }
                
                Spacer().frame(height: 4)
                
                // Horizontal Badges Carousel
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(achievements) { achievement in
                            badgeTile(achievement)
                        }
                    }
                }
            }
        }
    }
    
    private func nextMilestoneBanner(_ achievement: Achievement) -> some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: achievement.icon)
                    .font(.title3)
                    .foregroundStyle(AppColors.primary)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text("Next Goal: \(achievement.title)")
                        .font(AppFont.headline())
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Text("\(Int(achievement.progress * 100))%")
                        .font(AppFont.caption())
                        .bold()
                        .foregroundStyle(AppColors.primary)
                }
                
                ProgressView(value: achievement.progress)
                    .tint(AppColors.primary)
                
                Text(achievement.description)
                    .font(AppFont.caption())
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .fill(AppColors.primary.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func badgeTile(_ achievement: Achievement) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked
                        ? AnyShapeStyle(LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        : AnyShapeStyle(Color.gray.opacity(0.12))
                    )
                    .frame(width: 52, height: 52)
                    .shadow(
                        color: achievement.isUnlocked ? AppColors.primary.opacity(0.3) : Color.clear,
                        radius: 6, x: 0, y: 3
                    )
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundStyle(achievement.isUnlocked ? .white : Color.gray.opacity(0.5))
            }
            
            Text(achievement.title)
                .font(AppFont.caption())
                .fontWeight(achievement.isUnlocked ? .bold : .medium)
                .foregroundStyle(achievement.isUnlocked ? AppColors.textPrimary : AppColors.textSecondary)
                .lineLimit(1)
            
            if achievement.isUnlocked {
                Label("Unlocked", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(AppColors.success)
            } else {
                Text("\(Int(achievement.progress * 100))%")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(width: 100, height: 120)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .fill(AppColors.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(
                    achievement.isUnlocked ? AppColors.primary.opacity(0.3) : AppColors.border,
                    lineWidth: 1
                )
        )
    }
}
