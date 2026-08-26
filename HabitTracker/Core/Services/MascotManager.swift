//
//  MascotManager.swift
//  HabitTracker
//

import Foundation
import SwiftUI
import Combine

final class MascotManager: ObservableObject {
    static let shared = MascotManager()
    
    @Published var growthPoints: Int
    @Published var equippedAccessoryID: String
    
    private init() {
        self.growthPoints = UserDefaults.standard.integer(forKey: "mascotGrowthPoints")
        self.equippedAccessoryID = UserDefaults.standard.string(forKey: "mascotEquippedAccessoryID") ?? ""
    }
    
    var currentStage: GrowthStage {
        if growthPoints >= 80 { return .zenBlossom }
        if growthPoints >= 60 { return .majesticTree }
        if growthPoints >= 40 { return .pottedPlant }
        if growthPoints >= 20 { return .sprout }
        return .seedling
    }
    
    var nextStagePoints: Int {
        switch currentStage {
        case .seedling: return 20
        case .sprout: return 40
        case .pottedPlant: return 60
        case .majesticTree: return 80
        case .zenBlossom: return 100
        }
    }
    
    var equippedAccessory: MascotAccessory? {
        HabitMascot.availableAccessories.first(where: { $0.id == equippedAccessoryID })
    }
    
    func addGrowthPoints(_ points: Int) {
        objectWillChange.send()
        growthPoints = min(100, growthPoints + points)
        UserDefaults.standard.set(growthPoints, forKey: "mascotGrowthPoints")
        UserDefaults.standard.synchronize()
    }
    
    func equipAccessory(_ accessory: MascotAccessory?) {
        objectWillChange.send()
        if let acc = accessory {
            equippedAccessoryID = acc.id
            UserDefaults.standard.set(acc.id, forKey: "mascotEquippedAccessoryID")
        } else {
            equippedAccessoryID = ""
            UserDefaults.standard.set("", forKey: "mascotEquippedAccessoryID")
        }
        UserDefaults.standard.synchronize()
    }
    
    func isAccessoryUnlocked(_ accessory: MascotAccessory) -> Bool {
        return currentStage.rawValue >= accessory.requiredStage.rawValue
    }
}
