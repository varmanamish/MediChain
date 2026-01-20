import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl = "http://10.0.2.2:8081/api";
  // Android emulator → 10.0.2.2
  // Web → http://localhost:8080

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
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Login failed: ${response.statusCode} - ${response.body}",
      );
    }
  }
}
