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
                    AdaptiveGameGrid(
                        games: MiniGameType.allCases,
                        animateContent: animateContent,
                        selectedGame: $selectedGame
                    )
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
                        case .spaceBattle:
                            SpaceBattleGame(isPresented: $selectedGame)
                        case .memoryMatch:
                            MemoryMatchGame(isPresented: $selectedGame)
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

// MARK: - Adaptive Game Grid
struct AdaptiveGameGrid: View {
    let games: [MiniGameType]
    let animateContent: Bool
    @Binding var selectedGame: MiniGameType?
    
    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.width < 700
            
            if isCompact {
                // iPhone: vertical list
                VStack(spacing: 16) {
                    ForEach(games, id: \.self) { game in
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
                    ForEach(0..<((games.count + 1) / 2), id: \.self) { rowIndex in
                        HStack(spacing: 16) {
                            let startIndex = rowIndex * 2
                            let endIndex = min(startIndex + 2, games.count)
                            
                            ForEach(startIndex..<endIndex, id: \.self) { index in
                                MiniGameCard(game: games[index]) {
                                    selectedGame = games[index]
                                }
                                .opacity(animateContent ? 1 : 0)
                                .offset(x: animateContent ? 0 : -30)
                            }
                            
                            // Add spacer if odd number in last row
                            if endIndex - startIndex == 1 {
                                Color.clear
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
        }
        .frame(minHeight: calculateMinHeight())
    }
    
    func calculateMinHeight() -> CGFloat {
        let cardHeight: CGFloat = 160
        let spacing: CGFloat = 16
        let isCompact = UIScreen.main.bounds.width < 700
        
        if isCompact {
            // Vertical list: height = number of cards * (card height + spacing)
            return CGFloat(games.count) * (cardHeight + spacing)
        } else {
            // Grid: height = number of rows * (card height + spacing)
            let rows = (games.count + 1) / 2
            return CGFloat(rows) * (cardHeight + spacing)
        }
    }
}




