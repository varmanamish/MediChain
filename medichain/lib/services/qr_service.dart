// lib/services/qr_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:medichain/storage/secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../models/drug_batch_model.dart';
import 'api_service.dart';

class QRService {
  final ApiService _apiService = ApiService();

  /// Generate the JSON data for a QR code representing a [DrugBatch].
  String generateQRData(DrugBatch batch) {
    final qrData = {
      'batch_id': batch.batchId,
      'drug_name': batch.drugName,
      'manufacturer_id': batch.manufacturerId,
      'manufacture_date': batch.manufactureDate.toIso8601String(),
      'expiry_date': batch.expiryDate.toIso8601String(),
      'blockchain_hash': batch.blockchainHash,
    };
    return jsonEncode(qrData);
  }

  /// Return a Flutter [QrImageView] widget for displaying the QR code.
  QrImageView generateQRCodeWidget(
    String data, {
    double size = 200,
    Color backgroundColor = Colors.white,
    Color foregroundColor = Colors.black,
  }) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      gapless: true,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      embeddedImage: const AssetImage('assets/images/logo.png'),
      embeddedImageStyle: QrEmbeddedImageStyle(
        size: Size(size * 0.2, size * 0.2),
      ),
    );
  }

  /// Generate and save a QR code as a PNG image in a temporary directory.
  Future<String> saveQRCodeAsImage(String data, {String? fileName}) async {
    try {
      final byteData = await QrPainter(
        data: data,
        version: QrVersions.auto,
        gapless: true,
        color: Colors.black,
        emptyColor: Colors.white,
      ).toImageData(200);

      if (byteData == null) {
        throw Exception('Failed to generate QR code image.');
      }

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/${fileName ?? 'qrcode_${DateTime.now().millisecondsSinceEpoch}'}.png';
      final file = File(filePath);

      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file.path;
    } catch (e) {
      throw Exception('Failed to save QR code: $e');
    }
  }

  /// Share a QR code image file via platform sharing.
  Future<void> shareQRCode(String data, {String? subject}) async {
    try {
      final path = await saveQRCodeAsImage(data);
      await Share.shareXFiles(
        [XFile(path)],
        subject: subject ?? 'PharmaTrace QR Code',
        text: 'Scan this QR code to verify the drug authenticity.',
      );
    } catch (e) {
      throw Exception('Failed to share QR code: $e');
    }
  }

  /// Generate a QR code for [DrugBatch], upload it to the server, and return its metadata.
  Future<QRCode> generateAndUploadQRCode(DrugBatch batch) async {
    try {
      final qrData = generateQRData(batch);
      final filePath = await saveQRCodeAsImage(
        qrData,
        fileName: 'batch_${batch.batchId}',
      );

      final response = await _apiService.uploadFile(
        '/api/batches/${batch.id}/qr-code/',
        filePath,
        fieldName: 'qr_image',
        additionalData: {'qr_data': qrData},
      );

      if (response.statusCode == 201) {
        return QRCode.fromJson(response.data['qr_code']);
      } else {
        throw Exception(
          'Failed to upload QR code: ${response.data['message']}',
        );
      }
    } catch (e) {
      throw Exception('QR code generation and upload error: $e');
    }
  }

  /// Decode and parse a JSON-encoded QR data string.
  Map<String, dynamic> parseQRData(String qrData) {
    try {
      return jsonDecode(qrData);
    } catch (e) {
      throw Exception('Invalid QR code data: $e');
    }
  }

  /// Validate that a decoded QR data map contains all required fields.
  bool validateQRData(Map<String, dynamic> qrData) {
    const requiredFields = [
      'batch_id',
      'drug_name',
      'manufacturer_id',
      'blockchain_hash',
    ];

    for (final field in requiredFields) {
      if (!qrData.containsKey(field) || qrData[field] == null) {
        return false;
      }
    }

    try {
      if (qrData['manufacture_date'] != null) {
        DateTime.parse(qrData['manufacture_date']);
      }
      if (qrData['expiry_date'] != null) {
        DateTime.parse(qrData['expiry_date']);
      }
    } catch (_) {
      return false;
    }

    return true;
  }

  /// Generate and upload QR codes for multiple [DrugBatch] instances.
  Future<List<QRCode>> generateBatchQRCodes(List<DrugBatch> batches) async {
    final results = <QRCode>[];

    for (final batch in batches) {
      try {
        final qrCode = await generateAndUploadQRCode(batch);
        results.add(qrCode);
      } catch (e) {
        debugPrint('Failed to generate QR code for batch ${batch.batchId}: $e');
      }
    }

    return results;
  }

  /// Retrieve a QR code object for a batch from the server.
  Future<QRCode> getQRCode(String batchId) async {
    try {
      final response = await _apiService.get('/api/batches/$batchId/qr-code/');
      return QRCode.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get QR code: $e');
    }
  }

  /// Check if a QR code is currently active.
  Future<bool> isQRCodeActive(String batchId) async {
    try {
      final qrCode = await getQRCode(batchId);
      return qrCode.isActive;
    } catch (_) {
      return false;
    }
  }

  /// Deactivate a QR code (e.g., for recalled or expired batches).
  Future<bool> deactivateQRCode(String batchId) async {
    try {
      final response = await _apiService.patch(
        '/api/batches/$batchId/qr-code/deactivate/',
        {},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Generate a custom-styled QR code with optional logo and colors.
  QrImageView generateStyledQRCode(
    String data, {
    double size = 200,
    Color? backgroundColor,
    Color? foregroundColor,
    String? logoPath,
  }) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      gapless: true,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? Colors.black,
      embeddedImage: logoPath != null ? FileImage(File(logoPath)) : null,
      embeddedImageStyle: logoPath != null
          ? QrEmbeddedImageStyle(size: Size(size * 0.15, size * 0.15))
          : null,
    );
  }

  /// Generate a high-resolution QR code for printing.
  Future<String> generateHighResQRCode(String data, {int size = 500}) async {
    try {
      final byteData = await QrPainter(
        data: data,
        version: QrVersions.auto,
        gapless: true,
        color: Colors.black,
        emptyColor: Colors.white,
      ).toImageData(size.toDouble());

      if (byteData == null) {
        throw Exception('Failed to generate high-res QR code.');
      }

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/highres_qrcode_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);

      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file.path;
    } catch (e) {
      throw Exception('Failed to generate high-res QR code: $e');
    }
  }
}

/// Generate a QR code as PNG bytes (Uint8List).
Future<Uint8List> generateQrPng(String data) async {
  final qrPainter = QrPainter(
    data: data,
    version: QrVersions.auto,
    gapless: false,
  );

  final ui.Image qrImage = await qrPainter.toImage(300);
  final byteData = await qrImage.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<void> logout() async {
  final SecureStorage secureStorage = SecureStorage();
  await secureStorage.clearAll();
}

Exception _handleDioError(DioException e) {
  if (e.response != null && e.response?.data != null) {
    final message = e.response?.data['message'] ?? 'An error occurred';
    return Exception(message);
  } else {
    return Exception('Network error: ${e.message}');
  }
}
