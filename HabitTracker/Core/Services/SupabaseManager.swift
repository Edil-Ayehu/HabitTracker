//
//  SupabaseManager.swift
//  HabitTracker
//

import Foundation

@MainActor
final class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    private init() {}
    
    @Published var supabaseURL: String = SupabaseConfig.projectURL
    @Published var supabaseAnonKey: String = SupabaseConfig.anonKey
    
    var isConfigured: Bool {
        !supabaseURL.contains("your-project-id") &&
        !supabaseURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !supabaseAnonKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Connection Diagnostics Test
    func testConnection() async -> (success: Bool, message: String) {
        let cleanBase = supabaseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/ "))
        guard isConfigured, let requestURL = URL(string: "\(cleanBase)/rest/v1/squads?select=id") else {
            return (false, "Supabase credentials missing or invalid URL.")
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return (false, "Invalid HTTP response.")
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                return (true, "Successfully connected to Supabase project! (HTTP 200 OK)")
            } else {
                let responseStr = String(data: data, encoding: .utf8) ?? "Unknown error"
                if httpResponse.statusCode == 404 {
                    return (false, "Connected to Supabase, but table 'squads' was not found (HTTP 404). Check table schema & RLS grants.")
                } else if responseStr.contains("42501") || responseStr.contains("row-level security") {
                    return (false, "Connected to Supabase, but Row Level Security (RLS) is blocking inserts/reads. Add an RLS policy or disable RLS for 'squads'.")
                } else {
                    return (false, "HTTP \(httpResponse.statusCode): \(responseStr)")
                }
            }
        } catch {
            return (false, "Connection failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Generic REST Request Helper for Supabase
    func performRESTRequest(endpoint: String, method: String = "GET", body: Data? = nil) async throws -> Data {
        let cleanBase = supabaseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/ "))
        let cleanEndpoint = endpoint.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        guard isConfigured, let requestURL = URL(string: "\(cleanBase)/rest/v1/\(cleanEndpoint)") else {
            throw NSError(domain: "SupabaseManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Supabase URL & Anon Key not configured."])
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = method
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "SupabaseManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response."])
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMsg = String(data: data, encoding: .utf8) ?? "HTTP \(httpResponse.statusCode)"
            print("Supabase REST Error [\(httpResponse.statusCode)]: \(errorMsg)")
            throw NSError(domain: "SupabaseManager", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
        return data
    }
}
