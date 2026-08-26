//
//  MoodAnalyticsCard.swift
//  HabitTracker
//

import SwiftUI

struct MoodAnalyticsCard: View {
    @StateObject private var manager = ReflectionManager.shared
    
    var body: some View {
        let recent = manager.fetchRecentReflections(days: 7)
        
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "face.smiling.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.yellow)
                        Text("Mood & Energy Trend")
                            .font(AppFont.headline())
                    }
                    
                    Spacer()
                    
                    if let latest = recent.last {
                        Text("\(latest.mood.title) \(latest.mood.emoji)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(latest.mood.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(latest.mood.color.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                
                if recent.isEmpty {
                    Text("No reflection logs recorded yet. Log your nightly reflection on the Home Screen!")
                        .font(AppFont.caption())
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.vertical, 8)
                } else {
                    // Mood Rating Horizontal Trend
                    HStack(alignment: .bottom, spacing: 12) {
                        ForEach(recent) { ref in
                            VStack(spacing: 6) {
                                Text(ref.mood.emoji)
                                    .font(.system(size: 18))
                                
                                GeometryReader { geo in
                                    VStack {
                                        Spacer(minLength: 0)
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(ref.mood.color.opacity(0.8))
                                            .frame(height: max(10, geo.size.height * (CGFloat(ref.moodScore) / 5.0)))
                                    }
                                }
                                .frame(height: 70)
                                
                                Text(ref.dateString.suffix(5)) // mm-dd
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }
                    }
                    .padding(.top, 8)
                    
                    if let latest = recent.last, !latest.gratitudeNote.isEmpty {
                        Divider()
                            .padding(.vertical, 4)
                        
                        HStack(alignment: .top, spacing: 6) {
                            Text("🌟 Gratitude:")
                                .font(AppFont.caption())
                                .fontWeight(.bold)
                                .foregroundStyle(.orange)
                            Text("\"\(latest.gratitudeNote)\"")
                                .font(AppFont.caption())
                                .foregroundStyle(AppColors.textPrimary)
                                .italic()
                        }
                    }
                }
            }
        }
    }
}
