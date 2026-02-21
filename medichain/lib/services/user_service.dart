import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medichain/models/user_model.dart';
import 'package:medichain/services/api_service.dart';
import 'package:medichain/storage/secure_storage.dart';

class UserService {
  static const String emulator = "10.0.2.2";
  static const String phone = "192.168.0.131";

  static const String baseUrl = "http://$phone:8081/api";
  // Android emulator → 10.0.2.2
  // Web → http://localhost:8080

  ApiService _apiService = ApiService();
  SecureStorage _secureStorage = SecureStorage();

  /// ============================
  /// REGISTER USER
  /// ============================
  Future<bool> registerUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      // Helpful for debugging backend errors
      throw Exception(
        "Registration failed: ${response.statusCode} - ${response.body}",
      );
    }
  }

  /// ============================
  /// LOGIN USER
  /// ============================
  Future<bool> login(String usernameOrEmail, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'usernameOrEmail': usernameOrEmail,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Login response: $data');

        final token = data['token'];
        final username = data['username'];
        final role = data['role'];
        await _secureStorage.writeToken(token);
        await _secureStorage.writeUsername(username);
        await _secureStorage.writeUserRole(role);

        return true;
      } else {
        print('Login failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  /// ============================
  /// FETCH USER PROFILE
  /// ============================

  Future<User?> fetchUserProfile() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception("No token found");

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Profile data: $data');
        return User.fromJson(data);
      } else {
        throw Exception(
          "Failed to fetch profile: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print('Fetch profile error: $e');
      rethrow;
    }
  }
}
