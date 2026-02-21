// lib/views/pharmacy/dashboard.dart
import 'package:flutter/material.dart';
import 'package:medichain/storage/secure_storage.dart';
import 'package:medichain/views/profile_page.dart';
import '../../services/auth_service.dart';
import 'scan_qr_page.dart';
import 'inventory_page.dart';

class PharmacyDashboard extends StatefulWidget {
  const PharmacyDashboard({super.key});

  @override
  _PharmacyDashboardState createState() => _PharmacyDashboardState();
}

class _PharmacyDashboardState extends State<PharmacyDashboard> {
  final SecureStorage _secureStorage = SecureStorage();
  final AuthService _authService = AuthService();
  String _userName = '';
  final List<Map<String, dynamic>> _recentDeliveries = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userEmail = await _secureStorage.getUserEmail();
    setState(() {
      _userName = userEmail?.split('@').first ?? 'Pharmacy';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Pharmacy Dashboard'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _navigateToProfile,
          ),
        ],
      ),
      body: _buildDashboardContent(),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          _buildWelcomeCard(),
          const SizedBox(height: 24),

          // Inventory Stats
          _buildInventoryStats(),
          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 24),

          // Recent Deliveries
          _buildRecentDeliveries(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_pharmacy,
                color: Colors.green,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, $_userName!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your pharmacy inventory and verify deliveries',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          title: 'Total Items',
          value: '45',
          icon: Icons.inventory,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Low Stock',
          value: '3',
          icon: Icons.warning,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Expiring Soon',
          value: '2',
          icon: Icons.calendar_today,
          color: Colors.red,
        ),
        _buildStatCard(
          title: 'Today\'s Deliveries',
          value: '5',
          icon: Icons.local_shipping,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildActionCard(
              title: 'Scan Delivery',
              subtitle: 'Confirm drug receipt',
              icon: Icons.qr_code_scanner,
              color: Colors.green,
              onTap: _navigateToScanQR,
            ),
            _buildActionCard(
              title: 'Inventory',
              subtitle: 'Manage stock',
              icon: Icons.inventory_2,
              color: Colors.blue,
              onTap: _navigateToInventory,
            ),
            _buildActionCard(
              title: 'Verify Drug',
              subtitle: 'Check authenticity',
              icon: Icons.verified_user,
              color: Colors.orange,
              onTap: _navigateToVerify,
            ),
            _buildActionCard(
              title: 'Reports',
              subtitle: 'View analytics',
              icon: Icons.analytics,
              color: Colors.purple,
              onTap: _navigateToReports,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentDeliveries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Deliveries',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _navigateToDeliveries,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _recentDeliveries.isEmpty
            ? _buildEmptyDeliveries()
            : Column(
                children: _recentDeliveries
                    .map((delivery) => _buildDeliveryItem(delivery))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildDeliveryItem(Map<String, dynamic> delivery) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.local_shipping,
            color: Colors.green,
            size: 20,
          ),
        ),
        title: Text(delivery['drug_name'] ?? 'Unknown Drug'),
        subtitle: Text('Batch: ${delivery['batch_id'] ?? 'N/A'}'),
        trailing: Chip(
          label: const Text(
            'DELIVERED',
            style: TextStyle(color: Colors.green, fontSize: 10),
          ),
          backgroundColor: Colors.green.withOpacity(0.1),
        ),
        onTap: () => _viewDeliveryDetails(delivery),
      ),
    );
  }

  Widget _buildEmptyDeliveries() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No recent deliveries',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan a QR code to confirm a delivery',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToScanQR() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PharmacyScanQRPage()),
    );
  }

  void _navigateToInventory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InventoryPage()),
    );
  }

  void _navigateToVerify() {
    // TODO: Implement drug verification
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Drug verification coming soon!')),
    );
  }

  void _navigateToReports() {
    // TODO: Implement reports
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reports dashboard coming soon!')),
    );
  }

  void _navigateToDeliveries() {
    // TODO: Implement deliveries list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deliveries list coming soon!')),
    );
  }

  Future<void> _navigateToProfile() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
    }
  }

  void _viewDeliveryDetails(Map<String, dynamic> delivery) {
    // TODO: Implement delivery details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delivery details coming soon!')),
    );
  }
}
