//
//  MemoryMatchGame.swift
//  DF734
//
//  Created by IGOR on 13/11/2025.
//

import SwiftUI
import Combine

struct MemoryMatchGame: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var isPresented: MiniGameType?
    
    @State private var cards: [MemoryCard] = []
    @State private var flippedCards: [UUID] = []
    @State private var matchedCards: Set<UUID> = []
    @State private var score = 0
    @State private var moves = 0
    @State private var timeElapsed = 0
    @State private var gameState: GameState = .menu
    @State private var selectedDifficulty: MemoryDifficulty = .easy
    @State private var gameTimer: Timer?
    @State private var animateStart = false
    @State private var canFlip = true
    
    enum GameState {
        case menu, playing, completed
    }
    
    enum MemoryDifficulty: String, CaseIterable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        
        var gridSize: Int {
            switch self {
            case .easy: return 4 // 4x3 = 12 cards (6 pairs)
            case .medium: return 5 // 5x4 = 20 cards (10 pairs)
            case .hard: return 6 // 6x4 = 24 cards (12 pairs)
            }
        }
        
        var totalPairs: Int {
            switch self {
            case .easy: return 6
            case .medium: return 10
            case .hard: return 12
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
    
    struct MemoryCard: Identifiable, Equatable {
        let id = UUID()
        let symbol: String
        let pairId: Int
        var isFlipped = false
        var isMatched = false
    }
    
    let symbols = ["🌟", "🎈", "🎨", "🎭", "🎪", "🎯", "🎲", "🎸", "🎹", "🎺", "🎻", "🎬"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#2C1A4D"),
                        Color(hex: "#4A2C6B"),
                        Color(hex: "#2C1A4D")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if gameState == .menu {
                    menuView(geometry: geometry)
                } else if gameState == .playing {
                    gameplayView(geometry: geometry)
                } else {
                    completedView(geometry: geometry)
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
                Image(systemName: "square.on.square")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(Color(hex: "#9B59B6"))
                    .shadow(color: Color(hex: "#9B59B6").opacity(0.5), radius: 20)
                    .scaleEffect(animateStart ? 1 : 0.5)
                    .opacity(animateStart ? 1 : 0)
                
                VStack(spacing: 12) {
                    Text("Card Match")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Match pairs of cards to win")
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
                    
                    instructionRow(icon: "hand.tap.fill", text: "Tap a card to flip it")
                    instructionRow(icon: "square.on.square", text: "Find matching pairs")
                    instructionRow(icon: "checkmark.circle.fill", text: "Match all pairs to win")
                    instructionRow(icon: "clock.fill", text: "Complete as fast as possible!")
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
                        ForEach(MemoryDifficulty.allCases, id: \.self) { difficulty in
                            Button(action: {
                                selectedDifficulty = difficulty
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }) {
                                VStack(spacing: 4) {
                                    Text(difficulty.rawValue)
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("\(difficulty.totalPairs) pairs")
                                        .font(.system(size: 10))
                                }
                                .foregroundColor(selectedDifficulty == difficulty ? .white : .white.opacity(0.6))
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
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
                    title: "Start Game",
                    backgroundColor: Color(hex: "#9B59B6"),
                    foregroundColor: .white,
                    icon: "play.fill"
                ) {
                    startGame()
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
                .foregroundColor(Color(hex: "#9B59B6"))
                .frame(width: 30)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
        }
    }
    
    // MARK: - Gameplay View
    func gameplayView(geometry: GeometryProxy) -> some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    // HUD
                    HStack(spacing: 20) {
                        // Moves
                        VStack(spacing: 4) {
                            Text("Moves")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                            Text("\(moves)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                        )
                        
                        Spacer()
                        
                        // Timer
                        VStack(spacing: 4) {
                            Text("Time")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                            Text(formatTime(timeElapsed))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                        )
                        
                        Spacer()
                        
                        // Pairs
                        VStack(spacing: 4) {
                            Text("Pairs")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                            Text("\(matchedCards.count / 2)/\(selectedDifficulty.totalPairs)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(hex: "#9B59B6"))
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Cards grid
                    let columns = selectedDifficulty == .easy ? 3 : 4
                    let spacing: CGFloat = 8
                    let totalSpacing = spacing * CGFloat(columns + 1)
                    let availableWidth = geometry.size.width - totalSpacing - 40
                    let cardSize = availableWidth / CGFloat(columns)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns), spacing: spacing) {
                        ForEach(cards) { card in
                            CardView(
                                card: card,
                                size: cardSize,
                                isFlipped: flippedCards.contains(card.id) || matchedCards.contains(card.id)
                            )
                            .onTapGesture {
                                flipCard(card)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 80) // Space for close button
                }
            }
            
            // Close button overlay
            VStack {
                Spacer()
                
                Button(action: {
                    gameTimer?.invalidate()
                    gameTimer = nil
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
    
    // MARK: - Completed View
    func completedView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Completed!")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                resultRow(icon: "clock.fill", label: "Time", value: formatTime(timeElapsed))
                resultRow(icon: "hand.tap.fill", label: "Moves", value: "\(moves)")
                resultRow(icon: "star.fill", label: "Score", value: "\(score)")
                resultRow(icon: "leaf.fill", label: "Feathers Earned", value: "\(score / 10)")
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            .padding(.horizontal, 40)
            
            CustomButton(
                title: "Play Again",
                backgroundColor: Color(hex: "#9B59B6"),
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
    
    func resultRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#9B59B6"))
                .frame(width: 30)
            
            Text(label)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Card View
    struct CardView: View {
        let card: MemoryCard
        let size: CGFloat
        let isFlipped: Bool
        
        var body: some View {
            ZStack {
                if isFlipped {
                    // Front (symbol)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#9B59B6"),
                                    Color(hex: "#8E44AD")
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text(card.symbol)
                        .font(.system(size: size * 0.4))
                } else {
                    // Back
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Image(systemName: "square.on.square")
                        .font(.system(size: size * 0.3))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .frame(width: size, height: size)
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isFlipped)
        }
    }
    
    // MARK: - Game Logic
    func startGame() {
        generateCards()
        score = 0
        moves = 0
        timeElapsed = 0
        flippedCards = []
        matchedCards = []
        gameState = .playing
        canFlip = true
        
        // Start timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeElapsed += 1
        }
    }
    
    func resetGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        startGame()
    }
    
    func generateCards() {
        var newCards: [MemoryCard] = []
        let pairsNeeded = selectedDifficulty.totalPairs
        
        for i in 0..<pairsNeeded {
            let symbol = symbols[i % symbols.count]
            newCards.append(MemoryCard(symbol: symbol, pairId: i))
            newCards.append(MemoryCard(symbol: symbol, pairId: i))
        }
        
        cards = newCards.shuffled()
    }
    
    func flipCard(_ card: MemoryCard) {
        guard canFlip else { return }
        guard !matchedCards.contains(card.id) else { return }
        guard !flippedCards.contains(card.id) else { return }
        guard flippedCards.count < 2 else { return }
        
        flippedCards.append(card.id)
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        if flippedCards.count == 2 {
            moves += 1
            canFlip = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                checkMatch()
            }
        }
    }
    
    func checkMatch() {
        guard flippedCards.count == 2 else { return }
        
        let firstCard = cards.first { $0.id == flippedCards[0] }
        let secondCard = cards.first { $0.id == flippedCards[1] }
        
        if let first = firstCard, let second = secondCard, first.pairId == second.pairId {
            // Match!
            matchedCards.insert(first.id)
            matchedCards.insert(second.id)
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Check if game completed
            if matchedCards.count == cards.count {
                completeGame()
            }
        }
        
        flippedCards = []
        canFlip = true
    }
    
    func completeGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        gameState = .completed
        
        // Calculate score (based on time and moves)
        let timeBonus = max(0, 300 - timeElapsed) // bonus for fast completion
        let movesPenalty = moves * 2
        score = max(50, timeBonus - movesPenalty + (selectedDifficulty.totalPairs * 20))
        
        // Update statistics
        let feathersEarned = score / 10
        gameManager.statistics.addFeathers(feathersEarned)
        gameManager.statistics.completeGame()
        gameManager.statistics.updateBestScore(game: .memoryMatch, score: score)
        gameManager.saveStatistics()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

#Preview {
    MemoryMatchGame(isPresented: .constant(.memoryMatch))
        .environmentObject(GameManager())
}

