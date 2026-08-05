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
            context: ModelContext(container)
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
        
//        let context = ModelContext(container)
//        
//        let repository = HabitRepositoryImpl(context: context)
//        
//        let habitUseCase = HabitUseCaseImpl(
//            repository: repository
//        )
        
        return HomeViewModel(
            habitUseCase: makeHabitUseCase(),
            quoteUseCase: makeQuoteUseCase()
        )
    }
    
    func makeCreateHabitViewModel() -> CreateHabitViewModel {
        
//        let repository = HabitRepositoryImpl(
//            context: ModelContext(container)
//        )
//        
//        let useCase = HabitUseCaseImpl(
//            repository: repository
//        )
        
        return CreateHabitViewModel(
            habitUseCase: makeHabitUseCase()
        )
    }
    
    func makeHabitDetailViewModel(habit: Habit) -> HabitDetailViewModel {
        
//        let repository = HabitRepositoryImpl(
//            context: ModelContext(container)
//        )
//        
//        let useCase = HabitUseCaseImpl(
//            repository: repository
//        )
        
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
}
