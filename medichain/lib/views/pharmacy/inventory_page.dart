// lib/views/pharmacy/inventory_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/drug_batch_model.dart';
import '../../services/drug_service.dart';
import '../../widgets/status_badge.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final DrugService _drugService = DrugService();
  List<DrugBatch> _inventory = [];
  List<DrugBatch> _filteredInventory = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final String _statusFilter = 'all';
  String _stockFilter = 'all';

  // Sort options
  String _sortBy = 'expiry_date';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    try {
      // In a real app, this would fetch from API
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _inventory = _getMockInventory();
        _filteredInventory = _inventory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load inventory: $e');
    }
  }

  List<DrugBatch> _getMockInventory() {
    return [
      DrugBatch(
        id: '1',
        batchId: 'PARA2024001',
        drugName: 'Paracetamol 500mg',
        manufacturerId: 'mfg1',
        manufactureDate: DateTime(2024, 1, 15),
        expiryDate: DateTime(2025, 1, 15),
        quantity: 150,
        dosageForm: 'Tablet',
        composition: 'Paracetamol 500mg',
        storageConditions: 'Store below 25°C',
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
        quantity: 85,
        dosageForm: 'Tablet',
        composition: 'Ibuprofen 400mg',
        storageConditions: 'Store in cool, dry place',
        status: 'delivered',
        createdAt: DateTime(2024, 2, 1),
        updatedAt: DateTime(2024, 2, 1),
      ),
      DrugBatch(
        id: '3',
        batchId: 'AMOX2024001',
        drugName: 'Amoxicillin 250mg',
        manufacturerId: 'mfg3',
        manufactureDate: DateTime(2024, 1, 20),
        expiryDate: DateTime(2024, 10, 20), // Expiring soon
        quantity: 25,
        dosageForm: 'Capsule',
        composition: 'Amoxicillin Trihydrate 250mg',
        storageConditions: 'Store below 25°C',
        status: 'delivered',
        createdAt: DateTime(2024, 1, 20),
        updatedAt: DateTime(2024, 1, 20),
      ),
      DrugBatch(
        id: '4',
        batchId: 'VITA2024001',
        drugName: 'Vitamin C 1000mg',
        manufacturerId: 'mfg4',
        manufactureDate: DateTime(2024, 3, 1),
        expiryDate: DateTime(2025, 3, 1),
        quantity: 5, // Low stock
        dosageForm: 'Tablet',
        composition: 'Ascorbic Acid 1000mg',
        storageConditions: 'Store in cool, dry place',
        status: 'delivered',
        createdAt: DateTime(2024, 3, 1),
        updatedAt: DateTime(2024, 3, 1),
      ),
      DrugBatch(
        id: '5',
        batchId: 'MET2024001',
        drugName: 'Metformin 500mg',
        manufacturerId: 'mfg5',
        manufactureDate: DateTime(2024, 2, 15),
        expiryDate: DateTime(2025, 2, 15),
        quantity: 200,
        dosageForm: 'Tablet',
        composition: 'Metformin Hydrochloride 500mg',
        storageConditions: 'Store below 30°C',
        status: 'delivered',
        createdAt: DateTime(2024, 2, 15),
        updatedAt: DateTime(2024, 2, 15),
      ),
    ];
  }

  void _filterInventory() {
    List<DrugBatch> filtered = _inventory;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((item) =>
              item.drugName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              item.batchId.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply stock filter
    if (_stockFilter != 'all') {
      switch (_stockFilter) {
        case 'low':
          filtered = filtered.where((item) => item.quantity <= 10).toList();
          break;
        case 'expiring':
          final thirtyDaysFromNow =
              DateTime.now().add(const Duration(days: 30));
          filtered = filtered
              .where((item) =>
                  item.expiryDate.isBefore(thirtyDaysFromNow) &&
                  !item.isExpired)
              .toList();
          break;
        case 'expired':
          filtered = filtered.where((item) => item.isExpired).toList();
          break;
      }
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'drug_name':
          comparison = a.drugName.compareTo(b.drugName);
          break;
        case 'quantity':
          comparison = a.quantity.compareTo(b.quantity);
          break;
        case 'expiry_date':
          comparison = a.expiryDate.compareTo(b.expiryDate);
          break;
        case 'batch_id':
          comparison = a.batchId.compareTo(b.batchId);
          break;
        default:
          comparison = 0;
      }
      return _sortAscending ? comparison : -comparison;
    });

    setState(() {
      _filteredInventory = filtered;
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

  void _showItemDetails(DrugBatch item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.drugName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Batch ID', item.batchId),
              _buildDetailRow('Manufacturer', 'PharmaCorp Inc.'),
              _buildDetailRow('Manufacture Date',
                  DateFormat('MMM dd, yyyy').format(item.manufactureDate)),
              _buildDetailRow('Expiry Date',
                  DateFormat('MMM dd, yyyy').format(item.expiryDate)),
              _buildDetailRow('Quantity', '${item.quantity} units'),
              if (item.dosageForm != null)
                _buildDetailRow('Dosage Form', item.dosageForm!),
              if (item.composition != null)
                _buildDetailRow('Composition', item.composition!),
              if (item.storageConditions != null)
                _buildDetailRow('Storage', item.storageConditions!),
              const SizedBox(height: 16),
              _buildStockStatus(item),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStock(item);
            },
            child: const Text('Update Stock'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStockStatus(DrugBatch item) {
    Color color;
    String status;
    IconData icon;

    if (item.isExpired) {
      color = Colors.red;
      status = 'EXPIRED';
      icon = Icons.warning;
    } else if (item.willExpireSoon) {
      color = Colors.orange;
      status = 'EXPIRING SOON';
      icon = Icons.warning_amber;
    } else if (item.quantity <= 10) {
      color = Colors.orange;
      status = 'LOW STOCK';
      icon = Icons.inventory_2;
    } else {
      color = Colors.green;
      status = 'IN STOCK';
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          if (item.isExpired)
            Text(
              '${item.daysUntilExpiry.abs()} days ago',
              style: TextStyle(color: color, fontSize: 12),
            )
          else if (item.willExpireSoon)
            Text(
              '${item.daysUntilExpiry} days left',
              style: TextStyle(color: color, fontSize: 12),
            ),
        ],
      ),
    );
  }

  void _updateStock(DrugBatch item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current stock: ${item.quantity}'),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'New Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              initialValue: item.quantity.toString(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement stock update
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stock updated successfully')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy Inventory'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInventory,
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingScreen() : _buildInventoryContent(),
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
            'Loading Inventory...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryContent() {
    return Column(
      children: [
        // Search and Filter Section
        _buildSearchFilterSection(),
        const SizedBox(height: 8),

        // Inventory Stats
        _buildInventoryStats(),
        const SizedBox(height: 8),

        // Inventory List
        Expanded(
          child: _filteredInventory.isEmpty
              ? _buildEmptyState()
              : _buildInventoryList(),
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
              _filterInventory();
            },
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all', _stockFilter),
                const SizedBox(width: 8),
                _buildFilterChip('Low Stock', 'low', _stockFilter),
                const SizedBox(width: 8),
                _buildFilterChip('Expiring Soon', 'expiring', _stockFilter),
                const SizedBox(width: 8),
                _buildFilterChip('Expired', 'expired', _stockFilter),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Sort Options
          Row(
            children: [
              const Text('Sort by:', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _sortBy,
                items: const [
                  DropdownMenuItem(value: 'drug_name', child: Text('Name')),
                  DropdownMenuItem(value: 'quantity', child: Text('Quantity')),
                  DropdownMenuItem(value: 'expiry_date', child: Text('Expiry')),
                  DropdownMenuItem(value: 'batch_id', child: Text('Batch ID')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                  _filterInventory();
                },
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                ),
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                  });
                  _filterInventory();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String currentFilter) {
    return FilterChip(
      label: Text(label),
      selected: currentFilter == value,
      onSelected: (selected) {
        setState(() {
          _stockFilter = selected ? value : 'all';
        });
        _filterInventory();
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: Colors.green.shade100,
      checkmarkColor: Colors.green,
      labelStyle: TextStyle(
        color: _stockFilter == value ? Colors.green : Colors.grey.shade700,
      ),
    );
  }

  Widget _buildInventoryStats() {
    final totalItems = _inventory.length;
    final lowStockCount =
        _inventory.where((item) => item.quantity <= 10).length;
    final expiringCount =
        _inventory.where((item) => item.willExpireSoon).length;
    final expiredCount = _inventory.where((item) => item.isExpired).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalItems.toString(), Colors.blue),
          _buildStatItem('Low Stock', lowStockCount.toString(), Colors.orange),
          _buildStatItem('Expiring', expiringCount.toString(), Colors.orange),
          _buildStatItem('Expired', expiredCount.toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
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
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredInventory.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = _filteredInventory[index];
        return _buildInventoryItem(item);
      },
    );
  }

  Widget _buildInventoryItem(DrugBatch item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getItemColor(item).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getItemIcon(item),
            color: _getItemColor(item),
            size: 24,
          ),
        ),
        title: Text(
          item.drugName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Batch: ${item.batchId}'),
            const SizedBox(height: 2),
            Text('Qty: ${item.quantity} units'),
            const SizedBox(height: 2),
            Text(
                'Expiry: ${DateFormat('MMM dd, yyyy').format(item.expiryDate)}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildStockBadge(item),
            const SizedBox(height: 4),
            Text(
              '${item.daysUntilExpiry} days',
              style: TextStyle(
                fontSize: 12,
                color: _getExpiryColor(item),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        onTap: () => _showItemDetails(item),
      ),
    );
  }

  Widget _buildStockBadge(DrugBatch item) {
    Color color;
    String text;

    if (item.isExpired) {
      color = Colors.red;
      text = 'EXPIRED';
    } else if (item.willExpireSoon) {
      color = Colors.orange;
      text = 'SOON';
    } else if (item.quantity <= 10) {
      color = Colors.orange;
      text = 'LOW';
    } else {
      color = Colors.green;
      text = 'OK';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getItemColor(DrugBatch item) {
    if (item.isExpired) return Colors.red;
    if (item.willExpireSoon) return Colors.orange;
    if (item.quantity <= 10) return Colors.orange;
    return Colors.green;
  }

  IconData _getItemIcon(DrugBatch item) {
    if (item.isExpired) return Icons.warning;
    if (item.willExpireSoon) return Icons.warning_amber;
    if (item.quantity <= 10) return Icons.inventory_2;
    return Icons.medical_services;
  }

  Color _getExpiryColor(DrugBatch item) {
    if (item.isExpired) return Colors.red;
    if (item.willExpireSoon) return Colors.orange;
    return Colors.green;
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
            'No inventory items found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _stockFilter != 'all'
                ? 'Try adjusting your search or filters'
                : 'Scan deliveries to add items to inventory',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty && _stockFilter == 'all')
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/pharmacy/scan'),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan Delivery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
