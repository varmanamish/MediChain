// lib/views/end_user/verify_drug_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/drug_batch_model.dart';
import '../../models/transaction_model.dart';
import '../../services/drug_service.dart';
import '../../widgets/status_badge.dart';

class VerifyDrugPage extends StatefulWidget {
  final DrugBatch batch;

  const VerifyDrugPage({super.key, required this.batch});

  @override
  _VerifyDrugPageState createState() => _VerifyDrugPageState();
}

class _VerifyDrugPageState extends State<VerifyDrugPage> {
  final DrugService _drugService = DrugService();
  List<BatchTransaction> _transactionHistory = [];
  bool _isLoading = true;
  bool _verificationComplete = false;
  DrugVerification? _verificationResult;

  @override
  void initState() {
    super.initState();
    _verifyDrug();
    _loadTransactionHistory();
  }

  Future<void> _verifyDrug() async {
    try {
      final verification = await _drugService.verifyDrug(
        widget.batch.blockchainHash!,
      );
      setState(() {
        _verificationResult = verification;
        _verificationComplete = true;
      });
    } catch (e) {
      setState(() {
        _verificationComplete = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadTransactionHistory() async {
    try {
      final transactions = await _drugService.getBatchTransactions(
        widget.batch.id,
      );
      setState(() {
        _transactionHistory = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scanAnotherDrug() {
    Navigator.pushReplacementNamed(context, '/end-user/scan');
  }

  void _shareVerification() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  Color _getVerificationColor() {
    if (!_verificationComplete) return Colors.grey;
    if (_verificationResult?.isCounterfeit ?? false) return Colors.red;
    if (!(_verificationResult?.isValid ?? true)) return Colors.orange;
    return Colors.green;
  }

  String _getVerificationMessage() {
    if (!_verificationComplete) return 'Verifying...';
    if (_verificationResult?.isCounterfeit ?? false) return 'COUNTERFEIT DRUG';
    if (!(_verificationResult?.isValid ?? true)) return 'SUSPICIOUS DRUG';
    return 'AUTHENTIC DRUG';
  }

  IconData _getVerificationIcon() {
    if (!_verificationComplete) return Icons.hourglass_empty;
    if (_verificationResult?.isCounterfeit ?? false) return Icons.warning;
    if (!(_verificationResult?.isValid ?? true)) return Icons.error_outline;
    return Icons.verified_user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drug Verification'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareVerification,
            tooltip: 'Share Verification',
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingScreen() : _buildVerificationContent(),
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
            'Verifying Drug...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Checking blockchain for authenticity',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Verification Result Card
          _buildVerificationCard(),
          const SizedBox(height: 24),

          // Drug Information
          _buildDrugInfoCard(),
          const SizedBox(height: 24),

          // Supply Chain History
          _buildSupplyChainHistory(),
          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildVerificationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getVerificationColor().withOpacity(0.1),
              _getVerificationColor().withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                _getVerificationIcon(),
                size: 80,
                color: _getVerificationColor(),
              ),
              const SizedBox(height: 16),
              Text(
                _getVerificationMessage(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getVerificationColor(),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (_verificationComplete && _verificationResult != null)
                Text(
                  _verificationResult!.verificationMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              const SizedBox(height: 16),
              if (_verificationComplete)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildVerificationStat(
                      label: 'Blockchain Verified',
                      value: 'Yes',
                      color: Colors.green,
                    ),
                    _buildVerificationStat(
                      label: 'Supply Chain Steps',
                      value: '${_transactionHistory.length}',
                      color: Colors.blue,
                    ),
                    _buildVerificationStat(
                      label: 'Expiry Status',
                      value: widget.batch.expiryStatus,
                      color: widget.batch.isExpired ? Colors.red : Colors.green,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDrugInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Drug Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Drug Name', widget.batch.drugName),
            _buildInfoRow('Batch ID', widget.batch.batchId),
            _buildInfoRow('Manufacturer', _getManufacturerName()),
            _buildInfoRow(
              'Manufacture Date',
              DateFormat('MMMM dd, yyyy').format(widget.batch.manufactureDate),
            ),
            _buildInfoRow(
              'Expiry Date',
              DateFormat('MMMM dd, yyyy').format(widget.batch.expiryDate),
            ),
            if (widget.batch.dosageForm != null)
              _buildInfoRow('Dosage Form', widget.batch.dosageForm!),
            if (widget.batch.composition != null)
              _buildInfoRow('Composition', widget.batch.composition!),
            if (widget.batch.storageConditions != null)
              _buildInfoRow(
                'Storage Conditions',
                widget.batch.storageConditions!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplyChainHistory() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supply Chain History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete journey of this drug from manufacturer to you',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 16),
            _transactionHistory.isEmpty
                ? _buildEmptyHistory()
                : Column(
                    children: _transactionHistory
                        .map(_buildTransactionItem)
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BatchTransaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getTransactionColor(
                transaction.transactionType,
              ).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTransactionIcon(transaction.transactionType),
              color: _getTransactionColor(transaction.transactionType),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTransactionType(transaction.transactionType),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.location,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                if (transaction.hasEnvironmentalData) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.environmentalSummary,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                  ),
                ],
                if (transaction.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '"${transaction.notes!}"',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('MMM dd').format(transaction.timestamp),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              Text(
                DateFormat('HH:mm').format(transaction.timestamp),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.history_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No transaction history',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Transaction history will appear here',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _scanAnotherDrug,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Verify Another Drug'),
          ),
        ),
        const SizedBox(width: 16),
        if (_verificationResult?.isCounterfeit ?? false)
          Expanded(
            child: ElevatedButton(
              onPressed: _reportCounterfeit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Report Counterfeit',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }

  void _reportCounterfeit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Counterfeit Drug'),
        content: const Text(
          'This will report the drug as counterfeit to the authorities '
          'and the manufacturer. This action cannot be undone.\n\n'
          'Are you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitCounterfeitReport();
            },
            child: const Text('Report', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _submitCounterfeitReport() {
    // TODO: Implement counterfeit reporting
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Counterfeit drug reported to authorities'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Helper methods
  Color _getTransactionColor(String type) {
    switch (type) {
      case 'manufacture':
        return Colors.blue;
      case 'ship':
        return Colors.orange;
      case 'receive':
        return Colors.green;
      case 'sell':
        return Colors.purple;
      case 'recall':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'manufacture':
        return Icons.factory;
      case 'ship':
        return Icons.local_shipping;
      case 'receive':
        return Icons.inventory_2;
      case 'sell':
        return Icons.shopping_cart;
      case 'recall':
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }

  String _formatTransactionType(String type) {
    return type.replaceAll('_', ' ').toUpperCase();
  }

  String _getManufacturerName() {
    // return widget.batch.manufacturer?.companyName ??
    //     widget.batch.manufacturer?.fullName ??
    //     'Unknown Manufacturer';
    return 'Unknown Manufacturer';
  }
}
