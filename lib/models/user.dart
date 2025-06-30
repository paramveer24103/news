import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final List<String> preferences;
  final bool isEmailVerified;

  User({
    String? id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    List<String>? preferences,
    this.isEmailVerified = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        lastLoginAt = lastLoginAt ?? DateTime.now(),
        preferences = preferences ?? [];

  String get fullName => '$firstName $lastName';
  
  String get displayName => fullName.trim().isEmpty ? email : fullName;

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'preferences': preferences,
      'isEmailVerified': isEmailVerified,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] ?? DateTime.now().toIso8601String()),
      preferences: List<String>.from(json['preferences'] ?? []),
      isEmailVerified: json['isEmailVerified'] ?? false,
    );
  }

  // Create a copy with updated fields
  User copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    DateTime? lastLoginAt,
    List<String>? preferences,
    bool? isEmailVerified,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $fullName)';
  }
}

// Authentication result class
class AuthResult {
  final bool success;
  final User? user;
  final String? error;
  final String? token;

  AuthResult({
    required this.success,
    this.user,
    this.error,
    this.token,
  });

  factory AuthResult.success(User user, [String? token]) {
    return AuthResult(
      success: true,
      user: user,
      token: token,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult(
      success: false,
      error: error,
    );
  }
}
