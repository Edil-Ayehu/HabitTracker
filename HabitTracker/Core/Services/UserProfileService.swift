//
//  UserProfileService.swift
//  HabitTracker
//

import Foundation
import Combine

private struct SupabaseProfileDTO: Codable {
    let id: UUID
    let username: String
    let display_name: String
}

@MainActor
final class UserProfileService: ObservableObject {
    static let shared = UserProfileService()
    
    @Published var userID: UUID
    @Published var displayName: String
    @Published var usernameHandle: String
    @Published var isProfileCreated: Bool
    
    private let userIDKey = "user_device_id_key"
    private let displayNameKey = "user_display_name_key"
    private let usernameHandleKey = "user_handle_key"
    
    private init() {
        if let idStr = UserDefaults.standard.string(forKey: userIDKey),
           let existingID = UUID(uuidString: idStr) {
            self.userID = existingID
        } else {
            let newID = UUID()
            UserDefaults.standard.set(newID.uuidString, forKey: userIDKey)
            self.userID = newID
        }
        
        let savedName = UserDefaults.standard.string(forKey: displayNameKey) ?? ""
        let savedHandle = UserDefaults.standard.string(forKey: usernameHandleKey) ?? ""
        
        self.displayName = savedName
        self.usernameHandle = savedHandle
        self.isProfileCreated = !savedHandle.isEmpty
    }
    
    // MARK: - Handle Validation & Availability
    func cleanHandle(_ raw: String) -> String {
        var clean = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !clean.hasPrefix("@") && !clean.isEmpty {
            clean = "@" + clean
        }
        return clean
    }
    
    func checkHandleAvailability(handle: String) async -> (available: Bool, message: String) {
        let formatted = cleanHandle(handle)
        if formatted.count < 3 {
            return (false, "Handle must be at least 3 characters.")
        }
        
        guard SupabaseManager.shared.isConfigured else {
            return (true, "Local mode: Handle available.")
        }
        
        do {
            // Query Supabase profiles table for existing handle
            let endpoint = "profiles?username=eq.\(formatted)"
            let data = try await SupabaseManager.shared.performRESTRequest(endpoint: endpoint, method: "GET")
            let existingProfiles = try JSONDecoder().decode([SupabaseProfileDTO].self, from: data)
            
            if let matched = existingProfiles.first {
                if matched.id == userID {
                    return (true, "This is your current handle.")
                } else {
                    return (false, "Handle \(formatted) is already taken. Try another!")
                }
            } else {
                return (true, "Handle \(formatted) is available! 🎉")
            }
        } catch {
            return (true, "Handle \(formatted) is available! 🎉")
        }
    }
    
    // MARK: - Save Profile
    func saveProfile(name: String, handle: String) async throws {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let formattedHandle = cleanHandle(handle)
        
        guard !cleanName.isEmpty else {
            throw NSError(domain: "UserProfileService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Please enter your display name."])
        }
        
        let check = await checkHandleAvailability(handle: formattedHandle)
        guard check.available else {
            throw NSError(domain: "UserProfileService", code: 400, userInfo: [NSLocalizedDescriptionKey: check.message])
        }
        
        self.displayName = cleanName
        self.usernameHandle = formattedHandle
        self.isProfileCreated = true
        
        UserDefaults.standard.set(cleanName, forKey: displayNameKey)
        UserDefaults.standard.set(formattedHandle, forKey: usernameHandleKey)
        
        // Push profile to Supabase if configured
        if SupabaseManager.shared.isConfigured {
            do {
                let dto = SupabaseProfileDTO(id: userID, username: formattedHandle, display_name: cleanName)
                let body = try JSONEncoder().encode([dto])
                _ = try await SupabaseManager.shared.performRESTRequest(endpoint: "profiles", method: "POST", body: body)
            } catch {
                print("Supabase profile save warning: \(error.localizedDescription)")
            }
        }
    }
}
