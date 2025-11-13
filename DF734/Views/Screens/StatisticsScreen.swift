//
//  StatisticsScreen.swift
//  DF734
//
//  Created by IGOR on 06/11/2025.
//

import SwiftUI

struct StatisticsScreen: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showResetAlert = false
    @State private var animateContent = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Spacer()
                    .frame(height: 20)
                
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(AppTheme.accent)
                    
                    Text("Statistics")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Track your progress")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : -20)
                
                // Total stats
                VStack(spacing: 16) {
                    StatCard(
                        icon: "leaf.fill",
                        title: "Total Feathers",
                        value: "\(gameManager.statistics.totalFeathers)",
                        color: AppTheme.primaryButton
                    )
                    
                    StatCard(
                        icon: "checkmark.circle.fill",
                        title: "Games Completed",
                        value: "\(gameManager.statistics.gamesCompleted)",
                        color: AppTheme.accent
                    )
                }
                .padding(.horizontal, 20)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                
                // Best scores
                VStack(alignment: .leading, spacing: 12) {
                    Text("Best Scores")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        BestScoreRow(
                            gameName: "Step Timing",
                            score: gameManager.statistics.stepTimingBestScore,
                            icon: "clock.fill"
                        )
                        
                        BestScoreRow(
                            gameName: "Feather Catch",
                            score: gameManager.statistics.featherCatchBestScore,
                            icon: "leaf.fill"
                        )
                        
                        BestScoreRow(
                            gameName: "Bridge Balance",
                            score: gameManager.statistics.bridgeBalanceBestScore,
                            icon: "arrow.left.and.right"
                        )
                        
                        BestScoreRow(
                            gameName: "Space Battle",
                            score: gameManager.statistics.spaceBattleBestScore,
                            icon: "airplane"
                        )
                        
                        BestScoreRow(
                            gameName: "Card Match",
                            score: gameManager.statistics.memoryMatchBestScore,
                            icon: "square.on.square"
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                
                // Reset button
                Button(action: {
                    showResetAlert = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Reset Progress")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.accent)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.accent, lineWidth: 2)
                    )
                }
                .padding(.top, 10)
                .opacity(animateContent ? 1 : 0)
                
                Spacer()
                    .frame(height: 30)
            }
        }
        .alert("Reset Progress", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                withAnimation {
                    gameManager.resetProgress()
                }
            }
        } message: {
            Text("Are you sure you want to reset all your progress? This action cannot be undone.")
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateContent = true
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct BestScoreRow: View {
    let gameName: String
    let score: Int
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.primaryButton)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.08))
                )
            
            Text(gameName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
            
            Text("\(score)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.primaryButton)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

#Preview {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        StatisticsScreen()
            .environmentObject(GameManager())
    }
}



