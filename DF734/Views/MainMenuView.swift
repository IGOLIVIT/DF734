//
//  MainMenuView.swift
//  DF734
//
//  Created by IGOR on 06/11/2025.
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Content area
                TabView(selection: $selectedTab) {
                    HomeScreen(selectedTab: $selectedTab)
                        .tag(0)
                    
                    MiniGamesScreen()
                        .tag(1)
                    
                    StatisticsScreen()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Bottom navigation
                HStack(spacing: 0) {
                    TabButton(
                        icon: "house.fill",
                        title: "Home",
                        isSelected: selectedTab == 0
                    ) {
                        withAnimation(.easeInOut) {
                            selectedTab = 0
                        }
                    }
                    
                    TabButton(
                        icon: "gamecontroller.fill",
                        title: "Games",
                        isSelected: selectedTab == 1
                    ) {
                        withAnimation(.easeInOut) {
                            selectedTab = 1
                        }
                    }
                    
                    TabButton(
                        icon: "chart.bar.fill",
                        title: "Stats",
                        isSelected: selectedTab == 2
                    ) {
                        withAnimation(.easeInOut) {
                            selectedTab = 2
                        }
                    }
                }
                .padding(.vertical, 12)
                .background(
                    Color.black.opacity(0.3)
                        .overlay(
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 1),
                            alignment: .top
                        )
                )
            }
        }
    }
}

struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(isSelected ? AppTheme.primaryButton : AppTheme.textSecondary)
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? AppTheme.primaryButton : AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                isSelected ?
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.primaryButton.opacity(0.1))
                        .padding(.horizontal, 8)
                    : nil
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MainMenuView()
        .environmentObject(GameManager())
}



