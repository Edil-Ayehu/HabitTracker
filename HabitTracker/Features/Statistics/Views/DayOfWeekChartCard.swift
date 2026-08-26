//
//  DayOfWeekChartCard.swift
//  HabitTracker
//

import SwiftUI

struct DayOfWeekChartCard: View {
    let insights: AnalyticsInsights
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                // Header & Grade Pill
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Day-of-Week Consistency")
                            .font(AppFont.headline())
                        
                        Text("Completion rate by day of week")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text(insights.grade)
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppColors.primary.opacity(0.15))
                        .foregroundStyle(AppColors.primary)
                        .clipShape(Capsule())
                }
                
                // 7-Day Bar Chart Grid
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(insights.weekdayStats) { stat in
                        let isBest = insights.bestDay?.dayName == stat.dayName && stat.completionRate > 0
                        
                        VStack(spacing: 6) {
                            Text("\(stat.completionRate)%")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(isBest ? AppColors.primary : AppColors.textSecondary)
                            
                            GeometryReader { geo in
                                VStack {
                                    Spacer(minLength: 0)
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            isBest
                                            ? LinearGradient(colors: [AppColors.primary, Color.purple], startPoint: .bottom, endPoint: .top)
                                            : LinearGradient(colors: [Color.indigo.opacity(0.4), Color.indigo.opacity(0.2)], startPoint: .bottom, endPoint: .top)
                                        )
                                        .frame(height: max(6, geo.size.height * (CGFloat(stat.completionRate) / 100.0)))
                                }
                            }
                            .frame(height: 100)
                            
                            HStack(spacing: 2) {
                                if isBest {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 8))
                                        .foregroundStyle(.orange)
                                }
                                Text(stat.dayName)
                                    .font(.system(size: 11, weight: isBest ? .bold : .medium))
                                    .foregroundStyle(isBest ? AppColors.textPrimary : AppColors.textSecondary)
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}
