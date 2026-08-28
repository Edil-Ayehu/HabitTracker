//
//  HabitIconPicker.swift
//  HabitTracker
//

import SwiftUI

struct HabitIconPicker: View {
    @Binding var selected: HabitIcon
    
    var body: some View {
        ZStack(alignment: .trailing) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(HabitIcon.allCases) { icon in
                        let isSelected = selected == icon
                        
                        VStack(spacing: 4) {
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        isSelected
                                        ? AnyShapeStyle(
                                            LinearGradient(
                                                colors: [AppColors.primary, Color.indigo],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        : AnyShapeStyle(Color.gray.opacity(0.08))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 1.5)
                                    )
                                    .shadow(color: isSelected ? AppColors.primary.opacity(0.3) : .clear, radius: 6, x: 0, y: 3)
                                
                                Image(systemName: icon.rawValue)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
                                    .frame(width: 48, height: 48)
                                
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.white)
                                        .background(Circle().fill(AppColors.primary))
                                        .offset(x: 3, y: -3)
                                }
                            }
                            
                            Text(icon.title)
                                .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                                .foregroundStyle(isSelected ? AppColors.primary : AppColors.textSecondary)
                        }
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selected = icon
                            AudioManager.shared.playClickSound()
                        }
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
            }
            
            LinearGradient(
                colors: [Color.clear, AppColors.card.opacity(0.85)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 24)
            .allowsHitTesting(false)
        }
    }
}
