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
    @AppStorage("reflectionReminderEnabled") private var reflectionReminderEnabled: Bool = true
    
    @State private var showOnboardingSheet: Bool = false

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
            
            // Nightly Reflection Reminder Card
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(isOn: $reflectionReminderEnabled) {
                        Label("Nightly Reflection Reminder", systemImage: "moon.fill")
                            .font(AppFont.headline())
                    }
                    .tint(AppColors.primary)
                    .onChange(of: reflectionReminderEnabled) { newValue in
                        if newValue {
                            NotificationManager.shared.scheduleNightlyReflectionReminder()
                        } else {
                            NotificationManager.shared.removeNightlyReflectionReminder()
                        }
                    }
                    
                    if reflectionReminderEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: Binding(
                                get: {
                                    let hour = UserDefaults.standard.object(forKey: "reflectionReminderHour") as? Int ?? 21
                                    let minute = UserDefaults.standard.object(forKey: "reflectionReminderMinute") as? Int ?? 0
                                    return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
                                },
                                set: { newDate in
                                    let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                    NotificationManager.shared.scheduleNightlyReflectionReminder(
                                        hour: components.hour ?? 21,
                                        minute: components.minute ?? 0
                                    )
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .font(AppFont.body())
                    }
                    
                    Text("Configured time to receive your daily evening mood & reflection notification.")
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

                    settingsRow(
                        title: "Replay App Guide 📖",
                        icon: "book.fill"
                    ) {
                        showOnboardingSheet = true
                    }
                }
            }
            .fullScreenCover(isPresented: $showOnboardingSheet) {
                OnboardingView()
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
                .font(AppFont.body())

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
