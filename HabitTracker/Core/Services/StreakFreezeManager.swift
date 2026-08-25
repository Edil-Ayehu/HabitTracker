//
//  StreakFreezeManager.swift
//  HabitTracker
//

import Foundation
import SwiftUI

final class StreakFreezeManager {
    static let shared = StreakFreezeManager()
    
    @AppStorage("streakFreezeTokens") var tokens: Int = 2
    @AppStorage("userProfileXP") var storedXP: Int = 0
    
    private init() {}
    
    func canUseToken() -> Bool {
        return tokens > 0
    }
    
    func useToken() -> Bool {
        guard tokens > 0 else { return false }
        tokens -= 1
        return true
    }
    
    func canBuyTokenWithXP() -> Bool {
        return storedXP >= 150
    }
    
    func buyTokenWithXP() -> Bool {
        guard storedXP >= 150 else { return false }
        storedXP -= 150
        tokens += 1
        return true
    }
}
