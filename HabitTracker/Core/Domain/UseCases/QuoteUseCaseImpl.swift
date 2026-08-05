//
//  QuoteUseCaseImpl.swift
//  HabitTracker
//
//  Created by Edil on 05/08/2026.
//

final class QuoteUseCaseImpl: QuoteUseCase {
    
    private var quoteRepository: QuoteRepository
    
    init(quoteRepository: QuoteRepository) {
        self.quoteRepository = quoteRepository
    }
    
    func randomQuote() -> Quote {
        quoteRepository.randomQuote()
    }
}
