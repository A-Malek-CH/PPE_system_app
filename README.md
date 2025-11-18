# PPE Detection System

A Flutter mobile application for Personal Protective Equipment (PPE) detection with automated clock-in/clock-out functionality.

## Overview

This app implements a complete workflow for detecting PPE equipment (helmet and safety vest) using camera capture and backend analysis, followed by automated time tracking.

## Features

- **Live Camera Preview**: Real-time camera feed with camera controls
- **Countdown Timer**: 5-second countdown before automatic image capture
- **PPE Detection**: Analyzes captured images for helmet and vest compliance
- **Worker Recognition**: Identifies workers from the captured image
- **Conditional Clock Events**: Smart clock-in (morning) or clock-out (afternoon) based on time
- **Safety Compliance**: Only allows clocking if all PPE requirements are met
- **Material 3 Design**: Modern UI following Material Design 3 guidelines
- **Dark Mode Support**: Automatic theme switching based on system preferences

## Architecture

### Clean Architecture Pattern

```
lib/
├── main.dart                      # App entry point with routing
├── models/                        # Data models
│   ├── detection_result.dart     # PPE detection result model
│   └── clock_event.dart          # Clock in/out event model
├── services/                      # Business logic services
│   ├── auth_service.dart         # JWT token management
│   └── api_service.dart          # Backend API integration
├── controllers/                   # State management
│   └── detection_controller.dart # Detection flow controller
├── screens/                       # UI screens
│   ├── camera_screen.dart        # Camera preview & capture
│   ├── processing_screen.dart    # Loading indicator
│   └── result_screen.dart        # Detection results & actions
└── widgets/                       # Reusable components
    └── status_indicator.dart     # PPE status display widget
```

## App Flow

1. **Camera Screen**: Shows live camera preview with "Take Picture" button
2. **Countdown**: 5-second countdown overlay appears when button is pressed
3. **Capture**: Automatically captures image after countdown
4. **Processing Screen**: Displays loading indicator while sending image to backend
5. **Result Screen**: Shows detection results with appropriate action button:
   - If compliant (recognized + helmet + vest): Shows "Clock In" or "Clock Out" button
   - If non-compliant: Shows "Reset" button to retry

## Technical Stack

- **Framework**: Flutter 3.7.0+
- **State Management**: Riverpod 2.6.1
- **Navigation**: GoRouter 14.6.2
- **Camera**: camera 0.11.0+2
- **Networking**: Dio 5.7.0
- **Date Formatting**: intl 0.19.0

## API Integration

### Authentication
All API requests include JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

### Endpoints

#### 1. Analyze Image
- **URL**: `POST /analyze`
- **Content-Type**: `multipart/form-data`
- **Body**: Image file
- **Response**:
```json
{
  "name": "John Doe",
  "helmet": true,
  "vest": true,
  "timestamp": "2025-11-18T23:36:48.016Z"
}
```

#### 2. Clock Event
- **URL**: `POST /clock-event`
- **Content-Type**: `application/json`
- **Body**:
```json
{
  "workerName": "John Doe",
  "type": "clockIn",
  "timestamp": "2025-11-18T23:36:48.016Z",
  "helmet": true,
  "vest": true
}
```

## Configuration

### Backend URL
Update the base URL in `lib/services/api_service.dart`:
```dart
static const String _baseUrl = 'https://api.example.com';
```

### JWT Token
The app uses a placeholder JWT token. For production, implement proper authentication in `lib/services/auth_service.dart`.

## Getting Started

### Prerequisites
- Flutter SDK 3.7.0 or higher
- Dart SDK 3.7.0 or higher
- Android Studio / Xcode for mobile development
- Camera-enabled device or emulator

### Installation

1. Clone the repository:
```bash
git clone https://github.com/A-Malek-CH/PPE_system_app.git
cd PPE_system_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Platform-Specific Setup

#### Android
Camera permissions are automatically configured in `android/app/src/main/AndroidManifest.xml`

#### iOS
Camera usage description is configured in `ios/Runner/Info.plist`

## State Management

The app uses Riverpod for state management with the following providers:

- `authServiceProvider`: Provides JWT authentication
- `apiServiceProvider`: Provides API service instance
- `detectionControllerProvider`: Manages detection flow state

## Testing

Run tests:
```bash
flutter test
```

## Security Notes

⚠️ **Important**: This implementation uses placeholder values for demonstration:
- JWT token is hardcoded (implement proper auth for production)
- Backend URLs are placeholders (update with actual endpoints)
- No certificate pinning (add for production security)

## License

This project is licensed under the MIT License.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request
