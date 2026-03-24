import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/supply_chain_models.dart';
import '../../services/supply_chain_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';

class GetBatchPage extends StatefulWidget {
  const GetBatchPage({super.key});

  @override
  State<GetBatchPage> createState() => _GetBatchPageState();
}

class _GetBatchPageState extends State<GetBatchPage> {
  final _formKey = GlobalKey<FormState>();
  final SupplyChainService _supplyChainService = SupplyChainService();

  final TextEditingController _batchIdController = TextEditingController();
  bool _isLoading = false;
  SupplyChainBatch? _batch;

  @override
  void dispose() {
    _batchIdController.dispose();
    super.dispose();
  }

  Future<void> _loadBatch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _batch = null;
    });

    try {
      final batch = await _supplyChainService.getBatch(
        _batchIdController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _batch = batch;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load batch: $e')));
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
        title: const Text('Get Batch'),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _isLoading ? null : _loadBatch,
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
                    onPressed: _isLoading ? null : _loadBatch,
                    icon: const Icon(Icons.search),
                    label: const Text('Fetch Batch'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blueGrey.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_batch != null) _buildBatchCard(_batch!),
        ],
      ),
    );
  }

  Widget _buildBatchCard(SupplyChainBatch batch) {
    final createdAt = DateFormat('yyyy-MM-dd HH:mm').format(batch.createdAt);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Batch Info',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Batch ID', batch.batchId),
            _buildInfoRow('Owner', batch.owner),
            _buildInfoRow('State', batch.state),
            _buildInfoRow('Created At', createdAt),
            _buildInfoRow('Metadata Hash', batch.metadataHash),
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
            width: 110,
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
