# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application that converts images to ASCII art. The app allows users to pick an image from their gallery, then converts it to ASCII characters based on pixel brightness. The conversion runs in a compute isolate to prevent UI freezing.

## Architecture

The application is structured as a single-file Flutter app (lib/main.dart):

- **MyApp**: Root MaterialApp widget with Material 3 theme
- **MyHomePage**: StatefulWidget containing the main UI
- **_MyHomePageState**: Manages image picking and ASCII conversion state
  - Uses `image_picker` package for gallery access
  - Uses `image` package for image processing (resize, grayscale, pixel access)
  - Runs conversion in isolate via `compute()` to avoid blocking UI

### ASCII Conversion Logic

The conversion algorithm (lib/main.dart:65-93):
1. Loads image from file path
2. Resizes to width of 100 pixels
3. Converts to grayscale
4. Maps each pixel's brightness (0-255) to ASCII character ramp: `@%#*+=-:. `
5. Returns string buffer with newlines for each row

## Development Commands

### Run the application
```bash
flutter run
```

For specific platforms:
```bash
flutter run -d macos        # macOS
flutter run -d chrome       # Web
flutter run -d ios          # iOS (requires macOS)
flutter run -d android      # Android
```

### Testing
```bash
flutter test                # Run all tests
flutter test test/widget_test.dart  # Run specific test
```

Note: The existing widget test is a template and not aligned with current app functionality.

### Build
```bash
flutter build apk           # Android APK
flutter build ios           # iOS
flutter build macos         # macOS
flutter build web           # Web
```

### Code Quality
```bash
flutter analyze             # Run static analysis
flutter pub outdated        # Check for package updates
flutter pub upgrade         # Upgrade dependencies
```

### Clean and Reset
```bash
flutter clean               # Remove build artifacts
flutter pub get             # Fetch dependencies
```

## Dependencies

- `image_picker`: Gallery/camera image selection
- `image`: Image decoding, resizing, and pixel manipulation
- `cupertino_icons`: iOS-style icons

## Platform Support

Configured for Android, iOS, Web, macOS, Linux, and Windows with standard Flutter boilerplate.
