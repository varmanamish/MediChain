// lib/views/manufacturer/batch_details_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medichain/models/transaction_model.dart';
import '../../models/drug_batch_model.dart';
import '../../services/drug_service.dart';
import '../../widgets/status_badge.dart';

class BatchDetailsPage extends StatefulWidget {
  final DrugBatch batch;

  const BatchDetailsPage({super.key, required this.batch});

  @override
  _BatchDetailsPageState createState() => _BatchDetailsPageState();
}

class _BatchDetailsPageState extends State<BatchDetailsPage> {
  final DrugService _drugService = DrugService();
  List<BatchTransaction> _transactions = [];
  bool _isLoading = true;
  bool _showFullHistory = false;

  @override
  void initState() {
    super.initState();
    _loadBatchDetails();
  }

  Future<void> _loadBatchDetails() async {
    try {
      final transactions = await _drugService.getBatchTransactions(
        widget.batch.id,
      );
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load batch details: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _generateQRCode() {
    // TODO: Implement QR code generation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Code generation coming soon!')),
    );
  }

  void _viewOnBlockchain() {
    // TODO: Implement blockchain viewer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Blockchain viewer coming soon!')),
    );
  }

  void _recallBatch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recall Batch'),
        content: const Text(
          'Are you sure you want to recall this batch? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performRecall();
            },
            child: const Text('Recall', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _performRecall() async {
    try {
      // TODO: Implement batch recall
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Batch recall functionality coming soon!'),
        ),
      );
    } catch (e) {
      _showError('Failed to recall batch: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.batch.drugName),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: _generateQRCode,
            tooltip: 'Generate QR Code',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBatchDetails,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBatchDetailsContent(),
    );
  }

  Widget _buildBatchDetailsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Batch Header Card
          _buildBatchHeaderCard(),
          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 24),

          // Batch Information
          _buildBatchInformation(),
          const SizedBox(height: 24),

          // Transaction History
          _buildTransactionHistory(),
        ],
      ),
    );
  }

  Widget _buildBatchHeaderCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      widget.batch.status,
                    ).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(widget.batch.status),
                    color: _getStatusColor(widget.batch.status),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.batch.drugName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Batch: ${widget.batch.batchId}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      StatusBadge(status: widget.batch.status),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.batch.blockchainHash != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.link, color: Colors.green.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'On Blockchain: ${widget.batch.blockchainHash!.substring(0, 16)}...',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _viewOnBlockchain,
                      child: Text(
                        'View',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
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

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.qr_code_2,
            label: 'QR Code',
            color: Colors.blue,
            onTap: _generateQRCode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.link,
            label: 'Blockchain',
            color: Colors.green,
            onTap: _viewOnBlockchain,
          ),
        ),
        const SizedBox(width: 12),
        if (widget.batch.status != 'recalled')
          Expanded(
            child: _buildActionButton(
              icon: Icons.warning,
              label: 'Recall',
              color: Colors.red,
              onTap: _recallBatch,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
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
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatchInformation() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Batch Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Drug Name', widget.batch.drugName),
            _buildInfoRow('Batch ID', widget.batch.batchId),
            _buildInfoRow(
              'Manufacture Date',
              _formatDate(widget.batch.manufactureDate),
            ),
            _buildInfoRow('Expiry Date', _formatDate(widget.batch.expiryDate)),
            _buildInfoRow('Quantity', widget.batch.quantity.toString()),
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

  Widget _buildTransactionHistory() {
    final displayTransactions = _showFullHistory
        ? _transactions
        : _transactions.take(3).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaction History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_transactions.length > 3)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showFullHistory = !_showFullHistory;
                      });
                    },
                    child: Text(_showFullHistory ? 'Show Less' : 'Show All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _transactions.isEmpty
                ? _buildEmptyTransactions()
                : Column(
                    children: displayTransactions
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
      padding: const EdgeInsets.all(16),
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
                if (transaction.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.notes!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
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
                DateFormat('MMM dd, yyyy').format(transaction.timestamp),
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

  Widget _buildEmptyTransactions() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.history_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No transactions yet',
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

  String _formatDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }
}
