//
//  BridgeBalanceGame.swift
//  DF734
//
//  Created by IGOR on 06/11/2025.
//

import SwiftUI
import Combine
import CoreMotion

enum BalanceDifficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var targetDistance: Int {
        switch self {
        case .easy: return 40
        case .medium: return 70
        case .hard: return 100
        }
    }
    
    var safeZone: Double {
        switch self {
        case .easy: return 0.6
        case .medium: return 0.45
        case .hard: return 0.35
        }
    }
    
    var fallThreshold: Double {
        switch self {
        case .easy: return 1.0
        case .medium: return 0.85
        case .hard: return 0.75
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

struct BridgeBalanceGame: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var isPresented: MiniGameType?
    
    @State private var chickenPosition: CGFloat = 0
    @State private var tilt: Double = 0
    @State private var score = 0
    @State private var distance = 0
    @State private var isGameOver = false
    @State private var gameStarted = false
    @State private var showDifficultySelect = true
    @State private var selectedDifficulty: BalanceDifficulty = .medium
    
    let motionManager = CMMotionManager()
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        stopMotionUpdates()
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
                        
                        // Distance
                        HStack(spacing: 6) {
                            Image(systemName: "flag.fill")
                                .foregroundColor(AppTheme.accent)
                            Text("\(distance)m")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
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
                            Image(systemName: "arrow.left.and.right")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.primaryButton)
                            
                            Text("Bridge Balance")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("Choose Difficulty")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            VStack(spacing: 12) {
                                ForEach(BalanceDifficulty.allCases, id: \.self) { level in
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
                                                
                                                Text("\(level.targetDistance)m • Safe zone: \(Int(level.safeZone * 100))%")
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
                            Image(systemName: "arrow.left.and.right")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.primaryButton)
                            
                            Text("Bridge Balance")
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
                            
                            // Detailed instructions
                            VStack(spacing: 12) {
                                Text("How to Play:")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(alignment: .top, spacing: 12) {
                                        Text("📱")
                                            .font(.system(size: 24))
                                        Text("Tilt your device left and right")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    
                                    HStack(alignment: .top, spacing: 12) {
                                        Text("🟢")
                                            .font(.system(size: 24))
                                        Text("Keep the chicken in the green zone")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    
                                    HStack(alignment: .top, spacing: 12) {
                                        Text("🎯")
                                            .font(.system(size: 24))
                                        Text("Travel \(selectedDifficulty.targetDistance) meters to finish")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    
                                    HStack(alignment: .top, spacing: 12) {
                                        Text("⚠️")
                                            .font(.system(size: 24))
                                        Text("Strong tilt = fall off the bridge!")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppTheme.accent)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                            )
                            .padding(.horizontal, 20)
                            
                            CustomButton(title: "Start Game", backgroundColor: AppTheme.primaryButton) {
                                startGame()
                            }
                            .padding(.horizontal, 60)
                            .padding(.top, 10)
                            
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
                    GameOverView(
                        score: score,
                        feathersEarned: score,
                        onRestart: restartGame,
                        onClose: {
                            stopMotionUpdates()
                            isPresented = nil
                        }
                    )
                } else {
                    // Game area with proper spacing and centering
                    VStack(spacing: 0) {
                        Spacer()
                        
                        VStack(spacing: 30) {
                            // Progress bar
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Remaining:")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Text("\(selectedDifficulty.targetDistance - distance)m")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(AppTheme.primaryButton)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(0.1))
                                        
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [AppTheme.primaryButton, AppTheme.accent]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: geometry.size.width * CGFloat(distance) / CGFloat(selectedDifficulty.targetDistance))
                                    }
                                }
                                .frame(height: 20)
                            }
                            .padding(.horizontal, 40)
                            .frame(height: 50)
                            
                            // Bridge visualization
                            ZStack {
                                // Safe zone indicator with label
                                VStack {
                                    Text("Safe Zone")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.green)
                                        .offset(y: -80)
                                    
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.5), lineWidth: 3)
                                        .frame(width: 200, height: 140)
                                }
                                
                                // Bridge
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.brown.opacity(0.6))
                                    .frame(width: 280, height: 20)
                                    .rotationEffect(.degrees(tilt * 20))
                                
                                // Chicken
                                Image(systemName: "bird.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppTheme.primaryButton)
                                    .shadow(color: AppTheme.primaryButton.opacity(0.5), radius: 10)
                                    .offset(x: chickenPosition * 100)
                                    .rotationEffect(.degrees(tilt * 20))
                            }
                            .frame(height: 200)
                            
                            // Tilt indicator with instructions
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    Text("Device Tilt")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    if abs(tilt) < selectedDifficulty.safeZone {
                                        HStack(spacing: 4) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.green)
                                            Text("Perfect!")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.green)
                                        }
                                    } else if abs(tilt) > selectedDifficulty.fallThreshold {
                                        HStack(spacing: 4) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(AppTheme.accent)
                                            Text("Danger!")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(AppTheme.accent)
                                        }
                                    } else {
                                        HStack(spacing: 4) {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.orange)
                                            Text("Out of Zone")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.orange)
                                        }
                                    }
                                }
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.1))
                                        .frame(width: 200, height: 30)
                                    
                                    // Safe zone (adjusted based on difficulty)
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.green.opacity(0.3))
                                        .frame(width: CGFloat(selectedDifficulty.safeZone * 200), height: 30)
                                    
                                    // Tilt indicator
                                    Circle()
                                        .fill(abs(tilt) < selectedDifficulty.safeZone ? Color.green : (abs(tilt) > selectedDifficulty.fallThreshold ? AppTheme.accent : Color.orange))
                                        .frame(width: 20, height: 20)
                                        .offset(x: chickenPosition * 90)
                                }
                                
                                // Arrow hints
                                HStack(spacing: 60) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.left")
                                            .font(.system(size: 12))
                                        Text("Left")
                                            .font(.system(size: 11))
                                    }
                                    .foregroundColor(AppTheme.textSecondary.opacity(0.6))
                                    
                                    HStack(spacing: 4) {
                                        Text("Right")
                                            .font(.system(size: 11))
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 12))
                                    }
                                    .foregroundColor(AppTheme.textSecondary.opacity(0.6))
                                }
                            }
                        }
                        
                        Spacer()
                    }
                }
                
                Spacer()
            }
        }
        .onReceive(timer) { _ in
            if gameStarted && !isGameOver {
                updateGame()
            }
        }
    }
    
    func startGame() {
        gameStarted = true
        startMotionUpdates()
    }
    
    func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.05
            motionManager.startDeviceMotionUpdates(to: .main) { data, error in
                guard let data = data, error == nil else { return }
                
                // Use device roll for tilt
                tilt = data.attitude.roll
                chickenPosition = CGFloat(max(-1, min(1, tilt)))
            }
        }
    }
    
    func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func updateGame() {
        // Check if chicken is within safe zone (based on difficulty)
        if abs(tilt) < selectedDifficulty.safeZone {
            distance += 1
            score += 1
            
            if distance >= selectedDifficulty.targetDistance {
                completeGame()
            }
        } else if abs(tilt) > selectedDifficulty.fallThreshold {
            // Fell off the bridge
            isGameOver = true
            stopMotionUpdates()
        }
    }
    
    func completeGame() {
        isGameOver = true
        stopMotionUpdates()
        gameManager.completeGame(type: .bridgeBalance, score: score, feathersEarned: score)
    }
    
    func restartGame() {
        chickenPosition = 0
        tilt = 0
        score = 0
        distance = 0
        isGameOver = false
        gameStarted = false
        showDifficultySelect = true
        stopMotionUpdates()
    }
}

#Preview {
    BridgeBalanceGame(isPresented: .constant(.bridgeBalance))
        .environmentObject(GameManager())
}

