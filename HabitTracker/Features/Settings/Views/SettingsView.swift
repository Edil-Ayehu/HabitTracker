//
//  SettingsView.swift
//  HabitTracker
//

import SwiftUI
import UniformTypeIdentifiers

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct SettingsView: View {

    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var router: AppRouter
    @StateObject private var supabaseManager = SupabaseManager.shared
    
    @AppStorage("geminiApiKey") private var geminiApiKey: String = ""
    @AppStorage("soundEffectsEnabled") private var soundEffectsEnabled: Bool = true
    @AppStorage("reflectionReminderEnabled") private var reflectionReminderEnabled: Bool = true
    
    @State private var showOnboardingSheet: Bool = false
    @State private var shareItem: IdentifiableURL?
    @State private var showFileImporter: Bool = false
    @State private var alertMessage: String?
    @State private var showAlert: Bool = false

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
            
            // Data Backup & Export Card
            CardView {
                VStack(alignment: .leading, spacing: 14) {
                    Label("Data Backup & Export", systemImage: "arrow.triangle.2.circlepath.circle.fill")
                        .font(AppFont.headline())
                    
                    Text("Export your habit records or backup and restore your complete data.")
                        .font(AppFont.caption())
                        .foregroundStyle(AppColors.textSecondary)
                    
                    VStack(spacing: 10) {
                        Button {
                            exportCSV()
                        } label: {
                            HStack {
                                Label("Export History (CSV)", systemImage: "tablecells.fill")
                                    .font(AppFont.body())
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                            }
                            .foregroundStyle(AppColors.primary)
                            .padding(12)
                            .background(AppColors.primary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            exportJSONBackup()
                        } label: {
                            HStack {
                                Label("Create Full Backup (JSON)", systemImage: "doc.badge.plus")
                                    .font(AppFont.body())
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                            }
                            .foregroundStyle(Color.purple)
                            .padding(12)
                            .background(Color.purple.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            showFileImporter = true
                        } label: {
                            HStack {
                                Label("Restore Data from Backup", systemImage: "arrow.clockwise.icloud.fill")
                                    .font(AppFont.body())
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "folder")
                            }
                            .foregroundStyle(Color.orange)
                            .padding(12)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Supabase Backend Link Card
            CardView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Label("Supabase Backend Link", systemImage: "link.circle.fill")
                            .font(AppFont.headline())
                        
                        Spacer()
                        
                        Text(supabaseManager.isConfigured ? "Connected ⚡" : "Code Linked 🛠️")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(supabaseManager.isConfigured ? AppColors.success.opacity(0.15) : Color.purple.opacity(0.15))
                            .foregroundStyle(supabaseManager.isConfigured ? AppColors.success : Color.purple)
                            .clipShape(Capsule())
                    }
                    
                    Text("Your app is linked directly in code via SupabaseConfig.swift. Edit project URL & Anon Key in code whenever deploying.")
                        .font(AppFont.caption())
                        .foregroundStyle(AppColors.textSecondary)
                    
                    HStack {
                        Image(systemName: "curlybraces")
                            .foregroundStyle(Color.purple)
                        Text("Config: SupabaseConfig.swift")
                            .font(AppFont.caption())
                            .fontWeight(.bold)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.purple.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button {
                        Task {
                            let result = await supabaseManager.testConnection()
                            alertMessage = result.message
                            showAlert = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "bolt.horizontal.circle.fill")
                            Text("Test Supabase Connection ⚡")
                                .font(AppFont.body())
                                .fontWeight(.bold)
                        }
                        .foregroundStyle(Color.purple)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color.purple.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
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
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.url])
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                restoreFromBackup(fileURL: url)
            case .failure(let error):
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
        .alert("Data Backup", isPresented: $showAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage ?? "")
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
    
    private func exportCSV() {
        let habitUseCase = DIContainer.shared.makeHabitUseCase()
        guard let activeHabits = try? habitUseCase.fetchHabits(),
              let archivedHabits = try? habitUseCase.fetchArchivedHabits(),
              let entries = try? habitUseCase.fetchAllEntries() else { return }
        let allHabits = activeHabits + archivedHabits
        if let url = BackupManager.shared.generateCSV(habits: allHabits, entries: entries) {
            self.shareItem = IdentifiableURL(url: url)
        }
    }
    
    private func exportJSONBackup() {
        let habitUseCase = DIContainer.shared.makeHabitUseCase()
        guard let activeHabits = try? habitUseCase.fetchHabits(),
              let archivedHabits = try? habitUseCase.fetchArchivedHabits(),
              let entries = try? habitUseCase.fetchAllEntries() else { return }
        let allHabits = activeHabits + archivedHabits
        if let url = BackupManager.shared.generateJSONBackup(habits: allHabits, entries: entries) {
            self.shareItem = IdentifiableURL(url: url)
        }
    }
    
    private func restoreFromBackup(fileURL: URL) {
        guard fileURL.startAccessingSecurityScopedResource() else {
            alertMessage = "Permission denied to read backup file."
            showAlert = true
            return
        }
        defer { fileURL.stopAccessingSecurityScopedResource() }
        
        do {
            let result = try BackupManager.shared.restoreFromJSON(fileURL: fileURL, useCase: DIContainer.shared.makeHabitUseCase())
            if result.habitsCount == 0 && result.entriesCount == 0 {
                alertMessage = "Your data is already up to date! All \(result.totalInBackup) habits and check-in records in this backup are already present in your app."
            } else {
                alertMessage = "Restore completed successfully! Added \(result.habitsCount) new habits and \(result.entriesCount) check-in entries."
            }
            showAlert = true
            AudioManager.shared.playCompletionSound()
        } catch {
            alertMessage = "Failed to restore backup: \(error.localizedDescription)"
            showAlert = true
        }
    }
}
