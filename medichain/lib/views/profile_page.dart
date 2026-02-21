import 'package:flutter/material.dart';
import 'package:medichain/services/user_service.dart';
import '../models/user_model.dart';

import '../storage/secure_storage.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  final SecureStorage _secureStorage = SecureStorage();

  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
  try {
    final user = await _userService.fetchUserProfile();

    if (!mounted) return;

    setState(() {
      _user = user;
      _isLoading = false;
    });

  } catch (e) {
    print("Load profile error: $e");

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }
}

  Future<void> _logout() async {
    await _secureStorage.clearAll();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text("Failed to load profile")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileItem('Username', _user!.username),
            _profileItem('Role', _user!.role),
            _profileItem('First Name', _user!.firstName),
            _profileItem('Last Name', _user!.lastName),
            _profileItem('Email', _user!.mailId),
            _profileItem('Phone', _user!.phone),
            _profileItem('Date of Birth', _user!.dob),
            _profileItem('Status', _user!.isActive ? 'Active' : 'Inactive'),
          ],
        ),
      ),
    );
  }

  Widget _profileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Divider(),
        ],
      ),
    );
  }
}