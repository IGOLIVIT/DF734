//
//  FeatherCatchGame.swift
//  DF734
//
//  Created by IGOR on 06/11/2025.
//

import SwiftUI
import Combine

enum DifficultyLevel: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var timeLimit: Int {
        switch self {
        case .easy: return 40
        case .medium: return 30
        case .hard: return 25
        }
    }
    
    var spawnRate: Int {
        switch self {
        case .easy: return 60
        case .medium: return 45
        case .hard: return 35
        }
    }
    
    var badFeatherChance: Int {
        switch self {
        case .easy: return 15
        case .medium: return 25
        case .hard: return 35
        }
    }
    
    var speedRange: ClosedRange<Double> {
        switch self {
        case .easy: return 2.0...3.0
        case .medium: return 2.5...4.0
        case .hard: return 3.0...5.0
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

struct FallingFeather: Identifiable {
    let id = UUID()
    var position: CGPoint
    let isGood: Bool
    var speed: Double
}

struct FeatherCatchGame: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var isPresented: MiniGameType?
    
    @State private var chickenPosition: CGFloat = UIScreen.main.bounds.width / 2
    @State private var feathers: [FallingFeather] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeRemaining = 30
    @State private var isGameOver = false
    @State private var gameStarted = false
    @State private var showDifficultySelect = true
    @State private var selectedDifficulty: DifficultyLevel = .medium
    
    let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
                        
                        // Time
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(AppTheme.accent)
                            Text("\(timeRemaining)s")
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
                
                if !gameStarted {
                    Spacer()
                    
                    if showDifficultySelect {
                        // Difficulty selection
                        VStack(spacing: 25) {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.accent)
                            
                            Text("Feather Catch")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("Choose Difficulty")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            VStack(spacing: 12) {
                                ForEach(DifficultyLevel.allCases, id: \.self) { level in
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
                                                
                                                Text("\(level.timeLimit)s • \(100 - level.badFeatherChance)% good feathers")
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
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.accent)
                            
                            Text("Feather Catch")
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
                            
                            Text("Drag to move the chicken and collect golden feathers. Avoid red obstacles!")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            CustomButton(title: "Start Game", backgroundColor: AppTheme.accent) {
                                timeRemaining = selectedDifficulty.timeLimit
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
                    
                    Spacer()
                } else if isGameOver {
                    GameOverView(
                        score: score,
                        feathersEarned: score,
                        onRestart: restartGame,
                        onClose: { isPresented = nil }
                    )
                } else {
                    // Game area with proper spacing
                    GeometryReader { geometry in
                        ZStack(alignment: .topLeading) {
                            // Falling feathers
                            ForEach(feathers) { feather in
                                Image(systemName: feather.isGood ? "leaf.fill" : "xmark.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(feather.isGood ? AppTheme.primaryButton : AppTheme.accent)
                                    .position(x: feather.position.x, y: feather.position.y)
                            }
                            
                            // Chicken at bottom
                            Image(systemName: "bird.fill")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.primaryButton)
                                .shadow(color: AppTheme.primaryButton.opacity(0.5), radius: 10)
                                .position(x: chickenPosition, y: geometry.size.height - 40)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    chickenPosition = max(30, min(geometry.size.width - 30, value.location.x))
                                }
                        )
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            if gameStarted && !isGameOver {
                updateGame()
            }
        }
        .onReceive(countdownTimer) { _ in
            if gameStarted && !isGameOver {
                timeRemaining -= 1
                if timeRemaining <= 0 {
                    completeGame()
                }
            }
        }
    }
    
    func updateGame() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Spawn new feathers based on difficulty
        if Int.random(in: 0..<selectedDifficulty.spawnRate) == 0 {
            let isGood = Int.random(in: 0..<100) >= selectedDifficulty.badFeatherChance
            let feather = FallingFeather(
                position: CGPoint(x: CGFloat.random(in: 30...(screenWidth - 30)), y: 0),
                isGood: isGood,
                speed: Double.random(in: selectedDifficulty.speedRange)
            )
            feathers.append(feather)
        }
        
        // Update feather positions and check collisions
        var indicesToRemove: [Int] = []
        
        for index in feathers.indices.reversed() {
            feathers[index].position.y += CGFloat(feathers[index].speed)
            
            // Chicken is at the bottom of GeometryReader (which starts after header ~130px)
            // Check collision with chicken - more generous hitbox
            let distance = abs(feathers[index].position.x - chickenPosition)
            let featherY = feathers[index].position.y
            
            // Check if feather is near the bottom where chicken is (last 100px of game area)
            if distance < 50 && featherY > (screenHeight - 280) && featherY < (screenHeight - 180) {
                if feathers[index].isGood {
                    score += 10
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                } else {
                    lives -= 1
                    let impact = UIImpactFeedbackGenerator(style: .heavy)
                    impact.impactOccurred()
                    if lives <= 0 {
                        isGameOver = true
                    }
                }
                indicesToRemove.append(index)
            }
            
            // Remove off-screen feathers (below visible area)
            if feathers[index].position.y > screenHeight - 150 {
                indicesToRemove.append(index)
            }
        }
        
        // Remove feathers that were collected or went off-screen
        for index in Set(indicesToRemove).sorted().reversed() {
            if index < feathers.count {
                feathers.remove(at: index)
            }
        }
    }
    
    func completeGame() {
        isGameOver = true
        gameManager.completeGame(type: .featherCatch, score: score, feathersEarned: score)
    }
    
    func restartGame() {
        chickenPosition = UIScreen.main.bounds.width / 2
        feathers = []
        score = 0
        lives = 3
        timeRemaining = selectedDifficulty.timeLimit
        isGameOver = false
        gameStarted = false
        showDifficultySelect = true
    }
}

#Preview {
    FeatherCatchGame(isPresented: .constant(.featherCatch))
        .environmentObject(GameManager())
}

