//
//  StoryRecapView.swift
//  HabitTracker
//

import SwiftUI

struct StoryRecapView: View {
    let period: RecapPeriod
    
    @EnvironmentObject private var router: AppRouter
    @State private var currentSlide: Int = 0
    @State private var recapData: StoryRecapData?
    @State private var shareItem: IdentifiableImage?
    
    private let totalSlides = 5
    private let timer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()
    
    private let habitUseCase = DIContainer.shared.makeHabitUseCase()

    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [Color.black, Color(red: 0.08, green: 0.05, blue: 0.18), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if let data = recapData {
                VStack(spacing: 20) {
                    
                    // MARK: - Top Progress Bars & Close Button
                    VStack(spacing: 12) {
                        HStack(spacing: 4) {
                            ForEach(0..<totalSlides, id: \.self) { index in
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.white.opacity(0.3))
                                        
                                        Capsule()
                                            .fill(Color.white)
                                            .frame(width: index < currentSlide ? geo.size.width : (index == currentSlide ? geo.size.width : 0))
                                    }
                                }
                                .frame(height: 3)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        HStack {
                            Text(data.title.uppercased())
                                .font(.system(size: 11, weight: .black))
                                .foregroundStyle(Color.white.opacity(0.7))
                                .tracking(1.5)
                            
                            Spacer()
                            
                            Button {
                                router.pop()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color.white.opacity(0.7))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 12)
                    
                    Spacer()
                    
                    // MARK: - Slide Content
                    Group {
                        switch currentSlide {
                        case 0:
                            slideOverview(data: data)
                        case 1:
                            slideChampion(data: data)
                        case 2:
                            slidePeakDay(data: data)
                        case 3:
                            slideMood(data: data)
                        default:
                            slideXPAndShare(data: data)
                        }
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                    
                    Spacer()
                    
                    Text("Tap left to go back • Tap right to advance")
                        .font(AppFont.caption())
                        .foregroundStyle(Color.white.opacity(0.4))
                        .padding(.bottom, 20)
                }
                .contentShape(Rectangle())
                .onTapGesture { location in
                    let screenWidth = UIScreen.main.bounds.width
                    if location.x < screenWidth / 3 {
                        if currentSlide > 0 { currentSlide -= 1 }
                    } else {
                        if currentSlide < totalSlides - 1 {
                            currentSlide += 1
                        } else {
                            router.pop()
                        }
                    }
                }
            } else {
                ProgressView()
                    .tint(.white)
            }
        }
        .onAppear {
            loadRecap()
        }
        .onReceive(timer) { _ in
            if currentSlide < totalSlides - 1 {
                withAnimation { currentSlide += 1 }
            }
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.image])
        }
    }
    
    // MARK: - Slide 1: Overview
    private func slideOverview(data: StoryRecapData) -> some View {
        VStack(spacing: 24) {
            Text(data.dateRangeString)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(AppColors.primary.opacity(0.2))
                .clipShape(Capsule())
            
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 16)
                    .frame(width: 180, height: 180)
                
                Circle()
                    .trim(from: 0, to: CGFloat(data.completionRate) / 100.0)
                    .stroke(
                        LinearGradient(colors: [AppColors.primary, Color.purple], startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(data.completionRate)%")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(Color.white)
                    Text("Completion")
                        .font(AppFont.caption())
                        .foregroundStyle(Color.white.opacity(0.7))
                }
            }
            
            VStack(spacing: 8) {
                Text("\(data.totalCheckIns) Check-ins Logged 🎉")
                    .font(AppFont.title())
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
                
                Text("Consistency transforms daily action into lifelong mastery.")
                    .font(AppFont.body())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white.opacity(0.8))
                    .padding(.horizontal, 32)
            }
        }
    }
    
    // MARK: - Slide 2: Champion Habit
    private func slideChampion(data: StoryRecapData) -> some View {
        VStack(spacing: 20) {
            Text("🏆 CHAMPION HABIT")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(Color.yellow)
                .tracking(2)
            
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 120, height: 120)
                
                Image(systemName: data.championHabitIcon ?? "star.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(Color.yellow)
            }
            
            Text(data.championHabitTitle ?? "Daily Goal")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.white)
            
            Text("\(data.championHabitCount) Check-ins Completed")
                .font(AppFont.headline())
                .foregroundStyle(Color.white.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.1))
                .clipShape(Capsule())
        }
    }
    
    // MARK: - Slide 3: Peak Day
    private func slidePeakDay(data: StoryRecapData) -> some View {
        VStack(spacing: 20) {
            Text("🚀 PEAK PRODUCTIVITY")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(Color.cyan)
                .tracking(2)
            
            Text(data.peakDayName)
                .font(.system(size: 48, weight: .black))
                .foregroundStyle(LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .leading, endPoint: .trailing))
            
            Text("Your Most Active Day")
                .font(AppFont.headline())
                .foregroundStyle(Color.white.opacity(0.8))
            
            Text("You completed \(data.peakDayCount) habit check-ins on \(data.peakDayName)s!")
                .font(AppFont.body())
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.white.opacity(0.7))
                .padding(.horizontal, 32)
        }
    }
    
    // MARK: - Slide 4: Mood & Vibe Check
    private func slideMood(data: StoryRecapData) -> some View {
        VStack(spacing: 20) {
            Text("🎭 MOOD & VIBE CHECK")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(Color.pink)
                .tracking(2)
            
            Text(data.dominantMoodEmoji)
                .font(.system(size: 90))
            
            Text(data.dominantMoodTitle)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color.white)
            
            Text("Dominant mood recorded in your nightly reflection journal.")
                .font(AppFont.body())
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.white.opacity(0.7))
                .padding(.horizontal, 32)
        }
    }
    
    // MARK: - Slide 5: XP & Share Card
    private func slideXPAndShare(data: StoryRecapData) -> some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("⚡ RECAP SUMMARY")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(AppColors.primary)
                    .tracking(2)
                
                Text("+\(data.xpEarned) XP Earned")
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(LinearGradient(colors: [AppColors.primary, Color.purple], startPoint: .leading, endPoint: .trailing))
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Period:")
                        .foregroundStyle(Color.white.opacity(0.6))
                    Spacer()
                    Text(data.dateRangeString)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                }
                HStack {
                    Text("Check-ins:")
                        .foregroundStyle(Color.white.opacity(0.6))
                    Spacer()
                    Text("\(data.totalCheckIns)")
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                }
                HStack {
                    Text("Top Habit:")
                        .foregroundStyle(Color.white.opacity(0.6))
                    Spacer()
                    Text(data.championHabitTitle ?? "Consistency")
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.primary)
                }
            }
            .font(AppFont.body())
            .padding(20)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 32)
            
            Button {
                renderAndShare(data: data)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up.fill")
                    Text("Share Story Recap Card")
                        .fontWeight(.bold)
                }
                .font(AppFont.body())
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(LinearGradient(colors: [AppColors.primary, Color.purple], startPoint: .leading, endPoint: .trailing))
                .clipShape(Capsule())
                .shadow(color: AppColors.primary.opacity(0.4), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(.plain)
        }
    }
    
    private func loadRecap() {
        let activeHabits = (try? habitUseCase.fetchHabits()) ?? []
        let archivedHabits = (try? habitUseCase.fetchArchivedHabits()) ?? []
        let allHabits = activeHabits + archivedHabits
        let entries = (try? habitUseCase.fetchAllEntries()) ?? []
        let reflections = ReflectionManager.shared.fetchAllReflections()
        
        recapData = RecapAnalyticsEngine.shared.generateRecap(
            period: period,
            habits: allHabits,
            entries: entries,
            reflections: reflections
        )
    }
    
    private func renderAndShare(data: StoryRecapData) {
        let card = ShareableAchievementCard(
            streak: data.totalCheckIns,
            completedCount: data.totalCheckIns,
            totalCount: max(1, data.totalCheckIns),
            completionRate: data.completionRate,
            quoteText: "\(data.period.rawValue) Recap: \(data.dominantMoodEmoji) \(data.dominantMoodTitle)"
        )
        let renderer = ImageRenderer(content: card)
        renderer.scale = UIScreen.main.scale
        if let image = renderer.uiImage {
            self.shareItem = IdentifiableImage(image: image)
        }
    }
}
