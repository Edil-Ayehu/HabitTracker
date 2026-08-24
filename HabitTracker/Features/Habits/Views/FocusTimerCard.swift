//
//  FocusTimerCard.swift
//  HabitTracker
//

import SwiftUI

struct FocusTimerCard: View {
    @StateObject private var timer = FocusTimerEngine()
    let onCompleteSession: () -> Void
    
    let presets = [5, 15, 25, 45, 60]
    
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
                
                // Duration Presets
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
                    }
                }
                
                // Circular Timer Ring
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
                        Text(timer.timeFormatted)
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                        
                        Text(timer.isRunning ? "Focusing..." : (timer.isFinished ? "Session Done! 🎉" : "Ready"))
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .frame(width: 160, height: 160)
                .padding(.vertical, 8)
                
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
        .onChange(of: timer.isFinished) { _, finished in
            if finished {
                AudioManager.shared.playCelebrationSound()
                onCompleteSession()
            }
        }
    }
}
