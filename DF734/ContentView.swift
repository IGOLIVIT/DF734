//
//  ContentView.swift
//  DF734
//
//  Created by IGOR on 06/11/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameManager = GameManager()
    
    var body: some View {
        ZStack {
            if gameManager.hasCompletedOnboarding {
                MainMenuView()
                    .environmentObject(gameManager)
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .environmentObject(gameManager)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: gameManager.hasCompletedOnboarding)
    }
}

#Preview {
    ContentView()
}
