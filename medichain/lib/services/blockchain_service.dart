// lib/services/blockchain_service.dart
import '../models/drug_batch_model.dart';
import '../models/transaction_model.dart';
import 'api_service.dart';

class BlockchainService {
  final ApiService _apiService = ApiService();

  Future<DrugBatch> createBatchOnBlockchain(
      Map<String, dynamic> batchData) async {
    try {
      final response = await _apiService.post(
        '/api/blockchain/batches/create/',
        batchData,
      );

      if (response.statusCode == 201) {
        return DrugBatch.fromJson(response.data['batch']);
      } else {
        throw Exception(
            'Failed to create batch on blockchain: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Blockchain batch creation error: $e');
    }
  }

  Future<BatchTransaction> addTransactionToBlockchain(
      Map<String, dynamic> transactionData) async {
    try {
      final response = await _apiService.post(
        '/api/blockchain/transactions/add/',
        transactionData,
      );

      if (response.statusCode == 201) {
        return BatchTransaction.fromJson(response.data['transaction']);
      } else {
        throw Exception(
            'Failed to add transaction to blockchain: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Blockchain transaction error: $e');
    }
  }

  Future<DrugVerification> verifyDrugOnBlockchain(String batchHash) async {
    try {
      final response = await _apiService.get(
        '/api/blockchain/verify/$batchHash/',
      );

      if (response.statusCode == 200) {
        return DrugVerification.fromJson(response.data);
      } else {
        throw Exception('Verification failed: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Blockchain verification error: $e');
    }
  }

  Future<List<BatchTransaction>> getBatchTransactionHistory(
      String batchId) async {
    try {
      final response = await _apiService.get(
        '/api/blockchain/batches/$batchId/transactions/',
      );

      if (response.statusCode == 200) {
        return (response.data['transactions'] as List)
            .map((transaction) => BatchTransaction.fromJson(transaction))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch transaction history: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Blockchain history error: $e');
    }
  }

  Future<Map<String, dynamic>> getBatchFromBlockchain(String batchHash) async {
    try {
      final response = await _apiService.get(
        '/api/blockchain/batches/$batchHash/',
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to fetch batch from blockchain: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Blockchain batch fetch error: $e');
    }
  }

  Future<bool> checkBatchExists(String batchHash) async {
    try {
      final response = await _apiService.get(
        '/api/blockchain/batches/$batchHash/exists/',
      );

      if (response.statusCode == 200) {
        return response.data['exists'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getBlockchainStats() async {
    try {
      final response = await _apiService.get('/api/blockchain/stats/');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get blockchain stats: $e');
    }
  }

  Future<List<DrugBatch>> getBatchesByManufacturer(
      String manufacturerId) async {
    try {
      final response = await _apiService.get(
        '/api/blockchain/manufacturer/$manufacturerId/batches/',
      );

      if (response.statusCode == 200) {
        return (response.data['batches'] as List)
            .map((batch) => DrugBatch.fromJson(batch))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch manufacturer batches: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Blockchain manufacturer batches error: $e');
    }
  }

  Future<bool> recallBatchOnBlockchain(String batchId, String reason) async {
    try {
      final response = await _apiService.post(
        '/api/blockchain/batches/$batchId/recall/',
        {'reason': reason},
      );

      if (response.statusCode == 200) {
        return response.data['success'] ?? false;
      } else {
        throw Exception('Failed to recall batch: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Blockchain recall error: $e');
    }
  }

  // Real-time blockchain event listening (WebSocket)
  Stream<Map<String, dynamic>> listenToBlockchainEvents() {
    // This would typically use WebSockets for real-time updates
    // For now, returning an empty stream as placeholder
    return const Stream.empty();
  }

  // Batch verification with detailed report
  Future<Map<String, dynamic>> getDetailedVerificationReport(
      String batchHash) async {
    try {
      final response = await _apiService.get(
        '/api/blockchain/verify/$batchHash/detailed/',
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to get detailed verification: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Detailed verification error: $e');
    }
  }

  // Check if batch has been tampered with
  Future<bool> checkBatchIntegrity(String batchHash) async {
    try {
      final response = await _apiService.get(
        '/api/blockchain/batches/$batchHash/integrity/',
      );

      if (response.statusCode == 200) {
        return response.data['integrity_ok'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
