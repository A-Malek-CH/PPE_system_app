/// Service for handling authentication and JWT token management
class AuthService {
  // Placeholder JWT token for demonstration purposes
  static const String _placeholderToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';

  /// Returns the JWT token to be used in API requests
  /// In a real application, this would fetch from secure storage or refresh expired tokens
  String getToken() {
    return _placeholderToken;
  }

  /// Returns the authorization header value with Bearer token
  String getAuthorizationHeader() {
    return 'Bearer ${getToken()}';
  }
}
