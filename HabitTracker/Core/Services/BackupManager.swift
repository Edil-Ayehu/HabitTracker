//
//  BackupManager.swift
//  HabitTracker
//

import Foundation
import SwiftData

struct BackupHabitDTO: Codable {
    let id: UUID
    let title: String
    let icon: String
    let color: String
    let categoryRaw: String
    let timeOfDayRaw: String
    let habitTypeRaw: String
    let goal: Int?
    let unit: String?
    let frequencyRaw: String
    let createdAt: Date
    let subTasks: [SubTask]
    let isArchived: Bool
}

struct BackupEntryDTO: Codable {
    let id: UUID
    let habitID: UUID
    let date: Date
    let progress: Int
    let completed: Bool
    let note: String
    let isFrozen: Bool
    let completedSubTaskIDs: [UUID]
}

struct BackupDataPayload: Codable {
    let version: Int
    let exportDate: Date
    let habits: [BackupHabitDTO]
    let entries: [BackupEntryDTO]
}

@MainActor
final class BackupManager {
    static let shared = BackupManager()
    private init() {}
    
    // MARK: - CSV Export
    func generateCSV(habits: [Habit], entries: [HabitEntry]) -> URL? {
        var csvString = "Date,Habit Title,Category,Frequency,Status,Progress,Goal,Unit,Subtasks Done,Note\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let habitMap = Dictionary(uniqueKeysWithValues: habits.map { ($0.id, $0) })
        
        for entry in entries.sorted(by: { $0.date > $1.date }) {
            let habit = habitMap[entry.habitID] ?? entry.habit
            let dateStr = dateFormatter.string(from: entry.date)
            let title = "\"\(habit.title.replacingOccurrences(of: "\"", with: "\"\""))\""
            let category = habit.habitCategory.title
            let frequency = habit.frequency.title
            let status = entry.completed ? "Completed" : (entry.isFrozen ? "Frozen" : "Incomplete")
            let progress = "\(entry.progress)"
            let goal = "\(habit.goal ?? 1)"
            let unit = habit.unit ?? ""
            let subtaskProgress = habit.subTasks.isEmpty ? "N/A" : "\(entry.completedSubTaskIDs.count)/\(habit.subTasks.count)"
            let note = "\"\(entry.note.replacingOccurrences(of: "\"", with: "\"\""))\""
            
            let line = "\(dateStr),\(title),\(category),\(frequency),\(status),\(progress),\(goal),\(unit),\(subtaskProgress),\(note)\n"
            csvString.append(line)
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "HabitTracker_Export_\(dateFormatter.string(from: Date())).csv"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }
    
    // MARK: - JSON Export
    func generateJSONBackup(habits: [Habit], entries: [HabitEntry]) -> URL? {
        let habitDTOs = habits.map { h in
            BackupHabitDTO(
                id: h.id,
                title: h.title,
                icon: h.icon,
                color: h.color,
                categoryRaw: h.categoryRaw,
                timeOfDayRaw: h.timeOfDayRaw,
                habitTypeRaw: h.habitType.rawValue,
                goal: h.goal,
                unit: h.unit,
                frequencyRaw: h.frequency.rawValue,
                createdAt: h.createdAt,
                subTasks: h.subTasks,
                isArchived: h.isArchived
            )
        }
        
        let entryDTOs = entries.map { e in
            BackupEntryDTO(
                id: e.id,
                habitID: e.habitID,
                date: e.date,
                progress: e.progress,
                completed: e.completed,
                note: e.note,
                isFrozen: e.isFrozen,
                completedSubTaskIDs: Array(e.completedSubTaskIDs)
            )
        }
        
        let payload = BackupDataPayload(
            version: 1,
            exportDate: Date(),
            habits: habitDTOs,
            entries: entryDTOs
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(payload) else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "HabitTracker_Backup_\(dateFormatter.string(from: Date())).json"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
    
    // MARK: - JSON Restore
    func restoreFromJSON(fileURL: URL, useCase: HabitUseCase) throws -> (habitsCount: Int, entriesCount: Int, totalInBackup: Int) {
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let payload = try decoder.decode(BackupDataPayload.self, from: data)
        
        let existingHabits = (try? useCase.fetchHabits()) ?? []
        let existingArchived = (try? useCase.fetchArchivedHabits()) ?? []
        let allExistingHabits = existingHabits + existingArchived
        
        var restoredHabitCount = 0
        var restoredHabitMap: [UUID: Habit] = [:]
        
        for dto in payload.habits {
            if let existing = allExistingHabits.first(where: { $0.id == dto.id || $0.title.lowercased() == dto.title.lowercased() }) {
                restoredHabitMap[dto.id] = existing
            } else {
                let habit = Habit(
                    title: dto.title,
                    icon: HabitIcon(rawValue: dto.icon) ?? .water,
                    color: HabitColor(rawValue: dto.color) ?? .blue,
                    category: HabitCategory(rawValue: dto.categoryRaw) ?? .health,
                    timeOfDay: TimeOfDay(rawValue: dto.timeOfDayRaw) ?? .anyTime,
                    goal: dto.goal,
                    unit: dto.unit,
                    habitType: HabitType(rawValue: dto.habitTypeRaw) ?? .binary,
                    frequency: HabitFrequency(rawValue: dto.frequencyRaw) ?? .daily
                )
                habit.id = dto.id
                habit.subTasks = dto.subTasks
                habit.isArchived = dto.isArchived
                try useCase.addHabit(habit)
                restoredHabitMap[dto.id] = habit
                restoredHabitCount += 1
            }
        }
        
        var restoredEntriesCount = 0
        let allExistingEntries = (try? useCase.fetchAllEntries()) ?? []
        let existingEntryKeys = Set(allExistingEntries.map { "\($0.habitID)_\(Calendar.current.startOfDay(for: $0.date).timeIntervalSince1970)" })
        
        let repository = DIContainer.shared.makeHabitRepository()
        
        for entryDto in payload.entries {
            guard let targetHabit = restoredHabitMap[entryDto.habitID] else { continue }
            let key = "\(targetHabit.id)_\(Calendar.current.startOfDay(for: entryDto.date).timeIntervalSince1970)"
            
            if !existingEntryKeys.contains(key) {
                let entry = HabitEntry(habit: targetHabit, date: entryDto.date)
                entry.id = entryDto.id
                entry.progress = entryDto.progress
                entry.completed = entryDto.completed
                entry.note = entryDto.note
                entry.isFrozen = entryDto.isFrozen
                entry.completedSubTaskIDs = Set(entryDto.completedSubTaskIDs)
                try repository.saveEntry(entry)
                restoredEntriesCount += 1
            }
        }
        
        return (restoredHabitCount, restoredEntriesCount, payload.habits.count)
    }
}
