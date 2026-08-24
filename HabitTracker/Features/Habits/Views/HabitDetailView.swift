//
//  HabitDetailView.swift
//  HabitTracker
//
//  Created by Edil on 02/08/2026.
//

import SwiftUI

struct HabitDetailView: View {
    
    @StateObject var vm: HabitDetailViewModel
    @EnvironmentObject private var router: AppRouter
    
    @State private var showDeleteDialog: Bool = false
    @State private var showImagePickerOptions: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @FocusState private var isNoteFocused: Bool

    var body: some View {
        AppScaffold(title: vm.title) {
            VStack(spacing: 20) {
                
                HabitProgressRing(
                    current: vm.progress,
                    goal: vm.goal
                )
                .frame(width: 160)
                
                if vm.isMeasurable {
                    HStack(spacing: 20) {
                        AppIconButton(systemImage: "minus") {
                            vm.decrement()
                        }
                        .disabled(!vm.canDecrement)
                        
                        Text("\(vm.progress) / \(vm.goal)")
                            .font(AppFont.title())
                        
                        AppIconButton(systemImage: "plus") {
                            vm.increment()
                        }
                        .disabled(!vm.canIncrement)
                    }
                }
                
                FocusTimerCard {
                    vm.complete()
                }
                
                if vm.canComplete {
                    PrimaryButton(
                        title: vm.isBinary ? "Complete Habit" : "Mark Complete"
                    ) {
                        vm.complete()
                    }
                } else {
                    Label("Completed Today", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(AppColors.success)
                        .font(AppFont.headline())
                }
                
                if !vm.canComplete {
                    CardView {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Today's Reflection & Photo")
                                .font(AppFont.headline())
                            
                            if vm.isEditingNote {
                                TextField("Add your thoughts or reflection here...", text: $vm.note, axis: .vertical)
                                    .font(AppFont.body())
                                    .lineLimit(3...6)
                                    .focused($isNoteFocused)
                                    .padding(12)
                                    .background(Color.gray.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        isNoteFocused = true
                                    }
                                
                                if let image = vm.selectedImage {
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 160)
                                            .frame(maxWidth: .infinity)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                        Button {
                                            vm.selectedImage = nil
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.title2)
                                                .foregroundStyle(.white)
                                                .padding(8)
                                                .background(Circle().fill(Color.black.opacity(0.5)))
                                        }
                                        .padding(6)
                                    }
                                }
                                
                                HStack(spacing: 12) {
                                    Button {
                                        vm.isEditingNote = true
                                        showImagePickerOptions = true
                                    } label: {
                                        Label(
                                            vm.selectedImage == nil ? "Add Photo" : "Change Photo",
                                            systemImage: "camera.fill"
                                        )
                                        .font(AppFont.headline())
                                        .foregroundStyle(AppColors.primary)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 14)
                                        .background(AppColors.primary.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    
                                    Spacer()
                                    
                                    PrimaryButton(title: "Save Reflection") {
                                        vm.saveNote()
                                    }
                                }
                            } else {
                                if !vm.note.isEmpty {
                                    Text(vm.note)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color.gray.opacity(0.08))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                if let image = vm.selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 180)
                                        .frame(maxWidth: .infinity)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                
                                Button {
                                    vm.isEditingNote = true
                                } label: {
                                    Label("Edit Reflection", systemImage: "pencil")
                                        .font(AppFont.caption())
                                        .foregroundStyle(AppColors.primary)
                                }
                            }
                        }
                    }
                }
                
                HStack(spacing: AppSpacing.md) {
                    StatCard(
                        icon: "flame.fill",
                        title: "Current Streak",
                        value: vm.streak == 1 ? "1 day" : "\(vm.streak) days"
                    )
                    
                    StatCard(
                        icon: "trophy.fill",
                        title: "Best Streak",
                        value: vm.bestStreak == 1 ? "1 day" : "\(vm.bestStreak) days"
                    )
                }
                
                ReminderSection(
                    enabled: vm.reminderEnabled,
                    time: vm.reminderTime
                ) { enabled, time in
                    vm.updateReminder(enabled: enabled, time: time)
                }
                
                HabitCalendarView(entries: vm.entries)
                
                SectionHeader(title: "History")
                
                LazyVStack(spacing: AppSpacing.sm) {
                    ForEach(vm.entries) { entry in
                        CardView {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(AppFont.headline())
                                    
                                    Spacer()
                                    
                                    Image(systemName: entry.completed ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundStyle(entry.completed ? AppColors.success : Color.gray.opacity(0.4))
                                }
                                
                                if !entry.note.isEmpty {
                                    Text(entry.note)
                                        .font(AppFont.body())
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                                
                                if let data = entry.imageData, let img = UIImage(data: data) {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 140)
                                        .frame(maxWidth: .infinity)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            vm.load()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Edit") {
                        router.push(.editHabit(vm.habit))
                    }
                    
                    Button("Delete", role: .destructive) {
                        showDeleteDialog = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog("Delete habit?", isPresented: $showDeleteDialog) {
            Button("Delete", role: .destructive) {
                if vm.deleteHabit() {
                    router.pop()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete '\(vm.title)'? This will remove all tracked progress for this habit.")
        }
        .confirmationDialog("Attach Photo", isPresented: $showImagePickerOptions) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("📷 Take Photo") {
                    pickerSourceType = .camera
                    showImagePicker = true
                }
            }
            
            Button("🖼️ Choose from Photo Library") {
                pickerSourceType = .photoLibrary
                showImagePicker = true
            }
            
            if vm.selectedImage != nil {
                Button("Remove Photo", role: .destructive) {
                    vm.removeImage()
                }
            }
            
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showImagePicker, onDismiss: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isNoteFocused = true
            }
        }) {
            ImagePicker(sourceType: pickerSourceType, selectedImage: $vm.selectedImage)
        }
    }
}
