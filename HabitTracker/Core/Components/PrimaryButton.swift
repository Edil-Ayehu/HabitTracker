//
//  PrimaryButton.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct PrimaryButton: View {
    
    let title: String
    var isLoading: Bool = false
    var isEnabled: Bool = true
    var width: CGFloat? = nil
    var height: CGFloat = 56
    let action: () -> Void
    
    var body: some View {
        
        Button(action: action) {
            
            ZStack {
                
                if isLoading {
                    
                    ProgressView()
                        .tint(.white)
                    
                } else {
                    
                    Text(title)
                        .font(AppFont.headline())
                        .fontWeight(.semibold)
                }
                
            }
            .frame(maxWidth: width ?? .infinity)
            .frame(height: height)
            .background(
                isEnabled
                ? AppColors.buttonBackground
                : AppColors.border
            )
            .foregroundStyle(
                isEnabled
                ? Color.white
                : AppColors.textSecondary
            )
            .clipShape(
                RoundedRectangle(cornerRadius: AppRadius.lg)
            )
        }
        .buttonStyle(.plain)
//        .foregroundStyle(AppColors.textPrimary)
//        .background(AppColors.background)
//        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .disabled(!isEnabled || isLoading)
    }
}
