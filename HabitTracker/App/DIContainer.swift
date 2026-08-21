//
//  DIContainer.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import SwiftUI
import SwiftData

@MainActor
final class DIContainer {
    
    static let shared = DIContainer()
    
    private init() {}
    
    private var container: ModelContainer!
    
    func configure(container: ModelContainer) {
        self.container = container
    }
    
    func makeHabitUseCase() -> HabitUseCase {
        
        let repository = HabitRepositoryImpl(
            context: container.mainContext
        )
        
        return HabitUseCaseImpl(
            repository: repository
        )
    }
    
    func makeQuoteUseCase() -> QuoteUseCase {

        let repository = QuoteRepositoryImpl()

        return QuoteUseCaseImpl(
            quoteRepository: repository
        )
    }
    
    func makeHomeViewModel() -> HomeViewModel {        
        return HomeViewModel(
            habitUseCase: makeHabitUseCase(),
            quoteUseCase: makeQuoteUseCase()
        )
    }
    
    func makeCreateHabitViewModel() -> CreateHabitViewModel {
        
        return CreateHabitViewModel(
            habitUseCase: makeHabitUseCase()
        )
    }
    
    func makeHabitDetailViewModel(habit: Habit) -> HabitDetailViewModel {
        return HabitDetailViewModel(
            habit: habit,
            useCase: makeHabitUseCase()
        )
        
    }
    
    func makeEditHabitViewModel(
        habit: Habit
    ) -> CreateHabitViewModel {

        return CreateHabitViewModel(
            habitUseCase: makeHabitUseCase(),
            habit: habit
        )
    }
    
    func makeStatisticsViewModel() -> StatisticsViewModel {

        StatisticsViewModel(
            useCase: makeHabitUseCase()
        )
    }
}
