/// Enum representing the type of clock event
enum ClockEventType {
  clockIn,
  clockOut,
}

/// Model class representing a clock in/out event
class ClockEvent {
  final String workerName;
  final ClockEventType type;
  final String timestamp;
  final bool helmet;
  final bool vest;

  const ClockEvent({
    required this.workerName,
    required this.type,
    required this.timestamp,
    required this.helmet,
    required this.vest,
  });

  /// Factory constructor to create a ClockEvent from JSON
  factory ClockEvent.fromJson(Map<String, dynamic> json) {
    return ClockEvent(
      workerName: json['workerName'] as String? ?? '',
      type: json['type'] == 'clockIn' ? ClockEventType.clockIn : ClockEventType.clockOut,
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      helmet: json['helmet'] as bool? ?? false,
      vest: json['vest'] as bool? ?? false,
    );
  }

  /// Converts the ClockEvent to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'workerName': workerName,
      'type': type == ClockEventType.clockIn ? 'clockIn' : 'clockOut',
      'timestamp': timestamp,
      'helmet': helmet,
      'vest': vest,
    };
  }

  @override
  String toString() {
    return 'ClockEvent(workerName: $workerName, type: $type, timestamp: $timestamp, helmet: $helmet, vest: $vest)';
  }
}
