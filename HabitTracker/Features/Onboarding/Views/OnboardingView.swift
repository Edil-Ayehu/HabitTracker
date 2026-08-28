//
//  OnboardingView.swift
//  HabitTracker
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var currentTab: Int = 0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.lg) {
                // Header (Skip Button)
                HStack {
                    Spacer()
                    
                    Button {
                        completeOnboarding()
                    } label: {
                        Text("Skip")
                            .font(AppFont.caption())
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.md)
                
                // Page Carousel
                TabView(selection: $currentTab) {
                    ForEach(OnboardingData.slides) { slide in
                        VStack(spacing: AppSpacing.xl) {
                            Spacer()
                            
                            // Visual Icon Container
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: slide.gradientColors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 140, height: 140)
                                    .shadow(color: slide.gradientColors.first?.opacity(0.35) ?? .clear, radius: 20, x: 0, y: 10)
                                
                                Image(systemName: slide.iconName)
                                    .font(.system(size: 60))
                                    .foregroundStyle(.white)
                            }
                            
                            VStack(spacing: 10) {
                                Text(slide.badgeText)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(slide.gradientColors.first ?? AppColors.primary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background((slide.gradientColors.first ?? AppColors.primary).opacity(0.15))
                                    .clipShape(Capsule())
                                
                                Text(slide.title)
                                    .font(AppFont.title())
                                    .fontWeight(.bold)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .multilineTextAlignment(.center)
                                
                                Text(slide.subtitle)
                                    .font(AppFont.body())
                                    .foregroundStyle(AppColors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, AppSpacing.lg)
                            }
                            
                            Spacer()
                        }
                        .tag(slide.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Page Indicator Dots
                HStack(spacing: 8) {
                    ForEach(OnboardingData.slides) { slide in
                        Circle()
                            .fill(currentTab == slide.id ? slide.gradientColors.first ?? AppColors.primary : Color.gray.opacity(0.3))
                            .frame(width: currentTab == slide.id ? 10 : 8, height: currentTab == slide.id ? 10 : 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentTab)
                    }
                }
                .padding(.bottom, AppSpacing.sm)
                
                // Next / Get Started Button
                Button {
                    if currentTab < OnboardingData.slides.count - 1 {
                        withAnimation {
                            currentTab += 1
                        }
                        AudioManager.shared.playClickSound()
                    } else {
                        completeOnboarding()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(currentTab == OnboardingData.slides.count - 1 ? "Get Started 🚀" : "Next")
                        Image(systemName: "arrow.right")
                    }
                    .font(AppFont.headline())
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: OnboardingData.slides[currentTab].gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: OnboardingData.slides[currentTab].gradientColors.first?.opacity(0.3) ?? .clear, radius: 10, x: 0, y: 5)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xl)
            }
        }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
        AudioManager.shared.playCelebrationSound()
        dismiss()
    }
}
