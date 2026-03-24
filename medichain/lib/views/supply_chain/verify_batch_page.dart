import 'package:flutter/material.dart';
import '../../models/supply_chain_models.dart';
import '../../services/supply_chain_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';

class VerifyBatchPage extends StatefulWidget {
  const VerifyBatchPage({super.key});

  @override
  State<VerifyBatchPage> createState() => _VerifyBatchPageState();
}

class _VerifyBatchPageState extends State<VerifyBatchPage> {
  final _formKey = GlobalKey<FormState>();
  final SupplyChainService _supplyChainService = SupplyChainService();

  final TextEditingController _qrPayloadController = TextEditingController();
  final TextEditingController _batchIdController = TextEditingController();
  final TextEditingController _metadataHashController = TextEditingController();

  bool _isLoading = false;
  VerifyBatchResponse? _lastResponse;

  @override
  void dispose() {
    _qrPayloadController.dispose();
    _batchIdController.dispose();
    _metadataHashController.dispose();
    super.dispose();
  }

  Future<void> _verifyBatch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _lastResponse = null;
    });

    try {
      final qrPayload = _qrPayloadController.text.trim();
      final response = await _supplyChainService.verifyBatch(
        VerifyBatchRequest(
          qrPayload: qrPayload.isNotEmpty ? qrPayload : null,
          batchId: qrPayload.isEmpty ? _batchIdController.text.trim() : null,
          metadataHash: qrPayload.isEmpty
              ? _metadataHashController.text.trim()
              : null,
        ),
      );

      if (!mounted) return;
      setState(() {
        _lastResponse = response;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Verification complete.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to verify batch: $e')));
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
        title: const Text('Verify Batch'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_user),
            onPressed: _isLoading ? null : _verifyBatch,
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
            const Text(
              'Verification Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _qrPayloadController,
              labelText: 'QR Payload (paste from QR)',
              prefixIcon: const Icon(Icons.qr_code_2),
              maxLines: 3,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _batchIdController,
              labelText: 'Batch ID (hex) *',
              prefixIcon: const Icon(Icons.qr_code),
              validator: (value) {
                if (_qrPayloadController.text.trim().isNotEmpty) {
                  return null;
                }
                return Validators.validateHexString(
                  value,
                  fieldName: 'Batch ID',
                );
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _metadataHashController,
              labelText: 'Metadata Hash (hex) *',
              prefixIcon: const Icon(Icons.fingerprint),
              validator: (value) {
                if (_qrPayloadController.text.trim().isNotEmpty) {
                  return null;
                }
                return Validators.validateHexString(
                  value,
                  fieldName: 'Metadata Hash',
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _verifyBatch,
                icon: const Icon(Icons.verified),
                label: const Text('Verify Batch'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.purple.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_lastResponse != null) _buildResultCard(_lastResponse!),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(VerifyBatchResponse response) {
    final receipt = response.receipt;
    final statusColor = response.isValid ? Colors.green : Colors.red;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              response.isValid ? 'VALID' : 'INVALID',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
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
