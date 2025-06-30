import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthState _state = AuthState.initial;
  User? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated && _currentUser != null;
  bool get isUnauthenticated => _state == AuthState.unauthenticated;

  // Initialize authentication state
  Future<void> initialize() async {
    _setState(AuthState.loading);
    
    try {
      await _authService.initialize();
      
      if (await _authService.isSessionValid()) {
        _currentUser = await _authService.getCurrentUser();
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Failed to initialize authentication: ${e.toString()}');
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      if (result.success && result.user != null) {
        _currentUser = result.user;
        _setState(AuthState.authenticated);
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      if (result.success && result.user != null) {
        // Auto-login after successful registration
        final loginResult = await _authService.login(
          email: email,
          password: password,
        );
        
        if (loginResult.success && loginResult.user != null) {
          _currentUser = loginResult.user;
          _setState(AuthState.authenticated);
          _setLoading(false);
          return true;
        }
      }
      
      _setError(result.error ?? 'Registration failed');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
      _currentUser = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Update profile
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return false;
    
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        profileImageUrl: profileImageUrl,
      );

      if (result.success && result.user != null) {
        _currentUser = result.user;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(result.error ?? 'Failed to update profile');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (result.success) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Failed to change password');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to change password: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount(String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.deleteAccount(password);

      if (result.success) {
        _currentUser = null;
        _setState(AuthState.unauthenticated);
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Failed to delete account');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete account: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (_state != AuthState.authenticated) return;
    
    try {
      _currentUser = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh user data: ${e.toString()}');
    }
  }

  // Private helper methods
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _state = AuthState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = _currentUser != null 
          ? AuthState.authenticated 
          : AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // Clear error manually
  void clearError() {
    _clearError();
  }

  // Check if email exists (for registration validation)
  Future<bool> emailExists(String email) async {
    try {
      // This would typically be an API call
      // For now, we'll simulate by trying to get users
      return false; // Simplified for demo
    } catch (e) {
      return false;
    }
  }
}
