//
//  ChallengeManager.swift
//  HabitTracker
//

import Foundation
import SwiftUI
import Combine

final class ChallengeManager: ObservableObject {
    static let shared = ChallengeManager()
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    static var todayISOString: String {
        return dateFormatter.string(from: Date())
    }
    
    @Published var activeChallengeID: String
    @Published var completedDays: Int
    @Published var lastCheckInDate: String
    @Published var completedChallengeIDsRaw: String
    
    private init() {
        self.activeChallengeID = UserDefaults.standard.string(forKey: "activeChallengeID") ?? ""
        self.completedDays = UserDefaults.standard.integer(forKey: "challengeCompletedDays")
        self.lastCheckInDate = UserDefaults.standard.string(forKey: "lastChallengeCheckInDate") ?? ""
        self.completedChallengeIDsRaw = UserDefaults.standard.string(forKey: "completedChallengeIDs") ?? ""
    }
    
    var activeChallenge: HabitChallenge? {
        HabitChallenge.prebuiltChallenges.first(where: { $0.id == activeChallengeID })
    }
    
    var completedChallengeIDs: [String] {
        completedChallengeIDsRaw.components(separatedBy: ",").filter { !$0.isEmpty }
    }
    
    func enroll(in challenge: HabitChallenge) {
        // Prevent re-enrolling from resetting completed progress
        guard activeChallengeID != challenge.id else { return }
        
        objectWillChange.send()
        activeChallengeID = challenge.id
        completedDays = 0
        lastCheckInDate = ""
        
        UserDefaults.standard.set(challenge.id, forKey: "activeChallengeID")
        UserDefaults.standard.set(0, forKey: "challengeCompletedDays")
        UserDefaults.standard.set("", forKey: "lastChallengeCheckInDate")
        UserDefaults.standard.synchronize()
    }
    
    @discardableResult
    func checkInToday() -> Bool {
        let todayStr = ChallengeManager.todayISOString
        guard lastCheckInDate != todayStr else { return false }
        
        objectWillChange.send()
        let newDays = min(30, completedDays + 1)
        completedDays = newDays
        lastCheckInDate = todayStr
        
        UserDefaults.standard.set(newDays, forKey: "challengeCompletedDays")
        UserDefaults.standard.set(todayStr, forKey: "lastChallengeCheckInDate")
        
        var finished = false
        if newDays >= 30, let active = activeChallenge {
            _ = QuestManager.shared.addXP(active.xpReward)
            var current = completedChallengeIDs
            if !current.contains(active.id) {
                current.append(active.id)
                let raw = current.joined(separator: ",")
                completedChallengeIDsRaw = raw
                UserDefaults.standard.set(raw, forKey: "completedChallengeIDs")
            }
            activeChallengeID = ""
            UserDefaults.standard.set("", forKey: "activeChallengeID")
            finished = true
        }
        
        UserDefaults.standard.synchronize()
        return finished
    }
    
    func isChallengeCompleted(_ challengeID: String) -> Bool {
        completedChallengeIDs.contains(challengeID)
    }
}
