// lib/views/end_user/dashboard.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medichain/views/profile_page.dart';
import '../../storage/secure_storage.dart';
import '../../models/drug_batch_model.dart';
import '../../models/transaction_model.dart';
import '../../services/auth_service.dart';
import '../../services/drug_service.dart';
import 'verify_drug_page.dart';

class EndUserDashboard extends StatefulWidget {
  const EndUserDashboard({super.key});

  @override
  _EndUserDashboardState createState() => _EndUserDashboardState();
}

class _EndUserDashboardState extends State<EndUserDashboard> {
  final SecureStorage _secureStorage = SecureStorage();
  final DrugService _drugService = DrugService();
  final AuthService _authService = AuthService();

  String _userName = '';
  List<DrugVerification> _verificationHistory = [];
  List<DrugBatch> _recentlyVerified = [];
  bool _isLoading = true;
  int _totalVerified = 0;
  int _authenticCount = 0;
  int _counterfeitCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadVerificationHistory();
  }

  Future<void> _loadUserData() async {
    try {
      final userEmail = await _secureStorage.getUserEmail();
      setState(() {
        _userName = userEmail?.split('@').first ?? 'User';
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadVerificationHistory() async {
    try {
      // In a real app, this would fetch from an API
      // For demo purposes, we'll use mock data
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _verificationHistory = _getMockVerificationHistory();
        _recentlyVerified = _getMockRecentlyVerified();
        _totalVerified = _verificationHistory.length;
        _authenticCount = _verificationHistory
            .where((v) => v.isValid && !v.isCounterfeit)
            .length;
        _counterfeitCount = _verificationHistory
            .where((v) => v.isCounterfeit)
            .length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load verification history: $e');
    }
  }

  List<DrugVerification> _getMockVerificationHistory() {
    return [
      DrugVerification(
        isValid: true,
        isCounterfeit: false,
        batch: DrugBatch(
          id: '1',
          batchId: 'PARA2024001',
          drugName: 'Paracetamol 500mg',
          manufacturerId: 'mfg1',
          manufactureDate: DateTime(2024, 1, 15),
          expiryDate: DateTime(2025, 1, 15),
          quantity: 1000,
          status: 'delivered',
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        ),
        transactionHistory: [],
        verificationMessage: 'Authentic drug from verified manufacturer',
        verifiedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      DrugVerification(
        isValid: true,
        isCounterfeit: false,
        batch: DrugBatch(
          id: '2',
          batchId: 'IBU2024002',
          drugName: 'Ibuprofen 400mg',
          manufacturerId: 'mfg2',
          manufactureDate: DateTime(2024, 2, 1),
          expiryDate: DateTime(2025, 2, 1),
          quantity: 500,
          status: 'delivered',
          createdAt: DateTime(2024, 2, 1),
          updatedAt: DateTime(2024, 2, 1),
        ),
        transactionHistory: [],
        verificationMessage: 'Valid supply chain record found',
        verifiedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      DrugVerification(
        isValid: false,
        isCounterfeit: true,
        batch: DrugBatch(
          id: '3',
          batchId: 'SUSP2024001',
          drugName: 'Amoxicillin 250mg',
          manufacturerId: 'mfg3',
          manufactureDate: DateTime(2024, 1, 10),
          expiryDate: DateTime(2025, 1, 10),
          quantity: 200,
          status: 'delivered',
          createdAt: DateTime(2024, 1, 10),
          updatedAt: DateTime(2024, 1, 10),
        ),
        transactionHistory: [],
        verificationMessage: 'Counterfeit - Batch ID not found in blockchain',
        verifiedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }

  List<DrugBatch> _getMockRecentlyVerified() {
    return [
      DrugBatch(
        id: '1',
        batchId: 'PARA2024001',
        drugName: 'Paracetamol 500mg',
        manufacturerId: 'mfg1',
        manufactureDate: DateTime(2024, 1, 15),
        expiryDate: DateTime(2025, 1, 15),
        quantity: 1000,
        status: 'delivered',
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      ),
      DrugBatch(
        id: '2',
        batchId: 'IBU2024002',
        drugName: 'Ibuprofen 400mg',
        manufacturerId: 'mfg2',
        manufactureDate: DateTime(2024, 2, 1),
        expiryDate: DateTime(2025, 2, 1),
        quantity: 500,
        status: 'delivered',
        createdAt: DateTime(2024, 2, 1),
        updatedAt: DateTime(2024, 2, 1),
      ),
    ];
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _navigateToVerifyDrug() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VerifyDrugScannerPage()),
    ).then((_) => _loadVerificationHistory());
  }

  void _navigateToVerificationHistory() {
    // TODO: Implement verification history page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification history page coming soon!')),
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

  void _viewVerificationDetails(DrugVerification verification) {
    if (verification.batch != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyDrugPage(batch: verification.batch!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Medicine Verifier'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _navigateToProfile,
            tooltip: 'Profile',
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingScreen() : _buildDashboardContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToVerifyDrug,
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Loading your dashboard...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
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

          // Verification Stats
          _buildVerificationStats(),
          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 24),

          // Recent Verifications
          _buildRecentVerifications(),
          const SizedBox(height: 24),

          // Safety Tips
          _buildSafetyTips(),
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
                color: Colors.purple.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_services,
                color: Colors.purple,
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
                    'Verify your medicines and ensure safety',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$_totalVerified drugs verified',
                      style: TextStyle(
                        color: Colors.purple.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          title: 'Total Verified',
          value: _totalVerified.toString(),
          icon: Icons.verified_user,
          color: Colors.purple,
          subtitle: 'All time',
        ),
        _buildStatCard(
          title: 'Authentic',
          value: _authenticCount.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
          subtitle: 'Safe to use',
        ),
        _buildStatCard(
          title: 'Counterfeit',
          value: _counterfeitCount.toString(),
          icon: Icons.warning,
          color: Colors.red,
          subtitle: 'Reported',
        ),
        _buildStatCard(
          title: 'This Month',
          value: '5',
          icon: Icons.calendar_today,
          color: Colors.blue,
          subtitle: 'Recent checks',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
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
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildActionCard(
              title: 'Scan QR Code',
              subtitle: 'Verify a new drug',
              icon: Icons.qr_code_scanner,
              color: Colors.purple,
              onTap: _navigateToVerifyDrug,
            ),
            _buildActionCard(
              title: 'History',
              subtitle: 'View past verifications',
              icon: Icons.history,
              color: Colors.blue,
              onTap: _navigateToVerificationHistory,
            ),
            _buildActionCard(
              title: 'Safety Guide',
              subtitle: 'Learn about drug safety',
              icon: Icons.health_and_safety,
              color: Colors.green,
              onTap: _showSafetyGuide,
            ),
            _buildActionCard(
              title: 'Report Issue',
              subtitle: 'Report counterfeit drugs',
              icon: Icons.report,
              color: Colors.red,
              onTap: _reportIssue,
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
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentVerifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Verifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _navigateToVerificationHistory,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _verificationHistory.isEmpty
            ? _buildEmptyVerifications()
            : Column(
                children: _verificationHistory
                    .take(3)
                    .map(_buildVerificationItem)
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildVerificationItem(DrugVerification verification) {
    final isAuthentic = verification.isValid && !verification.isCounterfeit;
    final isCounterfeit = verification.isCounterfeit;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isCounterfeit
                ? Colors.red.shade100
                : isAuthentic
                ? Colors.green.shade100
                : Colors.orange.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCounterfeit
                ? Icons.warning
                : isAuthentic
                ? Icons.check_circle
                : Icons.error_outline,
            color: isCounterfeit
                ? Colors.red
                : isAuthentic
                ? Colors.green
                : Colors.orange,
            size: 24,
          ),
        ),
        title: Text(
          verification.batch?.drugName ?? 'Unknown Drug',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Batch: ${verification.batch?.batchId ?? 'N/A'}',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('MMM dd, yyyy').format(verification.verifiedAt),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              verification.verificationMessage,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            isCounterfeit
                ? 'COUNTERFEIT'
                : isAuthentic
                ? 'AUTHENTIC'
                : 'SUSPICIOUS',
            style: TextStyle(
              color: isCounterfeit
                  ? Colors.red
                  : isAuthentic
                  ? Colors.green
                  : Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: isCounterfeit
              ? Colors.red.shade50
              : isAuthentic
              ? Colors.green.shade50
              : Colors.orange.shade50,
        ),
        onTap: () => _viewVerificationDetails(verification),
      ),
    );
  }

  Widget _buildEmptyVerifications() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No verifications yet',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan a QR code to verify your first drug',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTips() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: Colors.green.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Safety Tips',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSafetyTip(
              'Always verify medicines before use',
              Icons.verified_user,
            ),
            _buildSafetyTip(
              'Check expiry dates regularly',
              Icons.calendar_today,
            ),
            _buildSafetyTip('Report suspicious packaging', Icons.warning),
            _buildSafetyTip(
              'Buy from licensed pharmacies only',
              Icons.local_pharmacy,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyTip(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.green.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showSafetyGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Drug Safety Guide'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGuideItem(
                'Verify Before Use',
                'Always scan the QR code to verify authenticity.',
              ),
              _buildGuideItem(
                'Check Expiry Dates',
                'Never use expired medications.',
              ),
              _buildGuideItem(
                'Inspect Packaging',
                'Look for tampering or damage.',
              ),
              _buildGuideItem(
                'Store Properly',
                'Follow storage instructions on packaging.',
              ),
              _buildGuideItem(
                'Report Suspicious Drugs',
                'Immediately report any counterfeit findings.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _reportIssue() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report an Issue'),
        content: const Text(
          'If you suspect a drug is counterfeit or have found any issues, '
          'please report it immediately to protect others.\n\n'
          'Your report will be sent to the authorities and the manufacturer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitIssueReport();
            },
            child: const Text('Report Issue'),
          ),
        ],
      ),
    );
  }

  void _submitIssueReport() {
    // TODO: Implement issue reporting
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Issue reported successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// Placeholder for the QR scanner page
class VerifyDrugScannerPage extends StatelessWidget {
  const VerifyDrugScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Drug QR Code'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'QR Scanner Placeholder',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
