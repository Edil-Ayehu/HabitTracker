//
//  SettingsView.swift
//  HabitTracker
//
//  Created by Edil on 04/08/2026.
//

import SwiftUI

struct SettingsView: View {

    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var router: AppRouter
    
    @AppStorage("geminiApiKey") private var geminiApiKey: String = ""
    @AppStorage("soundEffectsEnabled") private var soundEffectsEnabled: Bool = true

    var body: some View {

        AppScaffold(title: "Settings") {

            CardView {

                VStack(alignment: .leading, spacing: 20) {

                    Label(
                        "Appearance",
                        systemImage: "paintbrush"
                    )
                    .font(AppFont.headline())

                    Picker(
                        "Theme",
                        selection: $themeManager.theme
                    ) {

                        ForEach(AppTheme.allCases) { theme in

                            Text(theme.title)
                                .tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            
            // Sound Effects Card
            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    Toggle(isOn: $soundEffectsEnabled) {
                        Label("Sound Effects", systemImage: "speaker.wave.2.fill")
                            .font(AppFont.headline())
                    }
                    .tint(AppColors.primary)
                    
                    Text("Play audio chimes when completing habits and celebrating daily goals.")
                        .font(AppFont.caption())
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            
            // Gemini AI Configuration Card
            CardView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Label("Gemini AI Engine", systemImage: "sparkles")
                            .font(AppFont.headline())
                        
                        Spacer()
                        
                        if !geminiApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("Active")
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppColors.success.opacity(0.15))
                                .foregroundStyle(AppColors.success)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text("Enter your Google Gemini API Key to enable real-time AI routine generation.")
                        .font(AppFont.caption())
                        .foregroundStyle(AppColors.textSecondary)
                    
                    SecureField("AI API Key (e.g. AIzaSy...)", text: $geminiApiKey)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color.gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            CardView {

                VStack(alignment: .leading, spacing: 18) {

                    settingsRow(
                        title: "Notifications",
                        icon: "bell.fill"
                    ) {
                        router.push(.notification)
                    }

                    settingsRow(
                        title: "AI Routine Builder",
                        icon: "sparkles"
                    ) {
                        router.push(.aiRoutineGenerator)
                    }

                    settingsRow(
                        title: "Widgets & Home Screen",
                        icon: "square.grid.2x2.fill"
                    ) {
                        router.push(.widgetPreview)
                    }

                    settingsRow(
                        title: "Statistics",
                        icon: "chart.bar.fill"
                    ) {
                        router.push(.statistics)
                    }
                }
            }

            Spacer()
        }
    }

    @ViewBuilder
    private func settingsRow(
        title: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {

        HStack {

            Label(title, systemImage: icon)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}
