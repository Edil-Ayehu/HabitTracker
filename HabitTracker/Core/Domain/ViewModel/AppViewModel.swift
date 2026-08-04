//
//  AppViewModel.swift
//  HabitTracker
//
//  Created by Edil on 04/08/2026.
//

import Foundation

@MainActor
final class AppViewModel: ObservableObject {

    private let habitUseCase: HabitUseCase

    init(habitUseCase: HabitUseCase) {
        self.habitUseCase = habitUseCase
    }

    func start() async {

        await NotificationManager.shared.requestPermission()

        do {
            try habitUseCase.rescheduleReminders()
        } catch {
            print(error)
        }
    }
}
