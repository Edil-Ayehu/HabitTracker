//
//  LevelProgressCard.swift
//  HabitTracker
//

import SwiftUI

struct LevelProgressCard: View {
    let profile: UserProfile
    let quests: [DailyQuest]
    let onClaimQuest: (DailyQuest) -> Void
    
    @State private var isQuestsExpanded = false
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                // Header Level & Title
                HStack {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.primary, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: profile.levelIcon)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("Level \(profile.level)")
                                .font(AppFont.headline())
                            
                            Text(profile.levelTitle)
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(AppColors.primary.opacity(0.15))
                                .foregroundStyle(AppColors.primary)
                                .clipShape(Capsule())
                        }
                        
                        Text("\(profile.xp) Total XP")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring()) {
                            isQuestsExpanded.toggle()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "flag.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(AppColors.primary)
                            Text("Quests (\(quests.filter { $0.isCompleted && !$0.isClaimed }.count))")
                                .font(AppFont.caption())
                                .fontWeight(.bold)
                            Image(systemName: isQuestsExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppColors.primary.opacity(0.15))
                        .foregroundStyle(AppColors.primary)
                        .clipShape(Capsule())
                    }
                }
                
                // XP Progress Bar to Next Level
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Level Progress")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                        Spacer()
                        Text("\(profile.currentLevelXP)/100 XP to Level \(profile.level + 1)")
                            .font(AppFont.caption())
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColors.primary)
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 8)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColors.primary, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(8, geo.size.width * CGFloat(profile.progressToNextLevel)), height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                
                // Freeze Tokens Status & Purchase
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.cyan)
                        Text("\(StreakFreezeManager.shared.tokens) Freeze Tokens")
                            .font(AppFont.caption())
                    }
                    
                    Spacer()
                    
                    if StreakFreezeManager.shared.canBuyTokenWithXP() {
                        Button {
                            _ = StreakFreezeManager.shared.buyTokenWithXP()
                        } label: {
                            Text("Buy Token (150 XP)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.cyan)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.cyan.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Expandable Quests Section
                if isQuestsExpanded {
                    VStack(alignment: .leading, spacing: 10) {
                        Divider()
                            .padding(.vertical, 4)
                        
                        Text("Daily Quests")
                            .font(AppFont.caption())
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.textSecondary)
                        
                        ForEach(quests) { quest in
                            HStack(spacing: 12) {
                                Image(systemName: quest.icon)
                                    .font(.system(size: 18))
                                    .foregroundStyle(quest.isCompleted ? Color.green : AppColors.primary)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(quest.title)
                                        .font(AppFont.body())
                                        .fontWeight(.semibold)
                                    Text("\(quest.currentProgress)/\(quest.targetGoal) • +\(quest.rewardXP) XP")
                                        .font(AppFont.caption())
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                                
                                Spacer()
                                
                                if quest.isClaimed {
                                    Text("Claimed ✓")
                                        .font(AppFont.caption())
                                        .fontWeight(.bold)
                                        .foregroundStyle(.secondary)
                                } else if quest.isCompleted {
                                    Button {
                                        onClaimQuest(quest)
                                    } label: {
                                        Text("Claim +\(quest.rewardXP) XP")
                                            .font(AppFont.caption())
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.green)
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    Text("In Progress")
                                        .font(AppFont.caption())
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                            }
                            .padding(10)
                            .background(quest.isCompleted && !quest.isClaimed ? Color.green.opacity(0.1) : Color.gray.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}
