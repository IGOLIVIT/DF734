//
//  GameManager.swift
//  DF734
//
//  Created by IGOR on 06/11/2025.
//

import Foundation
import SwiftUI
import Combine

class GameManager: ObservableObject {
    @Published var statistics: GameStatistics
    @Published var hasCompletedOnboarding: Bool
    
    private let statisticsKey = "gameStatistics"
    private let onboardingKey = "hasCompletedOnboarding"
    
    init() {
        // Load statistics from UserDefaults
        if let data = UserDefaults.standard.data(forKey: statisticsKey),
           let decoded = try? JSONDecoder().decode(GameStatistics.self, from: data) {
            self.statistics = decoded
        } else {
            self.statistics = GameStatistics()
        }
        
        // Load onboarding status
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }
    
    func addFeathers(_ count: Int) {
        statistics.addFeathers(count)
        saveStatistics()
    }
    
    func completeGame(type: MiniGameType, score: Int, feathersEarned: Int) {
        statistics.completeGame()
        statistics.updateBestScore(game: type, score: score)
        statistics.addFeathers(feathersEarned)
        saveStatistics()
    }
    
    func resetProgress() {
        statistics.reset()
        saveStatistics()
    }
    
    private func saveStatistics() {
        if let encoded = try? JSONEncoder().encode(statistics) {
            UserDefaults.standard.set(encoded, forKey: statisticsKey)
        }
    }
}

