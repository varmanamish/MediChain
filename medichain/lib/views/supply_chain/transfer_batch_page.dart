import 'package:flutter/material.dart';
import '../../models/supply_chain_models.dart';
import '../../services/supply_chain_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';

class TransferBatchPage extends StatefulWidget {
  final String title;
  final Color color;
  final String? initialBatchId;

  const TransferBatchPage({
    super.key,
    required this.title,
    required this.color,
    this.initialBatchId,
  });

  @override
  State<TransferBatchPage> createState() => _TransferBatchPageState();
}

class _TransferBatchPageState extends State<TransferBatchPage> {
  final _formKey = GlobalKey<FormState>();
  final SupplyChainService _supplyChainService = SupplyChainService();

  late final TextEditingController _batchIdController;
  final TextEditingController _toController = TextEditingController();

  bool _isLoading = false;
  TransferBatchResponse? _lastResponse;

  @override
  void initState() {
    super.initState();
    _batchIdController = TextEditingController(
      text: widget.initialBatchId ?? '',
    );
  }

  @override
  void dispose() {
    _batchIdController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _transferBatch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _lastResponse = null;
    });

    try {
      final response = await _supplyChainService.transferBatch(
        TransferBatchRequest(
          batchId: _batchIdController.text.trim(),
          to: _toController.text.trim(),
        ),
      );

      if (!mounted) return;
      setState(() {
        _lastResponse = response;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transfer submitted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to transfer batch: $e')));
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
        title: Text(widget.title),
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading ? null : _transferBatch,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildFormContent(),
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.color,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _batchIdController,
              labelText: 'Batch ID (hex) *',
              prefixIcon: const Icon(Icons.qr_code),
              validator: (value) =>
                  Validators.validateHexString(value, fieldName: 'Batch ID'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _toController,
              labelText: 'Recipient Address *',
              prefixIcon: const Icon(Icons.account_balance_wallet),
              validator: Validators.validateEthAddress,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _transferBatch,
                icon: const Icon(Icons.local_shipping),
                label: const Text('Transfer Batch'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: widget.color,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_lastResponse != null) _buildReceiptCard(_lastResponse!),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard(TransferBatchResponse response) {
    final receipt = response.receipt;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction Receipt',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildReceiptRow('Tx Hash', receipt.txHash ?? 'N/A'),
            _buildReceiptRow(
              'Block Number',
              receipt.blockNumber?.toString() ?? 'N/A',
            ),
            _buildReceiptRow('Gas Used', receipt.gasUsed?.toString() ?? 'N/A'),
            _buildReceiptRow('Status', receipt.status ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
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
