// lib/views/manufacturer/dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medichain/views/profile_page.dart';
import '../../models/drug_batch_model.dart';
import '../../services/auth_service.dart';
import '../../services/drug_service.dart';
import '../../storage/secure_storage.dart';
import 'create_batch_page.dart';
import 'batch_list_page.dart';
import 'batch_details_page.dart';

class ManufacturerDashboard extends StatefulWidget {
  const ManufacturerDashboard({super.key});

  @override
  _ManufacturerDashboardState createState() => _ManufacturerDashboardState();
}

class _ManufacturerDashboardState extends State<ManufacturerDashboard> {
  final DrugService _drugService = DrugService();
  final SecureStorage _secureStorage = SecureStorage();
  final AuthService _authService = AuthService();
  List<DrugBatch> _recentBatches = [];
  bool _isLoading = true;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final userEmail = await _secureStorage.getUserEmail();
      _userName = userEmail?.split('@').first ?? 'Manufacturer';

      final batches = await _drugService.getMyBatches();
      setState(() {
        _recentBatches = batches.take(3).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load dashboard data: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Manufacturer Dashboard'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _navigateToProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboardContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateBatch,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
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

          // Quick Stats
          _buildStatsGrid(),
          const SizedBox(height: 24),

          // Recent Batches
          _buildRecentBatchesSection(),
          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActions(),
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
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.business_center,
                color: Colors.blue,
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
                    'Manage your drug batches and track shipments',
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

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          title: 'Total Batches',
          value: '12',
          icon: Icons.inventory_2,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'In Transit',
          value: '3',
          icon: Icons.local_shipping,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Delivered',
          value: '8',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Pending',
          value: '1',
          icon: Icons.pending_actions,
          color: Colors.red,
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

  Widget _buildRecentBatchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Batches',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _navigateToBatchList,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _recentBatches.isEmpty
            ? _buildEmptyState()
            : Column(
                children: _recentBatches
                    .map((batch) => _buildBatchItem(batch))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildBatchItem(DrugBatch batch) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatusColor(batch.status).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatusIcon(batch.status),
            color: _getStatusColor(batch.status),
            size: 20,
          ),
        ),
        title: Text(batch.drugName),
        subtitle: Text('Batch: ${batch.batchId}'),
        trailing: Chip(
          label: Text(
            batch.status.toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(batch.status),
              fontSize: 10,
            ),
          ),
          backgroundColor: _getStatusColor(batch.status).withOpacity(0.1),
        ),
        onTap: () => _navigateToBatchDetails(batch),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No batches created yet',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first drug batch to get started',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
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
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildActionCard(
              title: 'Create Batch',
              icon: Icons.add_circle_outline,
              color: Colors.blue,
              onTap: _navigateToCreateBatch,
            ),
            _buildActionCard(
              title: 'View All Batches',
              icon: Icons.list_alt,
              color: Colors.green,
              onTap: _navigateToBatchList,
            ),
            _buildActionCard(
              title: 'Scan QR',
              icon: Icons.qr_code_scanner,
              color: Colors.orange,
              onTap: _navigateToScanQR,
            ),
            _buildActionCard(
              title: 'Analytics',
              icon: Icons.analytics_outlined,
              color: Colors.purple,
              onTap: _navigateToAnalytics,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
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
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(String status) {
    switch (status) {
      case 'created':
        return Colors.blue;
      case 'in_transit':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'recalled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'created':
        return Icons.inventory_2;
      case 'in_transit':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'recalled':
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }

  // Navigation methods
  void _navigateToCreateBatch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateBatchPage()),
    ).then((_) => _loadDashboardData());
  }

  void _navigateToBatchList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BatchListPage()),
    );
  }

  void _navigateToBatchDetails(DrugBatch batch) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BatchDetailsPage(batch: batch)),
    );
  }

  void _navigateToScanQR() {
    // TODO: Implement QR scanner
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('QR Scanner coming soon!')));
  }

  void _navigateToAnalytics() {
    // TODO: Implement analytics
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analytics dashboard coming soon!')),
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
}
