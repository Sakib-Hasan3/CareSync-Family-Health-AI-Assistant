import 'dart:async';

/// Authentication service interface
abstract class AuthService {
  Future<String?> signInWithEmail(String email, String password);
  Future<String?> signUpWithEmail(String email, String password);
  Future<String?> signInWithGoogle();
  Future<void> signOut();
  Future<bool> isSignedIn();
  Future<String?> getCurrentUserId();
  Future<void> resetPassword(String email);
  Stream<bool> get authStateChanges;
}

/// Default implementation of AuthService
class AuthServiceImpl implements AuthService {
  // This would typically use Firebase Auth or similar
  String? _currentUserId;
  final StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();

  @override
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Basic validation
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      // Mock successful login
      _currentUserId = 'user_${email.hashCode}';
      _authStateController.add(true);
      return _currentUserId;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<String?> signUpWithEmail(String email, String password) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Basic validation
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Mock successful registration
      _currentUserId = 'user_${email.hashCode}';
      _authStateController.add(true);
      return _currentUserId;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<String?> signInWithGoogle() async {
    try {
      // Simulate Google Sign-In
      await Future.delayed(const Duration(seconds: 3));

      // Mock successful Google login
      _currentUserId = 'google_user_${DateTime.now().millisecondsSinceEpoch}';
      _authStateController.add(true);
      return _currentUserId;
    } catch (e) {
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    _currentUserId = null;
    _authStateController.add(false);
  }

  @override
  Future<bool> isSignedIn() async {
    return _currentUserId != null;
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _currentUserId;
  }

  @override
  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      throw Exception('Email is required');
    }

    // Simulate password reset email
    await Future.delayed(const Duration(seconds: 1));
    // In real implementation, this would trigger a password reset email
  }

  @override
  Stream<bool> get authStateChanges => _authStateController.stream;

  void dispose() {
    _authStateController.close();
  }
}
