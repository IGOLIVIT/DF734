//
//  StepTimingGame.swift
//  DF734
//
//  Created by IGOR on 06/11/2025.
//

import SwiftUI
import Combine

enum TimingDifficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var speed: CGFloat {
        switch self {
        case .easy: return 1.5
        case .medium: return 2.5
        case .hard: return 3.5
        }
    }
    
    var safeZoneSize: CGFloat {
        switch self {
        case .easy: return 120
        case .medium: return 90
        case .hard: return 70
        }
    }
    
    var totalPaths: Int {
        switch self {
        case .easy: return 6
        case .medium: return 8
        case .hard: return 12
        }
    }
    
    var color: Color {
        switch self {
        case .easy: return Color.green
        case .medium: return Color.orange
        case .hard: return Color.red
        }
    }
}

struct StepTimingGame: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var isPresented: MiniGameType?
    
    @State private var currentPath = 0
    @State private var pathPosition: CGFloat = 0
    @State private var score = 0
    @State private var lives = 3
    @State private var isGameOver = false
    @State private var showSuccess = false
    @State private var gameStarted = false
    @State private var showDifficultySelect = true
    @State private var selectedDifficulty: TimingDifficulty = .medium
    
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        isPresented = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        // Score
                        HStack(spacing: 6) {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(AppTheme.primaryButton)
                            Text("\(score)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        // Lives
                        HStack(spacing: 4) {
                            ForEach(0..<3) { index in
                                Image(systemName: index < lives ? "heart.fill" : "heart")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.accent)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                Spacer()
                
                if !gameStarted {
                    if showDifficultySelect {
                        // Difficulty selection
                        VStack(spacing: 25) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.primaryButton)
                            
                            Text("Step Timing")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("Choose Difficulty")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            VStack(spacing: 12) {
                                ForEach(TimingDifficulty.allCases, id: \.self) { level in
                                    Button(action: {
                                        selectedDifficulty = level
                                        withAnimation {
                                            showDifficultySelect = false
                                        }
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(level.rawValue)
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(AppTheme.textPrimary)
                                                
                                                Text("\(level.totalPaths) paths • Speed: \(String(format: "%.1f", level.speed))x")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(AppTheme.textSecondary)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(level.color)
                                        }
                                        .padding(16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.08))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(level.color.opacity(0.3), lineWidth: 2)
                                                )
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                    } else {
                        // Instructions
                        VStack(spacing: 20) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.primaryButton)
                            
                            Text("Step Timing")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            HStack(spacing: 8) {
                                Text(selectedDifficulty.rawValue)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(selectedDifficulty.color)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedDifficulty.color.opacity(0.2))
                                    )
                            }
                            
                            Text("Tap when the chicken is in the green zone to cross safely!")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            CustomButton(title: "Start Game", backgroundColor: AppTheme.primaryButton) {
                                gameStarted = true
                            }
                            .padding(.horizontal, 60)
                            .padding(.top, 20)
                            
                            Button(action: {
                                withAnimation {
                                    showDifficultySelect = true
                                }
                            }) {
                                Text("Change Difficulty")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                    }
                } else if isGameOver {
                    // Game Over
                    GameOverView(
                        score: score,
                        feathersEarned: score,
                        onRestart: restartGame,
                        onClose: { isPresented = nil }
                    )
                } else {
                    // Game area
                    VStack(spacing: 40) {
                        Text("Path \(currentPath + 1)/\(selectedDifficulty.totalPaths)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        // Moving path visualization
                        ZStack {
                            // Background path
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 80)
                            
                            // Safe zone (green) - size based on difficulty
                            HStack {
                                Spacer()
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.green.opacity(0.3))
                                    .frame(width: selectedDifficulty.safeZoneSize, height: 80)
                                Spacer()
                            }
                            
                            // Moving chicken
                            HStack {
                                Image(systemName: "bird.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(AppTheme.primaryButton)
                                    .offset(x: pathPosition)
                                
                                Spacer()
                            }
                            .padding(.leading, 20)
                        }
                        .frame(maxWidth: 300)
                        
                        if showSuccess {
                            Text("Perfect! ✓")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.green)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                
                Spacer()
                
                if gameStarted && !isGameOver {
                    // Tap button
                    Button(action: handleTap) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [AppTheme.primaryButton, AppTheme.primaryButton.opacity(0.8)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text("TAP")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(AppTheme.background)
                            )
                            .shadow(color: AppTheme.primaryButton.opacity(0.5), radius: 20, x: 0, y: 10)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .onReceive(timer) { _ in
            if gameStarted && !isGameOver {
                updateGame()
            }
        }
    }
    
    func updateGame() {
        pathPosition += selectedDifficulty.speed
        if pathPosition > 240 {
            pathPosition = -20
        }
    }
    
    func handleTap() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        
        // Safe zone is in the center of the path (150 is center of 300px width)
        // Calculate boundaries based on difficulty
        let centerPosition: CGFloat = 150
        let halfZone = selectedDifficulty.safeZoneSize / 2
        let safeZoneStart = centerPosition - halfZone - 20 // offset for bird position
        let safeZoneEnd = centerPosition + halfZone - 20
        
        // Debug: make it easier by accepting wider range
        let adjustedStart = safeZoneStart - 10
        let adjustedEnd = safeZoneEnd + 10
        
        // Check if in safe zone
        if pathPosition > adjustedStart && pathPosition < adjustedEnd {
            // Success
            impact.impactOccurred()
            score += 10
            currentPath += 1
            
            withAnimation {
                showSuccess = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showSuccess = false
                }
            }
            
            if currentPath >= selectedDifficulty.totalPaths {
                completeGame()
            } else {
                pathPosition = -20
            }
        } else {
            // Miss
            lives -= 1
            let missImpact = UIImpactFeedbackGenerator(style: .heavy)
            missImpact.impactOccurred()
            
            if lives <= 0 {
                isGameOver = true
            } else {
                pathPosition = -20
            }
        }
    }
    
    func completeGame() {
        isGameOver = true
        gameManager.completeGame(type: .stepTiming, score: score, feathersEarned: score)
    }
    
    func restartGame() {
        currentPath = 0
        pathPosition = 0
        score = 0
        lives = 3
        isGameOver = false
        showSuccess = false
        gameStarted = false
        showDifficultySelect = true
    }
}

#Preview {
    StepTimingGame(isPresented: .constant(.stepTiming))
        .environmentObject(GameManager())
}

