//
//  HabitRow.swift
//  HabitTracker
//

import SwiftUI

struct HabitRow: View {
    let entry: HabitEntry
    var streakCount: Int = 0
    let onIncrement: () -> Void
    let onComplete: () -> Void
    let onTap: () -> Void
    var onToggleSubTask: ((UUID) -> Void)? = nil
    
    @ObservedObject private var vacationManager = VacationManager.shared

    var body: some View {
        CardView {
            HStack(alignment: .top, spacing: AppSpacing.md) {
                
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
                VStack(alignment: .leading, spacing: 4) {
                    
                    // Line 1: Title
                    Text(entry.habit.title)
                        .font(AppFont.headline())
                        .foregroundStyle(entry.completed ? AppColors.textSecondary : AppColors.textPrimary)
                        .strikethrough(entry.completed, color: AppColors.textSecondary)
                        .lineLimit(1)
                    
                    // Line 2: Status / Progress Subtitle
                    HStack(spacing: 6) {
                        if entry.isFrozen {
                            HStack(spacing: 3) {
                                Image(systemName: "shield.fill")
                                    .font(.system(size: 9))
                                Text("Frozen 🛡️")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Color.cyan.opacity(0.18))
                            .foregroundStyle(Color.cyan)
                            .clipShape(Capsule())
                        } else if vacationManager.isVacationActive && !entry.completed {
                            HStack(spacing: 3) {
                                Text(vacationManager.vacationState?.reason.emoji ?? "🏖️")
                                    .font(.system(size: 9))
                                Text("Rest Day 🛡️")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.18))
                            .foregroundStyle(Color.orange)
                            .clipShape(Capsule())
                        } else if entry.habit.habitType == .measurable {
                            Text("\(entry.progress)/\(entry.habit.goal ?? 1) \(entry.habit.unit ?? "")")
                                .font(AppFont.caption())
                                .foregroundStyle(AppColors.textSecondary)
                        } else {
                            switch entry.habit.frequency {
                            case .daily:
                                Text(entry.completed ? "Done Today" : "Daily Goal")
                                    .font(AppFont.caption())
                                    .foregroundStyle(entry.completed ? AppColors.success : AppColors.textSecondary)
                            case .weekly:
                                Text(entry.completed ? "Completed for this week 📅" : "Due this week 📅")
                                    .font(AppFont.caption())
                                    .foregroundStyle(entry.completed ? AppColors.success : Color.purple)
                            case .monthly:
                                Text(entry.completed ? "Completed for this month 🗓️" : "Due this month 🗓️")
                                    .font(AppFont.caption())
                                    .foregroundStyle(entry.completed ? AppColors.success : Color.indigo)
                            }
                        }
                    }
                    
                    // Line 3: Clean Capsule Badges (Category • Streak • Time of Day • Frequency • Subtasks)
                    HStack(spacing: 6) {
                        // Category Capsule Badge
                        HStack(spacing: 3) {
                            Image(systemName: entry.habit.habitCategory.icon)
                                .font(.system(size: 9))
                            Text(entry.habit.habitCategory.title)
                                .font(.system(size: 9, weight: .semibold))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(entry.habit.habitCategory.color.opacity(0.12))
                        .foregroundStyle(entry.habit.habitCategory.color)
                        .clipShape(Capsule())
                        
                        // Individual Habit Streak Badge
                        if streakCount > 0 {
                            HStack(spacing: 3) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 9))
                                    .foregroundStyle(Color.orange)
                                Text("\(streakCount)d streak")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.14))
                            .foregroundStyle(Color.orange)
                            .clipShape(Capsule())
                        }
                        
                        // Time of Day Capsule Badge
                        if entry.habit.habitTimeOfDay != .anyTime {
                            HStack(spacing: 3) {
                                Image(systemName: entry.habit.habitTimeOfDay.icon)
                                    .font(.system(size: 9))
                                Text(entry.habit.habitTimeOfDay.shortTitle)
                                    .font(.system(size: 9, weight: .semibold))
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(entry.habit.habitTimeOfDay.themeColor.opacity(0.12))
                            .foregroundStyle(entry.habit.habitTimeOfDay.themeColor)
                            .clipShape(Capsule())
                        }
                        
                        // Sub-tasks Progress Badge
                        if !entry.habit.subTasks.isEmpty {
                            let completedCount = entry.habit.subTasks.filter { entry.completedSubTaskIDs.contains($0.id) }.count
                            HStack(spacing: 3) {
                                Image(systemName: "checklist")
                                    .font(.system(size: 9))
                                Text("\(completedCount)/\(entry.habit.subTasks.count)")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppColors.primary.opacity(0.12))
                            .foregroundStyle(AppColors.primary)
                            .clipShape(Capsule())
                        }
                        
                        // Frequency Capsule Badge (for Weekly & Monthly)
                        if entry.habit.frequency != .daily {
                            HStack(spacing: 3) {
                                Image(systemName: entry.habit.frequency == .weekly ? "calendar" : "calendar.badge.clock")
                                    .font(.system(size: 9))
                                Text(entry.habit.frequency.title)
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.15))
                            .foregroundStyle(Color.purple)
                            .clipShape(Capsule())
                        }
                    }
                    
                    // Line 4: Interactive Checklist Items
                    if !entry.habit.subTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(entry.habit.subTasks) { subTask in
                                let isDone = entry.completedSubTaskIDs.contains(subTask.id)
                                Button {
                                    onToggleSubTask?(subTask.id)
                                    AudioManager.shared.playClickSound()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: isDone ? "checkmark.square.fill" : "square")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(isDone ? AppColors.success : AppColors.textSecondary)
                                        
                                        Text(subTask.title)
                                            .font(AppFont.caption())
                                            .foregroundStyle(isDone ? AppColors.textSecondary : AppColors.textPrimary)
                                            .strikethrough(isDone, color: AppColors.textSecondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 4)
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
