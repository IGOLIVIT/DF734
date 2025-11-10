//
//  OnboardingView.swift
//  DF734
//
//  Created by IGOR on 06/11/2025.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var currentPage = 0
    @State private var animateContent = false
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            text: "A new day begins.",
            icon: "sun.max.fill",
            iconColor: Color(hex: "#F6D547")
        ),
        OnboardingPage(
            text: "Every step matters.",
            icon: "figure.walk",
            iconColor: Color(hex: "#E85A4F")
        ),
        OnboardingPage(
            text: "Let's see where the feathers lead.",
            icon: "leaf.fill",
            iconColor: Color(hex: "#F6D547")
        )
    ]
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .frame(height: 400)
                
                Spacer()
                
                // Start button
                if currentPage == pages.count - 1 {
                    CustomButton(
                        title: "Start",
                        backgroundColor: AppTheme.primaryButton,
                        foregroundColor: AppTheme.background
                    ) {
                        withAnimation(.easeInOut) {
                            gameManager.completeOnboarding()
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                    .transition(.opacity.combined(with: .scale))
                } else {
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text("Next")
                                .font(.system(size: 18, weight: .semibold))
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(AppTheme.textPrimary)
                        .padding()
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateContent = true
            }
        }
    }
}

struct OnboardingPage {
    let text: String
    let icon: String
    let iconColor: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: page.icon)
                .font(.system(size: 100))
                .foregroundColor(page.iconColor)
                .shadow(color: page.iconColor.opacity(0.3), radius: 20, x: 0, y: 10)
                .scaleEffect(animate ? 1 : 0.5)
                .opacity(animate ? 1 : 0)
            
            Text(page.text)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .offset(y: animate ? 0 : 20)
                .opacity(animate ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                animate = true
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(GameManager())
}



