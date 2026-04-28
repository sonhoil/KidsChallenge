import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_challenge/core/services/push_notification_service.dart';
import 'package:kids_challenge/presentation/state/auth_provider.dart';
import 'package:kids_challenge/presentation/state/mission_provider.dart';

/// 푸시 탭·백그라운드 복귀 시 미션/포인트 관련 Provider를 다시 불러오도록 갱신합니다.
class PushLifecycleRefresher extends ConsumerStatefulWidget {
  const PushLifecycleRefresher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PushLifecycleRefresher> createState() => _PushLifecycleRefresherState();
}

class _PushLifecycleRefresherState extends ConsumerState<PushLifecycleRefresher>
    with WidgetsBindingObserver {
  StreamSubscription<RemoteMessage>? _openedSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PushNotificationService.onLocalNotificationTapped = _invalidateMissionData;

    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen((_) {
      _invalidateMissionData();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        await _invalidateAfterFamilyReady();
      }
    });
  }

  @override
  void dispose() {
    PushNotificationService.onLocalNotificationTapped = null;
    _openedSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _invalidateMissionData();
    }
  }

  Future<void> _invalidateAfterFamilyReady() async {
    for (var i = 0; i < 15; i++) {
      final family = ref.read(currentFamilyProvider);
      if (family != null) {
        _invalidateMissionData();
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
  }

  void _invalidateMissionData() {
    if (!ref.read(authStateProvider).isAuthenticated) return;
    final family = ref.read(currentFamilyProvider);
    if (family == null) return;

    if (family.role == 'parent') {
      ref.invalidate(pendingMissionsProvider(family.id));
      ref.invalidate(familyAssignmentsProvider(family.id));
      ref.invalidate(pointBalanceProvider(family.id));
    } else {
      ref.invalidate(myMissionsProvider);
      ref.invalidate(pointBalanceProvider(family.id));
      ref.invalidate(myApprovedMissionsThisWeekProvider);
      ref.invalidate(myApprovedMissionsByDateProvider(null));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
