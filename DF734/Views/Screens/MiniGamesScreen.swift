//
//  MiniGamesScreen.swift
//  DF734
//
//  Created by IGOR on 06/11/2025.
//

import SwiftUI

struct MiniGamesScreen: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedGame: MiniGameType? = nil
    @State private var animateContent = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 25) {
                    Spacer()
                        .frame(height: 20)
                    
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(AppTheme.primaryButton)
                        
                        Text("Mini-Games")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("Choose a challenge")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : -20)
                    
                    // Adaptive games grid
                    GeometryReader { geometry in
                        let isCompact = geometry.size.width < 700
                        
                        if isCompact {
                            // iPhone: vertical list
                            VStack(spacing: 16) {
                                ForEach(MiniGameType.allCases, id: \.self) { game in
                                    MiniGameCard(game: game) {
                                        selectedGame = game
                                    }
                                    .opacity(animateContent ? 1 : 0)
                                    .offset(x: animateContent ? 0 : -30)
                                }
                            }
                        } else {
                            // iPad: grid layout
                            VStack(spacing: 16) {
                                HStack(spacing: 16) {
                                    ForEach(Array(MiniGameType.allCases.prefix(2)), id: \.self) { game in
                                        MiniGameCard(game: game) {
                                            selectedGame = game
                                        }
                                        .opacity(animateContent ? 1 : 0)
                                        .offset(x: animateContent ? 0 : -30)
                                    }
                                }
                                
                                if MiniGameType.allCases.count > 2 {
                                    HStack(spacing: 16) {
                                        ForEach(Array(MiniGameType.allCases.dropFirst(2)), id: \.self) { game in
                                            MiniGameCard(game: game) {
                                                selectedGame = game
                                            }
                                            .opacity(animateContent ? 1 : 0)
                                            .offset(x: animateContent ? 0 : -30)
                                        }
                                        
                                        // Spacer for odd number of games
                                        if MiniGameType.allCases.count % 2 != 0 {
                                            Spacer()
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(minHeight: 550) // Ensure GeometryReader has proper height
                    .padding(.horizontal, 20)
                    
                    Spacer()
                        .frame(height: 20)
                }
            }
            
            // Full screen game views
            if let game = selectedGame {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            selectedGame = nil
                        }
                    
                    Group {
                        switch game {
                        case .stepTiming:
                            StepTimingGame(isPresented: $selectedGame)
                        case .featherCatch:
                            FeatherCatchGame(isPresented: $selectedGame)
                        case .bridgeBalance:
                            BridgeBalanceGame(isPresented: $selectedGame)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateContent = true
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedGame)
    }
}

#Preview {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        MiniGamesScreen()
            .environmentObject(GameManager())
    }
}



