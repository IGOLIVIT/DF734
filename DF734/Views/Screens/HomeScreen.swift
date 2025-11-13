//
//  HomeScreen.swift
//  DF734
//
//  Created by IGOR on 06/11/2025.
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var animateContent = false
    @Binding var selectedTab: Int
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer()
                    .frame(height: 40)
                
                // Hero Section
                VStack(spacing: 20) {
                    // Chicken illustration
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        AppTheme.primaryButton.opacity(0.3),
                                        AppTheme.accent.opacity(0.2)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 150, height: 150)
                            .blur(radius: 30)
                        
                        Image(systemName: "bird.fill")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(AppTheme.primaryButton)
                            .shadow(color: AppTheme.primaryButton.opacity(0.5), radius: 20, x: 0, y: 10)
                    }
                    .scaleEffect(animateContent ? 1 : 0.5)
                    .opacity(animateContent ? 1 : 0)
                    
                    Text("Welcome, Adventurer!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .offset(y: animateContent ? 0 : 20)
                        .opacity(animateContent ? 1 : 0)
                    
                    Text("Guide your feathered friend through exciting challenges and collect feathers along the way.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .offset(y: animateContent ? 0 : 20)
                        .opacity(animateContent ? 1 : 0)
                }
                
                // Stats Grid
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        StatPreviewCard(
                            icon: "leaf.fill",
                            value: "\(gameManager.statistics.totalFeathers)",
                            label: "Feathers",
                            color: AppTheme.primaryButton
                        )
                        
                        StatPreviewCard(
                            icon: "checkmark.circle.fill",
                            value: "\(gameManager.statistics.gamesCompleted)",
                            label: "Completed",
                            color: AppTheme.accent
                        )
                    }
                    
                    HStack(spacing: 16) {
                        StatPreviewCard(
                            icon: "gamecontroller.fill",
                            value: "5",
                            label: "Games",
                            color: Color(hex: "#5A9FD4")
                        )
                        
                        StatPreviewCard(
                            icon: "trophy.fill",
                            value: "\(highestScore)",
                            label: "Best Score",
                            color: Color(hex: "#9B59B6")
                        )
                    }
                }
                .padding(.horizontal, 30)
                .offset(y: animateContent ? 0 : 30)
                .opacity(animateContent ? 1 : 0)
                
                Spacer()
                    .frame(height: 20)
                
                // Play button
                CustomButton(
                    title: "Play Mini-Games",
                    backgroundColor: AppTheme.primaryButton,
                    foregroundColor: AppTheme.background,
                    icon: "play.fill"
                ) {
                    withAnimation {
                        selectedTab = 1 // Switch to Games tab
                    }
                }
                .padding(.horizontal, 40)
                .offset(y: animateContent ? 0 : 40)
                .opacity(animateContent ? 1 : 0)
                
                Spacer()
                    .frame(height: 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateContent = true
            }
        }
    }
    
    var highestScore: Int {
        max(
            gameManager.statistics.stepTimingBestScore,
            gameManager.statistics.featherCatchBestScore,
            gameManager.statistics.bridgeBalanceBestScore,
            gameManager.statistics.spaceBattleBestScore,
            gameManager.statistics.memoryMatchBestScore
        )
    }
}

struct StatPreviewCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        HomeScreen(selectedTab: .constant(0))
            .environmentObject(GameManager())
    }
}



