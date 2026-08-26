//
//  ChallengeCard.swift
//  HabitTracker
//

import SwiftUI

struct ChallengeCard: View {
    let challenge: HabitChallenge
    let isEnrolled: Bool
    let isCompleted: Bool
    let onEnroll: () -> Void
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(AppColors.primary.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: challenge.icon)
                            .font(.title3)
                            .foregroundStyle(AppColors.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(challenge.title)
                            .font(AppFont.headline())
                        
                        Text("\(challenge.categoryTitle) • 30 Days")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    if isCompleted {
                        Text("Completed 🏆")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.15))
                            .foregroundStyle(Color.green)
                            .clipShape(Capsule())
                    } else if isEnrolled {
                        Text("Active ⚡️")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(Color.orange)
                            .clipShape(Capsule())
                    }
                }
                
                Text(challenge.description)
                    .font(AppFont.body())
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: challenge.badgeIcon)
                            .foregroundStyle(.orange)
                        Text(challenge.badgeTitle)
                            .font(AppFont.caption())
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    Text("+\(challenge.xpReward) XP")
                        .font(AppFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.primary)
                }
                .padding(8)
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                if !isEnrolled && !isCompleted {
                    Button {
                        onEnroll()
                    } label: {
                        Text("Enroll in Challenge")
                            .font(AppFont.body())
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(AppColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
            }
        }
    }
}
