// lib/views/distributor/dashboard.dart
import 'package:flutter/material.dart';
import 'package:medichain/services/auth_service.dart';
import 'package:medichain/services/drug_service.dart';
import 'package:medichain/views/profile_page.dart';
import '../../storage/secure_storage.dart';
import 'scan_qr_page.dart';
import 'update_transit_page.dart';

class DistributorDashboard extends StatefulWidget {
  const DistributorDashboard({super.key});

  @override
  _DistributorDashboardState createState() => _DistributorDashboardState();
}

class _DistributorDashboardState extends State<DistributorDashboard> {
  final SecureStorage _secureStorage = SecureStorage();
  final DrugService _drugService = DrugService();
  final AuthService _authService = AuthService();
  String _userName = '';
  final List<Map<String, dynamic>> _activeShipments = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userEmail = await _secureStorage.getUserEmail();
    setState(() {
      _userName = userEmail?.split('@').first ?? 'Distributor';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Distributor Dashboard'),
        backgroundColor: Colors.orange.shade800,
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

          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 24),

          // Active Shipments
          _buildActiveShipments(),
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
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_shipping,
                color: Colors.orange,
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
                    'Manage drug shipments and transit updates',
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
              title: 'Scan QR Code',
              subtitle: 'Scan batch to update',
              icon: Icons.qr_code_scanner,
              color: Colors.orange,
              onTap: _navigateToScanQR,
            ),
            _buildActionCard(
              title: 'Shipments',
              subtitle: 'View all shipments',
              icon: Icons.list_alt,
              color: Colors.blue,
              onTap: _navigateToShipments,
            ),
            _buildActionCard(
              title: 'Transit History',
              subtitle: 'View past deliveries',
              icon: Icons.history,
              color: Colors.green,
              onTap: _navigateToHistory,
            ),
            _buildActionCard(
              title: 'Location',
              subtitle: 'Update current location',
              icon: Icons.location_on,
              color: Colors.purple,
              onTap: _navigateToLocation,
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

  Widget _buildActiveShipments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Shipments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _navigateToShipments,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _activeShipments.isEmpty
            ? _buildEmptyShipments()
            : Column(
                children: _activeShipments
                    .map((shipment) => _buildShipmentItem(shipment))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildShipmentItem(Map<String, dynamic> shipment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.local_shipping,
            color: Colors.orange,
            size: 20,
          ),
        ),
        title: Text(shipment['drug_name'] ?? 'Unknown Drug'),
        subtitle: Text('Batch: ${shipment['batch_id'] ?? 'N/A'}'),
        trailing: Chip(
          label: const Text(
            'IN TRANSIT',
            style: TextStyle(color: Colors.orange, fontSize: 10),
          ),
          backgroundColor: Colors.orange.withOpacity(0.1),
        ),
        onTap: () => _updateShipment(shipment['batch_id']),
      ),
    );
  }

  Widget _buildEmptyShipments() {
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
            'No active shipments',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan a QR code to start tracking a shipment',
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
      MaterialPageRoute(builder: (context) => const DistributorScanQRPage()),
    );
  }

  void _navigateToShipments() {
    // TODO: Implement shipments list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shipments list coming soon!')),
    );
  }

  void _navigateToHistory() {
    // TODO: Implement history
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transit history coming soon!')),
    );
  }

  void _navigateToLocation() {
    // TODO: Implement location update
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location update coming soon!')),
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

  void _updateShipment(String batchId) async {
    final batch = await _drugService.getBatchById(batchId);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UpdateTransitPage(batch: batch)),
    );
  }
}
