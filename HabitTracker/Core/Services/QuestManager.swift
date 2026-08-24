//
//  QuestManager.swift
//  HabitTracker
//

import Foundation
import SwiftUI

struct DailyQuest: Identifiable, Codable {
    let id: String
    let title: String
    let icon: String
    let rewardXP: Int
    var currentProgress: Int
    let targetGoal: Int
    var isClaimed: Bool = false
    
    var isCompleted: Bool {
        return currentProgress >= targetGoal
    }
}

final class QuestManager {
    static let shared = QuestManager()
    
    @AppStorage("userProfileXP") var storedXP: Int = 0
    @AppStorage("questsLastGeneratedDate") var lastGeneratedDate: String = ""
    
    private let questsStorageKey = "daily_user_quests"
    
    private init() {}
    
    func getUserProfile() -> UserProfile {
        return UserProfile(xp: storedXP)
    }
    
    func addXP(_ amount: Int) -> (profile: UserProfile, leveledUp: Bool) {
        let oldLevel = (storedXP / 100) + 1
        storedXP += amount
        let newProfile = UserProfile(xp: storedXP)
        let leveledUp = newProfile.level > oldLevel
        return (newProfile, leveledUp)
    }
    
    func getDailyQuests(totalHabits: Int, completedHabits: Int, streak: Int) -> [DailyQuest] {
        let todayStr = Date.now.formatted(date: .numeric, time: .omitted)
        let targetForQ2 = totalHabits >= 3 ? 3 : max(1, totalHabits)
        let titleForQ2 = targetForQ2 == 1 ? "Complete 1 Habit" : "Complete \(targetForQ2) Habits Today"
        
        if lastGeneratedDate != todayStr {
            let newQuests = [
                DailyQuest(id: "q1", title: "Complete 1 Habit", icon: "checkmark.circle.fill", rewardXP: 30, currentProgress: min(completedHabits, 1), targetGoal: 1),
                DailyQuest(id: "q2", title: titleForQ2, icon: "flame.fill", rewardXP: 50, currentProgress: min(completedHabits, targetForQ2), targetGoal: targetForQ2),
                DailyQuest(id: "q3", title: "Maintain 3-Day Streak", icon: "star.fill", rewardXP: 75, currentProgress: min(streak, 3), targetGoal: 3)
            ]
            saveQuests(newQuests)
            lastGeneratedDate = todayStr
            return newQuests
        }
        
        var quests = loadQuests()
        // Update quest 2 target if totalHabits changed and quest is not yet completed/claimed
        if let idx = quests.firstIndex(where: { $0.id == "q2" }), !quests[idx].isClaimed {
            let updatedTarget = totalHabits >= 3 ? 3 : max(1, totalHabits)
            quests[idx] = DailyQuest(
                id: "q2",
                title: updatedTarget == 1 ? "Complete 1 Habit" : "Complete \(updatedTarget) Habits Today",
                icon: "flame.fill",
                rewardXP: 50,
                currentProgress: min(completedHabits, updatedTarget),
                targetGoal: updatedTarget,
                isClaimed: quests[idx].isClaimed
            )
            saveQuests(quests)
        }
        return quests
    }
    
    func updateQuestProgress(completedHabits: Int, streak: Int) {
        var quests = loadQuests()
        for i in 0..<quests.count {
            if quests[i].id == "q1" {
                quests[i].currentProgress = min(completedHabits, quests[i].targetGoal)
            } else if quests[i].id == "q2" {
                quests[i].currentProgress = min(completedHabits, quests[i].targetGoal)
            } else if quests[i].id == "q3" {
                quests[i].currentProgress = min(streak, quests[i].targetGoal)
            }
        }
        saveQuests(quests)
    }
    
    func claimQuest(_ quest: DailyQuest) -> (profile: UserProfile, leveledUp: Bool) {
        var quests = loadQuests()
        if let idx = quests.firstIndex(where: { $0.id == quest.id }), !quests[idx].isClaimed {
            quests[idx].isClaimed = true
            saveQuests(quests)
            return addXP(quest.rewardXP)
        }
        return (getUserProfile(), false)
    }
    
    private func saveQuests(_ quests: [DailyQuest]) {
        if let encoded = try? JSONEncoder().encode(quests) {
            UserDefaults.standard.set(encoded, forKey: questsStorageKey)
        }
    }
    
    private func loadQuests() -> [DailyQuest] {
        guard let data = UserDefaults.standard.data(forKey: questsStorageKey),
              let decoded = try? JSONDecoder().decode([DailyQuest].self, from: data) else {
            return [
                DailyQuest(id: "q1", title: "Complete 1 Habit", icon: "checkmark.circle.fill", rewardXP: 30, currentProgress: 0, targetGoal: 1),
                DailyQuest(id: "q2", title: "Complete 3 Habits Today", icon: "flame.fill", rewardXP: 50, currentProgress: 0, targetGoal: 3),
                DailyQuest(id: "q3", title: "Maintain 3-Day Streak", icon: "star.fill", rewardXP: 75, currentProgress: 0, targetGoal: 3)
            ]
        }
        return decoded
    }
}
