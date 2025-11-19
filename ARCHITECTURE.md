# Architecture Documentation

This document explains the architecture and design decisions of the PPE Detection System.

## System Overview

The PPE Detection System is a Flutter mobile application that follows **Clean Architecture** principles with clear separation between UI, business logic, and data layers.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                     Presentation Layer                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   Camera    │  │ Processing  │  │   Result    │    │
│  │   Screen    │  │   Screen    │  │   Screen    │    │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘    │
│         │                 │                 │            │
│         └─────────────────┴─────────────────┘            │
│                           │                              │
│                  ┌────────▼────────┐                     │
│                  │   Widgets       │                     │
│                  │  (Reusable UI)  │                     │
│                  └─────────────────┘                     │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│                   State Management Layer                 │
│              (Riverpod StateNotifier)                    │
│                                                          │
│          ┌────────────────────────────────┐             │
│          │   DetectionController          │             │
│          │  • Manages app state           │             │
│          │  • Coordinates countdown       │             │
│          │  • Handles camera capture      │             │
│          │  • Processes API responses     │             │
│          │  • Determines clock button     │             │
│          └───────────┬────────────────────┘             │
└──────────────────────┼──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                     Business Logic Layer                 │
│                                                          │
│  ┌──────────────────┐         ┌──────────────────┐     │
│  │   AuthService    │         │   ApiService     │     │
│  │  • JWT token     │         │  • analyzeImage  │     │
│  │  • Auth header   │────────▶│  • clockEvent    │     │
│  └──────────────────┘         │  • Dio HTTP      │     │
│                                └──────────────────┘     │
└──────────────────────────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                      Data Layer                          │
│                                                          │
│  ┌──────────────────┐         ┌──────────────────┐     │
│  │ DetectionResult  │         │   ClockEvent     │     │
│  │  • name          │         │  • workerName    │     │
│  │  • helmet        │         │  • type          │     │
│  │  • vest          │         │  • timestamp     │     │
│  │  • timestamp     │         │  • helmet/vest   │     │
│  └──────────────────┘         └──────────────────┘     │
│                                                          │
│  • JSON serialization/deserialization                   │
│  • Data validation                                      │
│  • Business rules (isCompliant, isRecognized)          │
└──────────────────────────────────────────────────────────┘
                       │
                       ▼
              ┌────────────────┐
              │  Backend API   │
              │  • POST /analyze     │
              │  • POST /clock-event │
              └────────────────┘
```

## Layer Responsibilities

### 1. Presentation Layer (UI)

**Location**: `lib/screens/`, `lib/widgets/`

**Responsibility**: Display information and handle user interactions

**Components**:
- **CameraScreen**: Live camera preview, countdown overlay, capture button
- **ProcessingScreen**: Loading indicator during API calls
- **ResultScreen**: Display detection results and action buttons
- **StatusIndicator**: Reusable widget for PPE status display

**Key Features**:
- Material 3 design system
- Responsive layouts
- Dark mode support
- Error handling UI

### 2. State Management Layer

**Location**: `lib/controllers/`

**Responsibility**: Manage application state and coordinate between UI and business logic

**Component**: **DetectionController**

**State Properties**:
```dart
class DetectionState {
  final bool isCountingDown;
  final int countdown;
  final bool isProcessing;
  final DetectionResult? result;
  final String? error;
  final bool isClockingEvent;
}
```

**Key Methods**:
- `startCountdown()`: Manages 5-second countdown
- `captureAndAnalyze()`: Coordinates camera capture and API call
- `recordClockEvent()`: Sends clock in/out event
- `reset()`: Returns to initial state

### 3. Business Logic Layer

**Location**: `lib/services/`

**Responsibility**: Handle business rules and external communications

**Components**:

#### AuthService
- Provides JWT token
- Formats authorization headers
- (Future: Token refresh, secure storage)

#### ApiService
- HTTP client using Dio
- Multipart file upload for images
- JSON data serialization
- Request/response logging
- Error handling

**Network Configuration**:
- Base URL: Configurable
- Timeout: 30 seconds
- Retry: Not implemented (add if needed)
- Interceptors: Logging enabled

### 4. Data Layer

**Location**: `lib/models/`

**Responsibility**: Define data structures and validation rules

**Components**:

#### DetectionResult
```dart
{
  name: String,
  helmet: bool,
  vest: bool,
  timestamp: String
}
```

**Business Rules**:
- `isRecognized`: name != "Unknown"
- `isCompliant`: isRecognized && helmet && vest

#### ClockEvent
```dart
{
  workerName: String,
  type: ClockEventType,
  timestamp: String,
  helmet: bool,
  vest: bool
}
```

## Data Flow

### Capture and Detection Flow

```
User taps "Take Picture"
         │
         ▼
Controller.captureAndAnalyze()
         │
         ├──▶ startCountdown() ──▶ UI shows 5,4,3,2,1
         │
         ├──▶ cameraController.takePicture()
         │
         ├──▶ Navigate to ProcessingScreen
         │
         ├──▶ ApiService.analyzeImage(file)
         │         │
         │         ├──▶ Add JWT header
         │         ├──▶ Create multipart form
         │         └──▶ POST to /analyze
         │
         ├──▶ Parse DetectionResult from JSON
         │
         ├──▶ Update state with result
         │
         └──▶ Navigate to ResultScreen
                   │
                   ▼
            Display results and button
```

### Clock Event Flow

```
User taps "Clock In/Out"
         │
         ▼
Controller.recordClockEvent(type)
         │
         ├──▶ Create ClockEvent from current state
         │
         ├──▶ ApiService.clockEvent(event)
         │         │
         │         ├──▶ Add JWT header
         │         ├──▶ Serialize to JSON
         │         └──▶ POST to /clock-event
         │
         ├──▶ Check success response
         │
         ├──▶ Show success message
         │
         ├──▶ Controller.reset()
         │
         └──▶ Navigate to CameraScreen
```

## State Management Choice: Riverpod

### Why Riverpod?

1. **Better than Provider**: Compile-time safety, no BuildContext needed
2. **Null Safety**: First-class null safety support
3. **Testing**: Easy to mock and test
4. **Performance**: Rebuilds only what changed
5. **Flexibility**: Works with any architecture

### Provider Structure

```dart
// Service Providers (singleton)
final authServiceProvider = Provider<AuthService>(...);
final apiServiceProvider = Provider<ApiService>(...);

// State Provider (with business logic)
final detectionControllerProvider = 
    StateNotifierProvider<DetectionController, DetectionState>(...);
```

## Navigation: GoRouter

### Why GoRouter?

1. **Declarative**: Routes defined in one place
2. **Type Safe**: Path constants prevent typos
3. **Deep Linking**: Easy to add later
4. **Web Support**: Works for web if needed

### Route Structure

```dart
GoRouter(
  routes: [
    GoRoute(path: '/', builder: CameraScreen),
    GoRoute(path: '/processing', builder: ProcessingScreen),
    GoRoute(path: '/result', builder: ResultScreen),
  ]
)
```

## Design Patterns

### 1. Repository Pattern (Simplified)
- `ApiService` acts as repository for backend data
- Could be extended with caching layer

### 2. State Pattern
- Different states drive different UI behaviors
- State machine: Camera → Countdown → Processing → Result

### 3. Factory Pattern
- Model classes use factory constructors for JSON parsing
- `DetectionResult.fromJson()`, `ClockEvent.fromJson()`

### 4. Provider Pattern
- Dependency injection through Riverpod providers
- Loose coupling between components

## Error Handling Strategy

### Network Errors
- Caught in `ApiService`
- Wrapped in `DioException`
- Propagated to controller
- Displayed in UI with SnackBar

### Camera Errors
- Caught during initialization
- Displayed on CameraScreen
- User cannot proceed without camera

### State Errors
- Null checks for `DetectionResult`
- Fallback navigation if state invalid
- Error messages in state object

## Performance Considerations

### Image Processing
- Images captured at high resolution
- Sent immediately (no local processing)
- Backend handles heavy computation

### State Updates
- Minimal rebuilds with Riverpod
- Only affected widgets rebuild
- Countdown uses efficient timer

### Memory Management
- Images not stored in memory
- File paths used instead
- Proper disposal of camera controller

## Security Architecture

### Current Implementation
- Placeholder JWT token (development only)
- HTTPS enforcement (in constants)
- No sensitive data stored locally

### Production Requirements
1. **Authentication**:
   - Real JWT with refresh tokens
   - Secure token storage (flutter_secure_storage)
   - Token expiration handling

2. **Network Security**:
   - Certificate pinning
   - HTTPS only
   - Request signing

3. **Data Protection**:
   - Encrypt local data
   - Secure image storage
   - Clear sensitive data on logout

## Testing Strategy

### Unit Tests
- Models: JSON parsing, business rules
- Services: Auth header format
- Controllers: State transitions (to be added)

### Widget Tests
- Screen rendering
- User interactions
- Navigation flows

### Integration Tests
- Full flow: Camera → Capture → Process → Result
- Mock backend responses
- Error scenarios

## Future Enhancements

### Planned Features
1. **Offline Mode**: Queue events when offline
2. **Image History**: Store past detections
3. **Analytics**: Track compliance rates
4. **Notifications**: Remind about clock out
5. **Multi-language**: i18n support

### Architecture Extensions
1. **Repository Layer**: Add between service and controller
2. **Use Cases**: Extract business logic to use case classes
3. **Caching**: Add local database (Hive/Drift)
4. **Logging**: Structured logging service
5. **Analytics**: Event tracking service

## Scalability

### Current Capacity
- Handles single user session
- Sequential image processing
- Stateless backend interaction

### Scaling Considerations
- Add request queuing for multiple captures
- Implement retry mechanism
- Add connection pooling
- Consider batch processing

## Maintenance

### Code Organization
- Follow existing folder structure
- One class per file
- Clear naming conventions
- Comprehensive documentation

### Updates
- Keep dependencies updated
- Follow Flutter best practices
- Maintain test coverage
- Update documentation with changes

## Conclusion

This architecture provides:
- ✅ Clean separation of concerns
- ✅ Easy to test and maintain
- ✅ Scalable and extensible
- ✅ Type-safe and null-safe
- ✅ Modern Flutter best practices

The system is production-ready with proper backend integration and security enhancements.
