//
//  ProfileSetupView.swift
//  HabitTracker
//

import SwiftUI

struct ProfileSetupView: View {
    @StateObject private var profileService = UserProfileService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var nameInput: String = ""
    @State private var handleInput: String = ""
    @State private var availabilityMessage: String? = nil
    @State private var isAvailable: Bool = false
    @State private var isChecking: Bool = false
    @State private var errorMessage: String? = nil
    @State private var isSaving: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(AppColors.primary.opacity(0.15))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 40))
                            .foregroundStyle(AppColors.primary)
                    }
                    .padding(.top, 20)
                    
                    Text("Set Up Your Profile 👤")
                        .font(AppFont.title())
                        .fontWeight(.bold)
                    
                    Text("Choose a display name and unique handle to connect with friends in Habit Squads.")
                        .font(AppFont.body())
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.horizontal, 20)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Display Name")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                        
                        TextField("e.g. Ram", text: $nameInput)
                            .textFieldStyle(.plain)
                            .padding(14)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Unique Username Handle")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColors.textSecondary)
                        
                        HStack {
                            TextField("e.g. @ram_99", text: $handleInput)
                                .textFieldStyle(.plain)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .onChange(of: handleInput) { newValue in
                                    checkHandle(newValue)
                                }
                            
                            if isChecking {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                        .padding(14)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        if let msg = availabilityMessage {
                            Text(msg)
                                .font(AppFont.caption())
                                .foregroundStyle(isAvailable ? AppColors.success : Color.red)
                                .padding(.leading, 4)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                if let err = errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text(err)
                            .font(AppFont.caption())
                    }
                    .foregroundStyle(Color.red)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 20)
                }
                
                Button {
                    saveProfile()
                } label: {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    } else {
                        Text("Save Profile")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.primary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .buttonStyle(.plain)
                .disabled(isSaving || nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !isAvailable)
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .onAppear {
                nameInput = profileService.displayName
                handleInput = profileService.usernameHandle
                if !handleInput.isEmpty {
                    checkHandle(handleInput)
                }
            }
            .toolbar {
                if profileService.isProfileCreated {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
            }
        }
    }
    
    private func checkHandle(_ text: String) {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard clean.count >= 3 else {
            availabilityMessage = "Handle must be at least 3 characters."
            isAvailable = false
            return
        }
        
        isChecking = true
        Task {
            let res = await profileService.checkHandleAvailability(handle: clean)
            isChecking = false
            isAvailable = res.available
            availabilityMessage = res.message
        }
    }
    
    private func saveProfile() {
        isSaving = true
        errorMessage = nil
        Task {
            do {
                try await profileService.saveProfile(name: nameInput, handle: handleInput)
                isSaving = false
                dismiss()
            } catch {
                isSaving = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
