import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _sessionTokenKey = 'session_token';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SharedPreferences? _prefs;

  // Initialize the service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Hash password for security
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Generate session token
  String _generateSessionToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  // Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate password strength
  bool _isValidPassword(String password) {
    // At least 6 characters, contains letter and number
    return password.length >= 6 && 
           RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password);
  }

  // Get all registered users
  Future<List<User>> _getRegisteredUsers() async {
    await initialize();
    final usersJson = _prefs!.getString(_usersKey);
    if (usersJson == null) return [];
    
    final List<dynamic> usersList = jsonDecode(usersJson);
    return usersList.map((json) => User.fromJson(json)).toList();
  }

  // Save registered users
  Future<void> _saveRegisteredUsers(List<User> users) async {
    await initialize();
    final usersJson = jsonEncode(users.map((user) => user.toJson()).toList());
    await _prefs!.setString(_usersKey, usersJson);
  }

  // Register new user
  Future<AuthResult> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // Validate input
      if (!_isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }
      
      if (!_isValidPassword(password)) {
        return AuthResult.failure('Password must be at least 6 characters with letters and numbers');
      }
      
      if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
        return AuthResult.failure('First name and last name are required');
      }

      // Check if user already exists
      final existingUsers = await _getRegisteredUsers();
      if (existingUsers.any((user) => user.email.toLowerCase() == email.toLowerCase())) {
        return AuthResult.failure('An account with this email already exists');
      }

      // Create new user
      final newUser = User(
        email: email.toLowerCase(),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isEmailVerified: true, // For demo purposes
      );

      // Save password hash (in real app, this would be on server)
      final passwordHash = _hashPassword(password);
      await _prefs!.setString('password_${newUser.id}', passwordHash);

      // Add to registered users
      existingUsers.add(newUser);
      await _saveRegisteredUsers(existingUsers);

      return AuthResult.success(newUser);
    } catch (e) {
      return AuthResult.failure('Registration failed: ${e.toString()}');
    }
  }

  // Login user
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      if (!_isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }

      if (password.isEmpty) {
        return AuthResult.failure('Password is required');
      }

      // Find user
      final users = await _getRegisteredUsers();
      final user = users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
        orElse: () => throw Exception('User not found'),
      );

      // Verify password
      final storedPasswordHash = _prefs!.getString('password_${user.id}');
      final inputPasswordHash = _hashPassword(password);
      
      if (storedPasswordHash != inputPasswordHash) {
        return AuthResult.failure('Invalid email or password');
      }

      // Update last login time
      final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
      final userIndex = users.indexWhere((u) => u.id == user.id);
      users[userIndex] = updatedUser;
      await _saveRegisteredUsers(users);

      // Generate session token
      final sessionToken = _generateSessionToken();
      
      // Save login state
      await _prefs!.setBool(_isLoggedInKey, true);
      await _prefs!.setString(_currentUserKey, jsonEncode(updatedUser.toJson()));
      await _prefs!.setString(_sessionTokenKey, sessionToken);

      return AuthResult.success(updatedUser, sessionToken);
    } catch (e) {
      return AuthResult.failure('Invalid email or password');
    }
  }

  // Logout user
  Future<void> logout() async {
    await initialize();
    await _prefs!.setBool(_isLoggedInKey, false);
    await _prefs!.remove(_currentUserKey);
    await _prefs!.remove(_sessionTokenKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    await initialize();
    return _prefs!.getBool(_isLoggedInKey) ?? false;
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    await initialize();
    final userJson = _prefs!.getString(_currentUserKey);
    if (userJson == null) return null;
    
    try {
      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<AuthResult> updateProfile({
    required String firstName,
    required String lastName,
    String? profileImageUrl,
  }) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return AuthResult.failure('No user logged in');
      }

      if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
        return AuthResult.failure('First name and last name are required');
      }

      // Update user
      final updatedUser = currentUser.copyWith(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        profileImageUrl: profileImageUrl,
      );

      // Update in storage
      final users = await _getRegisteredUsers();
      final userIndex = users.indexWhere((u) => u.id == currentUser.id);
      if (userIndex != -1) {
        users[userIndex] = updatedUser;
        await _saveRegisteredUsers(users);
      }

      // Update current user
      await _prefs!.setString(_currentUserKey, jsonEncode(updatedUser.toJson()));

      return AuthResult.success(updatedUser);
    } catch (e) {
      return AuthResult.failure('Failed to update profile: ${e.toString()}');
    }
  }

  // Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        return AuthResult.failure('No user logged in');
      }

      // Verify current password
      final storedPasswordHash = _prefs!.getString('password_${user.id}');
      final currentPasswordHash = _hashPassword(currentPassword);
      
      if (storedPasswordHash != currentPasswordHash) {
        return AuthResult.failure('Current password is incorrect');
      }

      if (!_isValidPassword(newPassword)) {
        return AuthResult.failure('New password must be at least 6 characters with letters and numbers');
      }

      // Save new password
      final newPasswordHash = _hashPassword(newPassword);
      await _prefs!.setString('password_${user.id}', newPasswordHash);

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure('Failed to change password: ${e.toString()}');
    }
  }

  // Delete account
  Future<AuthResult> deleteAccount(String password) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        return AuthResult.failure('No user logged in');
      }

      // Verify password
      final storedPasswordHash = _prefs!.getString('password_${user.id}');
      final inputPasswordHash = _hashPassword(password);
      
      if (storedPasswordHash != inputPasswordHash) {
        return AuthResult.failure('Password is incorrect');
      }

      // Remove user from registered users
      final users = await _getRegisteredUsers();
      users.removeWhere((u) => u.id == user.id);
      await _saveRegisteredUsers(users);

      // Remove password
      await _prefs!.remove('password_${user.id}');

      // Logout
      await logout();

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure('Failed to delete account: ${e.toString()}');
    }
  }

  // Get session token
  Future<String?> getSessionToken() async {
    await initialize();
    return _prefs!.getString(_sessionTokenKey);
  }

  // Validate session
  Future<bool> isSessionValid() async {
    final isLoggedIn = await this.isLoggedIn();
    final token = await getSessionToken();
    final user = await getCurrentUser();
    
    return isLoggedIn && token != null && user != null;
  }
}
