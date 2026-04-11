import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 라우터 재생성·백그라운드 복귀 시에도 초대 코드가 유지되도록 메모리에 보관합니다.
final pendingInviteCodeProvider = StateProvider<String?>((ref) => null);

final pendingMemberIdProvider = StateProvider<String?>((ref) => null);

void clearPendingInvite(WidgetRef ref) {
  ref.read(pendingInviteCodeProvider.notifier).state = null;
  ref.read(pendingMemberIdProvider.notifier).state = null;
}

/// [AuthNotifier] 등 `Ref` 전용 컨텍스트에서 사용합니다.
void clearPendingInviteForRef(Ref ref) {
  ref.read(pendingInviteCodeProvider.notifier).state = null;
  ref.read(pendingMemberIdProvider.notifier).state = null;
}

void storePendingInvite(WidgetRef ref, String inviteCode, String? memberId) {
  ref.read(pendingInviteCodeProvider.notifier).state = inviteCode;
  ref.read(pendingMemberIdProvider.notifier).state = memberId;
}
