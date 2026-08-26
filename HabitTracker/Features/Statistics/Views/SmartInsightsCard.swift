//
//  SmartInsightsCard.swift
//  HabitTracker
//

import SwiftUI

struct SmartInsightsCard: View {
    let tips: [String]
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.yellow)
                    Text("Smart Behavioral Insights")
                        .font(AppFont.headline())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Text(tip)
                                .font(AppFont.caption())
                                .foregroundStyle(AppColors.textPrimary)
                                .lineSpacing(3)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.yellow.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }
}
