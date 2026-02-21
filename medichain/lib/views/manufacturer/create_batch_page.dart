// lib/views/manufacturer/create_batch_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/drug_batch_model.dart';
import '../../services/drug_service.dart';
import '../../widgets/custom_text_field.dart';

class CreateBatchPage extends StatefulWidget {
  const CreateBatchPage({super.key});

  @override
  _CreateBatchPageState createState() => _CreateBatchPageState();
}

class _CreateBatchPageState extends State<CreateBatchPage> {
  final _formKey = GlobalKey<FormState>();
  final DrugService _drugService = DrugService();

  // Form controllers
  final TextEditingController _drugNameController = TextEditingController();
  final TextEditingController _batchIdController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _compositionController = TextEditingController();
  final TextEditingController _dosageFormController = TextEditingController();
  final TextEditingController _storageConditionsController =
      TextEditingController();

  // Dates
  DateTime? _manufactureDate;
  DateTime? _expiryDate;

  bool _isLoading = false;
  bool _generateBatchId = true;

  @override
  void initState() {
    super.initState();
    _generateBatchIdController();
  }

  void _generateBatchIdController() {
    if (_generateBatchId) {
      final now = DateTime.now();
      final batchId = 'B${now.millisecondsSinceEpoch}';
      _batchIdController.text = batchId;
    }
  }

  @override
  void dispose() {
    _drugNameController.dispose();
    _batchIdController.dispose();
    _quantityController.dispose();
    _compositionController.dispose();
    _dosageFormController.dispose();
    _storageConditionsController.dispose();
    super.dispose();
  }

  Future<void> _createBatch() async {
    if (!_formKey.currentState!.validate()) return;
    if (_manufactureDate == null || _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select manufacture and expiry dates')),
      );
      return;
    }

    if (_expiryDate!.isBefore(_manufactureDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Expiry date must be after manufacture date')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final batchData = {
        'drug_name': _drugNameController.text.trim(),
        'batch_id': _batchIdController.text.trim(),
        'manufacture_date': _manufactureDate!.toIso8601String(),
        'expiry_date': _expiryDate!.toIso8601String(),
        'quantity': int.parse(_quantityController.text.trim()),
        'composition': _compositionController.text.trim(),
        'dosage_form': _dosageFormController.text.trim(),
        'storage_conditions': _storageConditionsController.text.trim(),
      };

      final newBatch = await _drugService.createBatch(batchData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batch created successfully!')),
        );

        // Navigate to batch details or QR generation
        Navigator.pop(context, newBatch);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create batch: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectManufactureDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _manufactureDate) {
      setState(() {
        _manufactureDate = picked;
      });
    }
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Batch'),
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
            // Drug Information Section
            _buildSectionHeader('Drug Information'),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _drugNameController,
              labelText: 'Drug Name *',
              prefixIcon: Icon(Icons.medication),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter drug name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Batch ID Section
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _batchIdController,
                    labelText: 'Batch ID *',
                    prefixIcon: Icon(Icons.qr_code),
                    readOnly: _generateBatchId,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter batch ID';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: _generateBatchId ? 'Manual Entry' : 'Auto Generate',
                  child: IconButton(
                    icon: Icon(_generateBatchId ? Icons.auto_mode : Icons.edit),
                    onPressed: () {
                      setState(() {
                        _generateBatchId = !_generateBatchId;
                        if (_generateBatchId) {
                          _generateBatchIdController();
                        } else {
                          _batchIdController.clear();
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date Selection
            _buildDateSelection(),
            const SizedBox(height: 16),

            // Quantity
            CustomTextField(
              controller: _quantityController,
              labelText: 'Quantity *',
              prefixIcon: Icon(Icons.format_list_numbered),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (int.parse(value) <= 0) {
                  return 'Quantity must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Drug Details Section
            _buildSectionHeader('Drug Details'),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _compositionController,
              labelText: 'Composition',
              prefixIcon: Icon(Icons.science),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _dosageFormController,
              labelText: 'Dosage Form',
              prefixIcon: Icon(Icons.medical_services),
              hintText: 'e.g., Tablet, Capsule, Syrup',
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _storageConditionsController,
              labelText: 'Storage Conditions',
              prefixIcon: Icon(Icons.ac_unit),
              maxLines: 2,
              hintText: 'e.g., Store at 2-8°C, Protect from light',
            ),
            const SizedBox(height: 32),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildDateSelection() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _selectManufactureDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Manufacture Date *',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _manufactureDate != null
                        ? DateFormat('MMM dd, yyyy').format(_manufactureDate!)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          _manufactureDate != null ? Colors.black : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: _selectExpiryDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.event_available,
                          color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Expiry Date *',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _expiryDate != null
                        ? DateFormat('MMM dd, yyyy').format(_expiryDate!)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      color: _expiryDate != null ? Colors.black : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _createBatch,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Create Batch',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
