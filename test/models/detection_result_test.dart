import 'package:flutter_test/flutter_test.dart';
import 'package:safety_app/models/detection_result.dart';

void main() {
  group('DetectionResult', () {
    test('fromJson creates valid DetectionResult', () {
      final json = {
        'name': 'John Doe',
        'helmet': true,
        'vest': true,
        'timestamp': '2025-11-18T23:36:48.016Z',
      };

      final result = DetectionResult.fromJson(json);

      expect(result.name, 'John Doe');
      expect(result.helmet, true);
      expect(result.vest, true);
      expect(result.timestamp, '2025-11-18T23:36:48.016Z');
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final result = DetectionResult.fromJson(json);

      expect(result.name, 'Unknown');
      expect(result.helmet, false);
      expect(result.vest, false);
      expect(result.timestamp, isNotEmpty);
    });

    test('isRecognized returns true for known worker', () {
      final result = DetectionResult(
        name: 'John Doe',
        helmet: true,
        vest: true,
        timestamp: '2025-11-18T23:36:48.016Z',
      );

      expect(result.isRecognized, true);
    });

    test('isRecognized returns false for unknown worker', () {
      final result = DetectionResult(
        name: 'Unknown',
        helmet: true,
        vest: true,
        timestamp: '2025-11-18T23:36:48.016Z',
      );

      expect(result.isRecognized, false);
    });

    test('isCompliant returns true when all requirements met', () {
      final result = DetectionResult(
        name: 'John Doe',
        helmet: true,
        vest: true,
        timestamp: '2025-11-18T23:36:48.016Z',
      );

      expect(result.isCompliant, true);
    });

    test('isCompliant returns false when helmet missing', () {
      final result = DetectionResult(
        name: 'John Doe',
        helmet: false,
        vest: true,
        timestamp: '2025-11-18T23:36:48.016Z',
      );

      expect(result.isCompliant, false);
    });

    test('isCompliant returns false when vest missing', () {
      final result = DetectionResult(
        name: 'John Doe',
        helmet: true,
        vest: false,
        timestamp: '2025-11-18T23:36:48.016Z',
      );

      expect(result.isCompliant, false);
    });

    test('isCompliant returns false for unknown worker', () {
      final result = DetectionResult(
        name: 'Unknown',
        helmet: true,
        vest: true,
        timestamp: '2025-11-18T23:36:48.016Z',
      );

      expect(result.isCompliant, false);
    });

    test('toJson converts DetectionResult to map', () {
      final result = DetectionResult(
        name: 'John Doe',
        helmet: true,
        vest: true,
        timestamp: '2025-11-18T23:36:48.016Z',
      );

      final json = result.toJson();

      expect(json['name'], 'John Doe');
      expect(json['helmet'], true);
      expect(json['vest'], true);
      expect(json['timestamp'], '2025-11-18T23:36:48.016Z');
    });
  });
}
