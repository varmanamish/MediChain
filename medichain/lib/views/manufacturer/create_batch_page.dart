import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/supply_chain_models.dart';
import '../../services/supply_chain_service.dart';
import '../../utils/hash_utils.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';

class CreateBatchPage extends StatefulWidget {
  const CreateBatchPage({super.key});

  @override
  State<CreateBatchPage> createState() => _CreateBatchPageState();
}

class _CreateBatchPageState extends State<CreateBatchPage> {
  final _formKey = GlobalKey<FormState>();
  final SupplyChainService _supplyChainService = SupplyChainService();

  final TextEditingController _batchIdController = TextEditingController();
  final TextEditingController _metadataHashController = TextEditingController();
  final TextEditingController _metadataJsonController = TextEditingController();

  bool _isLoading = false;
  CreateBatchResponse? _lastResponse;
  List<Map<String, dynamic>> _medicines = [];
  Map<String, dynamic>? _selectedMedicine;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
    _generateBatchId();
  }

  @override
  void dispose() {
    _batchIdController.dispose();
    _metadataHashController.dispose();
    _metadataJsonController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicines() async {
    try {
      final jsonString = await rootBundle.loadString('assets/medicines.json');
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      setState(() {
        _medicines = decoded
            .whereType<Map<String, dynamic>>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load medicines: $e')));
    }
  }

  void _generateMetadataHash() {
    final payload = _metadataJsonController.text.trim();
    if (payload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter metadata JSON first.')),
      );
      return;
    }

    try {
      final hash = HashUtils.sha256HexFromJson(payload);
      setState(() {
        _metadataHashController.text = hash;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid JSON: $e')));
    }
  }

  void _selectMedicine(Map<String, dynamic>? medicine) {
    if (medicine == null) return;

    final payload = {
      'source': 'preset',
      'id': medicine['id'],
      'name': medicine['name'],
      'strength': medicine['strength'],
      'form': medicine['form'],
    };

    setState(() {
      _selectedMedicine = medicine;
      _metadataJsonController.text = jsonEncode(payload);
      _metadataHashController.text = HashUtils.sha256HexFromJson(
        _metadataJsonController.text,
      );
    });
  }

  void _generateBatchId() {
    final timestampHex = DateTime.now().millisecondsSinceEpoch.toRadixString(
      16,
    );
    final random = Random.secure();
    final randomBytes = List<int>.generate(4, (_) => random.nextInt(256));
    final randomHex = randomBytes
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();

    setState(() {
      _batchIdController.text = '0x$timestampHex$randomHex';
    });
  }

  Future<void> _createBatch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _lastResponse = null;
    });

    try {
      final response = await _supplyChainService.createBatch(
        CreateBatchRequest(
          batchId: _batchIdController.text.trim(),
          metadataHash: _metadataHashController.text.trim(),
        ),
      );

      if (!mounted) return;
      setState(() {
        _lastResponse = response;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Batch created successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create batch: $e')));
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
        title: const Text('Create Batch'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _createBatch,
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
              'Batch Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _batchIdController,
                    labelText: 'Batch ID (hex) *',
                    prefixIcon: const Icon(Icons.qr_code),
                    validator: (value) => Validators.validateHexString(
                      value,
                      fieldName: 'Batch ID',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _generateBatchId,
                  icon: const Icon(Icons.auto_fix_high),
                  tooltip: 'Generate Batch ID',
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Map<String, dynamic>>(
              value: _selectedMedicine,
              decoration: const InputDecoration(
                labelText: 'Select Medicine (preset)',
                border: OutlineInputBorder(),
              ),
              items: _medicines
                  .map(
                    (medicine) => DropdownMenuItem(
                      value: medicine,
                      child: Text(
                        '${medicine['name']} ${medicine['strength']} (${medicine['form']})',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _selectMedicine,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _metadataJsonController,
              labelText: 'Metadata JSON (optional)',
              prefixIcon: const Icon(Icons.data_object),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _generateMetadataHash,
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('Generate Hash'),
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _metadataHashController,
              labelText: 'Metadata Hash (hex) *',
              prefixIcon: const Icon(Icons.fingerprint),
              validator: (value) => Validators.validateHexString(
                value,
                fieldName: 'Metadata Hash',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _createBatch,
                icon: const Icon(Icons.send),
                label: const Text('Create Batch'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blue.shade700,
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

  Widget _buildReceiptCard(CreateBatchResponse response) {
    final receipt = response.receipt;
    final qrPayload = response.qrPayload ?? _buildUnsignedQrPayload();
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
            if (qrPayload != null) ...[
              const SizedBox(height: 16),
              const Text(
                'QR Payload',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Center(child: QrImageView(data: qrPayload, size: 180)),
            ],
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

  String? _buildUnsignedQrPayload() {
    final batchId = _batchIdController.text.trim();
    final metadataHash = _metadataHashController.text.trim();
    if (batchId.isEmpty || metadataHash.isEmpty) {
      return null;
    }

    final payload = {
      'batchId': batchId,
      'metadataHash': metadataHash,
      'issuer': 'MANUFACTURER',
      'issuedAt': DateTime.now().toUtc().toIso8601String(),
    };

    return jsonEncode(payload);
  }
}
