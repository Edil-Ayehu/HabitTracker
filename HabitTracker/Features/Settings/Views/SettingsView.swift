//
//  SettingsView.swift
//  HabitTracker
//
//  Created by Edil on 04/08/2026.
//

import SwiftUI

struct SettingsView: View {

    @EnvironmentObject
    private var themeManager: ThemeManager
    
    @EnvironmentObject private var router: AppRouter

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

            CardView {

                VStack(alignment: .leading, spacing: 18) {

                    settingsRow(
                        title: "Notifications",
                        icon: "bell.fill"
                    ) {
                        router.push(.notification)
                    }

                    settingsRow(
                        title: "Week Starts On",
                        icon: "calendar"
                    ) {
                        
                    }

                    settingsRow(
                        title: "Statistics",
                        icon: "chart.bar.fill"
                    ) {
                        router.push(.statistics)
                    }

                    settingsRow(
                        title: "About",
                        icon: "info.circle"
                    ) {
                        
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
        .contentShape(Rectangle())   // Makes the whole row tappable
        .onTapGesture {
            action()
        }
    }
}

