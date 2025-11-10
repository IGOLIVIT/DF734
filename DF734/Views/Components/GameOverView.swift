//
//  GameOverView.swift
//  DF734
//
//  Created by IGOR on 06/11/2025.
//

import SwiftUI

struct GameOverView: View {
    let score: Int
    let feathersEarned: Int
    let onRestart: () -> Void
    let onClose: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 70))
                    .foregroundColor(AppTheme.primaryButton)
                    .scaleEffect(animate ? 1 : 0.5)
                    .opacity(animate ? 1 : 0)
                
                Text("Game Complete!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .opacity(animate ? 1 : 0)
                
                VStack(spacing: 12) {
                    HStack(spacing: 10) {
                        Text("Score:")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                        Text("\(score)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    
                    HStack(spacing: 10) {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(AppTheme.primaryButton)
                        Text("+\(feathersEarned) Feathers")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppTheme.primaryButton)
                    }
                }
                .padding(.top, 10)
                .opacity(animate ? 1 : 0)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(AppTheme.primaryButton.opacity(0.3), lineWidth: 2)
                    )
            )
            .padding(.horizontal, 30)
            
            Spacer()
            
            VStack(spacing: 16) {
                CustomButton(
                    title: "Play Again",
                    backgroundColor: AppTheme.primaryButton,
                    foregroundColor: AppTheme.background,
                    icon: "arrow.clockwise"
                ) {
                    onRestart()
                }
                
                Button(action: onClose) {
                    Text("Back to Menu")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.vertical, 16)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
            .opacity(animate ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animate = true
            }
        }
    }
}

#Preview {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        GameOverView(score: 150, feathersEarned: 150, onRestart: {}, onClose: {})
    }
}



