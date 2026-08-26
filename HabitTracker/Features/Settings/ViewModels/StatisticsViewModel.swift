//
//  StatisticsViewModel.swift
//  HabitTracker
//
//  Created by Edil on 05/08/2026.
//
import SwiftUI

@MainActor
final class StatisticsViewModel: ObservableObject {

    @Published var statistics: HabitStatistics?

    @Published var weekly: [DailyCompletion] = []

    @Published var habits: [HabitProgress] = []
    
    @Published var analyticsInsights: AnalyticsInsights?
    @Published var categoryBalance: [CategoryBalance] = []

    private let useCase: HabitUseCase

    init(useCase: HabitUseCase) {
        self.useCase = useCase
    }

    func load() {

        do {

            statistics = try useCase.fetchStatistics()

            weekly = try useCase.weeklyCompletion()

            habits = try useCase.habitProgress()
            
            categoryBalance = (try? useCase.categoryBalance()) ?? []
            
            let allEntries = try useCase.fetchAllEntries()
            analyticsInsights = HabitAnalyticsEngine.shared.analyze(entries: allEntries)

        } catch {

        }
    }
}
