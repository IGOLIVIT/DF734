//
//  CustomButton.swift
//  DF734
//
//  Created by IGOR on 06/11/2025.
//

import SwiftUI

struct CustomButton: View {
    let title: String
    var backgroundColor: Color = AppTheme.primaryButton
    var foregroundColor: Color = AppTheme.background
    var icon: String? = nil
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundColor(foregroundColor)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [backgroundColor, backgroundColor.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: backgroundColor.opacity(0.4), radius: isPressed ? 5 : 15, x: 0, y: isPressed ? 2 : 8)
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

struct MiniGameCard: View {
    let game: MiniGameType
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        }) {
            VStack(spacing: 12) {
                Image(systemName: game.icon)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(game.color)
                    .frame(height: 60)
                
                Text(game.rawValue)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(game.description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 160)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(game.color.opacity(0.3), lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(color: game.color.opacity(0.2), radius: isPressed ? 5 : 10, x: 0, y: isPressed ? 2 : 5)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

#Preview {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        VStack(spacing: 20) {
            CustomButton(title: "Start Game") {}
            MiniGameCard(game: .stepTiming) {}
        }
        .padding()
    }
}



