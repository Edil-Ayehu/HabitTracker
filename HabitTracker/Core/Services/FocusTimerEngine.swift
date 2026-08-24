//
//  FocusTimerEngine.swift
//  HabitTracker
//

import Foundation
import Combine
import SwiftUI

final class FocusTimerEngine: ObservableObject {
    @Published var totalDuration: TimeInterval = 25 * 60 // Default 25 min
    @Published var timeRemaining: TimeInterval = 25 * 60
    @Published var isRunning: Bool = false
    @Published var isFinished: Bool = false
    
    private var timerCancellable: AnyCancellable?
    
    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return 1.0 - (timeRemaining / totalDuration)
    }
    
    var timeFormatted: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func setDuration(_ minutes: Int) {
        pause()
        totalDuration = TimeInterval(minutes * 60)
        timeRemaining = totalDuration
        isFinished = false
    }
    
    func start() {
        guard !isRunning else { return }
        if isFinished || timeRemaining <= 0 {
            timeRemaining = totalDuration
            isFinished = false
        }
        isRunning = true
        
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 1 {
                    self.timeRemaining -= 1
                } else {
                    self.timeRemaining = 0
                    self.isRunning = false
                    self.isFinished = true
                    self.timerCancellable?.cancel()
                }
            }
    }
    
    func pause() {
        isRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    func reset() {
        pause()
        timeRemaining = totalDuration
        isFinished = false
    }
}
