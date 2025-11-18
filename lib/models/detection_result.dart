/// Model class representing the detection result from the backend API
class DetectionResult {
  final String name;
  final bool helmet;
  final bool vest;
  final String timestamp;

  const DetectionResult({
    required this.name,
    required this.helmet,
    required this.vest,
    required this.timestamp,
  });

  /// Factory constructor to create a DetectionResult from JSON
  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      name: json['name'] as String? ?? 'Unknown',
      helmet: json['helmet'] as bool? ?? false,
      vest: json['vest'] as bool? ?? false,
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  /// Converts the DetectionResult to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'helmet': helmet,
      'vest': vest,
      'timestamp': timestamp,
    };
  }

  /// Returns true if the worker is recognized (not "Unknown")
  bool get isRecognized => name.toLowerCase() != 'unknown';

  /// Returns true if all safety requirements are met
  bool get isCompliant => isRecognized && helmet && vest;

  @override
  String toString() {
    return 'DetectionResult(name: $name, helmet: $helmet, vest: $vest, timestamp: $timestamp)';
  }
}
