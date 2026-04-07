import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/api_client.dart';
import '../../data/repositories/reward_repository.dart';
import '../../data/models/reward_model.dart';
import 'auth_provider.dart';

final rewardRepositoryProvider = Provider<RewardRepository>((ref) {
  return RewardRepository(ref.read(apiClientProvider));
});

final rewardsProvider = FutureProvider.family<List<RewardModel>, String>((ref, familyId) async {
  final repo = ref.read(rewardRepositoryProvider);
  return await repo.getRewardsByFamily(familyId, activeOnly: true);
});

final allRewardsProvider = FutureProvider.family<List<RewardModel>, String>((ref, familyId) async {
  final repo = ref.read(rewardRepositoryProvider);
  return await repo.getRewardsByFamily(familyId, activeOnly: false);
});

final myPurchasesProvider = FutureProvider<List<RewardPurchaseModel>>((ref) async {
  final repo = ref.read(rewardRepositoryProvider);
  return await repo.getMyPurchases();
});

final familyPurchasesProvider = FutureProvider.family<List<RewardPurchaseModel>, String>((ref, familyId) async {
  final repo = ref.read(rewardRepositoryProvider);
  return await repo.getFamilyPurchases(familyId);
});

typedef FamilyUserPurchaseQuery = ({String familyId, String userId});

final purchasesByUserProvider =
    FutureProvider.family<List<RewardPurchaseModel>, FamilyUserPurchaseQuery>((ref, query) async {
  final purchases = await ref.read(familyPurchasesProvider(query.familyId).future);
  final filtered = purchases.where((purchase) => purchase.buyerId == query.userId).toList();
  filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return filtered;
});

final usedPurchasesByUserProvider =
    FutureProvider.family<List<RewardPurchaseModel>, FamilyUserPurchaseQuery>((ref, query) async {
  final purchases = await ref.read(purchasesByUserProvider(query).future);
  return purchases
      .where((purchase) => purchase.buyerId == query.userId && purchase.status == 'used')
      .toList();
});

final rewardActionsProvider = Provider<RewardActions>((ref) {
  return RewardActions(ref.read(rewardRepositoryProvider), ref);
});

class RewardActions {
  final RewardRepository _repository;
  final Ref _ref;

  RewardActions(this._repository, this._ref);

  Future<void> purchaseReward(String rewardId, String familyId) async {
    await _repository.purchaseReward(rewardId);
    _ref.invalidate(rewardsProvider(familyId));
    _ref.invalidate(allRewardsProvider(familyId));
    _ref.invalidate(myPurchasesProvider);
    // pointBalanceProvider는 auth_provider에 정의되어 있음
    final pointProvider = pointBalanceProvider(familyId);
    _ref.invalidate(pointProvider);
  }

  Future<void> usePurchase(String purchaseId) async {
    await _repository.usePurchase(purchaseId);
    _ref.invalidate(myPurchasesProvider);
  }

  Future<void> updatePurchaseStatus(String familyId, String purchaseId, String status) async {
    await _repository.updatePurchaseStatus(purchaseId, status);
    _ref.invalidate(myPurchasesProvider);
    _ref.invalidate(familyPurchasesProvider(familyId));
  }

  Future<void> deleteReward(String rewardId, String familyId) async {
    await _repository.deleteReward(rewardId);
    _ref.invalidate(rewardsProvider(familyId));
    _ref.invalidate(allRewardsProvider(familyId));
  }

  Future<void> updateRewardVisibility(String rewardId, String familyId, bool isActive) async {
    await _repository.updateRewardVisibility(rewardId, isActive);
    _ref.invalidate(rewardsProvider(familyId));
    _ref.invalidate(allRewardsProvider(familyId));
  }
}
