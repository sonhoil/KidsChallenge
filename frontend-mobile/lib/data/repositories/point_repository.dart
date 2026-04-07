import 'package:kids_challenge/data/datasources/api_client.dart';
import 'package:kids_challenge/data/models/point_model.dart';
import 'package:kids_challenge/core/config/app_config.dart';

class PointRepository {
  final ApiClient _apiClient;

  PointRepository(this._apiClient);

  Future<PointBalanceModel> getBalance(String familyId) async {
    final response = await _apiClient.get(
      '${AppConfig.points}/balance/$familyId',
    );
    
    if (response.data['success'] == true && response.data['data'] != null) {
      return PointBalanceModel.fromJson(response.data['data']);
    }
    throw Exception('Failed to get balance');
  }

  Future<PointBalanceModel> getBalanceForUser(String familyId, String userId) async {
    final response = await _apiClient.get(
      '${AppConfig.points}/balance/$familyId/user/$userId',
    );

    if (response.data['success'] == true && response.data['data'] != null) {
      return PointBalanceModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to get member balance');
  }

  Future<List<PointTransactionModel>> getTransactions(String familyId, {int limit = 50}) async {
    final response = await _apiClient.get(
      '${AppConfig.points}/transactions/$familyId',
      queryParameters: {'limit': limit},
    );
    
    if (response.data['success'] == true && response.data['data'] != null) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => PointTransactionModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<PointBalanceModel> adjustPoints(Map<String, dynamic> request) async {
    final response = await _apiClient.post(
      '${AppConfig.points}/adjust',
      data: request,
    );
    
    if (response.data['success'] == true && response.data['data'] != null) {
      return PointBalanceModel.fromJson(response.data['data']);
    }
    throw Exception('Failed to adjust points');
  }
}
