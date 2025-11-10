# Feather Steps Journey

A charming iOS mini-game collection featuring an adventurous chicken on a journey to collect feathers through engaging challenges.

## Overview

**Feather Steps Journey** is a fully functional iOS application that offers three unique mini-games with a cohesive theme. Guide your feathered friend through various challenges, collect feathers, and track your progress as you master each game.

## Features

### 🎮 Three Unique Mini-Games

1. **Step Timing** - Test your reflexes by tapping at the perfect moment to help the chicken cross moving paths safely
2. **Feather Catch** - Swipe to move and collect falling golden feathers while avoiding red obstacles
3. **Bridge Balance** - Use device tilt to keep the chicken balanced on a wobbly bridge

### 📊 Statistics Tracking

- Total feathers collected across all games
- Number of completed games
- Best scores for each mini-game
- Reset progress option with confirmation dialog

### 🎨 Beautiful Design

- **Color Palette:**
  - Background: Deep Indigo (#0E1A2A)
  - Primary: Soft Yellow (#F6D547)
  - Accent: Warm Coral (#E85A4F)

- **Visual Features:**
  - Smooth animations and transitions
  - Professional UI layout with proper spacing
  - Responsive design for iPhone and iPad
  - Adaptive text sizing to prevent overflow
  - ScrollViews for smaller screens

### 🎯 User Experience

- **Onboarding:** Welcoming 3-page introduction with smooth animations
- **Bottom Navigation:** Easy access to Home, Mini-Games, and Statistics
- **Haptic Feedback:** Tactile responses for button interactions
- **Game Completion:** Celebratory screens with feather rewards
- **Data Persistence:** All progress saved locally using UserDefaults

## Technical Details

### Architecture

- **SwiftUI** for modern, declarative UI
- **Combine** for reactive state management
- **CoreMotion** for device tilt detection (Bridge Balance game)
- **MVVM Pattern** with GameManager as the central state manager

### File Structure

```
DF734/
├── Models/
│   ├── GameData.swift          # Data models and theme definitions
│   └── GameManager.swift       # State management and persistence
├── Views/
│   ├── OnboardingView.swift    # Welcome screens
│   ├── MainMenuView.swift      # Main navigation hub
│   ├── Components/
│   │   ├── CustomButton.swift  # Reusable button components
│   │   └── GameOverView.swift  # Game completion screen
│   ├── Screens/
│   │   ├── HomeScreen.swift           # Home dashboard
│   │   ├── MiniGamesScreen.swift      # Game selection
│   │   └── StatisticsScreen.swift     # Stats and progress
│   └── MiniGames/
│       ├── StepTimingGame.swift       # Timing-based game
│       ├── FeatherCatchGame.swift     # Collection game
│       └── BridgeBalanceGame.swift    # Balance game
├── ContentView.swift           # Root view controller
└── DF734App.swift             # App entry point
```

### Key Components

#### GameManager
- Handles all game statistics
- Manages UserDefaults persistence
- Tracks onboarding completion
- Updates scores and feather counts

#### Data Models
- `GameStatistics`: Stores player progress
- `MiniGameType`: Enum for game types
- `AppTheme`: Centralized color scheme

#### Custom UI Components
- `CustomButton`: Animated button with haptic feedback
- `MiniGameCard`: Game selection cards
- `StatCard`: Statistics display cards
- `GameOverView`: Completion celebration screen

## Requirements

- iOS 17.0+
- Xcode 16.0+
- Swift 5.0+
- Device with motion sensors (for Bridge Balance)

## Building the App

```bash
# Build for iOS Simulator
xcodebuild -project DF734.xcodeproj -scheme DF734 -sdk iphonesimulator -configuration Debug

# Build for iOS Device
xcodebuild -project DF734.xcodeproj -scheme DF734 -sdk iphoneos -configuration Debug CODE_SIGNING_ALLOWED=NO
```

## Gameplay Instructions

### Step Timing
- Watch the chicken move across the path
- Tap the button when it reaches the green zone
- Complete 10 successful crossings
- You have 3 lives - don't miss!

### Feather Catch
- Drag to move the chicken left and right
- Collect golden feathers (+10 points each)
- Avoid red obstacles (-1 life)
- Race against time (30 seconds)

### Bridge Balance
- Tilt your device to balance the chicken
- Stay within the safe zone (green area)
- Travel 100 meters to complete
- Don't fall off the bridge!

## Privacy & Permissions

This app:
- ✅ Does NOT require internet connection
- ✅ Does NOT collect personal data
- ✅ Does NOT require login or account
- ✅ Does NOT use camera or microphone
- ✅ Does NOT track location
- ⚠️ Uses motion sensors (CoreMotion) for Bridge Balance game only

## Design Principles

1. **Consistency** - Unified visual language across all screens
2. **Accessibility** - Readable fonts with automatic sizing
3. **Responsiveness** - Adapts to different screen sizes
4. **Feedback** - Visual and haptic responses to user actions
5. **Clarity** - Clear instructions and intuitive controls

## Future Enhancements

- Additional mini-games
- Achievement system
- Sound effects and background music
- Multiplayer challenges
- Daily rewards
- Customizable chicken skins

## Credits

Created for iOS with ❤️ using SwiftUI

---

**Version:** 1.0.0  
**Last Updated:** November 2025



