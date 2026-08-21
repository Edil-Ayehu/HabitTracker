//
//  CelebrationBanner.swift
//  HabitTracker
//

import SwiftUI

struct CelebrationBanner: View {
    
    let title: String
    let subtitle: String
    var quoteText: String? = nil
    var quoteAuthor: String? = nil
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.15))
                    .frame(width: 64, height: 64)
                
                Text("🎉")
                    .font(.system(size: 34))
            }
            
            VStack(spacing: 6) {
                Text(title)
                    .font(AppFont.title())
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(AppFont.body())
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if let quoteText, !quoteText.isEmpty {
                VStack(spacing: 6) {
                    Text("\"\(quoteText)\"")
                        .font(AppFont.body())
                        .italic()
                        .foregroundStyle(AppColors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    if let quoteAuthor, !quoteAuthor.isEmpty {
                        Text("— \(quoteAuthor)")
                            .font(AppFont.caption())
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColors.primary)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity)
                .background(AppColors.primary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            Button {
                onDismiss()
            } label: {
                Text("Keep it up! 🙌")
                    .font(AppFont.headline())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.card)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 24)
    }
}
