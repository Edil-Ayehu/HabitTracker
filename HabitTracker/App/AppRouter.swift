//
//  AppRouter.swift
//  HabitTracker
//
//  Created by Edil on 01/08/2026.
//

import SwiftUI

@MainActor
final class AppRouter: ObservableObject {

    @Published var path = NavigationPath()

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
