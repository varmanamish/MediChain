// lib/views/pharmacy/scan_qr_page.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/drug_batch_model.dart';
import '../../services/drug_service.dart';
import '../pharmacy/confirm_delivery_page.dart';

class PharmacyScanQRPage extends StatefulWidget {
  const PharmacyScanQRPage({super.key});

  @override
  _PharmacyScanQRPageState createState() => _PharmacyScanQRPageState();
}

class _PharmacyScanQRPageState extends State<PharmacyScanQRPage> {
  final DrugService _drugService = DrugService();
  MobileScannerController cameraController = MobileScannerController();
  bool _isLoading = false;
  String _scannedData = '';
  DrugBatch? _scannedBatch;
  bool _isFlashOn = false;
  bool _isCameraFacingFront = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onBarcodeDetect(BarcodeCapture barcodes) {
    final barcode = barcodes.barcodes.first;
    if (barcode.rawValue == null) {
      return;
    }

    final String code = barcode.rawValue!;

    // Prevent multiple scans of the same code
    if (code == _scannedData) {
      return;
    }

    setState(() {
      _scannedData = code;
      _isLoading = true;
    });

    // Process the scanned QR code
    _processScannedCode(code);
  }

  Future<void> _processScannedCode(String code) async {
    try {
      // Stop camera to prevent multiple scans
      await cameraController.stop();

      // Fetch batch details from backend
      final batch = await _drugService.getBatchByQrCode(code);

      if (mounted) {
        setState(() {
          _scannedBatch = batch;
          _isLoading = false;
        });

        // Navigate to confirm delivery page
        _navigateToConfirmDelivery(batch);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _showErrorDialog('Failed to process QR code: $e');

        // Restart camera after error
        await cameraController.start();
      }
    }
  }

  void _navigateToConfirmDelivery(DrugBatch batch) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmDeliveryPage(batch: batch),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetScanner();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetScanner() async {
    setState(() {
      _scannedData = '';
      _scannedBatch = null;
    });
    await cameraController.start();
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    cameraController.toggleTorch();
  }

  void _switchCamera() {
    setState(() {
      _isCameraFacingFront = !_isCameraFacingFront;
    });
    cameraController.switchCamera();
  }

  void _enterCodeManually() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Batch Code'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter batch ID or QR code data',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              Navigator.pop(context);
              _processScannedCode(value);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final textField =
                  context.findAncestorStateOfType<State<TextField>>();
              // This would need proper form handling in a real implementation
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Delivery QR Code'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
            tooltip: 'Toggle Flash',
          ),
          IconButton(
            icon: Icon(
                _isCameraFacingFront ? Icons.camera_front : Icons.camera_rear),
            onPressed: _switchCamera,
            tooltip: 'Switch Camera',
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingScreen() : _buildScannerScreen(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _enterCodeManually,
        icon: const Icon(Icons.keyboard),
        label: const Text('Enter Code'),
        backgroundColor: Colors.green.shade700,
      ),
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
            'Processing QR Code...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Please wait while we fetch delivery details',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerScreen() {
    return Stack(
      children: [
        // QR Scanner
        MobileScanner(
          controller: cameraController,
          onDetect: _onBarcodeDetect,
          fit: BoxFit.cover,
        ),

        // Scanner Overlay
        _buildScannerOverlay(),

        // Instructions
        _buildInstructions(),

        // Scanned Data Preview (if any)
        if (_scannedData.isNotEmpty) _buildScannedDataPreview(),
      ],
    );
  }

  Widget _buildScannerOverlay() {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.4),
        BlendMode.srcOut,
      ),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              backgroundBlendMode: BlendMode.dstOut,
            ),
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping, color: Colors.white, size: 50),
                  const SizedBox(height: 16),
                  Text(
                    'Scan Delivery QR Code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Align the QR code on the drug package within the frame',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Scan the QR code to confirm drug delivery and update inventory',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannedDataPreview() {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery QR Code Scanned',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _scannedData.length > 30
                        ? '${_scannedData.substring(0, 30)}...'
                        : _scannedData,
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
