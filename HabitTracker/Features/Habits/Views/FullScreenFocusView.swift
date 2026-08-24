//
//  FullScreenFocusView.swift
//  HabitTracker
//

import SwiftUI

struct FullScreenFocusView: View {
    @ObservedObject var timer: FocusTimerEngine
    let habitTitle: String
    let habitIcon: String
    let onDismiss: () -> Void
    let onCompleteSession: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Immersive Dark Background Gradient
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.09, blue: 0.18),
                    Color(red: 0.04, green: 0.04, blue: 0.10)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Subtle Background Pulsing Glow
            Circle()
                .fill(Color.indigo.opacity(timer.isRunning ? 0.25 : 0.1))
                .frame(width: 340, height: 340)
                .blur(radius: 50)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: timer.isRunning)
            
            VStack(spacing: AppSpacing.lg) {
                // Top Header Bar
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: habitIcon)
                            .font(.system(size: 16))
                            .foregroundStyle(Color.indigo)
                        Text(habitTitle)
                            .font(AppFont.headline())
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                        onDismiss()
                    } label: {
                        Image(systemName: "arrow.down.right.and.arrow.up.left.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // Giant Circular Countdown Timer
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 14)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(timer.progress))
                        .stroke(
                            LinearGradient(
                                colors: [Color.indigo, Color.purple, Color.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1.0), value: timer.progress)
                    
                    VStack(spacing: 8) {
                        Text(timer.timeFormatted)
                            .font(.system(size: 64, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .shadow(color: Color.purple.opacity(0.5), radius: 10, x: 0, y: 4)
                        
                        Text(timer.isRunning ? "Deep Focus Session" : (timer.isFinished ? "Session Completed! 🎉" : "Ready to Focus"))
                            .font(AppFont.body())
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .frame(width: 270, height: 270)
                
                // Motivational Quote
                Text("“Focus is a muscle. The more you practice, the easier it gets.”")
                    .font(AppFont.body())
                    .italic()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.horizontal, 36)
                    .padding(.top, 8)
                
                Spacer()
                
                // Bottom Controls Bar
                HStack(spacing: 24) {
                    Button {
                        if timer.isRunning {
                            timer.pause()
                        } else {
                            timer.start()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                                .font(.system(size: 20))
                            Text(timer.isRunning ? "Pause" : "Resume Focus")
                                .font(AppFont.headline())
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: timer.isRunning ? [.orange, .red] : [Color.indigo, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.indigo.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        timer.reset()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(16)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 40)
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
