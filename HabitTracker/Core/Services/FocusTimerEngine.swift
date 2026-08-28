//
//  FocusTimerEngine.swift
//  HabitTracker
//

import Foundation
import Combine
import SwiftUI

final class FocusTimerEngine: ObservableObject {
    static let shared = FocusTimerEngine()
    
    @Published var totalDuration: TimeInterval = 25 * 60 // Default 25 min
    @Published var timeRemaining: TimeInterval = 25 * 60
    @Published var isRunning: Bool = false
    @Published var isFinished: Bool = false
    @Published var activeHabitID: String? = nil
    
    private var targetEndDate: Date?
    private var timerCancellable: AnyCancellable?
    
    init() {
        startTimerPublisher()
    }
    
    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return 1.0 - (timeRemaining / totalDuration)
    }
    
    var timeFormatted: String {
        let minutes = max(0, Int(timeRemaining)) / 60
        let seconds = max(0, Int(timeRemaining)) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func setDuration(_ minutes: Int, forHabitID habitID: String? = nil) {
        if let habitID = habitID, activeHabitID != habitID {
            pause()
            activeHabitID = habitID
        }
        if !isRunning {
            totalDuration = TimeInterval(minutes * 60)
            timeRemaining = totalDuration
            isFinished = false
            targetEndDate = nil
        }
    }
    
    func start(forHabitID habitID: String? = nil) {
        if let habitID = habitID {
            activeHabitID = habitID
        }
        guard !isRunning else { return }
        
        if isFinished || timeRemaining <= 0 {
            timeRemaining = totalDuration
            isFinished = false
        }
        
        targetEndDate = Date().addingTimeInterval(timeRemaining)
        isRunning = true
        startTimerPublisher()
    }
    
    func pause() {
        if isRunning {
            updateTimeRemainingFromTargetDate()
        }
        isRunning = false
        targetEndDate = nil
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    func reset() {
        pause()
        timeRemaining = totalDuration
        isFinished = false
        targetEndDate = nil
    }
    
    private func startTimerPublisher() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    private func tick() {
        guard isRunning, let target = targetEndDate else { return }
        let now = Date()
        let remaining = target.timeIntervalSince(now)
        
        if remaining > 0 {
            self.timeRemaining = remaining
        } else {
            self.timeRemaining = 0
            self.isRunning = false
            self.isFinished = true
            self.targetEndDate = nil
            self.timerCancellable?.cancel()
        }
    }
    
    private func updateTimeRemainingFromTargetDate() {
        guard let target = targetEndDate else { return }
        let remaining = max(0, target.timeIntervalSince(Date()))
        self.timeRemaining = remaining
    }
}
