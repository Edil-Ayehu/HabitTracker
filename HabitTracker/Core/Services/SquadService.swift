//
//  SquadService.swift
//  HabitTracker
//

import Foundation
import Combine

private struct SupabaseSquadDTO: Codable {
    let id: UUID
    let name: String
    let code: String
    let icon: String
    let creator_name: String
    let combined_streak: Int
    let member_count: Int
}

private struct SupabaseMemberDTO: Codable {
    let id: UUID
    let squad_id: UUID
    let username: String
    let avatar_icon: String
    let streak_count: Int
    let weekly_check_ins: Int
    let total_xp: Int
}

private struct SupabaseActivityDTO: Codable {
    let id: UUID
    let squad_id: UUID
    let username: String
    let habit_title: String
    let habit_icon: String
    let clap_count: Int
}

@MainActor
final class SquadService: ObservableObject {
    static let shared = SquadService()
    
    @Published var activeSquad: Squad?
    @Published var members: [SquadMember] = []
    @Published var activities: [SquadActivity] = []
    
    private let activeSquadKey = "activeSquadData"
    private let squadMembersKey = "squadMembersData"
    private let squadActivitiesKey = "squadActivitiesData"
    
    private init() {
        loadPersistedSquad()
    }
    
    // MARK: - Squad Operations
    func createSquad(name: String, icon: String, creatorName: String) async -> Squad {
        let code = generateSquadCode()
        let squadID = UUID()
        let memberID = UUID()
        let userName = creatorName.isEmpty ? "You" : creatorName
        
        let squad = Squad(
            id: squadID,
            name: name,
            code: code,
            icon: icon,
            creatorName: userName,
            combinedStreak: 0,
            memberCount: 1,
            createdAt: Date()
        )
        
        let selfMember = SquadMember(
            id: memberID,
            squadID: squadID,
            username: userName,
            avatarIcon: "person.circle.fill",
            streakCount: 0,
            weeklyCheckIns: 0,
            totalXP: 0,
            isCurrentAccount: true
        )
        
        self.activeSquad = squad
        self.members = [selfMember]
        self.activities = []
        saveSquad()
        
        // Sync to Supabase if configured
        if SupabaseManager.shared.isConfigured {
            do {
                let squadDTO = SupabaseSquadDTO(
                    id: squadID,
                    name: name,
                    code: code,
                    icon: icon,
                    creator_name: userName,
                    combined_streak: 0,
                    member_count: 1
                )
                let squadBody = try JSONEncoder().encode([squadDTO])
                _ = try await SupabaseManager.shared.performRESTRequest(endpoint: "squads", method: "POST", body: squadBody)
                
                let memberDTO = SupabaseMemberDTO(
                    id: memberID,
                    squad_id: squadID,
                    username: userName,
                    avatar_icon: "person.circle.fill",
                    streak_count: 0,
                    weekly_check_ins: 0,
                    total_xp: 0
                )
                let memberBody = try JSONEncoder().encode([memberDTO])
                _ = try await SupabaseManager.shared.performRESTRequest(endpoint: "squad_members", method: "POST", body: memberBody)
            } catch {
                print("Supabase squad creation warning: \(error.localizedDescription)")
            }
        }
        
        return squad
    }
    
    func joinSquad(code: String, username: String) async throws -> Squad {
        let cleanCode = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !cleanCode.isEmpty else {
            throw NSError(domain: "SquadService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Please enter a valid squad code."])
        }
        
        let userName = username.isEmpty ? "You" : username
        var squadID = UUID()
        var squadName = ""
        var squadIcon = "person.3.sequence.fill"
        var creatorName = "Squad Leader"
        var combinedStreak = 0
        var existingMembersCount = 1
        
        // Attempt to fetch squad from Supabase if configured
        if SupabaseManager.shared.isConfigured {
            do {
                let data = try await SupabaseManager.shared.performRESTRequest(endpoint: "squads?code=eq.\(cleanCode)", method: "GET")
                let fetchedSquads = try JSONDecoder().decode([SupabaseSquadDTO].self, from: data)
                
                guard let matched = fetchedSquads.first else {
                    throw NSError(domain: "SquadService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No squad found matching code '\(cleanCode)'. Please check the code and try again."])
                }
                
                squadID = matched.id
                squadName = matched.name
                squadIcon = matched.icon
                creatorName = matched.creator_name
                combinedStreak = matched.combined_streak
                existingMembersCount = matched.member_count + 1
            } catch {
                if (error as NSError).code == 404 {
                    throw error
                } else {
                    throw NSError(domain: "SquadService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No squad found matching code '\(cleanCode)'. Please check the code and try again."])
                }
            }
        } else {
            // Local mode check
            if let active = activeSquad, active.code == cleanCode {
                squadID = active.id
                squadName = active.name
                squadIcon = active.icon
                creatorName = active.creatorName
                combinedStreak = active.combinedStreak
            } else {
                throw NSError(domain: "SquadService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No squad found matching code '\(cleanCode)'. Please verify the squad code."])
            }
        }
        
        let squad = Squad(
            id: squadID,
            name: squadName,
            code: cleanCode,
            icon: squadIcon,
            creatorName: creatorName,
            combinedStreak: combinedStreak,
            memberCount: existingMembersCount,
            createdAt: Date()
        )
        
        let memberID = UUID()
        let selfMember = SquadMember(
            id: memberID,
            squadID: squadID,
            username: userName,
            avatarIcon: "person.circle.fill",
            streakCount: 0,
            weeklyCheckIns: 0,
            totalXP: 0,
            isCurrentAccount: true
        )
        
        self.activeSquad = squad
        self.members = [selfMember]
        self.activities = []
        saveSquad()
        
        if SupabaseManager.shared.isConfigured {
            do {
                let memberDTO = SupabaseMemberDTO(
                    id: memberID,
                    squad_id: squadID,
                    username: userName,
                    avatar_icon: "person.circle.fill",
                    streak_count: 0,
                    weekly_check_ins: 0,
                    total_xp: 0
                )
                let memberBody = try JSONEncoder().encode([memberDTO])
                _ = try await SupabaseManager.shared.performRESTRequest(endpoint: "squad_members", method: "POST", body: memberBody)
            } catch {
                print("Supabase join member insert warning: \(error.localizedDescription)")
            }
        }
        
        return squad
    }
    
    func broadcastCheckIn(habitTitle: String, habitIcon: String) {
        guard let squad = activeSquad else { return }
        
        let userName = members.first(where: { $0.isCurrentAccount })?.username ?? "You"
        
        let newActivity = SquadActivity(
            id: UUID(),
            squadID: squad.id,
            username: userName,
            habitTitle: habitTitle,
            habitIcon: habitIcon,
            timestamp: Date(),
            clapCount: 0
        )
        
        activities.insert(newActivity, at: 0)
        
        // Update user's member check-in count
        if let idx = members.firstIndex(where: { $0.isCurrentAccount }) {
            let cur = members[idx]
            members[idx] = SquadMember(
                id: cur.id,
                squadID: cur.squadID,
                username: cur.username,
                avatarIcon: cur.avatarIcon,
                streakCount: cur.streakCount + 1,
                weeklyCheckIns: cur.weeklyCheckIns + 1,
                totalXP: cur.totalXP + 25,
                isCurrentAccount: true
            )
            members.sort(by: { $0.weeklyCheckIns > $1.weeklyCheckIns })
        }
        
        // Update combined squad streak
        let updatedSquad = Squad(
            id: squad.id,
            name: squad.name,
            code: squad.code,
            icon: squad.icon,
            creatorName: squad.creatorName,
            combinedStreak: squad.combinedStreak + 1,
            memberCount: members.count,
            createdAt: squad.createdAt
        )
        self.activeSquad = updatedSquad
        
        saveSquad()
        
        if SupabaseManager.shared.isConfigured {
            Task {
                do {
                    let activityDTO = SupabaseActivityDTO(
                        id: newActivity.id,
                        squad_id: squad.id,
                        username: userName,
                        habit_title: habitTitle,
                        habit_icon: habitIcon,
                        clap_count: 0
                    )
                    let body = try JSONEncoder().encode([activityDTO])
                    _ = try await SupabaseManager.shared.performRESTRequest(endpoint: "squad_activities", method: "POST", body: body)
                } catch {
                    print("Supabase broadcast check-in error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func clapActivity(id: UUID) {
        if let idx = activities.firstIndex(where: { $0.id == id }) {
            activities[idx].clapCount += 1
            saveSquad()
            AudioManager.shared.playClickSound()
        }
    }
    
    func leaveSquad() {
        activeSquad = nil
        members = []
        activities = []
        UserDefaults.standard.removeObject(forKey: activeSquadKey)
        UserDefaults.standard.removeObject(forKey: squadMembersKey)
        UserDefaults.standard.removeObject(forKey: squadActivitiesKey)
    }
    
    // MARK: - Private Helpers
    private func generateSquadCode() -> String {
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
    
    private func saveSquad() {
        guard let squad = activeSquad else { return }
        if let data = try? JSONEncoder().encode(squad) {
            UserDefaults.standard.set(data, forKey: activeSquadKey)
        }
        if let memData = try? JSONEncoder().encode(members) {
            UserDefaults.standard.set(memData, forKey: squadMembersKey)
        }
        if let actData = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(actData, forKey: squadActivitiesKey)
        }
    }
    
    private func loadPersistedSquad() {
        guard let data = UserDefaults.standard.data(forKey: activeSquadKey),
              let squad = try? JSONDecoder().decode(Squad.self, from: data) else { return }
        self.activeSquad = squad
        
        if let memData = UserDefaults.standard.data(forKey: squadMembersKey),
           let loadedMembers = try? JSONDecoder().decode([SquadMember].self, from: memData) {
            self.members = loadedMembers
        }
        
        if let actData = UserDefaults.standard.data(forKey: squadActivitiesKey),
           let loadedActivities = try? JSONDecoder().decode([SquadActivity].self, from: actData) {
            self.activities = loadedActivities
        }
    }
}
