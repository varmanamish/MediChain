// lib/views/distributor/update_transit_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/drug_batch_model.dart';
import '../../services/drug_service.dart';
import '../../services/location_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/status_badge.dart';

class UpdateTransitPage extends StatefulWidget {
  final DrugBatch batch;

  const UpdateTransitPage({super.key, required this.batch});

  @override
  _UpdateTransitPageState createState() => _UpdateTransitPageState();
}

class _UpdateTransitPageState extends State<UpdateTransitPage> {
  final DrugService _drugService = DrugService();
  final LocationService _locationService = LocationService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Form state
  String _transactionType = 'ship';
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  bool _isGettingLocation = false;
  bool _useCurrentLocation = true;
  Position? _currentPosition;

  // Environmental conditions
  double? _currentTemperature;
  double? _currentHumidity;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _getCurrentEnvironmentalConditions();
  }

  void _initializeForm() {
    // Set transaction type based on batch status
    _transactionType = widget.batch.status == 'created' ? 'ship' : 'receive';

    // Auto-get current location if enabled
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
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isGettingLocation = false;
      });

      // Get address from coordinates
      final address = await _locationService.getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );

      if (address != null) {
        _locationController.text = address;
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

  Future<void> _getCurrentEnvironmentalConditions() async {
    // In a real app, this would connect to environmental sensors
    // For now, we'll use mock data or leave it empty for manual entry
    setState(() {
      _currentTemperature = 22.5; // Mock temperature
      _currentHumidity = 65.0; // Mock humidity
    });
  }

  Future<void> _updateTransit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final transitData = {
        'batch_id': widget.batch.id,
        'transaction_type': _transactionType,
        'location': _locationController.text.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
        'temperature': _temperatureController.text.isNotEmpty
            ? double.parse(_temperatureController.text.trim())
            : null,
        'humidity': _humidityController.text.isNotEmpty
            ? double.parse(_humidityController.text.trim())
            : null,
        'notes': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      };

      final transaction = await _drugService.updateTransitDetails(transitData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transit details updated successfully!'),
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
            content: Text('Failed to update transit: $e'),
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

  void _scanAnotherBatch() {
    Navigator.pushReplacementNamed(context, '/distributor/scan');
  }

  void _showLocationPicker() async {
    // TODO: Implement map-based location picker
    // For now, show a dialog with manual location entry options
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
        title: const Text('Enter Location Manually'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _latitude = double.tryParse(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _longitude = double.tryParse(value);
                      },
                    ),
                  ),
                ],
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

  void _useCurrentEnvironmentalData() {
    if (_currentTemperature != null) {
      _temperatureController.text = _currentTemperature!.toStringAsFixed(1);
    }
    if (_currentHumidity != null) {
      _humidityController.text = _currentHumidity!.toStringAsFixed(1);
    }
  }

  void _clearEnvironmentalData() {
    _temperatureController.clear();
    _humidityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Transit Details'),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateTransit,
              tooltip: 'Save Transit Details',
            ),
        ],
      ),
      body: _isLoading ? _buildLoadingScreen() : _buildTransitForm(),
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
            'Updating Transit Details...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Please wait while we record the transaction on blockchain',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTransitForm() {
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

            // Transaction Type Section
            _buildTransactionTypeSection(),
            const SizedBox(height: 24),

            // Location Section
            _buildLocationSection(),
            const SizedBox(height: 24),

            // Environmental Conditions
            _buildEnvironmentalSection(),
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
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.medication,
                    color: Colors.orange,
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
                        'Manufacturer: ${_getManufacturerName()}',
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
          label: 'Quantity',
          value: '${widget.batch.quantity} units',
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

  Widget _buildTransactionTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transaction Type *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the type of transaction you are performing',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment<String>(
              value: 'ship',
              icon: Icon(Icons.local_shipping),
              label: Text('Ship Batch'),
            ),
            ButtonSegment<String>(
              value: 'receive',
              icon: Icon(Icons.inventory_2),
              label: Text('Receive Batch'),
            ),
          ],
          selected: {_transactionType},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              _transactionType = newSelection.first;
            });
          },
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getTransactionColor(_transactionType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _getTransactionIcon(_transactionType),
                color: _getTransactionColor(_transactionType),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getTransactionDescription(_transactionType),
                  style: TextStyle(
                    color: _getTransactionColor(_transactionType),
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

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location Details *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Record the current location of the batch',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _locationController,
          labelText: 'Location Address',
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
            const Text('Use current location'),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _showLocationPicker,
              icon: const Icon(Icons.map),
              label: const Text('Pick Location'),
            ),
          ],
        ),
        if (_latitude != null && _longitude != null) ...[
          const SizedBox(height: 8),
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
                    'Location captured: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEnvironmentalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Environmental Conditions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Optional: Record storage conditions during transit',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 12),

        // Environmental Data Actions
        if (_currentTemperature != null || _currentHumidity != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.sensors, color: Colors.blue.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sensor data available: '
                    '${_currentTemperature != null ? '$_currentTemperature°C' : ''}'
                    '${_currentTemperature != null && _currentHumidity != null ? ', ' : ''}'
                    '${_currentHumidity != null ? '$_currentHumidity% humidity' : ''}',
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: _useCurrentEnvironmentalData,
                  child: Text(
                    'Use This',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _temperatureController,
                labelText: 'Temperature (°C)',
                prefixIcon: Icon(Icons.thermostat),
                keyboardType: TextInputType.number,
                validator: Validators.validateTemperature,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _humidityController,
                labelText: 'Humidity (%)',
                prefixIcon: Icon(Icons.water_drop),
                keyboardType: TextInputType.number,
                validator: Validators.validateHumidity,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _clearEnvironmentalData,
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear'),
            ),
            const Spacer(),
            Text(
              'Ideal: 15-25°C, 45-65% humidity',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontStyle: FontStyle.italic,
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
          'Add any relevant notes about the transit, storage conditions, or observations',
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
                onPressed: _scanAnotherBatch,
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
                onPressed: _updateTransit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update Transit',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper methods
  Color _getTransactionColor(String type) {
    switch (type) {
      case 'ship':
        return Colors.orange;
      case 'receive':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'ship':
        return Icons.local_shipping;
      case 'receive':
        return Icons.inventory_2;
      default:
        return Icons.help_outline;
    }
  }

  String _getTransactionDescription(String type) {
    switch (type) {
      case 'ship':
        return 'Shipping this batch to the next destination in the supply chain';
      case 'receive':
        return 'Receiving this batch at your facility for storage or distribution';
      default:
        return 'Select a transaction type';
    }
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
    _temperatureController.dispose();
    _humidityController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
