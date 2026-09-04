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

private struct SupabaseMemberPatchDTO: Codable {
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

private struct SupabaseNudgeDTO: Codable {
    let id: UUID
    let squad_id: UUID
    let sender_username: String
    let receiver_username: String
    let nudge_message: String
    let nudge_type: String
}

private struct SupabaseSquadUpdateMemberCountDTO: Codable {
    let member_count: Int
}

@MainActor
final class SquadService: ObservableObject {
    static let shared = SquadService()
    
    @Published var joinedSquads: [Squad] = []
    @Published var activeSquad: Squad?
    @Published var members: [SquadMember] = []
    @Published var activities: [SquadActivity] = []
    @Published var incomingNudges: [SquadNudge] = []
    
    private let joinedSquadsKey = "joinedSquadsList"
    private let activeSquadIDKey = "activeSquadIDKey"
    
    private init() {
        loadPersistedSquads()
    }
    
    // MARK: - Squad Switcher
    func selectSquad(_ squad: Squad) {
        self.activeSquad = squad
        loadSquadData(for: squad.id)
        saveState()
        
        Task {
            await fetchLatestSquadData(for: squad.id)
        }
    }
    
    // MARK: - Live Supabase Sync
    func fetchLatestSquadData(for squadID: UUID) async {
        guard SupabaseManager.shared.isConfigured else { return }
        
        do {
            // Check if squad still exists in Supabase
            let squadData = try await SupabaseManager.shared.performRESTRequest(endpoint: "squads?id=eq.\(squadID.uuidString)", method: "GET")
            let fetchedSquads = try JSONDecoder().decode([SupabaseSquadDTO].self, from: squadData)
            
            if fetchedSquads.isEmpty {
                // Squad was deleted on Supabase! Remove locally.
                joinedSquads.removeAll(where: { $0.id == squadID })
                if activeSquad?.id == squadID {
                    activeSquad = joinedSquads.first
                    if let active = activeSquad {
                        loadSquadData(for: active.id)
                    } else {
                        members = []
                        activities = []
                    }
                }
                saveState()
                return
            }
            
            // 1. Fetch Members
            let membersData = try await SupabaseManager.shared.performRESTRequest(endpoint: "squad_members?squad_id=eq.\(squadID.uuidString)", method: "GET")
            let fetchedMembersDTO = try JSONDecoder().decode([SupabaseMemberDTO].self, from: membersData)
            
            let currentHandle = UserProfileService.shared.usernameHandle
            
            let updatedMembers = fetchedMembersDTO.map { dto in
                SquadMember(
                    id: dto.id,
                    squadID: dto.squad_id,
                    username: dto.username,
                    avatarIcon: dto.avatar_icon,
                    streakCount: dto.streak_count,
                    weeklyCheckIns: dto.weekly_check_ins,
                    totalXP: dto.total_xp,
                    isCurrentAccount: !currentHandle.isEmpty && dto.username.contains(currentHandle)
                )
            }.sorted(by: {
                if $0.streakCount != $1.streakCount {
                    return $0.streakCount > $1.streakCount
                } else {
                    return $0.totalXP > $1.totalXP
                }
            })
            
            self.members = updatedMembers
            
            // 2. Fetch Activities
            let actData = try await SupabaseManager.shared.performRESTRequest(endpoint: "squad_activities?squad_id=eq.\(squadID.uuidString)", method: "GET")
            let fetchedActDTO = try JSONDecoder().decode([SupabaseActivityDTO].self, from: actData)
            
            let updatedActivities = fetchedActDTO.map { dto in
                SquadActivity(
                    id: dto.id,
                    squadID: dto.squad_id,
                    username: dto.username,
                    habitTitle: dto.habit_title,
                    habitIcon: dto.habit_icon,
                    timestamp: Date(),
                    clapCount: dto.clap_count
                )
            }
            
            self.activities = updatedActivities
            
            // 3. Fetch Incoming Nudges
            do {
                let nudgeData = try await SupabaseManager.shared.performRESTRequest(endpoint: "squad_nudges?squad_id=eq.\(squadID.uuidString)", method: "GET")
                let fetchedNudgesDTO = try JSONDecoder().decode([SupabaseNudgeDTO].self, from: nudgeData)
                let currentHandle = UserProfileService.shared.usernameHandle
                
                let myNudges = fetchedNudgesDTO.filter { dto in
                    !currentHandle.isEmpty && dto.receiver_username.contains(currentHandle)
                }.map { dto in
                    SquadNudge(
                        id: dto.id,
                        squadID: dto.squad_id,
                        senderUsername: dto.sender_username,
                        receiverUsername: dto.receiver_username,
                        nudgeMessage: dto.nudge_message,
                        nudgeType: dto.nudge_type,
                        timestamp: Date()
                    )
                }
                self.incomingNudges = myNudges
            } catch {
                print("Fetch nudges notice: \(error.localizedDescription)")
            }
            
            // 4. Sync member count
            if let active = activeSquad, active.id == squadID {
                let realCount = max(fetchedMembersDTO.count, 1)
                let updatedSquad = Squad(
                    id: active.id,
                    name: active.name,
                    code: active.code,
                    icon: active.icon,
                    creatorName: active.creatorName,
                    combinedStreak: active.combinedStreak,
                    memberCount: realCount,
                    createdAt: active.createdAt
                )
                self.activeSquad = updatedSquad
                if let idx = joinedSquads.firstIndex(where: { $0.id == squadID }) {
                    joinedSquads[idx] = updatedSquad
                }
            }
            
            saveState()
        } catch {
            print("Fetch latest squad data error: \(error.localizedDescription)")
        }
    }
    
    func dismissNudge(_ nudge: SquadNudge) {
        incomingNudges.removeAll(where: { $0.id == nudge.id })
        if SupabaseManager.shared.isConfigured {
            Task {
                do {
                    _ = try await SupabaseManager.shared.performRESTRequest(endpoint: "squad_nudges?id=eq.\(nudge.id.uuidString)", method: "DELETE")
                } catch {
                    print("Dismiss nudge error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Squad Operations
    func createSquad(name: String, icon: String, creatorName: String, streakCount: Int = 0, totalXP: Int = 0) async -> Squad {
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
            streakCount: streakCount,
            weeklyCheckIns: 0,
            totalXP: totalXP,
            isCurrentAccount: true
        )
        
        if !joinedSquads.contains(where: { $0.id == squad.id }) {
            joinedSquads.append(squad)
        }
        self.activeSquad = squad
        self.members = [selfMember]
        self.activities = []
        saveState()
        
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
                    streak_count: streakCount,
                    weekly_check_ins: 0,
                    total_xp: totalXP
                )
                let memberBody = try JSONEncoder().encode([memberDTO])
                _ = try await SupabaseManager.shared.performRESTRequest(endpoint: "squad_members", method: "POST", body: memberBody)
            } catch {
                print("Supabase squad creation warning: \(error.localizedDescription)")
            }
        }
        
        return squad
    }
    
    func joinSquad(code: String, username: String, streakCount: Int = 0, totalXP: Int = 0) async throws -> Squad {
        let cleanCode = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !cleanCode.isEmpty else {
            throw NSError(domain: "SquadService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Please enter a valid squad code."])
        }
        
        // 1. Check local joined squad list
        if let existing = joinedSquads.first(where: { $0.code == cleanCode }) {
            throw NSError(domain: "SquadService", code: 409, userInfo: [NSLocalizedDescriptionKey: "You are already a member of '\(existing.name)'!"])
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
                
                // 2. Check remote Supabase membership table
                let currentHandle = UserProfileService.shared.usernameHandle
                if !currentHandle.isEmpty {
                    let encodedHandle = currentHandle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? currentHandle
                    let existingMemberData = try await SupabaseManager.shared.performRESTRequest(endpoint: "squad_members?squad_id=eq.\(squadID.uuidString)&username=ilike.*\(encodedHandle)*", method: "GET")
                    let existingMembers = try JSONDecoder().decode([SupabaseMemberDTO].self, from: existingMemberData)
                    if !existingMembers.isEmpty {
                        throw NSError(domain: "SquadService", code: 409, userInfo: [NSLocalizedDescriptionKey: "You are already a member of '\(squadName)'!"])
                    }
                }
            } catch {
                if (error as NSError).code == 404 || (error as NSError).code == 409 {
                    throw error
                } else {
                    throw NSError(domain: "SquadService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No squad found matching code '\(cleanCode)'. Please check the code and try again."])
                }
            }
        } else {
            // Local mode check
            if let existing = joinedSquads.first(where: { $0.code == cleanCode }) {
                squadID = existing.id
                squadName = existing.name
                squadIcon = existing.icon
                creatorName = existing.creatorName
                combinedStreak = existing.combinedStreak
            } else {
                squadName = "Squad \(cleanCode)"
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
            streakCount: streakCount,
            weeklyCheckIns: 0,
            totalXP: totalXP,
            isCurrentAccount: true
        )
        
        if let idx = joinedSquads.firstIndex(where: { $0.id == squad.id }) {
            joinedSquads[idx] = squad
        } else {
            joinedSquads.append(squad)
        }
        
        self.activeSquad = squad
        self.members = [selfMember]
        self.activities = []
        saveState()
        
        if SupabaseManager.shared.isConfigured {
            do {
                let memberDTO = SupabaseMemberDTO(
                    id: memberID,
                    squad_id: squadID,
                    username: userName,
                    avatar_icon: "person.circle.fill",
                    streak_count: streakCount,
                    weekly_check_ins: 0,
                    total_xp: totalXP
                )
                let memberBody = try JSONEncoder().encode([memberDTO])
                _ = try await SupabaseManager.shared.performRESTRequest(endpoint: "squad_members", method: "POST", body: memberBody)
                
                // Update member_count on Supabase squads table
                let updateDTO = SupabaseSquadUpdateMemberCountDTO(member_count: existingMembersCount)
                let updateBody = try JSONEncoder().encode(updateDTO)
                _ = try await SupabaseManager.shared.performRESTRequest(endpoint: "squads?id=eq.\(squadID.uuidString)", method: "PATCH", body: updateBody)
            } catch {
                print("Supabase join member insert warning: \(error.localizedDescription)")
            }
        }
        
        // Fetch all members from Supabase
        await fetchLatestSquadData(for: squadID)
        
        return squad
    }
    
    func broadcastCheckIn(habitTitle: String, habitIcon: String, userStreak: Int = 0, totalXP: Int = 0) {
        guard let squad = activeSquad else { return }
        
        let userName = members.first(where: { $0.isCurrentAccount })?.username ?? UserProfileService.shared.displayName
        
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
        
        var updatedSelfMember: SquadMember?
        
        // Update user's member check-in count, streak & XP
        if let idx = members.firstIndex(where: { $0.isCurrentAccount }) {
            let cur = members[idx]
            let newStreak = max(userStreak, cur.streakCount > 0 ? cur.streakCount : 1)
            let newXP = totalXP > 0 ? totalXP : (cur.totalXP + 25)
            
            let updated = SquadMember(
                id: cur.id,
                squadID: cur.squadID,
                username: cur.username,
                avatarIcon: cur.avatarIcon,
                streakCount: newStreak,
                weeklyCheckIns: cur.weeklyCheckIns + 1,
                totalXP: newXP,
                isCurrentAccount: true
            )
            members[idx] = updated
            updatedSelfMember = updated
            members.sort(by: {
                if $0.streakCount != $1.streakCount {
                    return $0.streakCount > $1.streakCount
                } else {
                    return $0.totalXP > $1.totalXP
                }
            })
        }
        
        // Update combined squad streak
        let updatedSquad = Squad(
            id: squad.id,
            name: squad.name,
            code: squad.code,
            icon: squad.icon,
            creatorName: squad.creatorName,
            combinedStreak: squad.combinedStreak + 1,
            memberCount: max(squad.memberCount, members.count),
            createdAt: squad.createdAt
        )
        self.activeSquad = updatedSquad
        if let idx = joinedSquads.firstIndex(where: { $0.id == squad.id }) {
            joinedSquads[idx] = updatedSquad
        }
        
        saveState()
        
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
                    
                    // PATCH member streak_count, weekly_check_ins, and total_xp on Supabase!
                    if let selfMember = updatedSelfMember {
                        let memberPatchDTO = SupabaseMemberPatchDTO(
                            streak_count: selfMember.streakCount,
                            weekly_check_ins: selfMember.weeklyCheckIns,
                            total_xp: selfMember.totalXP
                        )
                        let patchBody = try JSONEncoder().encode(memberPatchDTO)
                        _ = try await SupabaseManager.shared.performRESTRequest(endpoint: "squad_members?id=eq.\(selfMember.id.uuidString)", method: "PATCH", body: patchBody)
                    }
                } catch {
                    print("Supabase broadcast check-in error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func clapActivity(id: UUID) {
        if let idx = activities.firstIndex(where: { $0.id == id }) {
            activities[idx].clapCount += 1
            saveState()
            AudioManager.shared.playClickSound()
        }
    }
    
    func sendNudge(to targetMember: SquadMember, message: String, type: String) {
        guard let squad = activeSquad else { return }
        let senderName = UserProfileService.shared.displayName
        let senderHandle = UserProfileService.shared.usernameHandle
        let fullSender = senderHandle.isEmpty ? senderName : "\(senderName) (\(senderHandle))"
        
        let iconName: String
        switch type {
        case "high_five": iconName = "hand.raised.fill"
        case "flex": iconName = "figure.arms.open"
        case "streak_saver": iconName = "flame.fill"
        case "lightning": iconName = "bolt.fill"
        default: iconName = "sparkles"
        }
        
        let activityTitle = "Nudged \(targetMember.username): \"\(message)\""
        
        let newActivity = SquadActivity(
            id: UUID(),
            squadID: squad.id,
            username: fullSender,
            habitTitle: activityTitle,
            habitIcon: iconName,
            timestamp: Date(),
            clapCount: 0
        )
        
        activities.insert(newActivity, at: 0)
        saveState()
        AudioManager.shared.playCelebrationSound()
        
        if SupabaseManager.shared.isConfigured {
            Task {
                do {
                    // 1. Post to squad_activities
                    let activityDTO = SupabaseActivityDTO(
                        id: newActivity.id,
                        squad_id: squad.id,
                        username: fullSender,
                        habit_title: activityTitle,
                        habit_icon: iconName,
                        clap_count: 0
                    )
                    let body = try JSONEncoder().encode([activityDTO])
                    _ = try await SupabaseManager.shared.performRESTRequest(endpoint: "squad_activities", method: "POST", body: body)
                    
                    // 2. Post to squad_nudges
                    let nudgeDTO = SupabaseNudgeDTO(
                        id: UUID(),
                        squad_id: squad.id,
                        sender_username: fullSender,
                        receiver_username: targetMember.username,
                        nudge_message: message,
                        nudge_type: type
                    )
                    let nudgeBody = try JSONEncoder().encode([nudgeDTO])
                    _ = try await SupabaseManager.shared.performRESTRequest(endpoint: "squad_nudges", method: "POST", body: nudgeBody)
                } catch {
                    print("Supabase send nudge warning: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func leaveSquad(squad target: Squad) {
        let currentHandle = UserProfileService.shared.usernameHandle
        let targetMember = members.first(where: { $0.squadID == target.id && ($0.isCurrentAccount || (!currentHandle.isEmpty && $0.username.contains(currentHandle))) })
        
        joinedSquads.removeAll(where: { $0.id == target.id })
        if activeSquad?.id == target.id {
            activeSquad = joinedSquads.first
            if let active = activeSquad {
                loadSquadData(for: active.id)
            } else {
                members = []
                activities = []
            }
        }
        saveState()
        
        if SupabaseManager.shared.isConfigured {
            Task {
                do {
                    // 1. Delete member from squad_members table in Supabase
                    if let memberID = targetMember?.id {
                        _ = try await SupabaseManager.shared.performRESTRequest(endpoint: "squad_members?id=eq.\(memberID.uuidString)", method: "DELETE")
                    } else if !currentHandle.isEmpty {
                        let encodedHandle = currentHandle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? currentHandle
                        _ = try await SupabaseManager.shared.performRESTRequest(endpoint: "squad_members?squad_id=eq.\(target.id.uuidString)&username=ilike.*\(encodedHandle)*", method: "DELETE")
                    }
                    
                    // 2. Update member_count on squads table in Supabase
                    let remainingCount = max(0, target.memberCount - 1)
                    let updateDTO = SupabaseSquadUpdateMemberCountDTO(member_count: remainingCount)
                    let updateBody = try JSONEncoder().encode(updateDTO)
                    _ = try await SupabaseManager.shared.performRESTRequest(endpoint: "squads?id=eq.\(target.id.uuidString)", method: "PATCH", body: updateBody)
                } catch {
                    print("Supabase leave squad delete warning: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func resetAllSquadsData() {
        joinedSquads = []
        activeSquad = nil
        members = []
        activities = []
        UserDefaults.standard.removeObject(forKey: joinedSquadsKey)
        UserDefaults.standard.removeObject(forKey: activeSquadIDKey)
    }
    
    // MARK: - Private Helpers
    private func generateSquadCode() -> String {
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
    
    private func saveState() {
        if let listData = try? JSONEncoder().encode(joinedSquads) {
            UserDefaults.standard.set(listData, forKey: joinedSquadsKey)
        }
        if let activeID = activeSquad?.id {
            UserDefaults.standard.set(activeID.uuidString, forKey: activeSquadIDKey)
            saveSquadData(for: activeID)
        } else {
            UserDefaults.standard.removeObject(forKey: activeSquadIDKey)
        }
    }
    
    private func saveSquadData(for squadID: UUID) {
        let memKey = "squadMembersData_\(squadID.uuidString)"
        let actKey = "squadActivitiesData_\(squadID.uuidString)"
        if let memData = try? JSONEncoder().encode(members) {
            UserDefaults.standard.set(memData, forKey: memKey)
        }
        if let actData = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(actData, forKey: actKey)
        }
    }
    
    private func loadSquadData(for squadID: UUID) {
        let memKey = "squadMembersData_\(squadID.uuidString)"
        let actKey = "squadActivitiesData_\(squadID.uuidString)"
        if let memData = UserDefaults.standard.data(forKey: memKey),
           let loadedMembers = try? JSONDecoder().decode([SquadMember].self, from: memData) {
            self.members = loadedMembers
        } else {
            self.members = []
        }
        
        if let actData = UserDefaults.standard.data(forKey: actKey),
           let loadedActivities = try? JSONDecoder().decode([SquadActivity].self, from: actData) {
            self.activities = loadedActivities
        } else {
            self.activities = []
        }
    }
    
    private func loadPersistedSquads() {
        if let listData = UserDefaults.standard.data(forKey: joinedSquadsKey),
           let squads = try? JSONDecoder().decode([Squad].self, from: listData) {
            self.joinedSquads = squads
        }
        
        if let activeIDStr = UserDefaults.standard.string(forKey: activeSquadIDKey),
           let activeID = UUID(uuidString: activeIDStr),
           let matched = joinedSquads.first(where: { $0.id == activeID }) {
            self.activeSquad = matched
            loadSquadData(for: activeID)
        } else if let first = joinedSquads.first {
            self.activeSquad = first
            loadSquadData(for: first.id)
        }
    }
}
