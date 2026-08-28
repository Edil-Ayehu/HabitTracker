//
//  ReflectionJournalView.swift
//  HabitTracker
//

import SwiftUI

struct ReflectionJournalView: View {
    @StateObject private var manager = ReflectionManager.shared
    @State private var selectedMoodFilter: MoodRating? = nil
    @State private var selectedReflectionToEdit: NightlyReflection? = nil
    @State private var showReflectionSheet = false
    
    var filteredReflections: [NightlyReflection] {
        let all = manager.fetchAllReflections()
        guard let filter = selectedMoodFilter else { return all }
        return all.filter { $0.mood == filter }
    }
    
    var body: some View {
        AppScaffold(title: "Reflection Journal 📖") {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                
                // Mood Filter Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button {
                            selectedMoodFilter = nil
                            AudioManager.shared.playClickSound()
                        } label: {
                            Text("All Logs 📖")
                                .font(AppFont.caption())
                                .fontWeight(selectedMoodFilter == nil ? .bold : .medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(selectedMoodFilter == nil ? AppColors.primary.opacity(0.18) : AppColors.card)
                                .foregroundStyle(selectedMoodFilter == nil ? AppColors.primary : AppColors.textSecondary)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(selectedMoodFilter == nil ? AppColors.primary : Color.clear, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        
                        ForEach(MoodRating.allCases) { mood in
                            let isSelected = selectedMoodFilter == mood
                            Button {
                                selectedMoodFilter = isSelected ? nil : mood
                                AudioManager.shared.playClickSound()
                            } label: {
                                HStack(spacing: 4) {
                                    Text(mood.emoji)
                                        .font(.system(size: 13))
                                    Text(mood.title)
                                        .font(AppFont.caption())
                                        .fontWeight(isSelected ? .bold : .medium)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(isSelected ? mood.color.opacity(0.18) : AppColors.card)
                                .foregroundStyle(isSelected ? mood.color : AppColors.textSecondary)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(isSelected ? mood.color : Color.clear, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // Reflection Entries Feed
                if filteredReflections.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(AppColors.textSecondary.opacity(0.4))
                        Text(selectedMoodFilter == nil ? "No Nightly Reflections Yet" : "No \(selectedMoodFilter?.title ?? "") Reflections")
                            .font(AppFont.headline())
                        Text("Log your mood, gratitude, and daily wins at 9:00 PM to earn +25 XP and build your reflection journal.")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.xl)
                } else {
                    LazyVStack(spacing: AppSpacing.md) {
                        ForEach(filteredReflections) { ref in
                            CardView {
                                VStack(alignment: .leading, spacing: 10) {
                                    // Header: Date & Mood Badge
                                    HStack {
                                        HStack(spacing: 6) {
                                            Text(ref.mood.emoji)
                                                .font(.system(size: 20))
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(ref.dateString)
                                                    .font(AppFont.headline())
                                                Text(ref.mood.title)
                                                    .font(AppFont.caption())
                                                    .foregroundStyle(ref.mood.color)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: "checkmark.seal.fill")
                                                .font(.system(size: 10))
                                            Text("\(ref.completionRate)% Habits")
                                                .font(.system(size: 10, weight: .bold))
                                        }
                                        .foregroundStyle(AppColors.primary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(AppColors.primary.opacity(0.12))
                                        .clipShape(Capsule())
                                    }
                                    
                                    // Gratitude Note
                                    if !ref.gratitudeNote.isEmpty {
                                        Divider()
                                        
                                        HStack(alignment: .top, spacing: 6) {
                                            Text("🌟 Gratitude:")
                                                .font(AppFont.caption())
                                                .fontWeight(.bold)
                                                .foregroundStyle(.orange)
                                            Text("\"\(ref.gratitudeNote)\"")
                                                .font(AppFont.caption())
                                                .foregroundStyle(AppColors.textPrimary)
                                                .italic()
                                        }
                                    }
                                    
                                    // Journal / Highlights Note
                                    if !ref.journalNote.isEmpty {
                                        HStack(alignment: .top, spacing: 6) {
                                            Text("✨ Highlights:")
                                                .font(AppFont.caption())
                                                .fontWeight(.bold)
                                                .foregroundStyle(AppColors.primary)
                                            Text(ref.journalNote)
                                                .font(AppFont.caption())
                                                .foregroundStyle(AppColors.textSecondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
