// lib/services/drug_service.dart
import '../models/drug_batch_model.dart';
import '../models/transaction_model.dart';
import 'api_service.dart';

class DrugService {
  final ApiService _apiService = ApiService();

  // Batch Management Methods

  /// Create a new drug batch
  Future<DrugBatch> createBatch(Map<String, dynamic> batchData) async {
    try {
      final response = await _apiService.post('/api/batches/', batchData);

      if (response.statusCode == 201) {
        return DrugBatch.fromJson(response.data);
      } else {
        throw Exception('Failed to create batch: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Batch creation error: $e');
    }
  }

  /// Get all batches for the current user (manufacturer)
  Future<List<DrugBatch>> getMyBatches({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? search,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (status != null && status != 'all') {
        queryParameters['status'] = status;
      }

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      final response = await _apiService.get(
        '/api/batches/my-batches/',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return (response.data['results'] as List)
            .map((batch) => DrugBatch.fromJson(batch))
            .toList();
      } else {
        throw Exception('Failed to fetch batches: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Batch fetch error: $e');
    }
  }

  /// Get batch by ID
  Future<DrugBatch> getBatchById(String batchId) async {
    try {
      final response = await _apiService.get('/api/batches/$batchId/');

      if (response.statusCode == 200) {
        return DrugBatch.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch batch: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Batch fetch error: $e');
    }
  }

  /// Get batch by QR code data
  Future<DrugBatch> getBatchByQrCode(String qrData) async {
    try {
      final response = await _apiService.post(
        '/api/batches/scan-qr/',
        {'qr_data': qrData},
      );

      if (response.statusCode == 200) {
        return DrugBatch.fromJson(response.data['batch']);
      } else {
        throw Exception('Failed to scan batch: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('QR scan error: $e');
    }
  }

  /// Update batch information
  Future<DrugBatch> updateBatch(
      String batchId, Map<String, dynamic> updateData) async {
    try {
      final response = await _apiService.put(
        '/api/batches/$batchId/',
        updateData,
      );

      if (response.statusCode == 200) {
        return DrugBatch.fromJson(response.data);
      } else {
        throw Exception('Failed to update batch: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Batch update error: $e');
    }
  }

  /// Delete a batch (only for manufacturers)
  Future<bool> deleteBatch(String batchId) async {
    try {
      final response = await _apiService.delete('/api/batches/$batchId/');

      if (response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete batch: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Batch deletion error: $e');
    }
  }

  /// Recall a batch (mark as recalled)
  Future<bool> recallBatch(String batchId, String reason) async {
    try {
      final response = await _apiService.post(
        '/api/batches/$batchId/recall/',
        {'reason': reason},
      );

      if (response.statusCode == 200) {
        return response.data['success'] ?? false;
      } else {
        throw Exception('Failed to recall batch: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Batch recall error: $e');
    }
  }

  // Transaction Management Methods

  /// Update transit details for a batch
  Future<BatchTransaction> updateTransitDetails(
      Map<String, dynamic> transitData) async {
    try {
      final response = await _apiService.post(
        '/api/transactions/',
        transitData,
      );

      if (response.statusCode == 201) {
        return BatchTransaction.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to update transit: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Transit update error: $e');
    }
  }

  /// Get transaction history for a batch
  Future<List<BatchTransaction>> getBatchTransactions(
    String batchId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/batches/$batchId/transactions/',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        return (response.data['results'] as List)
            .map((transaction) => BatchTransaction.fromJson(transaction))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch transactions: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Transaction fetch error: $e');
    }
  }

  /// Get all transactions for the current user
  Future<List<BatchTransaction>> getMyTransactions({
    int page = 1,
    int pageSize = 20,
    String? transactionType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (transactionType != null) {
        queryParameters['transaction_type'] = transactionType;
      }

      if (startDate != null) {
        queryParameters['start_date'] = startDate.toIso8601String();
      }

      if (endDate != null) {
        queryParameters['end_date'] = endDate.toIso8601String();
      }

      final response = await _apiService.get(
        '/api/transactions/my-transactions/',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return (response.data['results'] as List)
            .map((transaction) => BatchTransaction.fromJson(transaction))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch transactions: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Transaction fetch error: $e');
    }
  }

  /// Get transaction by ID
  Future<BatchTransaction> getTransactionById(String transactionId) async {
    try {
      final response =
          await _apiService.get('/api/transactions/$transactionId/');

      if (response.statusCode == 200) {
        return BatchTransaction.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to fetch transaction: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Transaction fetch error: $e');
    }
  }

  // Verification Methods

  /// Verify drug authenticity
  Future<DrugVerification> verifyDrug(String batchHash) async {
    try {
      final response = await _apiService.get('/api/verify/$batchHash/');

      if (response.statusCode == 200) {
        return DrugVerification.fromJson(response.data);
      } else {
        throw Exception('Verification failed: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Drug verification error: $e');
    }
  }

  /// Get detailed verification report
  Future<Map<String, dynamic>> getDetailedVerification(String batchHash) async {
    try {
      final response =
          await _apiService.get('/api/verify/$batchHash/detailed/');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to get verification report: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Detailed verification error: $e');
    }
  }

  // Search and Filter Methods

  /// Search batches across the system
  Future<List<DrugBatch>> searchBatches({
    required String query,
    int page = 1,
    int pageSize = 20,
    String? manufacturerId,
    String? status,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'q': query,
        'page': page,
        'page_size': pageSize,
      };

      if (manufacturerId != null) {
        queryParameters['manufacturer_id'] = manufacturerId;
      }

      if (status != null) {
        queryParameters['status'] = status;
      }

      final response = await _apiService.get(
        '/api/batches/search/',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return (response.data['results'] as List)
            .map((batch) => DrugBatch.fromJson(batch))
            .toList();
      } else {
        throw Exception('Search failed: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Batch search error: $e');
    }
  }

  /// Get batches by status
  Future<List<DrugBatch>> getBatchesByStatus(
    String status, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/batches/',
        queryParameters: {
          'status': status,
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        return (response.data['results'] as List)
            .map((batch) => DrugBatch.fromJson(batch))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch batches by status: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Batch status fetch error: $e');
    }
  }

  /// Get batches expiring soon (within 30 days)
  Future<List<DrugBatch>> getExpiringBatches({int days = 30}) async {
    try {
      final response = await _apiService.get(
        '/api/batches/expiring-soon/',
        queryParameters: {'days': days},
      );

      if (response.statusCode == 200) {
        return (response.data['results'] as List)
            .map((batch) => DrugBatch.fromJson(batch))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch expiring batches: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Expiring batches fetch error: $e');
    }
  }

  // Analytics and Reports

  /// Get batch statistics for dashboard
  Future<Map<String, dynamic>> getBatchStats() async {
    try {
      final response = await _apiService.get('/api/batches/stats/');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to fetch batch stats: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Batch stats error: $e');
    }
  }

  /// Get transaction statistics
  Future<Map<String, dynamic>> getTransactionStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (startDate != null) {
        queryParameters['start_date'] = startDate.toIso8601String();
      }

      if (endDate != null) {
        queryParameters['end_date'] = endDate.toIso8601String();
      }

      final response = await _apiService.get(
        '/api/transactions/stats/',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to fetch transaction stats: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Transaction stats error: $e');
    }
  }

  /// Get supply chain analytics
  Future<Map<String, dynamic>> getSupplyChainAnalytics(String batchId) async {
    try {
      final response =
          await _apiService.get('/api/batches/$batchId/analytics/');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to fetch analytics: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Analytics fetch error: $e');
    }
  }

  // Inventory Management (for Pharmacies)

  /// Get pharmacy inventory
  Future<List<DrugBatch>> getPharmacyInventory({
    int page = 1,
    int pageSize = 20,
    String? search,
    bool? lowStock,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      if (lowStock != null) {
        queryParameters['low_stock'] = lowStock;
      }

      final response = await _apiService.get(
        '/api/inventory/',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return (response.data['results'] as List)
            .map((batch) => DrugBatch.fromJson(batch))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch inventory: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Inventory fetch error: $e');
    }
  }

  /// Update inventory quantity
  Future<DrugBatch> updateInventoryQuantity(
      String batchId, int newQuantity) async {
    try {
      final response = await _apiService.patch(
        '/api/inventory/$batchId/',
        {'quantity': newQuantity},
      );

      if (response.statusCode == 200) {
        return DrugBatch.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to update inventory: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Inventory update error: $e');
    }
  }

  /// Get low stock alerts
  Future<List<DrugBatch>> getLowStockAlerts({int threshold = 10}) async {
    try {
      final response = await _apiService.get(
        '/api/inventory/low-stock/',
        queryParameters: {'threshold': threshold},
      );

      if (response.statusCode == 200) {
        return (response.data['results'] as List)
            .map((batch) => DrugBatch.fromJson(batch))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch low stock alerts: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Low stock alerts error: $e');
    }
  }

  // Batch Operations

  /// Transfer batch to another user (distributor/pharmacy)
  Future<BatchTransaction> transferBatch({
    required String batchId,
    required String toUserId,
    required String location,
    String? notes,
    double? temperature,
    double? humidity,
  }) async {
    try {
      final transferData = {
        'batch_id': batchId,
        'to_user_id': toUserId,
        'location': location,
        'transaction_type': 'transfer',
        'notes': notes,
        'temperature': temperature,
        'humidity': humidity,
      };

      final response =
          await _apiService.post('/api/transactions/transfer/', transferData);

      if (response.statusCode == 201) {
        return BatchTransaction.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to transfer batch: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Batch transfer error: $e');
    }
  }

  /// Sell batch to end customer (pharmacy only)
  Future<BatchTransaction> sellBatch({
    required String batchId,
    required String customerInfo,
    required String location,
    int quantity = 1,
    String? notes,
  }) async {
    try {
      final sellData = {
        'batch_id': batchId,
        'customer_info': customerInfo,
        'location': location,
        'quantity': quantity,
        'transaction_type': 'sell',
        'notes': notes,
      };

      final response =
          await _apiService.post('/api/transactions/sell/', sellData);

      if (response.statusCode == 201) {
        return BatchTransaction.fromJson(response.data);
      } else {
        throw Exception('Failed to sell batch: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Batch sell error: $e');
    }
  }

  // Utility Methods

  /// Check if batch exists
  Future<bool> batchExists(String batchId) async {
    try {
      final response = await _apiService.get('/api/batches/$batchId/exists/');
      return response.statusCode == 200 && (response.data['exists'] ?? false);
    } catch (e) {
      return false;
    }
  }

  /// Validate batch data before creation
  Future<Map<String, dynamic>> validateBatchData(
      Map<String, dynamic> batchData) async {
    try {
      final response =
          await _apiService.post('/api/batches/validate/', batchData);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Validation failed: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Batch validation error: $e');
    }
  }

  /// Get batch timeline (all events in chronological order)
  Future<List<dynamic>> getBatchTimeline(String batchId) async {
    try {
      final response = await _apiService.get('/api/batches/$batchId/timeline/');

      if (response.statusCode == 200) {
        return response.data['timeline'] ?? [];
      } else {
        throw Exception(
            'Failed to fetch timeline: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Timeline fetch error: $e');
    }
  }

  /// Export batch data (for reports)
  Future<String> exportBatchData(String batchId,
      {String format = 'pdf'}) async {
    try {
      final response = await _apiService.get(
        '/api/batches/$batchId/export/',
        queryParameters: {'format': format},
      );

      if (response.statusCode == 200) {
        return response.data['download_url'] ?? '';
      } else {
        throw Exception(
            'Failed to export batch data: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Batch export error: $e');
    }
  }

  // Real-time Updates (WebSocket/SSE would be implemented here)
  Stream<BatchTransaction> getTransactionStream(String batchId) {
    // This would typically connect to a WebSocket or Server-Sent Events
    // For now, return an empty stream as placeholder
    return const Stream.empty();
  }

  Stream<List<DrugBatch>> getInventoryStream() {
    // Real-time inventory updates
    return const Stream.empty();
  }

  // Error handling and retry logic
  Future<T> retryOperation<T>(Future<T> Function() operation,
      {int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await operation();
      } catch (e) {
        if (i == maxRetries - 1) rethrow;
        await Future.delayed(Duration(seconds: 1 << i)); // Exponential backoff
      }
    }
    throw Exception('Operation failed after $maxRetries retries');
  }

  // Cache management (simple in-memory cache)
  final Map<String, dynamic> _cache = {};
  final Duration _cacheDuration = const Duration(minutes: 5);

  T? _getFromCache<T>(String key) {
    final cached = _cache[key];
    if (cached != null && cached is Map) {
      final timestamp = cached['timestamp'] as int;
      final data = cached['data'];
      if (DateTime.now().millisecondsSinceEpoch - timestamp <
          _cacheDuration.inMilliseconds) {
        return data as T;
      }
    }
    return null;
  }

  void _setToCache(String key, dynamic data) {
    _cache[key] = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': data,
    };
  }

  void clearCache() {
    _cache.clear();
  }
}
