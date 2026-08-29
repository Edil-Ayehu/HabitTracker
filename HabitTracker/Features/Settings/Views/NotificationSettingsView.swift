//
//  NotificationSettingsView.swift
//  HabitTracker
//
//  Created by Edil on 05/08/2026.
//

import SwiftUI

struct NotificationSettingsView: View {
    
    @AppStorage("notificationsEnabled")
    private var notificationsEnabled = true
    
    @Environment(\.scenePhase)
    private var scenePhase
    
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    var body: some View {
        
        AppScaffold(title: "Notifications") {
            
            CardView {
                
                Toggle(
                    "Enable Notifications",
                    isOn: $notificationsEnabled
                )
                .onChange(of: notificationsEnabled) { _, enabled in
                    
                    Task {
                        
                        await updateNotificationState(enabled)
                    }
                }
                .font(AppFont.body())

            }
            
            CardView {
                
                HStack {
                    
                    Text("Permission")
                        .font(AppFont.body())
                    
                    Spacer()
                    
                    Text(statusText)
                        .font(AppFont.headline())
                        .foregroundStyle(.secondary)
                }
            }
            
            if authorizationStatus == .denied {
                
                Text(
                    "Notifications are disabled in Settings."
                )
                .foregroundStyle(.orange)
                
                Button("Open Settings") {
                    
                    NotificationManager.shared.openSystemSettings()
                }
            }
            
            Spacer()
        }
        .task {
            
            await refreshAuthorizationStatus()
            
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else {
                return
            }
            
            Task {
                
                await refreshAuthorizationStatus()
            }
            
        }
    }
    
    private func updateNotificationState(_ enabled: Bool) async {
        
        if enabled {
            
            await NotificationManager.shared.requestPermission()
            
            let status =
            await NotificationManager.shared.authorizationStatus()
            
            authorizationStatus = status
            
            guard status == .authorized ||
                    status == .provisional else {
                return
            }
            
            await NotificationManager.shared.refreshAllReminders()
            
        } else {
            
            NotificationManager.shared.removeAllReminders()
            
            authorizationStatus =
            await NotificationManager.shared.authorizationStatus()
        }
    }
    
    private var statusText: String {
        
        switch authorizationStatus {
            
        case .authorized:
            return "Allowed"
            
        case .denied:
            return "Denied"
            
        case .notDetermined:
            return "Not Determined"
            
        case .provisional:
            return "Provisional"
            
        case .ephemeral:
            return "Ephemeral"
            
        @unknown default:
            return "Unknown"
        }
    }
    
    private func refreshAuthorizationStatus() async {

        authorizationStatus =
            await NotificationManager.shared.authorizationStatus()
    }
}

