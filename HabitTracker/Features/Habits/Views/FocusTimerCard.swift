//
//  FocusTimerCard.swift
//  HabitTracker
//

import SwiftUI

struct FocusTimerCard: View {
    var habitTitle: String = "Focus Session"
    var habitIcon: String = "timer"
    var habitID: String? = nil
    let onCompleteSession: () -> Void
    
    @ObservedObject private var timer = FocusTimerEngine.shared
    
    let presets = [5, 15, 25, 45, 60]
    
    @State private var localMinutes: Int = 25
    @State private var showCustomTimeSheet = false
    @State private var customMinutesInput: String = "25"
    @State private var showFullScreenMode = false
    
    var isCurrentHabitRunning: Bool {
        guard let id = habitID else { return timer.isRunning }
        return timer.activeHabitID == id
    }
    
    var displayIsRunning: Bool {
        isCurrentHabitRunning && timer.isRunning
    }
    
    var displayTimeFormatted: String {
        if isCurrentHabitRunning {
            return timer.timeFormatted
        } else {
            return String(format: "%02d:00", localMinutes)
        }
    }
    
    var displayProgress: Double {
        if isCurrentHabitRunning {
            return timer.progress
        } else {
            return 0.0
        }
    }
    
    var body: some View {
        CardView {
            VStack(spacing: AppSpacing.md) {
                // Header
                HStack {
                    Label("Focus Timer", systemImage: "timer")
                        .font(AppFont.headline())
                    
                    Spacer()
                    
                    if displayIsRunning {
                        Text("Active")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.success.opacity(0.15))
                            .foregroundStyle(AppColors.success)
                            .clipShape(Capsule())
                    } else if timer.isRunning && !isCurrentHabitRunning {
                        Text("Other Habit Active")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(Color.orange)
                            .clipShape(Capsule())
                    }
                    
                    Button {
                        if !isCurrentHabitRunning {
                            timer.setDuration(localMinutes, forHabitID: habitID)
                        }
                        showFullScreenMode = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.system(size: 11, weight: .bold))
                            Text("Full Screen")
                                .font(AppFont.caption())
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppColors.primary.opacity(0.12))
                        .foregroundStyle(AppColors.primary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                
                // Duration Presets & Custom Chip
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(presets, id: \.self) { min in
                            let selectedMin = isCurrentHabitRunning ? Int(timer.totalDuration) / 60 : localMinutes
                            let isSelected = selectedMin == min
                            Button {
                                localMinutes = min
                                timer.setDuration(min, forHabitID: habitID)
                            } label: {
                                Text("\(min) min")
                                    .font(AppFont.caption())
                                    .fontWeight(isSelected ? .bold : .medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(isSelected ? AppColors.primary.opacity(0.18) : Color.gray.opacity(0.1))
                                    .foregroundStyle(isSelected ? AppColors.primary : AppColors.textSecondary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // Custom Duration Chip
                        let selectedMin = isCurrentHabitRunning ? Int(timer.totalDuration) / 60 : localMinutes
                        let isCustomSelected = !presets.contains(selectedMin)
                        Button {
                            customMinutesInput = "\(selectedMin)"
                            showCustomTimeSheet = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 10))
                                Text(isCustomSelected ? "\(selectedMin) min" : "Custom")
                            }
                            .font(AppFont.caption())
                            .fontWeight(isCustomSelected ? .bold : .medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(isCustomSelected ? AppColors.primary.opacity(0.18) : Color.gray.opacity(0.1))
                            .foregroundStyle(isCustomSelected ? AppColors.primary : AppColors.textSecondary)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Circular Timer Ring (Tappable to edit duration)
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 10)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(displayProgress))
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.primary, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1.0), value: displayProgress)
                    
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Text(displayTimeFormatted)
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundStyle(AppColors.textPrimary)
                            
                            if !displayIsRunning {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(AppColors.primary.opacity(0.7))
                            }
                        }
                        
                        Text(displayIsRunning ? "Focusing..." : (isCurrentHabitRunning && timer.isFinished ? "Session Done! 🎉" : "Tap to Edit Time"))
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .frame(width: 160, height: 160)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .onTapGesture {
                    if !displayIsRunning {
                        let selectedMin = isCurrentHabitRunning ? Int(timer.totalDuration) / 60 : localMinutes
                        customMinutesInput = "\(selectedMin)"
                        showCustomTimeSheet = true
                    }
                }
                
                // Control Buttons
                HStack(spacing: 16) {
                    Button {
                        if displayIsRunning {
                            timer.pause()
                        } else {
                            if !isCurrentHabitRunning {
                                timer.setDuration(localMinutes, forHabitID: habitID)
                            }
                            timer.start(forHabitID: habitID)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: displayIsRunning ? "pause.fill" : "play.fill")
                            Text(displayIsRunning ? "Pause" : "Start Focus")
                        }
                        .font(AppFont.body())
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(displayIsRunning ? Color.orange : AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        if isCurrentHabitRunning {
                            timer.reset()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(AppColors.textSecondary)
                            .padding(12)
                            .background(Color.gray.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .alert("Set Custom Timer", isPresented: $showCustomTimeSheet) {
            TextField("Minutes (e.g. 12, 35, 90)", text: $customMinutesInput)
                .keyboardType(.numberPad)
            
            Button("Set Timer") {
                if let mins = Int(customMinutesInput.trimmingCharacters(in: .whitespacesAndNewlines)), mins > 0 {
                    localMinutes = mins
                    timer.setDuration(mins, forHabitID: habitID)
                }
            }
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter a custom duration in minutes for your focus session.")
        }
        .fullScreenCover(isPresented: $showFullScreenMode) {
            FullScreenFocusView(
                timer: timer,
                habitTitle: habitTitle,
                habitIcon: habitIcon,
                onDismiss: {},
                onCompleteSession: onCompleteSession
            )
        }
        .onChange(of: timer.isFinished) { _, finished in
            if finished && isCurrentHabitRunning {
                AudioManager.shared.playCelebrationSound()
                onCompleteSession()
            }
        }
    }
}
