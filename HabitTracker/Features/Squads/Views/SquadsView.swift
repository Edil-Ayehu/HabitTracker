//
//  SquadsView.swift
//  HabitTracker
//

import SwiftUI

struct SquadsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var squadService = SquadService.shared
    @StateObject private var supabaseManager = SupabaseManager.shared
    @StateObject private var profileService = UserProfileService.shared
    @EnvironmentObject private var router: AppRouter
    
    @State private var selectedTab: Int = 0 // 0: Leaderboard, 1: Feed
    @State private var showCreateModal: Bool = false
    @State private var showJoinModal: Bool = false
    @State private var showProfileModal: Bool = false
    
    @State private var newSquadName: String = ""
    @State private var joinCodeInput: String = ""
    @State private var copiedCodeToast: Bool = false
    @State private var joinErrorText: String? = nil
    @State private var isJoining: Bool = false
    @State private var showLeaveAlert: Bool = false
    @State private var squadToLeave: Squad? = nil

    var body: some View {
        AppScaffold(title: "Habit Squads 👥") {
            VStack(spacing: AppSpacing.lg) {
                
                // MARK: - User Profile Banner
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppColors.primary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(profileService.isProfileCreated ? profileService.displayName : "Guest User")
                                .font(AppFont.caption())
                                .fontWeight(.bold)
                            Text(profileService.isProfileCreated ? profileService.usernameHandle : "Set unique @handle")
                                .font(.system(size: 11))
                                .foregroundStyle(profileService.isProfileCreated ? AppColors.primary : Color.orange)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        showProfileModal = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: profileService.isProfileCreated ? "pencil.circle.fill" : "plus.circle.fill")
                            Text(profileService.isProfileCreated ? "Edit Profile" : "Set Handle")
                        }
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppColors.primary.opacity(0.12))
                        .foregroundStyle(AppColors.primary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(10)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // MARK: - Multi-Squad Horizontal Selector Bar
                if !squadService.joinedSquads.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(squadService.joinedSquads) { squadItem in
                                let isSelected = squadService.activeSquad?.id == squadItem.id
                                Button {
                                    squadService.selectSquad(squadItem)
                                    AudioManager.shared.playClickSound()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: squadItem.icon)
                                            .font(.system(size: 12))
                                        Text(squadItem.name)
                                            .font(AppFont.caption())
                                            .fontWeight(isSelected ? .bold : .medium)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? AppColors.primary.opacity(0.18) : AppColors.card)
                                    .foregroundStyle(isSelected ? AppColors.primary : AppColors.textSecondary)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            
                            Menu {
                                Button("Create Another Squad") { checkProfileThen { showCreateModal = true } }
                                Button("Join Another Squad") { checkProfileThen { showJoinModal = true } }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                    Text("Add")
                                }
                                .font(AppFont.caption())
                                .fontWeight(.bold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.12))
                                .foregroundStyle(AppColors.primary)
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
                
                if let squad = squadService.activeSquad {
                    // MARK: - Squad Header Card
                    CardView {
                        VStack(spacing: 12) {
                            HStack {
                                HStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .fill(AppColors.primary.opacity(0.15))
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: squad.icon)
                                            .font(.title3)
                                            .foregroundStyle(AppColors.primary)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(squad.name)
                                            .font(AppFont.headline())
                                        
                                        Text("Created by \(squad.creatorName) • \(max(squad.memberCount, squadService.members.count)) Members")
                                            .font(AppFont.caption())
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button {
                                    UIPasteboard.general.string = squad.code
                                    copiedCodeToast = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        copiedCodeToast = false
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: copiedCodeToast ? "checkmark" : "doc.on.doc")
                                            .font(.system(size: 11, weight: .bold))
                                        Text(copiedCodeToast ? "Copied!" : squad.code)
                                            .font(.system(size: 12, weight: .black))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.purple.opacity(0.15))
                                    .foregroundStyle(Color.purple)
                                    .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                            
                            HStack {
                                Spacer()
                                
                                Menu {
                                    Button("Copy Squad Code") {
                                        UIPasteboard.general.string = squad.code
                                        copiedCodeToast = true
                                    }
                                    Button("Create New Squad") { checkProfileThen { showCreateModal = true } }
                                    Button("Join Squad with Code") { checkProfileThen { showJoinModal = true } }
                                    Button("Leave This Squad", role: .destructive) {
                                        squadToLeave = squad
                                        showLeaveAlert = true
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "ellipsis.circle")
                                        Text("Options")
                                    }
                                    .font(AppFont.caption())
                                    .foregroundStyle(AppColors.textSecondary)
                                }
                            }
                        }
                    }
                    
                    // MARK: - Segment Picker
                    Picker("Squad View", selection: $selectedTab) {
                        Text("Leaderboard 🏆").tag(0)
                        Text("Squad Feed 💬").tag(1)
                    }
                    .pickerStyle(.segmented)
                    
                    if selectedTab == 0 {
                        // MARK: - Leaderboard Tab
                        VStack(spacing: 12) {
                            ForEach(Array(squadService.members.enumerated()), id: \.element.id) { index, member in
                                HStack(spacing: 14) {
                                    // Rank Badge
                                    ZStack {
                                        Circle()
                                            .fill(rankColor(index: index).opacity(0.15))
                                            .frame(width: 36, height: 36)
                                        
                                        Text(rankBadgeText(index: index))
                                            .font(.system(size: index < 3 ? 16 : 13, weight: .bold))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Text(member.username)
                                                .font(AppFont.body())
                                                .fontWeight(.bold)
                                            if member.isCurrentAccount {
                                                Text("(You)")
                                                    .font(AppFont.caption())
                                                    .foregroundStyle(AppColors.primary)
                                            }
                                        }
                                        
                                        Text("\(member.totalXP) XP • \(member.weeklyCheckIns) Check-ins")
                                            .font(AppFont.caption())
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "flame.fill")
                                                .font(.system(size: 14))
                                                .foregroundStyle(Color.orange)
                                            Text("\(member.streakCount)")
                                                .font(.system(size: 20, weight: .black, design: .rounded))
                                                .foregroundStyle(AppColors.primary)
                                        }
                                        Text("Day Streak")
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                }
                                .padding(12)
                                .background(member.isCurrentAccount ? AppColors.primary.opacity(0.08) : AppColors.card)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(member.isCurrentAccount ? AppColors.primary.opacity(0.3) : Color.clear, lineWidth: 1)
                                )
                            }
                        }
                    } else {
                        // MARK: - Squad Feed Tab
                        VStack(spacing: 12) {
                            if squadService.activities.isEmpty {
                                Text("No squad activities yet today! Check off a habit to inspire your squad.")
                                    .font(AppFont.caption())
                                    .foregroundStyle(AppColors.textSecondary)
                                    .padding(.vertical, 30)
                            } else {
                                ForEach(squadService.activities) { activity in
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.purple.opacity(0.15))
                                                .frame(width: 40, height: 40)
                                            
                                            Image(systemName: activity.habitIcon)
                                                .foregroundStyle(Color.purple)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("**\(activity.username)** completed **\(activity.habitTitle)**")
                                                .font(AppFont.body())
                                                .lineLimit(1)
                                            
                                            Text(activity.timestamp.formatted(.dateTime.hour().minute()))
                                                .font(AppFont.caption())
                                                .foregroundStyle(AppColors.textSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Button {
                                            squadService.clapActivity(id: activity.id)
                                        } label: {
                                            HStack(spacing: 4) {
                                                Text("👏")
                                                Text("\(activity.clapCount)")
                                                    .font(AppFont.caption())
                                                    .fontWeight(.bold)
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.yellow.opacity(0.2))
                                            .clipShape(Capsule())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(12)
                                    .background(AppColors.card)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                            }
                        }
                    }
                } else {
                    // MARK: - Empty Squad View
                    VStack(spacing: 20) {
                        Image(systemName: "person.3.sequence.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(AppColors.primary)
                            .padding(.top, 40)
                        
                        VStack(spacing: 8) {
                            Text("Join or Create a Habit Squad")
                                .font(AppFont.title())
                                .fontWeight(.bold)
                            
                            Text("Habit squads let you compete on weekly leaderboards, build group streaks, and cheer for friends in real-time.")
                                .font(AppFont.body())
                                .multilineTextAlignment(.center)
                                .foregroundStyle(AppColors.textSecondary)
                                .padding(.horizontal, 24)
                        }
                        
                        VStack(spacing: 12) {
                            Button {
                                checkProfileThen { showCreateModal = true }
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Create New Squad")
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColors.primary)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                checkProfileThen { showJoinModal = true }
                            } label: {
                                HStack {
                                    Image(systemName: "person.badge.plus")
                                    Text("Join Squad with Code")
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.gray.opacity(0.12))
                                .foregroundStyle(AppColors.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }
        }
        .sheet(isPresented: $showProfileModal) {
            ProfileSetupView()
        }
        .sheet(isPresented: $showCreateModal) {
            NavigationStack {
                VStack(spacing: 20) {
                    Text("Create a Habit Squad 🏆")
                        .font(AppFont.title())
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Squad Name")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                        TextField("e.g. Fitness Champions 🏋️", text: $newSquadName)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(AppColors.primary)
                        Text("Creating as **\(profileService.displayName)** (\(profileService.usernameHandle))")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.primary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button {
                        if !newSquadName.isEmpty {
                            let creatorIdentity = "\(profileService.displayName) (\(profileService.usernameHandle))"
                            let userXP = QuestManager.shared.getUserProfile().xp
                            let habitUseCase = HabitUseCaseImpl(repository: HabitRepositoryImpl(context: modelContext))
                            let currentStreak = (try? habitUseCase.fetchStatistics().currentStreak) ?? 0
                            
                            Task {
                                _ = await squadService.createSquad(
                                    name: newSquadName,
                                    icon: "flame.fill",
                                    creatorName: creatorIdentity,
                                    streakCount: currentStreak,
                                    totalXP: userXP
                                )
                                showCreateModal = false
                            }
                        }
                    } label: {
                        Text("Create Squad")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.primary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(24)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cancel") { showCreateModal = false }
                    }
                }
            }
        }
        .sheet(isPresented: $showJoinModal) {
            NavigationStack {
                VStack(spacing: 20) {
                    Text("Join a Squad 👥")
                        .font(AppFont.title())
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("6-Digit Squad Code")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                        TextField("e.g. SQUAD-789", text: $joinCodeInput)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(AppColors.primary)
                        Text("Joining as **\(profileService.displayName)** (\(profileService.usernameHandle))")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.primary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    if let errorMsg = joinErrorText {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(errorMsg)
                                .font(AppFont.caption())
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(Color.red)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button {
                        if !joinCodeInput.isEmpty {
                            isJoining = true
                            joinErrorText = nil
                            let memberIdentity = "\(profileService.displayName) (\(profileService.usernameHandle))"
                            let userXP = QuestManager.shared.getUserProfile().xp
                            let habitUseCase = HabitUseCaseImpl(repository: HabitRepositoryImpl(context: modelContext))
                            let currentStreak = (try? habitUseCase.fetchStatistics().currentStreak) ?? 0
                            
                            Task {
                                do {
                                    _ = try await squadService.joinSquad(
                                        code: joinCodeInput,
                                        username: memberIdentity,
                                        streakCount: currentStreak,
                                        totalXP: userXP
                                    )
                                    isJoining = false
                                    showJoinModal = false
                                } catch {
                                    isJoining = false
                                    joinErrorText = error.localizedDescription
                                }
                            }
                        }
                    } label: {
                        if isJoining {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColors.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        } else {
                            Text("Join Squad")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColors.primary)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(isJoining)
                    
                    Spacer()
                }
                .padding(24)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cancel") { showJoinModal = false }
                    }
                }
            }
        }
        .task {
            if let active = squadService.activeSquad {
                await squadService.fetchLatestSquadData(for: active.id)
            }
        }
        .alert("Leave Squad?", isPresented: $showLeaveAlert) {
            Button("Leave", role: .destructive) {
                if let target = squadToLeave {
                    squadService.leaveSquad(squad: target)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to leave \(squadToLeave?.name ?? "this squad")? You can rejoin anytime using the 6-digit squad code.")
        }
    }
    
    private func checkProfileThen(_ action: @escaping () -> Void) {
        if !profileService.isProfileCreated {
            showProfileModal = true
        } else {
            action()
        }
    }
    
    private func rankBadgeText(index: Int) -> String {
        switch index {
        case 0: return "🥇"
        case 1: return "🥈"
        case 2: return "🥉"
        default: return "\(index + 1)"
        }
    }
    
    private func rankColor(index: Int) -> Color {
        switch index {
        case 0: return .yellow
        case 1: return .gray
        case 2: return .orange
        default: return AppColors.primary
        }
    }
}
