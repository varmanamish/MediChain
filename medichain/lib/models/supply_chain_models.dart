import 'dart:convert';

class SupplyChainReceipt {
  final String? txHash;
  final int? blockNumber;
  final int? gasUsed;
  final String? status;

  SupplyChainReceipt({
    this.txHash,
    this.blockNumber,
    this.gasUsed,
    this.status,
  });

  factory SupplyChainReceipt.fromJson(Map<String, dynamic> json) {
    return SupplyChainReceipt(
      txHash:
          json['txHash'] ??
          json['transactionHash'] ??
          json['tx_hash'] ??
          json['transaction_hash'],
      blockNumber: _toInt(json['blockNumber'] ?? json['block_number']),
      gasUsed: _toInt(json['gasUsed'] ?? json['gas_used']),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'txHash': txHash,
      'blockNumber': blockNumber,
      'gasUsed': gasUsed,
      'status': status,
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class CreateBatchRequest {
  final String batchId;
  final String metadataHash;

  CreateBatchRequest({required this.batchId, required this.metadataHash});

  Map<String, dynamic> toJson() {
    return {'batchId': batchId, 'metadataHash': metadataHash};
  }
}

class TransferBatchRequest {
  final String batchId;
  final String to;

  TransferBatchRequest({required this.batchId, required this.to});

  Map<String, dynamic> toJson() {
    return {'batchId': batchId, 'to': to};
  }
}

class VerifyBatchRequest {
  final String? batchId;
  final String? metadataHash;
  final String? qrPayload;

  VerifyBatchRequest({this.batchId, this.metadataHash, this.qrPayload});

  Map<String, dynamic> toJson() {
    if (qrPayload != null && qrPayload!.isNotEmpty) {
      return {'qrPayload': qrPayload};
    }
    return {'batchId': batchId, 'metadataHash': metadataHash};
  }
}

class CreateBatchResponse {
  final SupplyChainReceipt receipt;
  final String? qrPayload;

  CreateBatchResponse({required this.receipt, this.qrPayload});

  factory CreateBatchResponse.fromJson(Map<String, dynamic> json) {
    print('CreateBatchResponse JSON: $json');
    return CreateBatchResponse(
      receipt: SupplyChainReceipt.fromJson(_receiptFrom(json)),
      qrPayload: _extractQrPayload(json),
    );
  }

  static Map<String, dynamic> _receiptFrom(Map<String, dynamic> json) {
    if (json['receipt'] is Map<String, dynamic>) {
      return json['receipt'] as Map<String, dynamic>;
    }
    if (json['data'] is Map<String, dynamic> &&
        (json['data'] as Map<String, dynamic>)['receipt']
            is Map<String, dynamic>) {
      return (json['data'] as Map<String, dynamic>)['receipt']
          as Map<String, dynamic>;
    }
    return json;
  }

  static String? _extractQrPayload(Map<String, dynamic> json) {
    final direct =
        json['qrPayload'] ??
        json['qr_payload'] ??
        json['qr'] ??
        json['qrData'] ??
        json['payload'];
    final nested = json['data'] is Map<String, dynamic>
        ? (json['data'] as Map<String, dynamic>)
        : null;
    final nestedValue = nested == null
        ? null
        : (nested['qrPayload'] ??
              nested['qr_payload'] ??
              nested['qr'] ??
              nested['qrData'] ??
              nested['payload']);

    return _payloadToString(direct) ?? _payloadToString(nestedValue);
  }

  static String? _payloadToString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value is Map || value is List ? jsonEncode(value) : value.toString();
  }
}

class TransferBatchResponse {
  final SupplyChainReceipt receipt;

  TransferBatchResponse({required this.receipt});

  factory TransferBatchResponse.fromJson(Map<String, dynamic> json) {
    return TransferBatchResponse(
      receipt: SupplyChainReceipt.fromJson(
        CreateBatchResponse._receiptFrom(json),
      ),
    );
  }
}

class VerifyBatchResponse {
  final bool isValid;
  final SupplyChainReceipt receipt;
  final String? batchId;
  final String? metadataHash;

  VerifyBatchResponse({
    required this.isValid,
    required this.receipt,
    this.batchId,
    this.metadataHash,
  });

  factory VerifyBatchResponse.fromJson(Map<String, dynamic> json) {
    return VerifyBatchResponse(
      isValid: json['valid'] ?? json['isValid'] ?? false,
      receipt: SupplyChainReceipt.fromJson(
        CreateBatchResponse._receiptFrom(json),
      ),
      batchId: json['batchId'] ?? json['batch_id'],
      metadataHash: json['metadataHash'] ?? json['metadata_hash'],
    );
  }
}

class SupplyChainBatch {
  final String batchId;
  final String owner;
  final DateTime createdAt;
  final String state;
  final String metadataHash;

  SupplyChainBatch({
    required this.batchId,
    required this.owner,
    required this.createdAt,
    required this.state,
    required this.metadataHash,
  });

  factory SupplyChainBatch.fromJson(Map<String, dynamic> json) {
    return SupplyChainBatch(
      batchId: json['batchId'] ?? json['batch_id'] ?? '',
      owner: json['owner'] ?? '',
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      state: json['state']?.toString() ?? '',
      metadataHash: json['metadataHash'] ?? json['metadata_hash'] ?? '',
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.tryParse(value.toString()) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }
}

class SupplyChainHistoryEntry {
  final String owner;
  final String role;
  final DateTime timestamp;

  SupplyChainHistoryEntry({
    required this.owner,
    required this.role,
    required this.timestamp,
  });

  factory SupplyChainHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SupplyChainHistoryEntry(
      owner: json['owner'] ?? '',
      role: json['role'] ?? '',
      timestamp: SupplyChainBatch._parseDate(
        json['timestamp'] ?? json['time'] ?? json['createdAt'],
      ),
    );
  }
}
