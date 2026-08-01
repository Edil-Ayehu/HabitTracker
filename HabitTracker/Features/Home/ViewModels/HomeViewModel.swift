//
//  HomeViewModel.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var greeting = "Good Morning"

    @Published var completedHabits = 3

    @Published var totalHabits = 7

    @Published var currentStreak = 12

    @Published var completionRate = 82

    func load() {

    }

}
