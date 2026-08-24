//
//  FocusTimerCard.swift
//  HabitTracker
//

import SwiftUI

struct FocusTimerCard: View {
    @StateObject private var timer = FocusTimerEngine()
    let onCompleteSession: () -> Void
    
    let presets = [5, 15, 25, 45, 60]
    
    @State private var showCustomTimeSheet = false
    @State private var customMinutesInput: String = "20"
    
    var body: some View {
        CardView {
            VStack(spacing: AppSpacing.md) {
                // Header
                HStack {
                    Label("Focus Timer", systemImage: "timer")
                        .font(AppFont.headline())
                    
                    Spacer()
                    
                    if timer.isRunning {
                        Text("Session Active")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.success.opacity(0.15))
                            .foregroundStyle(AppColors.success)
                            .clipShape(Capsule())
                    }
                }
                
                // Duration Presets & Custom Chip
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(presets, id: \.self) { min in
                            let isSelected = Int(timer.totalDuration) == min * 60
                            Button {
                                timer.setDuration(min)
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
                        let isCustomSelected = !presets.contains(Int(timer.totalDuration) / 60)
                        Button {
                            customMinutesInput = "\(Int(timer.totalDuration) / 60)"
                            showCustomTimeSheet = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 10))
                                Text(isCustomSelected ? "\(Int(timer.totalDuration) / 60) min" : "Custom")
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
                        .trim(from: 0, to: CGFloat(timer.progress))
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.primary, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1.0), value: timer.progress)
                    
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Text(timer.timeFormatted)
                                .font(.system(size: 36, weight: .black, design: .rounded))
                                .foregroundStyle(AppColors.textPrimary)
                            
                            if !timer.isRunning {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(AppColors.primary.opacity(0.7))
                            }
                        }
                        
                        Text(timer.isRunning ? "Focusing..." : (timer.isFinished ? "Session Done! 🎉" : "Tap to Edit Time"))
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .frame(width: 160, height: 160)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .onTapGesture {
                    if !timer.isRunning {
                        customMinutesInput = "\(Int(timer.totalDuration) / 60)"
                        showCustomTimeSheet = true
                    }
                }
                
                // Control Buttons
                HStack(spacing: 16) {
                    Button {
                        if timer.isRunning {
                            timer.pause()
                        } else {
                            timer.start()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                            Text(timer.isRunning ? "Pause" : "Start Focus")
                        }
                        .font(AppFont.body())
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(timer.isRunning ? Color.orange : AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        timer.reset()
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
                    timer.setDuration(mins)
                }
            }
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter a custom duration in minutes for your focus session.")
        }
        .onChange(of: timer.isFinished) { _, finished in
            if finished {
                AudioManager.shared.playCelebrationSound()
                onCompleteSession()
            }
        }
    }
}
