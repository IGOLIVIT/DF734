//
//  SpaceBattleGame.swift
//  DF734
//
//  Created by IGOR on 13/11/2025.
//

import SwiftUI
import Combine

struct SpaceBattleGame: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var isPresented: MiniGameType?
    
    @State private var playerPosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 150)
    @State private var isShooting = false
    @State private var bullets: [Bullet] = []
    @State private var enemies: [Enemy] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var gameState: GameState = .menu
    @State private var selectedDifficulty: BattleDifficulty = .easy
    @State private var gameTimer: Timer?
    @State private var enemySpawnTimer: Timer?
    @State private var shootTimer: Timer?
    @State private var animateStart = false
    @State private var showTutorial = false
    
    enum GameState {
        case menu, tutorial, playing, gameOver
    }
    
    enum BattleDifficulty: String, CaseIterable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        
        var enemySpeed: Double {
            switch self {
            case .easy: return 2.0
            case .medium: return 3.5
            case .hard: return 5.0
            }
        }
        
        var spawnInterval: Double {
            switch self {
            case .easy: return 1.5
            case .medium: return 1.0
            case .hard: return 0.7
            }
        }
        
        var color: Color {
            switch self {
            case .easy: return .green
            case .medium: return .orange
            case .hard: return .red
            }
        }
    }
    
    struct Bullet: Identifiable {
        let id = UUID()
        var position: CGPoint
        let speed: Double = 10.0
    }
    
    struct Enemy: Identifiable {
        let id = UUID()
        var position: CGPoint
        var speed: Double
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#0A0E27"),
                        Color(hex: "#1A1F3A"),
                        Color(hex: "#0A0E27")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Stars background
                ForEach(0..<50, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                        .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                }
                
                if gameState == .menu {
                    menuView(geometry: geometry)
                } else if gameState == .tutorial {
                    tutorialView(geometry: geometry)
                } else if gameState == .playing {
                    gameplayView(geometry: geometry)
                } else {
                    gameOverView(geometry: geometry)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    animateStart = true
                }
            }
        }
    }
    
    // MARK: - Menu View
    func menuView(geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer()
                    .frame(height: 60)
                
                // Game icon
                Image(systemName: "airplane")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(Color(hex: "#5A9FD4"))
                    .shadow(color: Color(hex: "#5A9FD4").opacity(0.5), radius: 20)
                    .scaleEffect(animateStart ? 1 : 0.5)
                    .opacity(animateStart ? 1 : 0)
                
                VStack(spacing: 12) {
                    Text("Space Battle")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Dodge enemies and shoot to survive")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .offset(y: animateStart ? 0 : 20)
                .opacity(animateStart ? 1 : 0)
                
                // Instructions
                VStack(alignment: .leading, spacing: 16) {
                    Text("How to Play:")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    instructionRow(icon: "hand.tap.fill", text: "Touch screen to move plane to that position")
                    instructionRow(icon: "hand.point.up.fill", text: "Hold finger to shoot automatically")
                    instructionRow(icon: "target", text: "Destroy enemies before they reach you")
                    instructionRow(icon: "heart.fill", text: "3 lives - don't let enemies pass!")
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                )
                .padding(.horizontal, 20)
                .offset(y: animateStart ? 0 : 30)
                .opacity(animateStart ? 1 : 0)
                
                // Difficulty selector
                VStack(spacing: 12) {
                    Text("Select Difficulty")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack(spacing: 12) {
                        ForEach(BattleDifficulty.allCases, id: \.self) { difficulty in
                            Button(action: {
                                selectedDifficulty = difficulty
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }) {
                                Text(difficulty.rawValue)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(selectedDifficulty == difficulty ? .white : .white.opacity(0.6))
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedDifficulty == difficulty ? difficulty.color : Color.white.opacity(0.1))
                                    )
                            }
                        }
                    }
                }
                .offset(y: animateStart ? 0 : 30)
                .opacity(animateStart ? 1 : 0)
                
                // Start button
                CustomButton(
                    title: "Start Battle",
                    backgroundColor: Color(hex: "#5A9FD4"),
                    foregroundColor: .white,
                    icon: "play.fill"
                ) {
                    gameState = .tutorial
                }
                .padding(.horizontal, 40)
                .offset(y: animateStart ? 0 : 30)
                .opacity(animateStart ? 1 : 0)
                
                // Close button
                Button(action: {
                    isPresented = nil
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark")
                        Text("Close")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .padding()
                }
                .offset(y: animateStart ? 0 : 30)
                .opacity(animateStart ? 1 : 0)
                
                Spacer()
                    .frame(height: 40)
            }
            .frame(minHeight: geometry.size.height)
        }
    }
    
    func instructionRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "#5A9FD4"))
                .frame(width: 30)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
        }
    }
    
    // MARK: - Tutorial View
    func tutorialView(geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer()
                    .frame(height: 60)
                
                // Warning icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.orange)
                    .shadow(color: .orange.opacity(0.5), radius: 20)
                
                Text("How to Play")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Read carefully before starting!")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                
                // Tutorial steps
                VStack(spacing: 20) {
                    TutorialStep(
                        number: "1",
                        icon: "hand.tap.fill",
                        title: "Move Your Plane",
                        description: "Touch anywhere on screen - your plane will instantly move to that position",
                        color: Color(hex: "#5A9FD4")
                    )
                    
                    TutorialStep(
                        number: "2",
                        icon: "hand.point.up.fill",
                        title: "Auto Shooting",
                        description: "While you HOLD your finger on screen, the plane will shoot automatically",
                        color: Color(hex: "#F6D547")
                    )
                    
                    TutorialStep(
                        number: "3",
                        icon: "target",
                        title: "Destroy Enemies",
                        description: "Shoot red triangles falling from top. Don't let them reach the bottom!",
                        color: .red
                    )
                    
                    TutorialStep(
                        number: "4",
                        icon: "heart.fill",
                        title: "3 Lives Only",
                        description: "Each enemy that reaches bottom = -1 life. Game over at 0 lives",
                        color: .red
                    )
                }
                .padding(.horizontal, 20)
                
                // Visual demo
                VStack(spacing: 16) {
                    Text("Controls Demo")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.05))
                            .frame(height: 200)
                        
                        VStack(spacing: 12) {
                            Image(systemName: "airplane")
                                .font(.system(size: 50))
                                .foregroundColor(Color(hex: "#F6D547"))
                                .rotationEffect(.degrees(-90))
                            
                            Text("↑")
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: "#5A9FD4"))
                            
                            Text("Plane points UP")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text("Touch & Hold = Move + Shoot")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Start button
                CustomButton(
                    title: "I Understand - Start!",
                    backgroundColor: .green,
                    foregroundColor: .white,
                    icon: "checkmark.circle.fill"
                ) {
                    startGame()
                }
                .padding(.horizontal, 40)
                
                // Back button
                Button(action: {
                    gameState = .menu
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.left")
                        Text("Back to Menu")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .padding()
                }
                
                Spacer()
                    .frame(height: 40)
            }
            .frame(minHeight: geometry.size.height)
        }
    }
    
    struct TutorialStep: View {
        let number: String
        let icon: String
        let title: String
        let description: String
        let color: Color
        
        var body: some View {
            HStack(alignment: .top, spacing: 16) {
                // Number badge
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 36, height: 36)
                    
                    Text(number)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .foregroundColor(color)
                        
                        Text(title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.3), lineWidth: 2)
            )
        }
    }
    
    // MARK: - Gameplay View
    func gameplayView(geometry: GeometryProxy) -> some View {
        ZStack {
            // Game area
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            // Move player to touch position
                            let newX = min(max(value.location.x, 30), geometry.size.width - 30)
                            let newY = min(max(value.location.y, geometry.size.height / 2), geometry.size.height - 80)
                            playerPosition = CGPoint(x: newX, y: newY)
                            
                            // Start shooting
                            if !isShooting {
                                isShooting = true
                                startShooting()
                            }
                        }
                        .onEnded { _ in
                            // Stop shooting
                            isShooting = false
                            stopShooting()
                        }
                )
            
            // Enemies
            ForEach(enemies) { enemy in
                Image(systemName: "triangle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.red)
                    .rotationEffect(.degrees(180))
                    .position(enemy.position)
            }
            
            // Bullets
            ForEach(bullets) { bullet in
                Circle()
                    .fill(Color(hex: "#5A9FD4"))
                    .frame(width: 8, height: 8)
                    .position(bullet.position)
            }
            
            // Player
            Image(systemName: "airplane")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Color(hex: "#F6D547"))
                .shadow(color: Color(hex: "#F6D547").opacity(0.5), radius: 10)
                .rotationEffect(.degrees(-90))
                .position(playerPosition)
            
            // HUD
            VStack {
                HStack {
                    // Lives
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(lives)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.5))
                    )
                    
                    Spacer()
                    
                    // Score
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(hex: "#F6D547"))
                        Text("\(score)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.5))
                    )
                }
                .padding()
                
                Spacer()
                
                // Exit button
                Button(action: {
                    stopTimers()
                    isPresented = nil
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                        Text("Exit Game")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(0.8))
                    )
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Game Over View
    func gameOverView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: lives <= 0 ? "xmark.circle.fill" : "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(lives <= 0 ? .red : .green)
            
            Text(lives <= 0 ? "Game Over" : "Victory!")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                Text("Score: \(score)")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Feathers Earned: \(score / 10)")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#F6D547"))
            }
            
            CustomButton(
                title: "Play Again",
                backgroundColor: Color(hex: "#5A9FD4"),
                foregroundColor: .white,
                icon: "arrow.clockwise"
            ) {
                resetGame()
            }
            .padding(.horizontal, 40)
            
            CustomButton(
                title: "Back to Menu",
                backgroundColor: .white.opacity(0.1),
                foregroundColor: .white,
                icon: "house.fill"
            ) {
                gameState = .menu
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    // MARK: - Game Logic
    func startGame() {
        score = 0
        lives = 3
        bullets = []
        enemies = []
        playerPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 150)
        gameState = .playing
        
        // Start game loop
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateGame()
        }
        
        // Start enemy spawning
        enemySpawnTimer = Timer.scheduledTimer(withTimeInterval: selectedDifficulty.spawnInterval, repeats: true) { _ in
            spawnEnemy()
        }
    }
    
    func resetGame() {
        stopTimers()
        startGame()
    }
    
    func stopTimers() {
        gameTimer?.invalidate()
        gameTimer = nil
        enemySpawnTimer?.invalidate()
        enemySpawnTimer = nil
        shootTimer?.invalidate()
        shootTimer = nil
    }
    
    func startShooting() {
        shootTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            shoot()
        }
    }
    
    func stopShooting() {
        shootTimer?.invalidate()
        shootTimer = nil
    }
    
    func shoot() {
        let bullet = Bullet(position: CGPoint(x: playerPosition.x, y: playerPosition.y - 30))
        bullets.append(bullet)
    }
    
    func spawnEnemy() {
        let randomX = CGFloat.random(in: 30...(UIScreen.main.bounds.width - 30))
        let enemy = Enemy(
            position: CGPoint(x: randomX, y: -30),
            speed: selectedDifficulty.enemySpeed
        )
        enemies.append(enemy)
    }
    
    func updateGame() {
        let screenHeight = UIScreen.main.bounds.height
        
        // Update bullets
        var bulletsToRemove: [UUID] = []
        for index in bullets.indices {
            bullets[index].position.y -= bullets[index].speed
            if bullets[index].position.y < 0 {
                bulletsToRemove.append(bullets[index].id)
            }
        }
        bullets.removeAll { bulletsToRemove.contains($0.id) }
        
        // Update enemies
        var enemiesToRemove: [UUID] = []
        for index in enemies.indices {
            enemies[index].position.y += enemies[index].speed
            
            // Check if enemy reached bottom
            if enemies[index].position.y > screenHeight {
                enemiesToRemove.append(enemies[index].id)
                lives -= 1
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                
                if lives <= 0 {
                    endGame()
                    return
                }
            }
        }
        enemies.removeAll { enemiesToRemove.contains($0.id) }
        
        // Check collisions
        for bullet in bullets {
            for enemy in enemies {
                let distance = sqrt(pow(bullet.position.x - enemy.position.x, 2) + pow(bullet.position.y - enemy.position.y, 2))
                if distance < 25 {
                    bulletsToRemove.append(bullet.id)
                    enemiesToRemove.append(enemy.id)
                    score += 10
                    
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
            }
        }
        
        bullets.removeAll { bulletsToRemove.contains($0.id) }
        enemies.removeAll { enemiesToRemove.contains($0.id) }
    }
    
    func endGame() {
        stopTimers()
        gameState = .gameOver
        
        // Update statistics
        let feathersEarned = score / 10
        gameManager.statistics.addFeathers(feathersEarned)
        gameManager.statistics.completeGame()
        gameManager.statistics.updateBestScore(game: .spaceBattle, score: score)
        gameManager.saveStatistics()
    }
}

#Preview {
    SpaceBattleGame(isPresented: .constant(.spaceBattle))
        .environmentObject(GameManager())
}

