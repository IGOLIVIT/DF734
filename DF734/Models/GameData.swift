//
//  GameData.swift
//  DF734
//
//  Created by IGOR on 06/11/2025.
//

import Foundation
import SwiftUI

// MARK: - Game Statistics Model
struct GameStatistics: Codable {
    var totalFeathers: Int = 0
    var gamesCompleted: Int = 0
    var stepTimingBestScore: Int = 0
    var featherCatchBestScore: Int = 0
    var bridgeBalanceBestScore: Int = 0
    
    mutating func addFeathers(_ count: Int) {
        totalFeathers += count
    }
    
    mutating func completeGame() {
        gamesCompleted += 1
    }
    
    mutating func updateBestScore(game: MiniGameType, score: Int) {
        switch game {
        case .stepTiming:
            if score > stepTimingBestScore {
                stepTimingBestScore = score
            }
        case .featherCatch:
            if score > featherCatchBestScore {
                featherCatchBestScore = score
            }
        case .bridgeBalance:
            if score > bridgeBalanceBestScore {
                bridgeBalanceBestScore = score
            }
        }
    }
    
    mutating func reset() {
        totalFeathers = 0
        gamesCompleted = 0
        stepTimingBestScore = 0
        featherCatchBestScore = 0
        bridgeBalanceBestScore = 0
    }
}

// MARK: - Mini Game Types
enum MiniGameType: String, CaseIterable {
    case stepTiming = "Step Timing"
    case featherCatch = "Feather Catch"
    case bridgeBalance = "Bridge Balance"
    
    var description: String {
        switch self {
        case .stepTiming:
            return "Tap at the right time to cross moving paths"
        case .featherCatch:
            return "Swipe to collect falling feathers"
        case .bridgeBalance:
            return "Keep balance on a wobbly bridge"
        }
    }
    
    var icon: String {
        switch self {
        case .stepTiming:
            return "clock.fill"
        case .featherCatch:
            return "leaf.fill"
        case .bridgeBalance:
            return "arrow.left.and.right"
        }
    }
    
    var color: Color {
        switch self {
        case .stepTiming:
            return Color(hex: "#F6D547")
        case .featherCatch:
            return Color(hex: "#E85A4F")
        case .bridgeBalance:
            return Color(hex: "#F6D547")
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - App Theme
struct AppTheme {
    static let background = Color(hex: "#0E1A2A")
    static let primaryButton = Color(hex: "#F6D547")
    static let accent = Color(hex: "#E85A4F")
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
}



