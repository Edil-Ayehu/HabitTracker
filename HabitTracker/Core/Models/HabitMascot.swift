//
//  HabitMascot.swift
//  HabitTracker
//

import Foundation
import SwiftUI

enum GrowthStage: Int, CaseIterable, Codable {
    case seedling = 1
    case sprout = 2
    case pottedPlant = 3
    case majesticTree = 4
    case zenBlossom = 5
    
    var title: String {
        switch self {
        case .seedling: return "Stage 1: Seedling 🌱"
        case .sprout: return "Stage 2: Sprout 🌿"
        case .pottedPlant: return "Stage 3: Potted Plant 🪴"
        case .majesticTree: return "Stage 4: Majestic Tree 🌳"
        case .zenBlossom: return "Stage 5: Zen Blossom 🌸"
        }
    }
    
    var iconName: String {
        switch self {
        case .seedling: return "leaf.fill"
        case .sprout: return "leaf.circle.fill"
        case .pottedPlant: return "leaf.arrow.triangle.circlepath"
        case .majesticTree: return "tree.fill"
        case .zenBlossom: return "sparkles"
        }
    }
    
    var stageColor: Color {
        switch self {
        case .seedling: return .green
        case .sprout: return .mint
        case .pottedPlant: return .teal
        case .majesticTree: return .indigo
        case .zenBlossom: return .purple
        }
    }
    
    var minPoints: Int {
        switch self {
        case .seedling: return 0
        case .sprout: return 20
        case .pottedPlant: return 40
        case .majesticTree: return 60
        case .zenBlossom: return 80
        }
    }
}

struct MascotAccessory: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let icon: String
    let requiredStage: GrowthStage
}

struct HabitMascot {
    static let availableAccessories: [MascotAccessory] = [
        MascotAccessory(id: "blossom", name: "Cherry Blossom 🌺", icon: "flower.rose.fill", requiredStage: .sprout),
        MascotAccessory(id: "sunglasses", name: "Cool Shades 🕶️", icon: "eyeglasses", requiredStage: .pottedPlant),
        MascotAccessory(id: "crown", name: "Royal Crown 👑", icon: "crown.fill", requiredStage: .majesticTree),
        MascotAccessory(id: "aura", name: "Golden Aura 🌟", icon: "sparkles", requiredStage: .zenBlossom)
    ]
}
