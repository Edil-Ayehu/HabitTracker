//
//  SendNudgeView.swift
//  HabitTracker
//

import SwiftUI

struct NudgePreset {
    let id: String
    let title: String
    let icon: String
    let message: String
    let color: Color
}

struct SendNudgeView: View {
    let targetMember: SquadMember
    let onSend: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPresetID: String = "high_five"
    @State private var customMessage: String = ""
    @State private var isCustomSelected: Bool = false
    
    private let presets: [NudgePreset] = [
        NudgePreset(id: "high_five", title: "High Five ✋", icon: "hand.raised.fill", message: "High Five! Keep up the awesome streak!", color: .purple),
        NudgePreset(id: "flex", title: "Flex Muscle 💪", icon: "figure.arms.open", message: "Flexing! Time to crush your daily habits today!", color: .blue),
        NudgePreset(id: "streak_saver", title: "Streak Saver 🔥", icon: "flame.fill", message: "Don't break the streak! We believe in you!", color: .orange),
        NudgePreset(id: "lightning", title: "Lightning Cheer ⚡", icon: "bolt.fill", message: "Sending energy! Check off your habits today!", color: .yellow)
    ]
    
    var activeMessage: String {
        if isCustomSelected {
            return customMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return presets.first(where: { $0.id == selectedPresetID })?.message ?? "You got this!"
        }
    }
    
    var activeType: String {
        if isCustomSelected {
            return "custom"
        } else {
            return selectedPresetID
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    
                    // MARK: - Target Member Header Card
                    CardView {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.primary.opacity(0.15))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: targetMember.avatarIcon)
                                    .font(.title2)
                                    .foregroundStyle(AppColors.primary)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(targetMember.username)
                                    .font(AppFont.headline())
                                
                                HStack(spacing: 8) {
                                    HStack(spacing: 3) {
                                        Image(systemName: "flame.fill")
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color.orange)
                                        Text("\(targetMember.streakCount)d streak")
                                            .font(AppFont.caption())
                                            .fontWeight(.bold)
                                    }
                                    
                                    Text("•")
                                        .foregroundStyle(AppColors.textSecondary)
                                    
                                    Text("\(targetMember.totalXP) XP")
                                        .font(AppFont.caption())
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Choose Accountability Nudge ⚡")
                            .font(AppFont.headline())
                        
                        // Preset Options Grid
                        VStack(spacing: 10) {
                            ForEach(presets, id: \.id) { preset in
                                let isSelected = !isCustomSelected && selectedPresetID == preset.id
                                Button {
                                    isCustomSelected = false
                                    selectedPresetID = preset.id
                                    AudioManager.shared.playClickSound()
                                } label: {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(preset.color.opacity(0.18))
                                                .frame(width: 38, height: 38)
                                            
                                            Image(systemName: preset.icon)
                                                .font(.system(size: 16))
                                                .foregroundStyle(preset.color)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(preset.title)
                                                .font(AppFont.body())
                                                .fontWeight(.bold)
                                                .foregroundStyle(AppColors.textPrimary)
                                            
                                            Text("\"\(preset.message)\"")
                                                .font(AppFont.caption())
                                                .foregroundStyle(AppColors.textSecondary)
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                            .foregroundStyle(isSelected ? AppColors.primary : Color.gray.opacity(0.3))
                                    }
                                    .padding(12)
                                    .background(isSelected ? AppColors.primary.opacity(0.1) : AppColors.card)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 1.5)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Custom Write-in Button/Option
                            VStack(alignment: .leading, spacing: 8) {
                                Button {
                                    isCustomSelected = true
                                    AudioManager.shared.playClickSound()
                                } label: {
                                    HStack {
                                        Image(systemName: "pencil.line")
                                            .foregroundStyle(AppColors.primary)
                                        Text("Write Custom Nudge ✏️")
                                            .font(AppFont.body())
                                            .fontWeight(.bold)
                                        Spacer()
                                        Image(systemName: isCustomSelected ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                            .foregroundStyle(isCustomSelected ? AppColors.primary : Color.gray.opacity(0.3))
                                    }
                                    .padding(12)
                                    .background(isCustomSelected ? AppColors.primary.opacity(0.1) : AppColors.card)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(isCustomSelected ? AppColors.primary : Color.clear, lineWidth: 1.5)
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                if isCustomSelected {
                                    TextField("Type your custom encouragement message...", text: $customMessage)
                                        .textFieldStyle(.plain)
                                        .padding(12)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                    }
                    
                    // MARK: - Send Action Button
                    Button {
                        guard !activeMessage.isEmpty else { return }
                        onSend(activeMessage, activeType)
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "paperplane.fill")
                            Text("Send Nudge 🚀")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(activeMessage.isEmpty ? Color.gray.opacity(0.3) : AppColors.primary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .disabled(activeMessage.isEmpty)
                }
                .padding(24)
            }
            .navigationTitle("Nudge Accountability Buddy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
