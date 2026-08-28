//
//  NightlyReflectionSheet.swift
//  HabitTracker
//

import SwiftUI

struct NightlyReflectionSheet: View {
    let completionRate: Int
    @StateObject private var manager = ReflectionManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedMood: MoodRating = .good
    @State private var gratitudeNote: String = ""
    @State private var journalNote: String = ""
    
    var body: some View {
        AppScaffold(title: "Nightly Reflection 🌙") {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                let isEditing = manager.todayReflection != nil
                
                // Header Banner
                CardView {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isEditing ? "Edit Today's Reflection" : "How was your day?")
                            .font(AppFont.headline())
                            .fontWeight(.bold)
                        Text(isEditing ? "Update your mood, gratitude, or evening journal entry." : "Log your mood, reflect on gratitude, and earn +25 XP.")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                
                // Mood Emoji Picker
                SectionHeader(title: "Select Mood Rating")
                
                HStack(spacing: 0) {
                    ForEach(MoodRating.allCases) { mood in
                        let isSelected = selectedMood == mood
                        VStack(spacing: 6) {
                            Text(mood.emoji)
                                .font(.system(size: isSelected ? 36 : 28))
                                .scaleEffect(isSelected ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                            
                            Text(mood.title)
                                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                .foregroundStyle(isSelected ? mood.color : AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isSelected ? mood.color.opacity(0.12) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedMood = mood
                            AudioManager.shared.playClickSound()
                        }
                    }
                }
                .padding(6)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Gratitude Entry
                SectionHeader(title: "Daily Gratitude 🌟")
                
                CardView {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("What is 1 thing you are grateful for today?")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                        
                        TextField("e.g., Morning coffee, great workout, call with family...", text: $gratitudeNote)
                            .font(AppFont.body())
                            .textFieldStyle(.plain)
                    }
                }
                
                // Journal Notes
                SectionHeader(title: "Evening Reflection Notes 📝")
                
                CardView {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Write any thoughts or highlights from today...")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                        
                        TextField("e.g., Stayed focused on reading, felt energized after walking...", text: $journalNote, axis: .vertical)
                            .font(AppFont.body())
                            .lineLimit(3...5)
                            .textFieldStyle(.plain)
                    }
                }
                
                // Save / Update Button
                Button {
                    manager.saveReflection(
                        mood: selectedMood,
                        journalNote: journalNote,
                        gratitudeNote: gratitudeNote,
                        completionRate: completionRate
                    )
                    AudioManager.shared.playCompletionSound()
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                        Text(isEditing ? "Update Reflection" : "Save Reflection (+25 XP)")
                    }
                    .font(AppFont.body())
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [AppColors.primary, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            if let existing = manager.todayReflection {
                selectedMood = existing.mood
                gratitudeNote = existing.gratitudeNote
                journalNote = existing.journalNote
            }
        }
    }
}
