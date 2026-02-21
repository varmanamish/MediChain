// lib/utils/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // Keys for storage
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'id';
  static const String _usernameKey = 'username';
  static const _userRoleKey = 'role';
  static const _userEmailKey = 'mail_id';
  static const String _firstNameKey = 'first_name';
  static const String _lastNameKey = 'last_name';
  static const String _phoneKey = 'phone';
  static const String _dobKey = 'dob';
  static const String _roleKey = 'role';
  static const String _isLoggedInKey = 'is_logged_in';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Token Management
  Future<void> writeToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> writeRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // User Role Management
  Future<void> writeUserRole(String role) async {
    await _storage.write(key: _userRoleKey, value: role);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: _userRoleKey);
  }

  // User Email Management
  Future<void> writeUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }


  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  // Username Management
  Future<void> writeUsername(String email) async {
    await _storage.write(key: _usernameKey, value: email);
  }


  Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  // Clear all stored data (logout)
  Future<void> clearAll() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userRoleKey);
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _userEmailKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Save user data after login/registration
  // Future<void> saveUserData(Map<String, dynamic> userData) async {
  //   try {
  //     await Future.wait([
  //       // Save individual fields
  //       _storage.write(key: _userIdKey, value: userData['id']?.toString()),
  //       _storage.write(key: _usernameKey, value: userData['username']),
  //       _storage.write(key: _userEmailKey, value: userData['email']),
  //       _storage.write(key: _firstNameKey, value: userData['firstName']),
  //       _storage.write(key: _lastNameKey, value: userData['lastName']),
  //       _storage.write(key: _phoneKey, value: userData['phone']),
  //       _storage.write(key: _dobKey, value: userData['dob']),
  //       _storage.write(key: _roleKey, value: userData['role']),
  //       _storage.write(key: _isLoggedInKey, value: 'true'),
  //     ]);
  //   } catch (e) {
  //     print('Error saving user data: $e');
  //     rethrow;
  //   }
  // }
}
