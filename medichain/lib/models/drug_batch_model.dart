// lib/models/drug_batch_model.dart
import 'package:medichain/models/transaction_model.dart';
import 'package:medichain/models/user_model.dart';

class DrugBatch {
  final String id;
  final String batchId;
  final String drugName;
  final String manufacturerId;
  final User? manufacturer;
  final DateTime manufactureDate;
  final DateTime expiryDate;
  final int quantity;
  final String? composition;
  final String? dosageForm;
  final String? storageConditions;
  final String status;
  final String? blockchainHash;
  final String? blockchainTxHash;
  final DateTime createdAt;
  final DateTime updatedAt;
  final QRCode? qrCode;
  final List<BatchTransaction>? transactions;

  DrugBatch({
    required this.id,
    required this.batchId,
    required this.drugName,
    required this.manufacturerId,
    this.manufacturer,
    required this.manufactureDate,
    required this.expiryDate,
    required this.quantity,
    this.composition,
    this.dosageForm,
    this.storageConditions,
    required this.status,
    this.blockchainHash,
    this.blockchainTxHash,
    required this.createdAt,
    required this.updatedAt,
    this.qrCode,
    this.transactions,
  });

  factory DrugBatch.fromJson(Map<String, dynamic> json) {
    return DrugBatch(
      id: json['id'] ?? json['_id'] ?? '',
      batchId: json['batch_id'] ?? json['batchId'] ?? '',
      drugName: json['drug_name'] ?? json['drugName'] ?? '',
      manufacturerId: json['manufacturer_id'] ?? json['manufacturerId'] ?? '',
      manufacturer: json['manufacturer'] != null
          ? User.fromJson(
              json['manufacturer'] is Map ? json['manufacturer'] : {},
            )
          : null,
      manufactureDate: json['manufacture_date'] != null
          ? DateTime.parse(json['manufacture_date'])
          : json['manufactureDate'] != null
          ? DateTime.parse(json['manufactureDate'])
          : DateTime.now(),
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : DateTime.now().add(const Duration(days: 365)),
      quantity: json['quantity'] ?? 0,
      composition: json['composition'],
      dosageForm: json['dosage_form'] ?? json['dosageForm'],
      storageConditions:
          json['storage_conditions'] ?? json['storageConditions'],
      status: json['status'] ?? 'created',
      blockchainHash: json['blockchain_hash'] ?? json['blockchainHash'],
      blockchainTxHash: json['blockchain_tx_hash'] ?? json['blockchainTxHash'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      qrCode: json['qr_code'] != null
          ? QRCode.fromJson(json['qr_code'] is Map ? json['qr_code'] : {})
          : null,
      transactions: json['transactions'] != null
          ? (json['transactions'] as List)
                .map((transaction) => BatchTransaction.fromJson(transaction))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_id': batchId,
      'drug_name': drugName,
      'manufacturer_id': manufacturerId,
      'manufacture_date': manufactureDate.toIso8601String(),
      'expiry_date': expiryDate.toIso8601String(),
      'quantity': quantity,
      'composition': composition,
      'dosage_form': dosageForm,
      'storage_conditions': storageConditions,
      'status': status,
      'blockchain_hash': blockchainHash,
      'blockchain_tx_hash': blockchainTxHash,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'qr_code': qrCode?.toJson(),
      'transactions': transactions?.map((t) => t.toJson()).toList(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get willExpireSoon {
    final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
    return expiryDate.isBefore(thirtyDaysFromNow) && !isExpired;
  }

  int get daysUntilExpiry {
    final now = DateTime.now();
    return expiryDate.difference(now).inDays;
  }

  String get expiryStatus {
    if (isExpired) return 'Expired';
    if (willExpireSoon) return 'Expiring Soon';
    return 'Valid';
  }

  DrugBatch copyWith({
    String? id,
    String? batchId,
    String? drugName,
    String? manufacturerId,
    User? manufacturer,
    DateTime? manufactureDate,
    DateTime? expiryDate,
    int? quantity,
    String? composition,
    String? dosageForm,
    String? storageConditions,
    String? status,
    String? blockchainHash,
    String? blockchainTxHash,
    DateTime? createdAt,
    DateTime? updatedAt,
    QRCode? qrCode,
    List<BatchTransaction>? transactions,
  }) {
    return DrugBatch(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      drugName: drugName ?? this.drugName,
      manufacturerId: manufacturerId ?? this.manufacturerId,
      manufacturer: manufacturer ?? this.manufacturer,
      manufactureDate: manufactureDate ?? this.manufactureDate,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      composition: composition ?? this.composition,
      dosageForm: dosageForm ?? this.dosageForm,
      storageConditions: storageConditions ?? this.storageConditions,
      status: status ?? this.status,
      blockchainHash: blockchainHash ?? this.blockchainHash,
      blockchainTxHash: blockchainTxHash ?? this.blockchainTxHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      qrCode: qrCode ?? this.qrCode,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  String toString() {
    return 'DrugBatch(id: $id, batchId: $batchId, drugName: $drugName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DrugBatch && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class QRCode {
  final String id;
  final String batchId;
  final String qrData;
  final String? qrImage;
  final bool isActive;
  final DateTime createdAt;

  QRCode({
    required this.id,
    required this.batchId,
    required this.qrData,
    this.qrImage,
    required this.isActive,
    required this.createdAt,
  });

  factory QRCode.fromJson(Map<String, dynamic> json) {
    return QRCode(
      id: json['id'] ?? json['_id'] ?? '',
      batchId: json['batch_id'] ?? json['batchId'] ?? '',
      qrData: json['qr_data'] ?? json['qrData'] ?? '',
      qrImage: json['qr_image'] ?? json['qrImage'],
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_id': batchId,
      'qr_data': qrData,
      'qr_image': qrImage,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  QRCode copyWith({
    String? id,
    String? batchId,
    String? qrData,
    String? qrImage,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return QRCode(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      qrData: qrData ?? this.qrData,
      qrImage: qrImage ?? this.qrImage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'QRCode(id: $id, batchId: $batchId, isActive: $isActive)';
  }
}
