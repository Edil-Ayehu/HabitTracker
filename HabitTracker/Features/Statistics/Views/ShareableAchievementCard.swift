//
//  ShareableAchievementCard.swift
//  HabitTracker
//

import SwiftUI

struct ShareableAchievementCard: View {
    let streak: Int
    let completedCount: Int
    let totalCount: Int
    let completionRate: Int
    let quoteText: String?
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [
                    Color(red: 0.39, green: 0.40, blue: 0.95), // Indigo
                    Color(red: 0.55, green: 0.36, blue: 0.96)  // Purple
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Decorative Background Circles
            VStack {
                HStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 160, height: 160)
                        .offset(x: -40, y: -40)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 200, height: 200)
                        .offset(x: 50, y: 50)
                }
            }
            
            VStack(spacing: 20) {
                // Header Branding
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .bold))
                        Text("HABIT TRACKER")
                            .font(.system(size: 12, weight: .black))
                            .tracking(1.5)
                    }
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.18))
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    Text(Date.now.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Central Streak Banner
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 90, height: 90)
                        
                        Image(systemName: "flame.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    
                    Text("\(streak) DAY STREAK!")
                        .font(.system(size: 26, weight: .black))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    Text("Building consistency every single day")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                }
                
                Spacer()
                
                // Stats Grid Container
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("\(completionRate)%")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Completion")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    VStack(spacing: 4) {
                        Text("\(completedCount)/\(totalCount)")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Habits Done")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
                if let quote = quoteText, !quote.isEmpty {
                    Text("“\(quote)”")
                        .font(.system(size: 12, weight: .medium))
                        .italic()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(2)
                        .padding(.top, 4)
                }
            }
            .padding(24)
        }
        .frame(width: 340, height: 440)
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }
}
