import '../models/supply_chain_models.dart';
import 'api_service.dart';

class SupplyChainService {
  final ApiService _apiService = ApiService();

  Future<CreateBatchResponse> createBatch(CreateBatchRequest request) async {
    final response = await _apiService.post(
      '/supply-chain/batches',
      request.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CreateBatchResponse.fromJson(response.data);
    }

    throw Exception('Failed to create batch');
  }

  Future<TransferBatchResponse> transferBatch(
    TransferBatchRequest request,
  ) async {
    final response = await _apiService.post(
      '/supply-chain/batches/transfer',
      request.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return TransferBatchResponse.fromJson(response.data);
    }

    throw Exception('Failed to transfer batch');
  }

  Future<VerifyBatchResponse> verifyBatch(VerifyBatchRequest request) async {
    final response = await _apiService.post(
      '/supply-chain/batches/verify',
      request.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return VerifyBatchResponse.fromJson(response.data);
    }

    throw Exception('Failed to verify batch');
  }

  Future<SupplyChainBatch> getBatch(String batchId) async {
    final response = await _apiService.get('/supply-chain/batches/$batchId');

    if (response.statusCode == 200) {
      return SupplyChainBatch.fromJson(response.data);
    }

    throw Exception('Failed to load batch');
  }

  Future<List<int>> getBatchHistoryIndexes(String batchId) async {
    final response = await _apiService.get(
      '/supply-chain/batches/$batchId/history',
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is List) {
        return data.map((value) => int.parse(value.toString())).toList();
      }
      if (data is Map && data['indexes'] is List) {
        return (data['indexes'] as List)
            .map((value) => int.parse(value.toString()))
            .toList();
      }
      if (data is Map && data['indices'] is List) {
        return (data['indices'] as List)
            .map((value) => int.parse(value.toString()))
            .toList();
      }
      return [];
    }

    throw Exception('Failed to load history indexes');
  }

  Future<SupplyChainHistoryEntry> getBatchHistoryEntry(
    String batchId,
    int index,
  ) async {
    final response = await _apiService.get(
      '/supply-chain/batches/$batchId/history/$index',
    );

    if (response.statusCode == 200) {
      return SupplyChainHistoryEntry.fromJson(response.data);
    }

    throw Exception('Failed to load history entry');
  }
}
