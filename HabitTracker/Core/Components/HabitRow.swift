//
//  HabitRow.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

struct HabitRow: View {
    
    let entry: HabitEntry
    let onIncrement: () -> Void
    let onComplete: () -> Void
    let onTap: () -> Void

    var body: some View {
        CardView {
            HStack(spacing: AppSpacing.md) {
                
                // MARK: - Left Icon Container
                ZStack {
                    Circle()
                        .fill(entry.habit.habitColor.color.opacity(entry.completed ? 0.2 : 0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: entry.habit.icon)
                        .font(.title3)
                        .foregroundStyle(entry.habit.habitColor.color)
                }
                
                // MARK: - Middle Title & Metadata
                VStack(alignment: .leading, spacing: 5) {
                    
                    Text(entry.habit.title)
                        .font(AppFont.headline())
                        .foregroundStyle(entry.completed ? AppColors.textSecondary : AppColors.textPrimary)
                        .strikethrough(entry.completed, color: AppColors.textSecondary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        // Category Capsule Badge
                        HStack(spacing: 4) {
                            Image(systemName: entry.habit.habitCategory.icon)
                                .font(.system(size: 9))
                            Text(entry.habit.habitCategory.title)
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(entry.habit.habitCategory.color.opacity(0.12))
                        .foregroundStyle(entry.habit.habitCategory.color)
                        .clipShape(Capsule())
                        
                        // Status / Progress Subtitle
                        if entry.isFrozen {
                            HStack(spacing: 3) {
                                Image(systemName: "shield.fill")
                                    .font(.system(size: 9))
                                Text("Frozen 🛡️")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.cyan.opacity(0.18))
                            .foregroundStyle(Color.cyan)
                            .clipShape(Capsule())
                        } else if VacationManager.shared.isVacationActive && !entry.completed {
                            HStack(spacing: 3) {
                                Text(VacationManager.shared.vacationState?.reason.emoji ?? "🏖️")
                                    .font(.system(size: 9))
                                Text("Rest Day 🛡️")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.orange.opacity(0.18))
                            .foregroundStyle(Color.orange)
                            .clipShape(Capsule())
                        } else if entry.habit.habitType == .measurable {
                            Text("\(entry.progress)/\(entry.habit.goal ?? 1) \(entry.habit.unit ?? "")")
                                .font(AppFont.caption())
                                .foregroundStyle(AppColors.textSecondary)
                        } else {
                            Text(entry.completed ? "Done Today" : "Daily Goal")
                                .font(AppFont.caption())
                                .foregroundStyle(entry.completed ? AppColors.success : AppColors.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                // MARK: - Right Action Controls
                if entry.isFrozen {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.cyan)
                } else if entry.habit.habitType == .binary {
                    Button {
                        onComplete()
                    } label: {
                        Image(systemName: entry.completed ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 28))
                            .foregroundStyle(entry.completed ? AppColors.success : Color.gray.opacity(0.35))
                    }
                    .buttonStyle(.plain)
                    
                } else {
                    HStack(spacing: 8) {
                        Button {
                            onIncrement()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 26))
                                .foregroundStyle(entry.completed ? AppColors.success : entry.habit.habitColor.color)
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            onComplete()
                        } label: {
                            Image(systemName: entry.completed ? "checkmark.circle.fill" : "checkmark.circle")
                                .font(.system(size: 26))
                                .foregroundStyle(entry.completed ? AppColors.success : Color.gray.opacity(0.4))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
