import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/supply_chain_models.dart';
import '../../services/supply_chain_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';

class BatchHistoryPage extends StatefulWidget {
  const BatchHistoryPage({super.key});

  @override
  State<BatchHistoryPage> createState() => _BatchHistoryPageState();
}

class _BatchHistoryPageState extends State<BatchHistoryPage> {
  final _formKey = GlobalKey<FormState>();
  final SupplyChainService _supplyChainService = SupplyChainService();

  final TextEditingController _batchIdController = TextEditingController();
  bool _isLoading = false;
  List<SupplyChainHistoryEntry> _entries = [];

  @override
  void dispose() {
    _batchIdController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _entries = [];
    });

    try {
      final batchId = _batchIdController.text.trim();
      final indexes = await _supplyChainService.getBatchHistoryIndexes(batchId);

      final entries = <SupplyChainHistoryEntry>[];
      for (final index in indexes) {
        final entry = await _supplyChainService.getBatchHistoryEntry(
          batchId,
          index,
        );
        entries.add(entry);
      }

      if (!mounted) return;
      setState(() {
        _entries = entries;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load history: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch History'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _isLoading ? null : _loadHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _batchIdController,
                  labelText: 'Batch ID (hex) *',
                  prefixIcon: const Icon(Icons.qr_code),
                  validator: (value) => Validators.validateHexString(
                    value,
                    fieldName: 'Batch ID',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loadHistory,
                    icon: const Icon(Icons.history),
                    label: const Text('Load History'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_entries.isEmpty)
            const Text(
              'No history loaded yet.',
              style: TextStyle(color: Colors.grey),
            )
          else
            Column(children: _entries.map(_buildHistoryCard).toList()),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(SupplyChainHistoryEntry entry) {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm').format(entry.timestamp);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Owner', entry.owner),
            _buildInfoRow('Role', entry.role),
            _buildInfoRow('Timestamp', timestamp),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
