//
//  AchievementCard.swift
//  HabitTracker
//

import SwiftUI

struct AchievementCard: View {
    
    let achievement: Achievement
    
    var body: some View {
        CardView {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(achievement.isUnlocked ? AppColors.primary.opacity(0.15) : Color.gray.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: achievement.icon)
                        .font(.title2)
                        .foregroundStyle(achievement.isUnlocked ? AppColors.primary : Color.gray.opacity(0.5))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(achievement.title)
                            .font(AppFont.headline())
                            .foregroundStyle(achievement.isUnlocked ? AppColors.textPrimary : AppColors.textSecondary)
                        
                        Spacer()
                        
                        if achievement.isUnlocked {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppColors.success)
                                .font(.subheadline)
                        } else {
                            Text("\(Int(achievement.progress * 100))%")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    
                    Text(achievement.description)
                        .font(AppFont.caption())
                        .foregroundStyle(AppColors.textSecondary)
                    
                    if !achievement.isUnlocked {
                        ProgressView(value: achievement.progress)
                            .tint(AppColors.primary)
                            .padding(.top, 2)
                    }
                }
            }
        }
        .opacity(achievement.isUnlocked ? 1.0 : 0.75)
    }
}
