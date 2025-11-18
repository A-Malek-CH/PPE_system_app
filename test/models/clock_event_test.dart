import 'package:flutter_test/flutter_test.dart';
import 'package:safety_app/models/clock_event.dart';

void main() {
  group('ClockEvent', () {
    test('fromJson creates valid ClockEvent for clockIn', () {
      final json = {
        'workerName': 'John Doe',
        'type': 'clockIn',
        'timestamp': '2025-11-18T23:36:48.016Z',
        'helmet': true,
        'vest': true,
      };

      final event = ClockEvent.fromJson(json);

      expect(event.workerName, 'John Doe');
      expect(event.type, ClockEventType.clockIn);
      expect(event.timestamp, '2025-11-18T23:36:48.016Z');
      expect(event.helmet, true);
      expect(event.vest, true);
    });

    test('fromJson creates valid ClockEvent for clockOut', () {
      final json = {
        'workerName': 'Jane Smith',
        'type': 'clockOut',
        'timestamp': '2025-11-18T17:00:00.000Z',
        'helmet': true,
        'vest': true,
      };

      final event = ClockEvent.fromJson(json);

      expect(event.workerName, 'Jane Smith');
      expect(event.type, ClockEventType.clockOut);
      expect(event.timestamp, '2025-11-18T17:00:00.000Z');
      expect(event.helmet, true);
      expect(event.vest, true);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final event = ClockEvent.fromJson(json);

      expect(event.workerName, '');
      expect(event.type, ClockEventType.clockOut);
      expect(event.timestamp, isNotEmpty);
      expect(event.helmet, false);
      expect(event.vest, false);
    });

    test('toJson converts ClockEvent to map for clockIn', () {
      final event = ClockEvent(
        workerName: 'John Doe',
        type: ClockEventType.clockIn,
        timestamp: '2025-11-18T23:36:48.016Z',
        helmet: true,
        vest: true,
      );

      final json = event.toJson();

      expect(json['workerName'], 'John Doe');
      expect(json['type'], 'clockIn');
      expect(json['timestamp'], '2025-11-18T23:36:48.016Z');
      expect(json['helmet'], true);
      expect(json['vest'], true);
    });

    test('toJson converts ClockEvent to map for clockOut', () {
      final event = ClockEvent(
        workerName: 'Jane Smith',
        type: ClockEventType.clockOut,
        timestamp: '2025-11-18T17:00:00.000Z',
        helmet: true,
        vest: false,
      );

      final json = event.toJson();

      expect(json['workerName'], 'Jane Smith');
      expect(json['type'], 'clockOut');
      expect(json['timestamp'], '2025-11-18T17:00:00.000Z');
      expect(json['helmet'], true);
      expect(json['vest'], false);
    });
  });
}
