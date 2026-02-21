// lib/views/manufacturer/batch_list_page.dart
import 'package:flutter/material.dart';
import '../../models/drug_batch_model.dart';
import '../../services/drug_service.dart';
import 'batch_details_page.dart';

class BatchListPage extends StatefulWidget {
  const BatchListPage({super.key});

  @override
  _BatchListPageState createState() => _BatchListPageState();
}

class _BatchListPageState extends State<BatchListPage> {
  final DrugService _drugService = DrugService();
  List<DrugBatch> _batches = [];
  List<DrugBatch> _filteredBatches = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    try {
      final batches = await _drugService.getMyBatches();
      setState(() {
        _batches = batches;
        _filteredBatches = batches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load batches: $e');
    }
  }

  void _filterBatches() {
    List<DrugBatch> filtered = _batches;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((batch) =>
              batch.drugName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              batch.batchId.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply status filter
    if (_statusFilter != 'all') {
      filtered =
          filtered.where((batch) => batch.status == _statusFilter).toList();
    }

    setState(() {
      _filteredBatches = filtered;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Batches'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBatches,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBatchListContent(),
    );
  }

  Widget _buildBatchListContent() {
    return Column(
      children: [
        // Search and Filter Section
        _buildSearchFilterSection(),
        const SizedBox(height: 8),

        // Batch Count
        _buildBatchCount(),
        const SizedBox(height: 8),

        // Batch List
        Expanded(
          child:
              _filteredBatches.isEmpty ? _buildEmptyState() : _buildBatchList(),
        ),
      ],
    );
  }

  Widget _buildSearchFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by drug name or batch ID...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _filterBatches();
            },
          ),
          const SizedBox(height: 12),

          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Created', 'created'),
                const SizedBox(width: 8),
                _buildFilterChip('In Transit', 'in_transit'),
                const SizedBox(width: 8),
                _buildFilterChip('Delivered', 'delivered'),
                const SizedBox(width: 8),
                _buildFilterChip('Recalled', 'recalled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _statusFilter == value,
      onSelected: (selected) {
        setState(() {
          _statusFilter = selected ? value : 'all';
        });
        _filterBatches();
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
      labelStyle: TextStyle(
        color: _statusFilter == value ? Colors.blue : Colors.grey.shade700,
      ),
    );
  }

  Widget _buildBatchCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_filteredBatches.length} batch${_filteredBatches.length != 1 ? 'es' : ''}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_searchQuery.isNotEmpty || _statusFilter != 'all')
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _statusFilter = 'all';
                });
                _filterBatches();
              },
              child: const Text('Clear Filters'),
            ),
        ],
      ),
    );
  }

  Widget _buildBatchList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredBatches.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final batch = _filteredBatches[index];
        return _buildBatchListItem(batch);
      },
    );
  }

  Widget _buildBatchListItem(DrugBatch batch) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getStatusColor(batch.status).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatusIcon(batch.status),
            color: _getStatusColor(batch.status),
            size: 24,
          ),
        ),
        title: Text(
          batch.drugName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Batch: ${batch.batchId}'),
            const SizedBox(height: 2),
            Text('Qty: ${batch.quantity}'),
            const SizedBox(height: 2),
            Text('Expiry: ${_formatDate(batch.expiryDate)}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Chip(
              label: Text(
                batch.status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(batch.status),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: _getStatusColor(batch.status).withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(batch.manufactureDate),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        onTap: () => _navigateToBatchDetails(batch),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No batches found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _statusFilter != 'all'
                ? 'Try adjusting your search or filters'
                : 'Create your first batch to get started',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty && _statusFilter == 'all')
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Create First Batch'),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToBatchDetails(DrugBatch batch) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BatchDetailsPage(batch: batch),
      ),
    ).then((_) => _loadBatches());
  }
}
