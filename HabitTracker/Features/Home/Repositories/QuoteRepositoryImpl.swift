//
//  QuoteRepositoryImpl.swift
//  HabitTracker
//
//  Created by Edil on 05/08/2026.
//

final class QuoteRepositoryImpl: QuoteRepository {

    func randomQuote() -> Quote {
        Quotes.all.randomElement()!
    }

}
