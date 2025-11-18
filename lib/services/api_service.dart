import 'dart:io';
import 'package:dio/dio.dart';
import '../models/detection_result.dart';
import '../models/clock_event.dart';
import 'auth_service.dart';

/// Service for handling API calls to the backend
class ApiService {
  late final Dio _dio;
  final AuthService _authService;

  // Placeholder backend URLs - should be configured based on environment
  static const String _baseUrl = 'https://api.example.com';
  static const String _analyzeEndpoint = '/analyze';
  static const String _clockEventEndpoint = '/clock-event';

  ApiService({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptor to log requests and responses
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  /// Analyzes an image file and returns the detection result
  /// 
  /// [imageFile] - The captured image file to analyze
  /// Returns a [DetectionResult] with worker name, helmet status, vest status, and timestamp
  /// Throws [DioException] if the request fails
  Future<DetectionResult> analyzeImage(File imageFile) async {
    try {
      // Create multipart form data
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'capture_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      // Send POST request with JWT token
      final response = await _dio.post(
        _analyzeEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': _authService.getAuthorizationHeader(),
          },
          contentType: 'multipart/form-data',
        ),
      );

      // Parse response and return DetectionResult
      if (response.statusCode == 200 || response.statusCode == 201) {
        return DetectionResult.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to analyze image: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Rethrow DioException or wrap other exceptions
      if (e is DioException) {
        rethrow;
      }
      throw DioException(
        requestOptions: RequestOptions(path: _analyzeEndpoint),
        error: 'Error analyzing image: $e',
      );
    }
  }

  /// Sends a clock in/out event to the backend
  /// 
  /// [clockEvent] - The clock event to send
  /// Returns true if the event was successfully recorded
  /// Throws [DioException] if the request fails
  Future<bool> clockEvent(ClockEvent clockEvent) async {
    try {
      // Send POST request with JWT token
      final response = await _dio.post(
        _clockEventEndpoint,
        data: clockEvent.toJson(),
        options: Options(
          headers: {
            'Authorization': _authService.getAuthorizationHeader(),
          },
        ),
      );

      // Check if request was successful
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // Rethrow DioException or wrap other exceptions
      if (e is DioException) {
        rethrow;
      }
      throw DioException(
        requestOptions: RequestOptions(path: _clockEventEndpoint),
        error: 'Error recording clock event: $e',
      );
    }
  }

  /// Updates the base URL for the API
  /// Useful for switching between development, staging, and production environments
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }
}
