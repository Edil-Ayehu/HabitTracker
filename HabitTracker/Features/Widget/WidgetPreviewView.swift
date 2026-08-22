//
//  WidgetPreviewView.swift
//  HabitTracker
//

import SwiftUI

struct WidgetPreviewView: View {
    @State private var widgetData = WidgetSharedData.load()
    @State private var selectedTab = 0
    
    var body: some View {
        AppScaffold(title: "Widgets & Home Screen") {
            VStack(spacing: AppSpacing.lg) {
                
                // Segmented Picker
                Picker("Widget Type", selection: $selectedTab) {
                    Text("Small").tag(0)
                    Text("Medium").tag(1)
                    Text("Lock Screen").tag(2)
                }
                .pickerStyle(.segmented)
                
                // Live Preview Card
                CardView {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        HStack {
                            Text("Live Widget Preview")
                                .font(AppFont.headline())
                            Spacer()
                            Label("WidgetKit", systemImage: "sparkles")
                                .font(AppFont.caption())
                                .foregroundStyle(AppColors.primary)
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.1))
                            
                            switch selectedTab {
                            case 0:
                                HabitSmallWidgetView(data: widgetData)
                                    .frame(width: 160, height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 22))
                                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                            case 1:
                                HabitMediumWidgetView(data: widgetData)
                                    .frame(width: 330, height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 22))
                                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                            case 2:
                                HStack(spacing: 20) {
                                    VStack {
                                        Text("Circular")
                                            .font(AppFont.caption())
                                            .foregroundStyle(AppColors.textSecondary)
                                        HabitLockScreenCircularView(data: widgetData)
                                            .frame(width: 60, height: 60)
                                    }
                                    
                                    VStack {
                                        Text("Rectangular")
                                            .font(AppFont.caption())
                                            .foregroundStyle(AppColors.textSecondary)
                                        HabitLockScreenRectangularView(data: widgetData)
                                            .frame(width: 160, height: 60)
                                            .padding(8)
                                            .background(Color.black)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            default:
                                EmptyView()
                            }
                        }
                        .frame(minHeight: 200)
                        .padding(.vertical, 8)
                    }
                }
                
                // How to Add Widgets Guide
                CardView {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("📲 How to Add Widgets to iOS")
                            .font(AppFont.headline())
                        
                        VStack(alignment: .leading, spacing: 12) {
                            GuideStepRow(step: "1", title: "Long press Home Screen", description: "Touch and hold any empty area on your iPhone Home Screen until apps start to jiggle.")
                            GuideStepRow(step: "2", title: "Tap the '+' button", description: "Tap the plus button (+) in the top-left corner of your screen.")
                            GuideStepRow(step: "3", title: "Select HabitTracker", description: "Search for HabitTracker and pick your favorite Small, Medium, or Lock Screen widget.")
                        }
                    }
                }
                
                // Xcode Extension Developer Note Card
                CardView {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "hammer.fill")
                                .foregroundStyle(AppColors.primary)
                            Text("Xcode Widget Extension Target")
                                .font(AppFont.headline())
                        }
                        
                        Text("WidgetKit code & shared App Group sync (`WidgetSharedData.swift`) are fully compiled. To enable iOS system-wide widget gallery rendering in Xcode:\n\n1. Open `HabitTracker.xcodeproj` in Xcode.\n2. Go to **File > New > Target**.\n3. Select **Widget Extension** and name it `HabitTrackerWidget`.\n4. Enable **App Groups** (`group.com.myorganization.HabitTracker`) on both targets.")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
        }
        .onAppear {
            widgetData = WidgetSharedData.load()
        }
    }
}

struct GuideStepRow: View {
    let step: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.15))
                    .frame(width: 28, height: 28)
                Text(step)
                    .font(AppFont.caption())
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.primary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.body())
                    .fontWeight(.semibold)
                Text(description)
                    .font(AppFont.caption())
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}
