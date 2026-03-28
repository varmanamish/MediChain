// lib/views/pharmacy/scan_qr_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/supply_chain_models.dart';
import '../../services/supply_chain_service.dart';
import '../supply_chain/transfer_batch_page.dart';

class PharmacyScanQRPage extends StatefulWidget {
  const PharmacyScanQRPage({super.key});

  @override
  _PharmacyScanQRPageState createState() => _PharmacyScanQRPageState();
}

class _PharmacyScanQRPageState extends State<PharmacyScanQRPage> {
  final SupplyChainService _supplyChainService = SupplyChainService();
  MobileScannerController cameraController = MobileScannerController();
  bool _isLoading = false;
  String _scannedData = '';
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
    await cameraController.stop();

    try {
      final response = await _verifyQrPayload(code);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (!response.isValid && !_isReceiptSuccessful(response.receipt)) {
        _showErrorDialog('QR verification failed.');
        await cameraController.start();
        return;
      }

      final batchId = _extractBatchId(code, response.batchId);
      if (batchId == null || batchId.isEmpty) {
        _showErrorDialog('Batch ID not found in QR payload.');
        await cameraController.start();
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TransferBatchPage(
            title: 'Transfer Batch (Pharmacy)',
            color: Colors.green.shade800,
            initialBatchId: batchId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to verify QR: $e');
      await cameraController.start();
    }
  }

  Future<VerifyBatchResponse> _verifyQrPayload(String code) async {
    try {
      return await _supplyChainService.verifyBatch(
        VerifyBatchRequest(qrPayload: code),
      );
    } catch (e) {
      if (!_isBadRequest(e)) rethrow;

      final batchId = _extractBatchId(code, null);
      final metadataHash = _extractMetadataHash(code);
      if (batchId == null || metadataHash == null) rethrow;

      return await _supplyChainService.verifyBatch(
        VerifyBatchRequest(batchId: batchId, metadataHash: metadataHash),
      );
    }
  }

  bool _isBadRequest(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('bad request') || message.contains('400');
  }

  bool _isReceiptSuccessful(SupplyChainReceipt receipt) {
    final status = receipt.status?.toString().toLowerCase();
    return status == '1' || status == '0x1' || status == 'success';
  }

  String? _extractBatchId(String qrPayload, String? fallback) {
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }

    try {
      final decoded = jsonDecode(qrPayload);
      if (decoded is Map<String, dynamic>) {
        return (decoded['batchId'] ?? decoded['batch_id'])?.toString();
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  String? _extractMetadataHash(String qrPayload) {
    try {
      final decoded = jsonDecode(qrPayload);
      if (decoded is Map<String, dynamic>) {
        return (decoded['metadataHash'] ?? decoded['metadata_hash'])
            ?.toString();
      }
    } catch (_) {
      return null;
    }

    return null;
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
            onPressed: () => Navigator.pop(context),
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
              _isCameraFacingFront ? Icons.camera_front : Icons.camera_rear,
            ),
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
