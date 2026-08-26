//
//  StreakFreezeManager.swift
//  HabitTracker
//

import Foundation
import SwiftUI

final class StreakFreezeManager {
    static let shared = StreakFreezeManager()
    
    @AppStorage("streakFreezeTokens") var storedTokens: Int = 2
    @AppStorage("lastFreezeRefillDate") var lastRefillDate: String = ""
    @AppStorage("userProfileXP") var storedXP: Int = 0
    
    private init() {
        checkDailyRefill()
    }
    
    var tokens: Int {
        checkDailyRefill()
        return storedTokens
    }
    
    func checkDailyRefill() {
        let todayStr = Date.now.formatted(date: .numeric, time: .omitted)
        if lastRefillDate != todayStr {
            // Refill back to 2 free tokens every new day
            if storedTokens < 2 {
                storedTokens = 2
            }
            lastRefillDate = todayStr
        }
    }
    
    func canUseToken() -> Bool {
        checkDailyRefill()
        return storedTokens > 0
    }
    
    func useToken() -> Bool {
        checkDailyRefill()
        guard storedTokens > 0 else { return false }
        storedTokens -= 1
        return true
    }
    
    func canBuyTokenWithXP() -> Bool {
        return storedXP >= 150
    }
    
    func buyTokenWithXP() -> Bool {
        guard storedXP >= 150 else { return false }
        storedXP -= 150
        storedTokens += 1
        return true
    }
}
