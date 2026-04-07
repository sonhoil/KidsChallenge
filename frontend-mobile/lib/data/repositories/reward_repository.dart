import 'package:kids_challenge/data/datasources/api_client.dart';
import 'package:kids_challenge/data/models/reward_model.dart';
import 'package:kids_challenge/core/config/app_config.dart';

class RewardRepository {
  final ApiClient _apiClient;

  RewardRepository(this._apiClient);

  Future<List<RewardModel>> getRewardsByFamily(String familyId, {bool activeOnly = true}) async {
    final response = await _apiClient.get(
      '${AppConfig.rewards}/family/$familyId',
      queryParameters: {'activeOnly': activeOnly},
    );
    
    if (response.data['success'] == true && response.data['data'] != null) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => RewardModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<RewardModel> createReward(Map<String, dynamic> request) async {
    final response = await _apiClient.post(
      AppConfig.rewards,
      data: request,
    );
    
    if (response.data['success'] == true && response.data['data'] != null) {
      return RewardModel.fromJson(response.data['data']);
    }
    throw Exception('Failed to create reward');
  }

  Future<RewardModel> updateReward(String rewardId, Map<String, dynamic> request) async {
    final response = await _apiClient.put(
      '${AppConfig.rewards}/$rewardId',
      data: request,
    );

    if (response.data['success'] == true && response.data['data'] != null) {
      return RewardModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to update reward');
  }

  Future<void> deleteReward(String rewardId) async {
    final response = await _apiClient.delete(
      '${AppConfig.rewards}/$rewardId',
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to delete reward');
    }
  }

  Future<RewardModel> updateRewardVisibility(String rewardId, bool isActive) async {
    final response = await _apiClient.post(
      '${AppConfig.rewards}/$rewardId/visibility',
      data: {'isActive': isActive},
    );

    if (response.data['success'] == true && response.data['data'] != null) {
      return RewardModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to update reward visibility');
  }

  Future<RewardPurchaseModel> purchaseReward(String rewardId) async {
    final response = await _apiClient.post(
      '${AppConfig.rewards}/$rewardId/purchase',
    );
    
    if (response.data['success'] == true && response.data['data'] != null) {
      return RewardPurchaseModel.fromJson(response.data['data']);
    }
    throw Exception('Failed to purchase reward');
  }

  Future<List<RewardPurchaseModel>> getMyPurchases({String? status}) async {
    final response = await _apiClient.get(
      '${AppConfig.rewards}/me',
      queryParameters: status != null ? {'status': status} : null,
    );
    
    if (response.data['success'] == true && response.data['data'] != null) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => RewardPurchaseModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<RewardPurchaseModel>> getFamilyPurchases(String familyId) async {
    final response = await _apiClient.get(
      '${AppConfig.rewards}/family/$familyId/purchases',
    );

    if (response.data['success'] == true && response.data['data'] != null) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => RewardPurchaseModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<RewardPurchaseModel> usePurchase(String purchaseId) async {
    final response = await _apiClient.post(
      '${AppConfig.rewards}/purchases/$purchaseId/use',
    );
    
    if (response.data['success'] == true && response.data['data'] != null) {
      return RewardPurchaseModel.fromJson(response.data['data']);
    }
    throw Exception('Failed to use purchase');
  }

  Future<RewardPurchaseModel> updatePurchaseStatus(String purchaseId, String status) async {
    final response = await _apiClient.post(
      '${AppConfig.rewards}/purchases/$purchaseId/status',
      data: {'status': status},
    );

    if (response.data['success'] == true && response.data['data'] != null) {
      return RewardPurchaseModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to update purchase status');
  }
}
