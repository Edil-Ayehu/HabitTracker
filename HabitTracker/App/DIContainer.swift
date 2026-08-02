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
    
    func makeHomeViewModel() -> HomeViewModel {
        
        let context = ModelContext(container)
        
        let repository = HabitRepositoryImpl(context: context)
        
        let habitUseCase = HabitUseCaseImpl(
            repository: repository
        )
        
        return HomeViewModel(
            habitUseCase: habitUseCase
        )
    }
    
    func makeCreateHabitViewModel() -> CreateHabitViewModel {
        
        let repository = HabitRepositoryImpl(
            context: ModelContext(container)
        )
        
        let useCase = HabitUseCaseImpl(
            repository: repository
        )
        
        return CreateHabitViewModel(
            habitUseCase: useCase
        )
    }
    
    func makeHabitDetailViewModel(habit: Habit) -> HabitDetailViewModel {

        let repository = HabitRepositoryImpl(
            context: ModelContext(container)
        )

        let useCase = HabitUseCaseImpl(
            repository: repository
        )

        return HabitDetailViewModel(
            habit: habit,
            useCase: useCase
        )
    }
}
