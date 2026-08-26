//
//  ChallengeManager.swift
//  HabitTracker
//

import Foundation
import SwiftUI
import Combine

struct ChallengeProgressState: Codable, Identifiable {
    var id: String { challengeID }
    let challengeID: String
    var completedDays: Int
    var lastCheckInDate: String
}

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
    
    @Published var activeProgressMap: [String: ChallengeProgressState] = [:]
    @Published var completedChallengeIDsRaw: String = ""
    
    private init() {
        self.completedChallengeIDsRaw = UserDefaults.standard.string(forKey: "completedChallengeIDs") ?? ""
        loadActiveProgress()
    }
    
    private func loadActiveProgress() {
        if let data = UserDefaults.standard.data(forKey: "activeProgressMapData"),
           let map = try? JSONDecoder().decode([String: ChallengeProgressState].self, from: data) {
            self.activeProgressMap = map
        } else {
            // Migration for legacy single challenge
            let singleID = UserDefaults.standard.string(forKey: "activeChallengeID") ?? ""
            if !singleID.isEmpty {
                let days = UserDefaults.standard.integer(forKey: "challengeCompletedDays")
                let lastDate = UserDefaults.standard.string(forKey: "lastChallengeCheckInDate") ?? ""
                let state = ChallengeProgressState(challengeID: singleID, completedDays: days, lastCheckInDate: lastDate)
                self.activeProgressMap[singleID] = state
                saveActiveProgress()
            }
        }
    }
    
    private func saveActiveProgress() {
        if let data = try? JSONEncoder().encode(activeProgressMap) {
            UserDefaults.standard.set(data, forKey: "activeProgressMapData")
            UserDefaults.standard.synchronize()
        }
    }
    
    var activeChallenges: [HabitChallenge] {
        HabitChallenge.prebuiltChallenges.filter { activeProgressMap.keys.contains($0.id) }
    }
    
    var completedChallengeIDs: [String] {
        completedChallengeIDsRaw.components(separatedBy: ",").filter { !$0.isEmpty }
    }
    
    func enroll(in challenge: HabitChallenge) {
        guard activeProgressMap[challenge.id] == nil else { return }
        
        objectWillChange.send()
        let newState = ChallengeProgressState(challengeID: challenge.id, completedDays: 0, lastCheckInDate: "")
        activeProgressMap[challenge.id] = newState
        saveActiveProgress()
    }
    
    func progress(for challengeID: String) -> ChallengeProgressState? {
        return activeProgressMap[challengeID]
    }
    
    func isEnrolled(in challengeID: String) -> Bool {
        return activeProgressMap[challengeID] != nil
    }
    
    @discardableResult
    func checkInToday(for challengeID: String) -> Bool {
        let todayStr = ChallengeManager.todayISOString
        guard var state = activeProgressMap[challengeID] else { return false }
        guard state.lastCheckInDate != todayStr else { return false }
        
        objectWillChange.send()
        state.completedDays = min(30, state.completedDays + 1)
        state.lastCheckInDate = todayStr
        activeProgressMap[challengeID] = state
        
        var finished = false
        if state.completedDays >= 30, let challenge = HabitChallenge.prebuiltChallenges.first(where: { $0.id == challengeID }) {
            _ = QuestManager.shared.addXP(challenge.xpReward)
            var current = completedChallengeIDs
            if !current.contains(challengeID) {
                current.append(challengeID)
                let raw = current.joined(separator: ",")
                completedChallengeIDsRaw = raw
                UserDefaults.standard.set(raw, forKey: "completedChallengeIDs")
            }
            activeProgressMap.removeValue(forKey: challengeID)
            finished = true
        }
        
        saveActiveProgress()
        return finished
    }
    
    func isChallengeCompleted(_ challengeID: String) -> Bool {
        completedChallengeIDs.contains(challengeID)
    }
}
