import 'dart:async';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Authentication state
class AuthState {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Authentication provider (simplified version)
class AuthProvider {
  final AuthService _authService;
  AuthState _state = const AuthState();
  final StreamController<AuthState> _controller =
      StreamController<AuthState>.broadcast();

  AuthProvider(this._authService);

  AuthState get state => _state;
  Stream<AuthState> get stream => _controller.stream;

  void _updateState(AuthState newState) {
    _state = newState;
    _controller.add(_state);
  }

  Future<void> signIn(String email, String password) async {
    _updateState(_state.copyWith(isLoading: true, error: null));

    try {
      final userId = await _authService.signInWithEmail(email, password);
      if (userId != null) {
        final user = User(
          id: userId,
          email: email,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isEmailVerified: true,
        );
        _updateState(AuthState(isAuthenticated: true, user: user));
      }
    } catch (e) {
      _updateState(_state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> signUp(String email, String password) async {
    _updateState(_state.copyWith(isLoading: true, error: null));

    try {
      final userId = await _authService.signUpWithEmail(email, password);
      if (userId != null) {
        final user = User(
          id: userId,
          email: email,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _updateState(AuthState(isAuthenticated: true, user: user));
      }
    } catch (e) {
      _updateState(_state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _updateState(const AuthState());
  }

  void dispose() {
    _controller.close();
  }
}
