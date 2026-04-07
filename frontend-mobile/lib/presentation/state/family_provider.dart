import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_challenge/data/models/family_model.dart';
import 'auth_provider.dart';

/// 특정 가족의 멤버 목록
final familyMembersProvider =
    FutureProvider.family<List<FamilyMemberModel>, String>((ref, familyId) async {
  final repo = ref.read(familyRepositoryProvider);
  return await repo.getFamilyMembers(familyId);
});

