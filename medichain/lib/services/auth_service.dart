// lib/services/auth_service.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../storage/secure_storage.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final SecureStorage _secureStorage = SecureStorage();

  // Future<bool> login(String email, String password) async {
  //   try {
  //     final response = await _apiService.post('/api/login', {
  //       'email': email,
  //       'password': password,
  //     });

  //     if (response.statusCode == 200) {
  //       final user = User.fromJson(response.data['user']);
  //       final accessToken = response.data['access'];
  //       final refreshToken = response.data['refresh'];

  //       // Store tokens and user data securely
  //       await _secureStorage.writeToken(accessToken);
  //       await _secureStorage.writeRefreshToken(refreshToken);
  //       await _secureStorage.writeUserRole(user.role);
  //       await _secureStorage.writeUserEmail(user.email);

  //       return true;
  //     } else {
  //       throw Exception('Login failed: ${response.data['message']}');
  //     }
  //   } on DioException catch (e) {
  //     throw _handleDioError(e);
  //   } catch (e) {
  //     return false;
  //     throw Exception('Login error: $e');
  //   }
  // }

  // Future<bool> login(String usernameOrEmail, String password) async {
  //   try {
  //     final response = await _apiService.post('/api/login', {
  //       'username': usernameOrEmail,
  //       'password': password,
  //     });

  //     // Check if success is true
  //     if (response.data['success'] == true) {
  //       // Save user info to storage
  //       await _secureStorage.saveUserData(response.data['user']);
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     print('Login error: $e');
  //     return false;
  //   }
  // }

  // Future<bool> register(Map<String, dynamic> userData) async {
  //   try {
  //     final response = await _apiService.post('/api/register', userData);

  //     if (response.statusCode == 201) {
  //       final user = User.fromJson(response.data['user']);
  //       final accessToken = response.data['access'];
  //       final refreshToken = response.data['refresh'];

  //       // Store tokens and user data securely
  //       await _secureStorage.writeToken(accessToken);
  //       await _secureStorage.writeRefreshToken(refreshToken);
  //       await _secureStorage.writeUserRole(user.role);
  //       await _secureStorage.writeUserEmail(user.email);

  //       return true;
  //     } else {
  //       throw Exception('Registration failed: ${response.data['message']}');
  //     }
  //   } on DioException catch (e) {
  //     throw _handleDioError(e);
  //   } catch (e) {
  //     return false;
  //     throw Exception('Registration error: $e');
  //   }
  // }

  Future<bool> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.post('/api/register', {
        'username': userData['username'],
        'firstName': userData['firstName'],
        'lastName': userData['lastName'],
        'mailId': userData['email'], // Note: use mailId for backend
        'phone': userData['phone'] ?? '',
        'dob': userData['dob'],
        'password': userData['password'],
        'confirmPassword': userData['confirmPassword'],
        'role': userData['role'],
      });

      return response.data['success'] == true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      // Call backend logout if needed
      await _apiService.post('/api/logout/', {'refresh': refreshToken});
    } catch (e) {
      // Continue with local cleanup even if API fails
    } finally {
      // Always clear local storage
      await _secureStorage.clearAll();
    }
  }

  // Future<User> getCurrentUser() async {
  //   try {
  //     final response = await _apiService.get('/api/user/profile/');
  //     return User.fromJson(response.data);
  //   } on DioException catch (e) {
  //     throw _handleDioError(e);
  //   } catch (e) {
  //     throw Exception('Failed to get user profile: $e');
  //   }
  // }

  // Future<bool> isLoggedIn() async {
  //   final token = await _secureStorage.getToken();
  //   if (token == null) return false;

  //   // Optional: Validate token with backend
  //   try {
  //     await _apiService.get('/api/user/profile/');
  //     return true;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  Future<String?> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        await _secureStorage.clearAll();
        return null;
      }

      final response = await _apiService.post('/api/token/refresh/', {
        'refresh': refreshToken,
      });

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'];
        await _secureStorage.writeToken(newAccessToken);
        return newAccessToken;
      } else {
        await _secureStorage.clearAll();
        return null;
      }
    } catch (e) {
      await _secureStorage.clearAll();
      return null;
    }
  }

  // Future<void> updateProfile(Map<String, dynamic> profileData) async {
  //   try {
  //     await _apiService.put('/api/user/profile/', profileData);
  //   } on DioException catch (e) {
  //     throw _handleDioError(e);
  //   } catch (e) {
  //     throw Exception('Failed to update profile: $e');
  //   }
  // }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _apiService.post('/api/user/change-password/', {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      await _apiService.post('/api/password-reset/', {'email': email});
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to request password reset: $e');
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final message =
          e.response!.data?['message'] ??
          e.response!.data?['error'] ??
          e.message;

      switch (statusCode) {
        case 400:
          return Exception('Bad request: $message');
        case 401:
          return Exception('Unauthorized: Please login again');
        case 403:
          return Exception('Access denied: $message');
        case 404:
          return Exception('Resource not found: $message');
        case 500:
          return Exception('Server error: Please try again later');
        default:
          return Exception('Network error: $message');
      }
    } else {
      return Exception('Network error: ${e.message}');
    }
  }
}
