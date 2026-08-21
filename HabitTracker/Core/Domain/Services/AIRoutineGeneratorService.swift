//
//  AIRoutineGeneratorService.swift
//  HabitTracker
//

import Foundation

struct AIRoutineTemplate: Identifiable, Hashable {
    let id: String
    let title: String
    let icon: String
    let subtitle: String
    let category: String
}

protocol AIRoutineGeneratorService {
    func availableTemplates() -> [AIRoutineTemplate]
    func generateRoutine(for prompt: String) async -> [HabitDraft]
}

final class AIRoutineGeneratorServiceImpl: AIRoutineGeneratorService {
    
    private let apiKeyKey = "geminiApiKey"
    
    func availableTemplates() -> [AIRoutineTemplate] {
        [
            AIRoutineTemplate(
                id: "sleep",
                title: "Sleep & Wind Down",
                icon: "moon.fill",
                subtitle: "Optimize rest & deep sleep",
                category: "Wellness"
            ),
            AIRoutineTemplate(
                id: "fitness",
                title: "10K Running Prep",
                icon: "figure.walk",
                subtitle: "Endurance & stamina routine",
                category: "Fitness"
            ),
            AIRoutineTemplate(
                id: "mindfulness",
                title: "Mind & Focus Boost",
                icon: "book.fill",
                subtitle: "Clarity, calm & gratitude",
                category: "Mindfulness"
            ),
            AIRoutineTemplate(
                id: "productivity",
                title: "Deep Work Sprint",
                icon: "figure.strengthtraining.traditional",
                subtitle: "High output & focus",
                category: "Productivity"
            ),
            AIRoutineTemplate(
                id: "health",
                title: "Healthy Lifestyle",
                icon: "drop.fill",
                subtitle: "Hydration, nutrition & vitals",
                category: "Health"
            )
        ]
    }
    
    func generateRoutine(for prompt: String) async -> [HabitDraft] {
        let secretsKey = Secrets.geminiApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let settingsKey = UserDefaults.standard.string(forKey: apiKeyKey)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let apiKey = !secretsKey.isEmpty ? secretsKey : settingsKey
        
        if !apiKey.isEmpty {
            do {
                let aiHabits = try await fetchGeminiRoutine(prompt: prompt, apiKey: apiKey)
                if !aiHabits.isEmpty {
                    return aiHabits
                }
            } catch {
                print("Gemini API call failed, falling back to local engine:", error)
            }
        }
        
        // Fallback to local intelligent generation engine
        try? await Task.sleep(nanoseconds: 400_000_000)
        let lower = prompt.lowercased()
        
        if lower.contains("sleep") || lower.contains("rest") || lower.contains("night") {
            return sleepRoutine()
        } else if lower.contains("run") || lower.contains("10k") || lower.contains("fitness") || lower.contains("workout") || lower.contains("gym") {
            return fitnessRoutine()
        } else if lower.contains("mind") || lower.contains("meditat") || lower.contains("calm") || lower.contains("stress") {
            return mindfulnessRoutine()
        } else if lower.contains("work") || lower.contains("study") || lower.contains("code") || lower.contains("focus") || lower.contains("learn") {
            return productivityRoutine()
        } else if lower.contains("health") || lower.contains("diet") || lower.contains("water") || lower.contains("eat") {
            return healthRoutine()
        } else {
            return customRoutine(for: prompt)
        }
    }
    
    // MARK: - Gemini API Call
    
    private func fetchGeminiRoutine(prompt: String, apiKey: String) async throws -> [HabitDraft] {
        let models = ["gemini-3.6-flash", "gemini-1.5-flash-latest", "gemini-2.5-flash", "gemini-flash", "gemini-pro"]
        var lastError: Error?
        
        for model in models {
            do {
                let result = try await fetchGeminiRoutineWithModel(prompt: prompt, apiKey: apiKey, modelName: model)
                if !result.isEmpty {
                    return result
                }
            } catch {
                lastError = error
            }
        }
        
        if let lastError {
            throw lastError
        }
        return []
    }
    
    private func fetchGeminiRoutineWithModel(prompt: String, apiKey: String, modelName: String) async throws -> [HabitDraft] {
        let cleanKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var components = URLComponents(string: "https://generativelanguage.googleapis.com/v1beta/models/\(modelName):generateContent")
        components?.queryItems = [URLQueryItem(name: "key", value: cleanKey)]
        
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        
        let systemInstruction = """
        You are an expert Habit Coach. Generate 3 to 5 habit recommendations for the goal: "\(prompt)".
        Return ONLY a raw JSON array of objects with no markdown block formatting.
        Each object must match this schema:
        {
          "title": "Habit Title",
          "icon": "drop.fill" | "book.fill" | "figure.walk" | "figure.strengthtraining.traditional" | "moon.fill" | "pills.fill",
          "color": "blue" | "green" | "orange" | "purple" | "red",
          "habitType": "binary" | "measurable",
          "goal": Int (default 1),
          "unit": "pages" | "mins" | "glasses" | "hours" | "liters" | "servings" | "",
          "reminderHour": Int (0 to 23),
          "reminderMinute": Int (0 to 59)
        }
        """
        
        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": systemInstruction]
                    ]
                ]
            ],
            "generationConfig": [
                "responseMimeType": "application/json",
                "temperature": 0.7
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorText = String(data: data, encoding: .utf8) ?? ""
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorObj = errorJson["error"] as? [String: Any],
               let message = errorObj["message"] as? String {
                print("Gemini API Error (\(httpResponse.statusCode)): \(message)")
                throw NSError(
                    domain: "GeminiAPI",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Gemini API Error (\(httpResponse.statusCode)): \(message)"]
                )
            }
            print("Gemini HTTP Error (\(httpResponse.statusCode)): \(errorText)")
            throw URLError(.badServerResponse)
        }
        
        struct GeminiResponse: Decodable {
            struct Candidate: Decodable {
                struct Content: Decodable {
                    struct Part: Decodable {
                        let text: String
                    }
                    let parts: [Part]
                }
                let content: Content
            }
            let candidates: [Candidate]?
        }
        
        let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let text = decoded.candidates?.first?.content.parts.first?.text else {
            throw URLError(.cannotParseResponse)
        }
        
        // Clean JSON text if wrapped in markdown
        let cleanedText = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        struct GeminiHabitItem: Decodable {
            let title: String
            let icon: String?
            let color: String?
            let habitType: String?
            let goal: Int?
            let unit: String?
            let reminderHour: Int?
            let reminderMinute: Int?
        }
        
        guard let jsonData = cleanedText.data(using: .utf8) else {
            return []
        }
        
        let items = try JSONDecoder().decode([GeminiHabitItem].self, from: jsonData)
        
        return items.map { item in
            var draft = HabitDraft()
            draft.title = item.title
            
            if let iconStr = item.icon, let iconEnum = HabitIcon(rawValue: iconStr) {
                draft.icon = iconEnum
            } else {
                draft.icon = .book
            }
            
            if let colorStr = item.color, let colorEnum = HabitColor(rawValue: colorStr) {
                draft.color = colorEnum
            } else {
                draft.color = .blue
            }
            
            if item.habitType == "measurable" {
                draft.habitType = .measurable
                draft.goal = item.goal ?? 1
                draft.unit = item.unit ?? ""
            } else {
                draft.habitType = .binary
                draft.goal = 1
                draft.unit = ""
            }
            
            draft.frequency = .daily
            draft.reminderEnabled = true
            
            var comp = DateComponents()
            comp.hour = item.reminderHour ?? 9
            comp.minute = item.reminderMinute ?? 0
            draft.reminderTime = Calendar.current.date(from: comp) ?? Date()
            
            return draft
        }
    }
    
    // MARK: - Preset Routines (Local Fallback)
    
    private func sleepRoutine() -> [HabitDraft] {
        return [
            makeDraft(title: "No Screens 30m Before Bed", icon: .moon, color: .purple, habitType: .binary, reminderHour: 22, reminderMinute: 0),
            makeDraft(title: "Read 15 Pages in Bed", icon: .book, color: .blue, habitType: .measurable, goal: 15, unit: "pages", reminderHour: 22, reminderMinute: 30),
            makeDraft(title: "Evening Chamomile Tea", icon: .water, color: .orange, habitType: .binary, reminderHour: 21, reminderMinute: 30),
            makeDraft(title: "8 Hours Sleep Target", icon: .moon, color: .purple, habitType: .binary, reminderHour: 23, reminderMinute: 0)
        ]
    }
    
    private func fitnessRoutine() -> [HabitDraft] {
        return [
            makeDraft(title: "Morning 20m Cardio / Run", icon: .walk, color: .orange, habitType: .measurable, goal: 20, unit: "mins", reminderHour: 7, reminderMinute: 0),
            makeDraft(title: "Drink 8 Glasses of Water", icon: .water, color: .blue, habitType: .measurable, goal: 8, unit: "glasses", reminderHour: 9, reminderMinute: 0),
            makeDraft(title: "Post-Workout Stretching", icon: .workout, color: .green, habitType: .binary, reminderHour: 8, reminderMinute: 0),
            makeDraft(title: "Core Stability Session", icon: .workout, color: .red, habitType: .binary, reminderHour: 18, reminderMinute: 0)
        ]
    }
    
    private func mindfulnessRoutine() -> [HabitDraft] {
        return [
            makeDraft(title: "10m Morning Meditation", icon: .moon, color: .purple, habitType: .measurable, goal: 10, unit: "mins", reminderHour: 7, reminderMinute: 30),
            makeDraft(title: "Write 3 Gratitude Notes", icon: .book, color: .green, habitType: .measurable, goal: 3, unit: "items", reminderHour: 21, reminderMinute: 0),
            makeDraft(title: "20m Walk in Nature", icon: .walk, color: .blue, habitType: .binary, reminderHour: 17, reminderMinute: 30)
        ]
    }
    
    private func productivityRoutine() -> [HabitDraft] {
        return [
            makeDraft(title: "2 Hours Deep Work Sprint", icon: .workout, color: .purple, habitType: .measurable, goal: 2, unit: "hours", reminderHour: 9, reminderMinute: 0),
            makeDraft(title: "Read 20 Pages Tech / Skill Book", icon: .book, color: .blue, habitType: .measurable, goal: 20, unit: "pages", reminderHour: 20, reminderMinute: 0),
            makeDraft(title: "No Social Media Before Noon", icon: .moon, color: .red, habitType: .binary, reminderHour: 8, reminderMinute: 0),
            makeDraft(title: "Clear Inbox & Plan Next Day", icon: .pills, color: .orange, habitType: .binary, reminderHour: 17, reminderMinute: 0)
        ]
    }
    
    private func healthRoutine() -> [HabitDraft] {
        return [
            makeDraft(title: "Drink 2L Fresh Water Daily", icon: .water, color: .blue, habitType: .measurable, goal: 2, unit: "liters", reminderHour: 8, reminderMinute: 30),
            makeDraft(title: "Eat 3 Servings Veggies & Fruit", icon: .pills, color: .green, habitType: .measurable, goal: 3, unit: "servings", reminderHour: 12, reminderMinute: 0),
            makeDraft(title: "Take Daily Vitamins & Minerals", icon: .pills, color: .purple, habitType: .binary, reminderHour: 8, reminderMinute: 0),
            makeDraft(title: "30m Active Walk / Exercise", icon: .walk, color: .orange, habitType: .measurable, goal: 30, unit: "mins", reminderHour: 18, reminderMinute: 30)
        ]
    }
    
    private func customRoutine(for prompt: String) -> [HabitDraft] {
        let cleanedPrompt = prompt.capitalized
        return [
            makeDraft(title: "Daily Practice: \(cleanedPrompt)", icon: .book, color: .purple, habitType: .measurable, goal: 30, unit: "mins", reminderHour: 9, reminderMinute: 0),
            makeDraft(title: "Track Progress & Reflection", icon: .book, color: .blue, habitType: .binary, reminderHour: 21, reminderMinute: 0),
            makeDraft(title: "Stay Hydrated & Energized", icon: .water, color: .green, habitType: .measurable, goal: 8, unit: "glasses", reminderHour: 10, reminderMinute: 0)
        ]
    }
    
    private func makeDraft(
        title: String,
        icon: HabitIcon,
        color: HabitColor,
        habitType: HabitType,
        goal: Int = 1,
        unit: String = "",
        reminderHour: Int = 9,
        reminderMinute: Int = 0
    ) -> HabitDraft {
        var draft = HabitDraft()
        draft.title = title
        draft.icon = icon
        draft.color = color
        draft.habitType = habitType
        draft.goal = goal
        draft.unit = unit
        draft.frequency = .daily
        draft.reminderEnabled = true
        
        var comp = DateComponents()
        comp.hour = reminderHour
        comp.minute = reminderMinute
        draft.reminderTime = Calendar.current.date(from: comp) ?? Date()
        
        return draft
    }
}
