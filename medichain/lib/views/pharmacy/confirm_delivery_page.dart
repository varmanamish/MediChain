// lib/views/pharmacy/confirm_delivery_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/drug_batch_model.dart';
import '../../services/drug_service.dart';
import '../../services/location_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/status_badge.dart';

class ConfirmDeliveryPage extends StatefulWidget {
  final DrugBatch batch;

  const ConfirmDeliveryPage({super.key, required this.batch});

  @override
  _ConfirmDeliveryPageState createState() => _ConfirmDeliveryPageState();
}

class _ConfirmDeliveryPageState extends State<ConfirmDeliveryPage> {
  final DrugService _drugService = DrugService();
  final LocationService _locationService = LocationService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _storageTemperatureController =
      TextEditingController();
  final TextEditingController _storageHumidityController =
      TextEditingController();
  final TextEditingController _receivedQuantityController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Form state
  bool _isLoading = false;
  bool _isGettingLocation = false;
  bool _useCurrentLocation = true;
  bool _quantityMatches = true;
  Position? _currentPosition;
  int _receivedQuantity = 0;

  // Storage conditions
  final List<String> _storageConditions = [
    'Room Temperature (15-25°C)',
    'Refrigerated (2-8°C)',
    'Frozen (-20°C)',
    'Controlled Room Temperature',
    'Other',
  ];
  String _selectedStorageCondition = 'Room Temperature (15-25°C)';

  // Damage assessment
  bool _packageIntact = true;
  bool _sealsIntact = true;
  bool _temperatureCompliant = true;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _receivedQuantity = widget.batch.quantity;
    _receivedQuantityController.text = _receivedQuantity.toString();
  }

  void _initializeForm() {
    if (_useCurrentLocation) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!_useCurrentLocation) return;

    setState(() {
      _isGettingLocation = true;
    });

    try {
      final position = await _locationService.getCurrentPosition();

      setState(() {
        _currentPosition = position;
        _isGettingLocation = false;
      });

      // Get address from coordinates
      final address = await _locationService.getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );

      if (address != null) {
        _locationController.text = '$address (Pharmacy Location)';
      }
    } catch (e) {
      setState(() {
        _isGettingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDelivery() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_packageIntact || !_sealsIntact || !_temperatureCompliant) {
      final shouldProceed = await _showQualityCheckWarning();
      if (!shouldProceed) {
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final deliveryData = {
        'batch_id': widget.batch.id,
        'transaction_type': 'receive',
        'location': _locationController.text.trim(),
        'latitude': _currentPosition?.latitude,
        'longitude': _currentPosition?.longitude,
        'received_quantity': int.parse(_receivedQuantityController.text.trim()),
        'storage_condition': _selectedStorageCondition,
        'storage_temperature': _storageTemperatureController.text.isNotEmpty
            ? double.parse(_storageTemperatureController.text.trim())
            : null,
        'storage_humidity': _storageHumidityController.text.isNotEmpty
            ? double.parse(_storageHumidityController.text.trim())
            : null,
        'package_intact': _packageIntact,
        'seals_intact': _sealsIntact,
        'temperature_compliant': _temperatureCompliant,
        'notes': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      };

      final transaction = await _drugService.updateTransitDetails(deliveryData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery confirmed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back with success result
        Navigator.pop(context, transaction);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to confirm delivery: $e'),
            backgroundColor: Colors.red,
          ),
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

  Future<bool> _showQualityCheckWarning() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quality Check Issues'),
            content: const Text(
              'You have reported issues with the delivery quality. '
              'Are you sure you want to accept this delivery? '
              'This will be recorded in the blockchain permanently.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Accept Anyway',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showLocationPicker() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Location Method'),
        content: const Text('Choose how you want to set the location'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _useCurrentLocation = true;
              _getCurrentLocation();
            },
            child: const Text('Use Current Location'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showManualLocationEntry();
            },
            child: const Text('Enter Manually'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showManualLocationEntry() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Pharmacy Location'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Pharmacy Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _useCurrentLocation = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _scanAnotherDelivery() {
    Navigator.pushReplacementNamed(context, '/pharmacy/scan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Delivery'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: _confirmDelivery,
              tooltip: 'Confirm Delivery',
            ),
        ],
      ),
      body: _isLoading ? _buildLoadingScreen() : _buildDeliveryForm(),
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
            'Confirming Delivery...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Recording transaction on blockchain',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Batch Information Card
            _buildBatchInfoCard(),
            const SizedBox(height: 24),

            // Delivery Location Section
            _buildLocationSection(),
            const SizedBox(height: 24),

            // Quantity Verification
            _buildQuantitySection(),
            const SizedBox(height: 24),

            // Quality Check Section
            _buildQualityCheckSection(),
            const SizedBox(height: 24),

            // Storage Conditions
            _buildStorageSection(),
            const SizedBox(height: 24),

            // Additional Notes
            _buildNotesSection(),
            const SizedBox(height: 32),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_pharmacy,
                    color: Colors.green,
                    size: 24,
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
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Batch: ${widget.batch.batchId}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'From: ${_getManufacturerName()}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: widget.batch.status),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 8),
            _buildBatchDetailsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchDetailsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildDetailItem(
          icon: Icons.calendar_today,
          label: 'Manufactured',
          value: DateFormat(
            'MMM dd, yyyy',
          ).format(widget.batch.manufactureDate),
        ),
        _buildDetailItem(
          icon: Icons.event_available,
          label: 'Expires',
          value: DateFormat('MMM dd, yyyy').format(widget.batch.expiryDate),
        ),
        _buildDetailItem(
          icon: Icons.inventory_2,
          label: 'Expected Qty',
          value: '${widget.batch.quantity}',
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery Location *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Where is this batch being stored?',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _locationController,
          labelText: 'Pharmacy Storage Location',
          prefixIcon: Icon(Icons.location_on),
          validator: Validators.validateLocation,
          readOnly: _isGettingLocation,
          suffixIcon: _isGettingLocation
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: _useCurrentLocation,
              onChanged: (value) {
                setState(() {
                  _useCurrentLocation = value ?? false;
                });
                if (_useCurrentLocation) {
                  _getCurrentLocation();
                }
              },
            ),
            const Text('Use current pharmacy location'),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _showLocationPicker,
              icon: const Icon(Icons.map),
              label: const Text('Pick Location'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantity Verification *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Verify the received quantity matches the expected quantity',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        'Expected',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${widget.batch.quantity}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'units',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _receivedQuantityController,
                labelText: 'Received Quantity',
                prefixIcon: Icon(Icons.inventory_2),
                keyboardType: TextInputType.number,
                validator: (value) => Validators.validatePositiveNumber(
                  value,
                  fieldName: 'Received quantity',
                ),
                onChanged: (value) {
                  final received = int.tryParse(value) ?? 0;
                  setState(() {
                    _quantityMatches = received == widget.batch.quantity;
                    _receivedQuantity = received;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!_quantityMatches)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Quantity mismatch: Expected ${widget.batch.quantity}, Received $_receivedQuantity',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildQualityCheckSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quality Check *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Verify the condition of the delivered goods',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildQualityCheckItem(
                  label: 'Package is intact and undamaged',
                  value: _packageIntact,
                  onChanged: (value) => setState(() => _packageIntact = value!),
                ),
                const SizedBox(height: 12),
                _buildQualityCheckItem(
                  label: 'Security seals are intact',
                  value: _sealsIntact,
                  onChanged: (value) => setState(() => _sealsIntact = value!),
                ),
                const SizedBox(height: 12),
                _buildQualityCheckItem(
                  label: 'Temperature during transit was compliant',
                  value: _temperatureCompliant,
                  onChanged: (value) =>
                      setState(() => _temperatureCompliant = value!),
                ),
              ],
            ),
          ),
        ),
        if (!_packageIntact || !_sealsIntact || !_temperatureCompliant) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.red.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Quality issues detected. This will be recorded in the blockchain.',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQualityCheckItem({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: value ? Colors.green.shade700 : Colors.grey.shade600,
              fontWeight: value ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStorageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Storage Conditions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'How will this batch be stored in your pharmacy?',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedStorageCondition,
          decoration: const InputDecoration(
            labelText: 'Storage Condition',
            border: OutlineInputBorder(),
          ),
          items: _storageConditions.map((condition) {
            return DropdownMenuItem(value: condition, child: Text(condition));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedStorageCondition = value!;
            });
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _storageTemperatureController,
                labelText: 'Storage Temperature (°C)',
                prefixIcon: Icon(Icons.thermostat),
                keyboardType: TextInputType.number,
                validator: Validators.validateTemperature,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _storageHumidityController,
                labelText: 'Storage Humidity (%)',
                prefixIcon: Icon(Icons.water_drop),
                keyboardType: TextInputType.number,
                validator: Validators.validateHumidity,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Notes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Any observations about the delivery or storage conditions',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _notesController,
          labelText: 'Notes (Optional)',
          prefixIcon: Icon(Icons.note),
          maxLines: 4,
          validator: Validators.validateNotes,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Validation Summary
        if (_formKey.currentState != null && _formKey.currentState!.validate())
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'All required fields are complete and valid',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _scanAnotherDelivery,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Scan Another'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _confirmDelivery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirm Delivery',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getManufacturerName() {
    // return widget.batch.manufacturer?.companyName ??
    //     widget.batch.manufacturer?.fullName ??
    //     'Unknown Manufacturer';
    return 'Unknown Manufacturer';
  }

  @override
  void dispose() {
    _locationController.dispose();
    _storageTemperatureController.dispose();
    _storageHumidityController.dispose();
    _receivedQuantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
