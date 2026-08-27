//
//  VacationManager.swift
//  HabitTracker
//

import Foundation
import SwiftUI
import Combine
import WidgetKit

final class VacationManager: ObservableObject {
    static let shared = VacationManager()
    
    @Published var vacationState: VacationMode?
    
    private init() {
        loadState()
    }
    
    private func loadState() {
        if let data = UserDefaults.standard.data(forKey: "vacationModeStateData"),
           let state = try? JSONDecoder().decode(VacationMode.self, from: data) {
            if Date() > state.endDate {
                self.vacationState = nil
                UserDefaults.standard.removeObject(forKey: "vacationModeStateData")
                UserDefaults.standard.synchronize()
            } else {
                self.vacationState = state
            }
        }
    }
    
    private func saveState() {
        if let state = vacationState, let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: "vacationModeStateData")
        } else {
            UserDefaults.standard.removeObject(forKey: "vacationModeStateData")
        }
        UserDefaults.standard.synchronize()
    }
    
    var isVacationActive: Bool {
        guard let state = vacationState else { return false }
        if Date() > state.endDate {
            deactivateVacation()
            return false
        }
        return state.isActive
    }
    
    func activateVacation(endDate: Date, reason: VacationReason, note: String) {
        objectWillChange.send()
        let state = VacationMode(
            isActive: true,
            startDate: Date(),
            endDate: endDate,
            reason: reason,
            note: note
        )
        self.vacationState = state
        saveState()
        WidgetSharedData.syncVacationState(isVacationActive: true, reasonEmoji: reason.emoji)
    }
    
    func deactivateVacation() {
        objectWillChange.send()
        self.vacationState = nil
        saveState()
        WidgetSharedData.syncVacationState(isVacationActive: false, reasonEmoji: "🏖️")
    }
    
    func isDateInVacation(_ date: Date) -> Bool {
        guard let state = vacationState, state.isActive else { return false }
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        let start = calendar.startOfDay(for: state.startDate)
        let end = calendar.startOfDay(for: state.endDate)
        return day >= start && day <= end
    }
}
