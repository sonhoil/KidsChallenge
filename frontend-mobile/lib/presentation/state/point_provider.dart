import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_challenge/data/models/point_model.dart';
import 'package:kids_challenge/presentation/state/auth_provider.dart';

typedef PointBalanceQuery = ({String familyId, String userId});

final memberPointBalanceProvider =
    FutureProvider.family<int, PointBalanceQuery>((ref, query) async {
  final repo = ref.read(pointRepositoryProvider);
  final balance = await repo.getBalanceForUser(query.familyId, query.userId);
  return balance.balance;
});

final pointActionsProvider = Provider<PointActions>((ref) {
  return PointActions(ref);
});

class PointActions {
  final Ref _ref;

  PointActions(this._ref);

  Future<PointBalanceModel> adjustMemberPoints({
    required String familyId,
    required String targetUserId,
    required int signedAmount,
    String? reason,
  }) async {
    final repo = _ref.read(pointRepositoryProvider);
    final amount = signedAmount.abs();
    final response = await repo.adjustPoints({
      'familyId': familyId,
      'targetUserId': targetUserId,
      'amount': amount,
      'isEarn': signedAmount >= 0,
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    });

    _ref.invalidate(memberPointBalanceProvider((familyId: familyId, userId: targetUserId)));
    _ref.invalidate(pointBalanceProvider(familyId));

    return response;
  }
}

