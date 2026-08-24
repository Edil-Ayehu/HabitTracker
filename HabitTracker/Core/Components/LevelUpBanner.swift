//
//  LevelUpBanner.swift
//  HabitTracker
//

import SwiftUI

struct LevelUpBanner: View {
    let profile: UserProfile
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: .orange.opacity(0.4), radius: 12, x: 0, y: 6)
                
                Image(systemName: profile.levelIcon)
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            VStack(spacing: 6) {
                Text("LEVEL UP! ⚡️")
                    .font(AppFont.title())
                    .fontWeight(.black)
                    .foregroundStyle(AppColors.textPrimary)
                
                Text("You reached Level \(profile.level)")
                    .font(AppFont.headline())
                    .foregroundStyle(AppColors.primary)
                
                Text("Title unlocked: \(profile.levelTitle)")
                    .font(AppFont.body())
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.textSecondary)
            }
            
            Button {
                onDismiss()
            } label: {
                Text("Awesome! 🚀")
                    .font(AppFont.headline())
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [AppColors.primary, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.card)
                .shadow(color: Color.black.opacity(0.25), radius: 24, x: 0, y: 12)
        )
        .padding(.horizontal, 24)
    }
}
