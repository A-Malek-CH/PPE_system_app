import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../models/detection_result.dart';
import '../models/clock_event.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Provider for ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ApiService(authService: authService);
});

/// State for the detection flow
class DetectionState {
  final bool isCountingDown;
  final int countdown;
  final bool isProcessing;
  final DetectionResult? result;
  final String? error;
  final bool isClockingEvent;

  const DetectionState({
    this.isCountingDown = false,
    this.countdown = 5,
    this.isProcessing = false,
    this.result,
    this.error,
    this.isClockingEvent = false,
  });

  DetectionState copyWith({
    bool? isCountingDown,
    int? countdown,
    bool? isProcessing,
    DetectionResult? result,
    String? error,
    bool? isClockingEvent,
  }) {
    return DetectionState(
      isCountingDown: isCountingDown ?? this.isCountingDown,
      countdown: countdown ?? this.countdown,
      isProcessing: isProcessing ?? this.isProcessing,
      result: result ?? this.result,
      error: error ?? this.error,
      isClockingEvent: isClockingEvent ?? this.isClockingEvent,
    );
  }

  DetectionState clearError() {
    return DetectionState(
      isCountingDown: isCountingDown,
      countdown: countdown,
      isProcessing: isProcessing,
      result: result,
      error: null,
      isClockingEvent: isClockingEvent,
    );
  }

  DetectionState reset() {
    return const DetectionState();
  }
}

/// Controller for managing the detection flow
class DetectionController extends StateNotifier<DetectionState> {
  final ApiService _apiService;

  DetectionController(this._apiService) : super(const DetectionState());

  /// Starts the countdown before taking a picture
  Future<void> startCountdown() async {
    state = state.copyWith(isCountingDown: true, countdown: 5);

    // Countdown from 5 to 1
    for (int i = 5; i > 0; i--) {
      state = state.copyWith(countdown: i);
      await Future.delayed(const Duration(seconds: 1));
    }

    state = state.copyWith(isCountingDown: false, countdown: 0);
  }

  /// Captures the image and processes it through the API
  Future<void> captureAndAnalyze(CameraController cameraController) async {
    try {
      // Start countdown
      await startCountdown();

      // Capture the image
      final XFile imageFile = await cameraController.takePicture();
      
      // Start processing
      state = state.copyWith(isProcessing: true, error: null);

      // Send to API for analysis
      final result = await _apiService.analyzeImage(File(imageFile.path));

      // Update state with result
      state = state.copyWith(isProcessing: false, result: result);
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to capture or analyze image: $e',
      );
    }
  }

  /// Records a clock in/out event
  Future<bool> recordClockEvent(ClockEventType type) async {
    if (state.result == null) {
      state = state.copyWith(error: 'No detection result available');
      return false;
    }

    try {
      state = state.copyWith(isClockingEvent: true, error: null);

      final clockEvent = ClockEvent(
        workerName: state.result!.name,
        type: type,
        timestamp: DateTime.now().toIso8601String(),
        helmet: state.result!.helmet,
        vest: state.result!.vest,
      );

      final success = await _apiService.clockEvent(clockEvent);

      state = state.copyWith(isClockingEvent: false);

      if (!success) {
        state = state.copyWith(error: 'Failed to record clock event');
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isClockingEvent: false,
        error: 'Error recording clock event: $e',
      );
      return false;
    }
  }

  /// Resets the detection state
  void reset() {
    state = state.reset();
  }

  /// Clears the current error
  void clearError() {
    state = state.clearError();
  }

  /// Determines if it's morning (before 12 PM) or afternoon
  bool isMorning() {
    final hour = DateTime.now().hour;
    return hour < 12;
  }

  /// Returns the appropriate button text based on time of day
  String getClockButtonText() {
    return isMorning() ? 'Clock In' : 'Clock Out';
  }

  /// Returns the appropriate clock event type based on time of day
  ClockEventType getClockEventType() {
    return isMorning() ? ClockEventType.clockIn : ClockEventType.clockOut;
  }
}

/// Provider for DetectionController
final detectionControllerProvider =
    StateNotifierProvider<DetectionController, DetectionState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return DetectionController(apiService);
});
