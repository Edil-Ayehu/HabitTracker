//
//  SettingsView.swift
//  HabitTracker
//
//  Created by Edil on 04/08/2026.
//

import SwiftUI

//struct SettingsView: View {
//
//    @EnvironmentObject
//    private var themeManager: ThemeManager
//    
//    @EnvironmentObject private var router: AppRouter
//
//    var body: some View {
//
//        AppScaffold(title: "Settings") {
//
//            CardView {
//
//                VStack(alignment: .leading, spacing: 20) {
//
//                    Label(
//                        "Appearance",
//                        systemImage: "paintbrush"
//                    )
//                    .font(AppFont.headline())
//
//                    Picker(
//                        "Theme",
//                        selection: $themeManager.theme
//                    ) {
//
//                        ForEach(AppTheme.allCases) { theme in
//
//                            Text(theme.title)
//                                .tag(theme)
//                        }
//                    }
//                    .pickerStyle(.segmented)
//                }
//            }
//
//            CardView {
//
//                VStack(alignment: .leading, spacing: 18) {
//
//                    settingsRow(
//                        title: "Notifications",
//                        icon: "bell.fill"
//                    ) {
//                        router.push(.notification)
//                    }
//
//                    settingsRow(
//                        title: "Week Starts On",
//                        icon: "calendar"
//                    ) {
//                        
//                    }
//
//                    settingsRow(
//                        title: "Statistics",
//                        icon: "chart.bar.fill"
//                    ) {
//                        router.push(.statistics)
//                    }
//
//                    settingsRow(
//                        title: "About",
//                        icon: "info.circle"
//                    ) {
//                        
//                    }
//                }
//            }
//
//            Spacer()
//        }
//    }
//
//    @ViewBuilder
//    private func settingsRow(
//        title: String,
//        icon: String,
//        action: @escaping () -> Void
//    ) -> some View {
//
//        HStack {
//
//            Label(title, systemImage: icon)
//
//            Spacer()
//
//            Image(systemName: "chevron.right")
//                .foregroundStyle(.secondary)
//        }
//        .padding(.vertical, 6)
//        .contentShape(Rectangle())   // Makes the whole row tappable
//        .onTapGesture {
//            action()
//        }
//    }
//}
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

    var body: some View {
        AppScaffold(title: "Settings") {
            VStack(spacing: 20) {
                // MARK: - Appearance Card
                CardView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            iconBadge(icon: "paintbrush.fill", color: .indigo)

                            Text("Appearance")
                                .font(AppFont.headline())
                                .foregroundColor(.primary)
                        }

                        Picker("Theme", selection: $themeManager.theme) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(theme.title).tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)
                }

                // MARK: - General Settings Card
                CardView {
                    VStack(spacing: 0) {
                        settingsRow(
                            title: "Notifications",
                            icon: "bell.fill",
                            color: .red
                        ) {
                            router.push(.notification)
                        }

                        Divider()
                            .padding(.leading, 44)

                        settingsRow(
                            title: "Week Starts On",
                            icon: "calendar",
                            color: .blue,
                            value: "Monday"
                        ) {
                            // Week start action
                        }

                        Divider()
                            .padding(.leading, 44)

                        settingsRow(
                            title: "Statistics",
                            icon: "chart.bar.fill",
                            color: .green
                        ) {
                            router.push(.statistics)
                        }

                        Divider()
                            .padding(.leading, 44)

                        settingsRow(
                            title: "About",
                            icon: "info.circle.fill",
                            color: .gray,
                            value: "v1.0"
                        ) {
                            // About action
                        }
                    }
                }

                Spacer()
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Reusable Row Component

    @ViewBuilder
    private func settingsRow(
        title: String,
        icon: String,
        color: Color,
        value: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                iconBadge(icon: icon, color: color)

                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()

                if let value = value {
                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Icon Badge

    @ViewBuilder
    private func iconBadge(icon: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color.gradient)
                .frame(width: 32, height: 32)

            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}
