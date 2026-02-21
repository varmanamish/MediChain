import 'package:dio/dio.dart';
import '../services/api_service.dart';

class ProfileService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await _api.get('/api/user/profile');
    return response.data;
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      await _api.put('/api/user/profile', data);
      return true;
    } catch (e) {
      return false;
    }
  }
}
