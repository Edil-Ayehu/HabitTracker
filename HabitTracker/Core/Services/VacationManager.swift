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
    
    let maxVacationDaysPerYear: Int = 14
    @Published var usedVacationDaysThisYear: Int = 0
    @Published var vacationState: VacationMode?
    
    private init() {
        loadState()
    }
    
    private func currentYearKey() -> String {
        let year = Calendar.current.component(.year, from: Date())
        return "usedVacationDays_\(year)"
    }
    
    private func loadState() {
        let yearKey = currentYearKey()
        self.usedVacationDaysThisYear = UserDefaults.standard.integer(forKey: yearKey)
        
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
        let yearKey = currentYearKey()
        UserDefaults.standard.set(usedVacationDaysThisYear, forKey: yearKey)
        
        if let state = vacationState, let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: "vacationModeStateData")
        } else {
            UserDefaults.standard.removeObject(forKey: "vacationModeStateData")
        }
        UserDefaults.standard.synchronize()
    }
    
    var remainingVacationDaysThisYear: Int {
        max(0, maxVacationDaysPerYear - usedVacationDaysThisYear)
    }
    
    var isVacationActive: Bool {
        guard let state = vacationState else { return false }
        if Date() > state.endDate {
            deactivateVacation()
            return false
        }
        return state.isActive
    }
    
    func calculateDaysBetween(start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        let s = calendar.startOfDay(for: start)
        let e = calendar.startOfDay(for: end)
        let components = calendar.dateComponents([.day], from: s, to: e)
        return max(1, (components.day ?? 0) + 1)
    }
    
    func activateVacation(endDate: Date, reason: VacationReason, note: String) {
        let startDate = Date()
        let requestedDays = calculateDaysBetween(start: startDate, end: endDate)
        
        guard requestedDays <= remainingVacationDaysThisYear else { return }
        
        objectWillChange.send()
        usedVacationDaysThisYear += requestedDays
        
        let state = VacationMode(
            isActive: true,
            startDate: startDate,
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
        
        // Refund unused days if ending early
        if let state = vacationState, state.isActive {
            let today = Date()
            let calendar = Calendar.current
            let endDay = calendar.startOfDay(for: state.endDate)
            let todayDay = calendar.startOfDay(for: today)
            
            if endDay > todayDay {
                let unusedDays = (calendar.dateComponents([.day], from: todayDay, to: endDay).day ?? 0)
                if unusedDays > 0 {
                    usedVacationDaysThisYear = max(0, usedVacationDaysThisYear - unusedDays)
                }
            }
        }
        
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
