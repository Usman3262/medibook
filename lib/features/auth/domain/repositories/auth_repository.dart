import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/user_entity.dart';
import '../../core/error/failure.dart';

abstract class AuthRepository {
  /// Register a new user
  Future<(UserEntity?, Failure?)> register({
    required String email,
    required String password,
    required String fullName,
  });

  /// Login user
  Future<(UserEntity?, Failure?)> login({
    required String email,
    required String password,
  });

  /// Logout user
  Future<Failure?> logout();

  /// Get current user
  Future<(UserEntity?, Failure?)> getCurrentUser();

  /// Update user profile
  Future<(UserEntity?, Failure?)> updateProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? gender,
  });

  /// Reset password
  Future<Failure?> resetPassword(String email);

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get current user ID
  String? getCurrentUserId();
}
