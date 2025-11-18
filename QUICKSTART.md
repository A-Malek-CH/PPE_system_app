# Quick Start Guide

Get the PPE Detection System up and running in minutes.

## Prerequisites

Before you begin, ensure you have:

- [ ] Flutter SDK 3.7.0 or higher installed
- [ ] A code editor (VS Code, Android Studio, or IntelliJ)
- [ ] A physical device or emulator with camera support
- [ ] Git installed

### Verify Flutter Installation

```bash
flutter --version
flutter doctor
```

Fix any issues reported by `flutter doctor` before proceeding.

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/A-Malek-CH/PPE_system_app.git
cd PPE_system_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

This will download all required packages:
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `camera` - Camera functionality
- `dio` - HTTP client
- `intl` - Date formatting

### 3. Configure Backend URL (Optional for Testing)

The app comes with placeholder backend URLs. For actual testing:

1. Open `lib/services/api_service.dart`
2. Update the `_baseUrl` constant:

```dart
static const String _baseUrl = 'https://your-backend-url.com';
```

**For local development:**
- iOS Simulator: `http://localhost:3000`
- Android Emulator: `http://10.0.2.2:3000`
- Physical Device: `http://192.168.1.x:3000` (your computer's IP)

### 4. Run the App

#### On Connected Device

```bash
flutter run
```

#### Select Specific Device

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

#### Run in Release Mode (Better Performance)

```bash
flutter run --release
```

## Testing Without a Backend

The app is designed to work with a backend, but you can test the UI flow:

### Option 1: Mock Server (Recommended)

Create a simple mock server using the example in `BACKEND_API.md`:

```bash
# Install Node.js if not installed
# Then create server.js with the example code

npm init -y
npm install express multer

node server.js
```

### Option 2: Modify Error Handling

Temporarily modify `lib/services/api_service.dart` to return mock data on error:

```dart
Future<DetectionResult> analyzeImage(File imageFile) async {
  try {
    // ... existing code
  } catch (e) {
    // Mock response for testing
    return DetectionResult(
      name: 'Test Worker',
      helmet: true,
      vest: true,
      timestamp: DateTime.now().toIso8601String(),
    );
  }
}
```

## Running Tests

### Unit Tests

```bash
flutter test
```

### Widget Tests

```bash
flutter test test/widget_test.dart
```

### Integration Tests (if you create them)

```bash
flutter test integration_test/
```

## Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
# Build iOS app
flutter build ios --release
```

Then open the Xcode project and archive from there.

## Common Issues and Solutions

### Issue: Camera Permission Denied

**Solution**: 
- Android: Grant camera permission in device settings
- iOS: Permission dialog should appear automatically

### Issue: Network Error

**Symptoms**: "Failed to connect" or timeout errors

**Solutions**:
1. Check backend URL is correct
2. Ensure backend server is running
3. For Android emulator, use `10.0.2.2` instead of `localhost`
4. Check firewall settings
5. Verify network connectivity

### Issue: Build Fails

**Solutions**:
```bash
# Clean build cache
flutter clean

# Get dependencies again
flutter pub get

# Rebuild
flutter run
```

### Issue: Hot Reload Not Working

**Solution**:
```bash
# Use hot restart instead
# Press 'R' in the terminal or use the IDE button
```

## Development Workflow

### Making Changes

1. Edit Dart files in `lib/`
2. Save file (hot reload happens automatically)
3. Test changes in running app
4. Commit changes when ready

### Adding New Features

1. Create feature branch
2. Implement feature following existing architecture
3. Add tests
4. Update documentation
5. Submit pull request

## Project Structure Overview

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── detection_result.dart
│   └── clock_event.dart
├── services/                 # Business logic
│   ├── auth_service.dart
│   └── api_service.dart
├── controllers/              # State management
│   └── detection_controller.dart
├── screens/                  # UI screens
│   ├── camera_screen.dart
│   ├── processing_screen.dart
│   └── result_screen.dart
└── widgets/                  # Reusable widgets
    └── status_indicator.dart
```

## Next Steps

1. **Set up backend**: Follow `BACKEND_API.md` to implement backend endpoints
2. **Configure JWT**: Implement proper authentication instead of placeholder
3. **Customize UI**: Modify theme colors in `lib/main.dart`
4. **Add features**: Extend functionality as needed
5. **Deploy**: Build and deploy to app stores

## Getting Help

- **Documentation**: See `README.md` for detailed info
- **API Spec**: See `BACKEND_API.md` for backend requirements
- **Flutter Docs**: https://docs.flutter.dev
- **Issues**: Open an issue on GitHub

## Performance Tips

1. **Use Release Mode** for testing performance
2. **Profile Mode** for debugging performance:
   ```bash
   flutter run --profile
   ```
3. **Check Performance**: Use Flutter DevTools
   ```bash
   flutter pub global activate devtools
   flutter pub global run devtools
   ```

## Security Checklist

Before deploying to production:

- [ ] Replace placeholder JWT token with real authentication
- [ ] Use HTTPS for all API calls
- [ ] Store sensitive data securely (use flutter_secure_storage)
- [ ] Implement certificate pinning
- [ ] Add obfuscation: `flutter build apk --obfuscate --split-debug-info=/symbols`
- [ ] Review permissions and remove unnecessary ones
- [ ] Test on real devices
- [ ] Perform security audit

## Ready to Go! 🚀

You should now have the PPE Detection System running. Explore the code, customize it to your needs, and happy coding!

For questions or issues, refer to the main README.md or open an issue on GitHub.
