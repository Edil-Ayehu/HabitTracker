//
//  ReflectionPromptCard.swift
//  HabitTracker
//

import SwiftUI

struct ReflectionPromptCard: View {
    let completionRate: Int
    @StateObject private var manager = ReflectionManager.shared
    @State private var showReflectionSheet = false
    
    var body: some View {
        Button {
            showReflectionSheet = true
        } label: {
            CardView {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 44, height: 44)
                        
                        Text(manager.todayReflection?.mood.emoji ?? "🌙")
                            .font(.system(size: 22))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("Nightly Reflection")
                                .font(AppFont.headline())
                                .foregroundStyle(AppColors.textPrimary)
                            
                            Spacer()
                            
                            if let ref = manager.todayReflection {
                                Text("\(ref.mood.title) \(ref.mood.emoji)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(ref.mood.color)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(ref.mood.color.opacity(0.15))
                                    .clipShape(Capsule())
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }
                        
                        Text(manager.todayReflection != nil ? "Reflection saved for today ✓ Tap to view/edit" : "Log your mood & gratitude for +25 XP")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showReflectionSheet) {
            NightlyReflectionSheet(completionRate: completionRate)
        }
    }
}
