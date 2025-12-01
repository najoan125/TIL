# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Flutter clone of Carrot Market (당근마켓), a Korean peer-to-peer marketplace app. Currently in early development stage using GetX for state management.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run                    # Default device
flutter run -d ios             # iOS simulator
flutter run -d android         # Android device
flutter run -d macos           # macOS desktop

# Build for release
flutter build apk              # Android APK
flutter build ios              # iOS app

# Testing and analysis
flutter test                   # Run all tests
flutter test test/widget_test.dart  # Run single test file
flutter analyze                # Run Dart analyzer
```

## Architecture

### State Management
- **Framework:** GetX (^4.6.5)
- Uses `GetMaterialApp` for routing and state management
- Routes defined via `getPages` parameter

### Project Structure
```
lib/
├── main.dart          # Entry point, GetMaterialApp configuration
└── src/
    └── app.dart       # Main App widget

assets/
├── images/            # PNG images (logos, profile icons)
└── svg/icons/         # 34 SVG icons for UI elements
```

### Key Dependencies
- `get` - State management, routing, dependency injection
- `flutter_svg` - SVG rendering
- `shared_preferences` - Local persistent storage
- `google_fonts` - Typography
- `equatable` - Value equality for data classes

### Theme Configuration
- Dark mode by default
- Primary background: #212123
- White text on dark backgrounds
