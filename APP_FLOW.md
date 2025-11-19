# PPE Detection System - App Flow Diagram

This document provides a visual representation of the application flow.

## Complete User Journey

```
┌─────────────────────────────────────────────────────────────┐
│                    APP STARTS                                │
│                       ↓                                       │
│              ProviderScope Initialized                       │
│              GoRouter Configured                             │
│                       ↓                                       │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│                 CAMERA SCREEN                                │
│  ┌───────────────────────────────────────────────────┐      │
│  │                                                    │      │
│  │        📹  LIVE CAMERA PREVIEW                    │      │
│  │                                                    │      │
│  │                                                    │      │
│  │                                                    │      │
│  │                                                    │      │
│  │                                                    │      │
│  │                                                    │      │
│  │                                                    │      │
│  │              [Take Picture 📷]                     │      │
│  │                                                    │      │
│  └───────────────────────────────────────────────────┘      │
│                       ↓                                       │
│              User taps "Take Picture"                        │
│                       ↓                                       │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│              COUNTDOWN OVERLAY                               │
│  ┌───────────────────────────────────────────────────┐      │
│  │                                                    │      │
│  │                     ⏰                             │      │
│  │                     5                              │      │
│  │                                                    │      │
│  │                "Get ready..."                      │      │
│  │                                                    │      │
│  └───────────────────────────────────────────────────┘      │
│                       ↓                                       │
│          Countdown: 5 → 4 → 3 → 2 → 1                       │
│                       ↓                                       │
│                  📸 CAPTURE!                                 │
│                       ↓                                       │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│              PROCESSING SCREEN                               │
│  ┌───────────────────────────────────────────────────┐      │
│  │                                                    │      │
│  │                     ⌛                             │      │
│  │                                                    │      │
│  │             "Analyzing Image..."                   │      │
│  │                                                    │      │
│  │      "Please wait while we detect PPE"            │      │
│  │                                                    │      │
│  └───────────────────────────────────────────────────┘      │
│                       ↓                                       │
│         POST /analyze (multipart/form-data)                 │
│         Authorization: Bearer <JWT_TOKEN>                    │
│                       ↓                                       │
│              Backend processes image                         │
│                       ↓                                       │
│         Response: {name, helmet, vest, timestamp}           │
│                       ↓                                       │
└─────────────────────────────────────────────────────────────┘
                        ↓
         ┌──────────────┴──────────────┐
         │                             │
         ▼                             ▼
┌──────────────────┐         ┌──────────────────┐
│   COMPLIANT      │         │  NON-COMPLIANT   │
│                  │         │                  │
│ ✅ Recognized    │         │ ❌ Unknown OR    │
│ ✅ Helmet ON     │         │ ❌ No Helmet OR  │
│ ✅ Vest ON       │         │ ❌ No Vest       │
│                  │         │                  │
└────────┬─────────┘         └────────┬─────────┘
         │                             │
         ▼                             ▼
┌─────────────────────────────────────────────────────────────┐
│                  RESULT SCREEN                               │
│  ┌───────────────────────────────────────────────────┐      │
│  │                                                    │      │
│  │                     👤                             │      │
│  │                  John Doe                          │      │
│  │             Nov 18, 2025 - 08:00 AM               │      │
│  │                                                    │      │
│  ├───────────────────────────────────────────────────┤      │
│  │           PPE Equipment Status                    │      │
│  ├───────────────────────────────────────────────────┤      │
│  │  🏗️ Safety Helmet          ✅ / ❌              │      │
│  │  🦺 Safety Vest             ✅ / ❌              │      │
│  ├───────────────────────────────────────────────────┤      │
│  │                                                    │      │
│  │  IF COMPLIANT:                                    │      │
│  │  ┌─────────────────────────────────────┐         │      │
│  │  │   🌅 Clock In  / 🌆 Clock Out      │         │      │
│  │  └─────────────────────────────────────┘         │      │
│  │  ┌─────────────────────────────────────┐         │      │
│  │  │          Cancel                     │         │      │
│  │  └─────────────────────────────────────┘         │      │
│  │                                                    │      │
│  │  IF NON-COMPLIANT:                                │      │
│  │  ┌─────────────────────────────────────┐         │      │
│  │  │      🔄 Reset                       │         │      │
│  │  └─────────────────────────────────────┘         │      │
│  │                                                    │      │
│  └───────────────────────────────────────────────────┘      │
│                       ↓                                       │
└─────────────────────────────────────────────────────────────┘
         │                             │
         ▼                             ▼
┌──────────────────┐         ┌──────────────────┐
│   Clock In/Out   │         │      Reset       │
│                  │         │                  │
│ POST /clock-event│         │  No API call     │
│ Authorization:   │         │  Return to       │
│ Bearer <JWT>     │         │  Camera Screen   │
│                  │         │                  │
│ ✅ Success:      │         └────────┬─────────┘
│  Show message    │                  │
│  Return to Camera│                  │
│                  │                  │
│ ❌ Error:        │                  │
│  Show error      │                  │
│  Stay on Result  │                  │
│                  │                  │
└────────┬─────────┘                  │
         │                            │
         │                            │
         └────────────┬───────────────┘
                      ↓
          ┌───────────────────────┐
          │  Return to            │
          │  CAMERA SCREEN        │
          │  (Ready for next)     │
          └───────────────────────┘
                      │
                      └──────┐
                             │
                      ┌──────▼──────┐
                      │   LOOP      │
                      └─────────────┘
```

## State Transitions

### DetectionState Flow

```
INITIAL STATE
  isCountingDown: false
  countdown: 5
  isProcessing: false
  result: null
  error: null
  isClockingEvent: false
           ↓
    [Take Picture]
           ↓
COUNTDOWN STATE
  isCountingDown: true
  countdown: 5 → 4 → 3 → 2 → 1
           ↓
CAPTURE STATE
  isCountingDown: false
  countdown: 0
           ↓
PROCESSING STATE
  isProcessing: true
           ↓
     [API Call]
           ↓
  ┌────────┴────────┐
  ↓                 ↓
SUCCESS          ERROR
  isProcessing: false   isProcessing: false
  result: DetectionResult   error: "message"
  ↓                 ↓
RESULT STATE    ERROR STATE
           ↓
    [Clock Event]
           ↓
CLOCKING STATE
  isClockingEvent: true
           ↓
     [API Call]
           ↓
  ┌────────┴────────┐
  ↓                 ↓
SUCCESS          ERROR
  isClockingEvent: false   isClockingEvent: false
  ↓                 error: "message"
  ↓                 ↓
[Reset]          [Stay]
  ↓
INITIAL STATE
```

## API Call Flow

### Image Analysis

```
┌─────────────┐
│ User Action │
│ Take Picture│
└──────┬──────┘
       ↓
┌─────────────────────────┐
│ CameraController        │
│ .takePicture()          │
└──────┬──────────────────┘
       ↓
┌─────────────────────────┐
│ DetectionController     │
│ .captureAndAnalyze()    │
└──────┬──────────────────┘
       ↓
┌─────────────────────────┐
│ ApiService              │
│ .analyzeImage(file)     │
└──────┬──────────────────┘
       ↓
┌─────────────────────────────────────┐
│ HTTP Request                         │
│ POST https://api.example.com/analyze│
│                                      │
│ Headers:                             │
│   Authorization: Bearer <token>     │
│   Content-Type: multipart/form-data │
│                                      │
│ Body:                                │
│   image: [binary data]              │
└──────┬───────────────────────────────┘
       ↓
┌─────────────────────────┐
│ Backend Processing      │
│ • Image Analysis        │
│ • Face Recognition      │
│ • Helmet Detection      │
│ • Vest Detection        │
└──────┬──────────────────┘
       ↓
┌─────────────────────────────┐
│ JSON Response                │
│ {                            │
│   "name": "John Doe",        │
│   "helmet": true,            │
│   "vest": true,              │
│   "timestamp": "2025-11-18"  │
│ }                            │
└──────┬───────────────────────┘
       ↓
┌─────────────────────────┐
│ DetectionResult.fromJson│
└──────┬──────────────────┘
       ↓
┌─────────────────────────┐
│ State Update            │
│ result = DetectionResult│
└──────┬──────────────────┘
       ↓
┌─────────────────────────┐
│ Navigate to Result      │
└─────────────────────────┘
```

### Clock Event

```
┌─────────────┐
│ User Action │
│ Clock In/Out│
└──────┬──────┘
       ↓
┌─────────────────────────┐
│ DetectionController     │
│ .recordClockEvent(type) │
└──────┬──────────────────┘
       ↓
┌─────────────────────────┐
│ Create ClockEvent       │
│ from DetectionResult    │
└──────┬──────────────────┘
       ↓
┌─────────────────────────┐
│ ApiService              │
│ .clockEvent(event)      │
└──────┬──────────────────┘
       ↓
┌──────────────────────────────────────┐
│ HTTP Request                          │
│ POST https://api.example.com/clock-event│
│                                       │
│ Headers:                              │
│   Authorization: Bearer <token>      │
│   Content-Type: application/json     │
│                                       │
│ Body:                                 │
│ {                                     │
│   "workerName": "John Doe",           │
│   "type": "clockIn",                  │
│   "timestamp": "2025-11-18T08:00:00", │
│   "helmet": true,                     │
│   "vest": true                        │
│ }                                     │
└──────┬────────────────────────────────┘
       ↓
┌─────────────────────────┐
│ Backend Processing      │
│ • Validate request      │
│ • Store event           │
│ • Update attendance     │
└──────┬──────────────────┘
       ↓
┌─────────────────────────┐
│ JSON Response            │
│ {                        │
│   "success": true,       │
│   "eventId": "evt_123"   │
│ }                        │
└──────┬──────────────────┘
       ↓
┌─────────────────────────┐
│ Check Success           │
│ return true/false       │
└──────┬──────────────────┘
       ↓
  ┌────┴────┐
  ↓         ↓
SUCCESS   ERROR
  ↓         ↓
┌─────┐   ┌─────┐
│Reset│   │Show │
│State│   │Error│
└──┬──┘   └──┬──┘
   ↓         ↓
  [To Camera] [Stay]
```

## Time-Based Logic

```
┌─────────────────────────┐
│ Current Time Check      │
│ DateTime.now().hour     │
└──────┬──────────────────┘
       │
  ┌────┴────┐
  ↓         ↓
hour < 12   hour ≥ 12
  ↓         ↓
MORNING   AFTERNOON
  ↓         ↓
"Clock In" "Clock Out"
  ↓         ↓
ClockEventType.clockIn
ClockEventType.clockOut
```

## Compliance Decision Tree

```
                ┌─────────────────┐
                │ Detection Result│
                └────────┬────────┘
                         │
                   ┌─────┴─────┐
                   │           │
            name == "Unknown"? │
                   │           │
              ┌────┴────┐      │
              ↓         ↓      │
             YES       NO      │
              │         │      │
              │    ┌────┴───┐  │
              │    │        │  │
              │  helmet?    │  │
              │    │        │  │
              │  ┌─┴─┐      │  │
              │  ↓   ↓      │  │
              │ YES  NO     │  │
              │  │   │      │  │
              │  │   └──────┼──┼──┐
              │  │          │  │  │
              │  │    ┌─────┴──┘  │
              │  │    │           │
              │  │   vest?        │
              │  │    │           │
              │  │  ┌─┴─┐         │
              │  │  ↓   ↓         │
              │  │ YES  NO        │
              │  │  │   │         │
              │  │  │   └─────────┼──┐
              ↓  ↓  ↓             ↓  ↓
         ┌─────────────┐    ┌──────────────┐
         │NON-COMPLIANT│    │  COMPLIANT   │
         │             │    │              │
         │Show "Reset" │    │Show "Clock   │
         │Button       │    │In/Out" Button│
         │             │    │              │
         │Error Message│    │Success Banner│
         └─────────────┘    └──────────────┘
```

## Error Handling Flow

```
┌─────────────────┐
│   Operation     │
└────────┬────────┘
         │
    ┌────┴────┐
    │  Try    │
    └────┬────┘
         │
    ┌────┴────────────┐
    │                 │
    ↓                 ↓
 SUCCESS           ERROR
    │                 │
    │            ┌────┴────┐
    │            │         │
    │       DioException  Other
    │            │         │
    │       ┌────┴────┐    │
    │       │         │    │
    │    Network  Timeout  │
    │       │         │    │
    │       │    Parse     │
    │       │    Error     │
    │       └────┬────┘    │
    │            │         │
    │       ┌────┴─────────┘
    │       │
    │   Set Error
    │   in State
    │       │
    │   ┌───┴───┐
    │   │       │
    └───┤Display│
        │SnackBar
        └───┬───┘
            │
        User Action
            │
      ┌─────┴─────┐
      ↓           ↓
    Retry       Go Back
```

## Navigation Flow

```
┌──────────────┐
│   Route: /   │  ← Initial Route
│ CameraScreen │
└──────┬───────┘
       │ context.push('/processing')
       ↓
┌──────────────────┐
│  Route: /processing
│ ProcessingScreen │
└──────┬───────────┘
       │ context.pushReplacement('/result')
       ↓
┌──────────────┐
│Route: /result│
│ ResultScreen │
└──────┬───────┘
       │ context.go('/')
       ↓
┌──────────────┐
│   Route: /   │
│ CameraScreen │  ← Back to start
└──────────────┘
```

## Summary

This app flow provides:

1. **Clear User Journey**: Camera → Countdown → Capture → Process → Result → Action
2. **Smart Decision Making**: Compliance-based button display
3. **Time-Aware Logic**: Morning clock-in vs afternoon clock-out
4. **Robust Error Handling**: Multiple error paths with user feedback
5. **Seamless Navigation**: Automatic transitions between screens
6. **State Management**: Predictable state transitions throughout

The flow is designed to be intuitive, efficient, and fail-safe for production use.
