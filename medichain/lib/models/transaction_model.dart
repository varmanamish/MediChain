// lib/models/transaction_model.dart
import 'package:medichain/models/drug_batch_model.dart';
import 'package:medichain/models/user_model.dart';

class BatchTransaction {
  final String id;
  final String batchId;
  final DrugBatch? batch;
  final String transactionType;
  final String fromUserId;
  final User? fromUser;
  final String? toUserId;
  final User? toUser;
  final String location;
  final double? latitude;
  final double? longitude;
  final double? temperature;
  final double? humidity;
  final String? notes;
  final String? blockchainTxHash;
  final int? blockchainBlockNumber;
  final DateTime timestamp;

  BatchTransaction({
    required this.id,
    required this.batchId,
    this.batch,
    required this.transactionType,
    required this.fromUserId,
    this.fromUser,
    this.toUserId,
    this.toUser,
    required this.location,
    this.latitude,
    this.longitude,
    this.temperature,
    this.humidity,
    this.notes,
    this.blockchainTxHash,
    this.blockchainBlockNumber,
    required this.timestamp,
  });

  factory BatchTransaction.fromJson(Map<String, dynamic> json) {
    return BatchTransaction(
      id: json['id'] ?? json['_id'] ?? '',
      batchId: json['batch_id'] ?? json['batchId'] ?? '',
      batch: json['batch'] != null
          ? DrugBatch.fromJson(json['batch'] is Map ? json['batch'] : {})
          : null,
      transactionType:
          json['transaction_type'] ?? json['transactionType'] ?? '',
      fromUserId: json['from_user_id'] ?? json['fromUserId'] ?? '',
      fromUser: json['from_user'] != null
          ? User.fromJson(json['from_user'] is Map ? json['from_user'] : {})
          : null,
      toUserId: json['to_user_id'] ?? json['toUserId'],
      toUser: json['to_user'] != null
          ? User.fromJson(json['to_user'] is Map ? json['to_user'] : {})
          : null,
      location: json['location'] ?? '',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      temperature: json['temperature'] != null
          ? double.tryParse(json['temperature'].toString())
          : null,
      humidity: json['humidity'] != null
          ? double.tryParse(json['humidity'].toString())
          : null,
      notes: json['notes'],
      blockchainTxHash: json['blockchain_tx_hash'] ?? json['blockchainTxHash'],
      blockchainBlockNumber:
          json['blockchain_block_number'] ?? json['blockchainBlockNumber'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_id': batchId,
      'transaction_type': transactionType,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'temperature': temperature,
      'humidity': humidity,
      'notes': notes,
      'blockchain_tx_hash': blockchainTxHash,
      'blockchain_block_number': blockchainBlockNumber,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get displayType {
    switch (transactionType) {
      case 'manufacture':
        return 'Manufactured';
      case 'ship':
        return 'Shipped';
      case 'receive':
        return 'Received';
      case 'sell':
        return 'Sold';
      case 'recall':
        return 'Recalled';
      default:
        return transactionType;
    }
  }

  String get displayIcon {
    switch (transactionType) {
      case 'manufacture':
        return '🏭';
      case 'ship':
        return '🚚';
      case 'receive':
        return '📦';
      case 'sell':
        return '💰';
      case 'recall':
        return '⚠️';
      default:
        return '📋';
    }
  }

  bool get hasEnvironmentalData => temperature != null || humidity != null;
  bool get hasLocationData => latitude != null && longitude != null;

  String get environmentalSummary {
    final parts = <String>[];
    if (temperature != null) {
      parts.add('$temperature°C');
    }
    if (humidity != null) {
      parts.add('$humidity% humidity');
    }
    return parts.join(', ');
  }

  BatchTransaction copyWith({
    String? id,
    String? batchId,
    DrugBatch? batch,
    String? transactionType,
    String? fromUserId,
    User? fromUser,
    String? toUserId,
    User? toUser,
    String? location,
    double? latitude,
    double? longitude,
    double? temperature,
    double? humidity,
    String? notes,
    String? blockchainTxHash,
    int? blockchainBlockNumber,
    DateTime? timestamp,
  }) {
    return BatchTransaction(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      batch: batch ?? this.batch,
      transactionType: transactionType ?? this.transactionType,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUser: fromUser ?? this.fromUser,
      toUserId: toUserId ?? this.toUserId,
      toUser: toUser ?? this.toUser,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      notes: notes ?? this.notes,
      blockchainTxHash: blockchainTxHash ?? this.blockchainTxHash,
      blockchainBlockNumber:
          blockchainBlockNumber ?? this.blockchainBlockNumber,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'BatchTransaction(id: $id, type: $transactionType, location: $location, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BatchTransaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Additional models for API responses and verification

class DrugVerification {
  final bool isValid;
  final bool isCounterfeit;
  final DrugBatch? batch;
  final List<BatchTransaction> transactionHistory;
  final String verificationMessage;
  final DateTime verifiedAt;

  DrugVerification({
    required this.isValid,
    required this.isCounterfeit,
    this.batch,
    required this.transactionHistory,
    required this.verificationMessage,
    required this.verifiedAt,
  });

  factory DrugVerification.fromJson(Map<String, dynamic> json) {
    return DrugVerification(
      isValid: json['is_valid'] ?? json['isValid'] ?? false,
      isCounterfeit: json['is_counterfeit'] ?? json['isCounterfeit'] ?? false,
      batch: json['batch'] != null
          ? DrugBatch.fromJson(json['batch'] is Map ? json['batch'] : {})
          : null,
      transactionHistory: json['transaction_history'] != null
          ? (json['transaction_history'] as List)
                .map((transaction) => BatchTransaction.fromJson(transaction))
                .toList()
          : json['transactions'] != null
          ? (json['transactions'] as List)
                .map((transaction) => BatchTransaction.fromJson(transaction))
                .toList()
          : [],
      verificationMessage:
          json['verification_message'] ??
          json['verificationMessage'] ??
          (json['is_valid'] ?? false ? 'Valid Drug' : 'Invalid Drug'),
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_valid': isValid,
      'is_counterfeit': isCounterfeit,
      'batch': batch?.toJson(),
      'transaction_history': transactionHistory.map((t) => t.toJson()).toList(),
      'verification_message': verificationMessage,
      'verified_at': verifiedAt.toIso8601String(),
    };
  }

  String get statusColor {
    if (isCounterfeit) return 'red';
    if (!isValid) return 'orange';
    return 'green';
  }

  String get statusText {
    if (isCounterfeit) return 'Counterfeit';
    if (!isValid) return 'Suspicious';
    return 'Authentic';
  }
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final dynamic error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : json['data'],
      error: json['error'],
      statusCode: json['status_code'] ?? json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'error': error,
      'status_code': statusCode,
    };
  }
}

class PaginatedResponse<T> {
  final List<T> results;
  final int count;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;

  PaginatedResponse({
    required this.results,
    required this.count,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      results: (json['results'] as List)
          .map((item) => fromJsonT(item))
          .toList(),
      count: json['count'] ?? 0,
      currentPage: json['current_page'] ?? json['currentPage'] ?? 1,
      totalPages: json['total_pages'] ?? json['totalPages'] ?? 1,
      pageSize: json['page_size'] ?? json['pageSize'] ?? 20,
      hasNext: json['has_next'] ?? json['hasNext'] ?? false,
      hasPrevious: json['has_previous'] ?? json['hasPrevious'] ?? false,
    );
  }
}
