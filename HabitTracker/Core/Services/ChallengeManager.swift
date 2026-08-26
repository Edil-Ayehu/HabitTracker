//
//  ChallengeManager.swift
//  HabitTracker
//

import Foundation
import SwiftUI

final class ChallengeManager: ObservableObject {
    static let shared = ChallengeManager()
    
    @AppStorage("activeChallengeID") var activeChallengeID: String = ""
    @AppStorage("challengeCompletedDays") var completedDays: Int = 0
    @AppStorage("lastChallengeCheckInDate") var lastCheckInDate: String = ""
    @AppStorage("completedChallengeIDs") var completedChallengeIDsRaw: String = ""
    
    private init() {}
    
    var activeChallenge: HabitChallenge? {
        HabitChallenge.prebuiltChallenges.first(where: { $0.id == activeChallengeID })
    }
    
    var completedChallengeIDs: [String] {
        completedChallengeIDsRaw.components(separatedBy: ",").filter { !$0.isEmpty }
    }
    
    func enroll(in challenge: HabitChallenge) {
        activeChallengeID = challenge.id
        completedDays = 0
        lastCheckInDate = ""
    }
    
    func checkInToday() -> Bool {
        let todayStr = Date.now.formatted(date: .numeric, time: .omitted)
        guard lastCheckInDate != todayStr else { return false }
        
        lastCheckInDate = todayStr
        completedDays = min(30, completedDays + 1)
        
        if completedDays >= 30, let active = activeChallenge {
            _ = QuestManager.shared.addXP(active.xpReward)
            var current = completedChallengeIDs
            if !current.contains(active.id) {
                current.append(active.id)
                completedChallengeIDsRaw = current.joined(separator: ",")
            }
            activeChallengeID = ""
            return true
        }
        return false
    }
    
    func isChallengeCompleted(_ challengeID: String) -> Bool {
        completedChallengeIDs.contains(challengeID)
    }
}
