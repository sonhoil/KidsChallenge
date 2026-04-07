import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/api_client.dart';
import '../../data/repositories/mission_repository.dart';
import '../../data/models/mission_model.dart';
import 'auth_provider.dart';

final missionRepositoryProvider = Provider<MissionRepository>((ref) {
  return MissionRepository(ref.read(apiClientProvider));
});

final missionsProvider = FutureProvider.family<List<MissionModel>, String>((ref, familyId) async {
  final repo = ref.read(missionRepositoryProvider);
  return await repo.getMissionsByFamily(familyId);
});

final allMissionsProvider = FutureProvider.family<List<MissionModel>, String>((ref, familyId) async {
  final repo = ref.read(missionRepositoryProvider);
  return await repo.getMissionsByFamily(familyId, activeOnly: false);
});

final myMissionsProvider = FutureProvider<List<MissionAssignmentModel>>((ref) async {
  try {
    print('[Provider] myMissionsProvider: Starting...');
    final repo = ref.read(missionRepositoryProvider);
    final today = DateTime.now();
    final ymd = '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final result = await repo.getMyMissions(dueDate: ymd);
    print('[Provider] myMissionsProvider: Success, ${result.length} missions');
    return result;
  } catch (e, stack) {
    print('[Provider] myMissionsProvider: Error - $e');
    print('[Provider] Stack: $stack');
    rethrow;
  }
});

final myApprovedMissionsByDateProvider = FutureProvider.family<List<MissionAssignmentModel>, DateTime?>((ref, date) async {
  final repo = ref.read(missionRepositoryProvider);
  final target = date ?? DateTime.now();
  final ymd = '${target.year.toString().padLeft(4, '0')}-${target.month.toString().padLeft(2, '0')}-${target.day.toString().padLeft(2, '0')}';
  return await repo.getMyApprovedMissions(dueDate: ymd);
});

final myApprovedMissionsThisWeekProvider = FutureProvider<List<MissionAssignmentModel>>((ref) async {
  final repo = ref.read(missionRepositoryProvider);
  final now = DateTime.now();
  final start = now.subtract(const Duration(days: 6));
  String fmt(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  return await repo.getMyApprovedMissionsInRange(startDate: fmt(start), endDate: fmt(now));
});

final pendingMissionsProvider = FutureProvider.family<List<MissionAssignmentModel>, String>((ref, familyId) async {
  final repo = ref.read(missionRepositoryProvider);
  return await repo.getPendingMissions(familyId);
});

final familyAssignmentsProvider = FutureProvider.family<List<MissionAssignmentModel>, String>((ref, familyId) async {
  final repo = ref.read(missionRepositoryProvider);
  return await repo.getAssignmentsByFamily(familyId);
});

typedef FamilyUserMissionQuery = ({String familyId, String userId});

final familyUserMissionsProvider =
    FutureProvider.family<List<MissionAssignmentModel>, FamilyUserMissionQuery>((ref, query) async {
  final repo = ref.read(missionRepositoryProvider);
  return await repo.getMissionsByFamilyAndUser(query.familyId, query.userId);
});

final missionActionsProvider = Provider<MissionActions>((ref) {
  return MissionActions(ref.read(missionRepositoryProvider), ref);
});

class MissionActions {
  final MissionRepository _repository;
  final Ref _ref;

  MissionActions(this._repository, this._ref);

  Future<void> completeMission(String assignmentId) async {
    await _repository.completeMission(assignmentId);
    _ref.invalidate(myMissionsProvider);
  }

  Future<void> approveMission(String assignmentId) async {
    await _repository.approveMission(assignmentId);
    final familyId = _ref.read(currentFamilyProvider)?.id;
    if (familyId != null) {
      _ref.invalidate(pendingMissionsProvider(familyId));
      _ref.invalidate(familyAssignmentsProvider(familyId));
    }
    _ref.invalidate(myMissionsProvider);
    _ref.invalidate(myApprovedMissionsByDateProvider(null));
  }

  Future<void> rejectMission(String assignmentId, {String? comment}) async {
    await _repository.rejectMission(assignmentId, comment: comment);
    final familyId = _ref.read(currentFamilyProvider)?.id;
    if (familyId != null) {
      _ref.invalidate(pendingMissionsProvider(familyId));
      _ref.invalidate(familyAssignmentsProvider(familyId));
    }
    // 아이 화면도 즉시 갱신되도록 오늘자 할 일 무효화
    _ref.invalidate(myMissionsProvider);
  }

  Future<void> deleteMission(String missionId) async {
    await _repository.deleteMission(missionId);
    final familyId = _ref.read(currentFamilyProvider)?.id;
    if (familyId != null) {
      _ref.invalidate(missionsProvider(familyId));
      _ref.invalidate(allMissionsProvider(familyId));
      _ref.invalidate(pendingMissionsProvider(familyId));
      _ref.invalidate(familyAssignmentsProvider(familyId));
    }
  }

  Future<void> updateMissionVisibility(String missionId, bool isActive) async {
    await _repository.updateMissionVisibility(missionId, isActive);
    final familyId = _ref.read(currentFamilyProvider)?.id;
    if (familyId != null) {
      _ref.invalidate(missionsProvider(familyId));
      _ref.invalidate(allMissionsProvider(familyId));
      _ref.invalidate(pendingMissionsProvider(familyId));
      _ref.invalidate(familyAssignmentsProvider(familyId));
    }
  }
}
