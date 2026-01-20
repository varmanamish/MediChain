// lib/views/auth/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medichain/storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medichain/views/distributor/distributor_dashboard.dart';
import 'package:medichain/views/end_user/end_user_dashboard.dart';
import 'package:medichain/views/manufacturer/manufacturer_dashboard.dart';
import 'package:medichain/views/pharmacy/pharmacy_dashboard.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SecureStorage _secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash delay

    try {
      final token = await _secureStorage.getToken();
      final role = await _secureStorage.getUserRole();

      if (token != null && role != null) {
        // User is logged in, navigate to role-based dashboard
        _navigateToDashboard(role);
      } else {
        // No token found, navigate to login
        _navigateToLogin();
      }
    } catch (e) {
      // Error reading storage, navigate to login
      _navigateToLogin();
    }
  }

  void _navigateToDashboard(String role) {
    Widget dashboard;

    switch (role) {
      case 'manufacturer':
        dashboard = const ManufacturerDashboard();
        break;
      case 'distributor':
        dashboard = const DistributorDashboard();
        break;
      case 'pharmacy':
        dashboard = const PharmacyDashboard();
        break;
      case 'end_user':
        dashboard = const EndUserDashboard();
        break;
      default:
        dashboard = const LoginPage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => dashboard),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.medical_services,
                size: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 30),
            // App Name
            const Text(
              'MediChain',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Blockchain Drug Traceability',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 50),
            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Checking authentication...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
