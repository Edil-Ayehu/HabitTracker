//
//  AudioManager.swift
//  HabitTracker
//

import Foundation
import AudioToolbox
import SwiftUI

final class AudioManager {
    static let shared = AudioManager()
    
    @AppStorage("soundEffectsEnabled") var isSoundEnabled: Bool = true
    
    private init() {}
    
    /// Ascending 2-note sparkling completion chime
    func playCompletionSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1057)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.09) {
            AudioServicesPlaySystemSound(1001)
        }
    }
    
    /// Triumphant 3-note fanfare celebration chord
    func playCelebrationSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1025)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            AudioServicesPlaySystemSound(1016)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                AudioServicesPlaySystemSound(1001)
            }
        }
    }
    
    /// Subtle UI click feedback
    func playClickSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1104)
    }
}
