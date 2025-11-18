import 'package:flutter_test/flutter_test.dart';
import 'package:safety_app/services/auth_service.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('getToken returns a non-empty token', () {
      final token = authService.getToken();
      expect(token, isNotEmpty);
    });

    test('getAuthorizationHeader returns Bearer token format', () {
      final header = authService.getAuthorizationHeader();
      expect(header, startsWith('Bearer '));
      expect(header.length, greaterThan(7));
    });

    test('getAuthorizationHeader contains the token', () {
      final token = authService.getToken();
      final header = authService.getAuthorizationHeader();
      expect(header, 'Bearer $token');
    });
  });
}
