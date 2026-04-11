import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/pending_invite_provider.dart';

/// 백그라운드에서 열린 앱이 `kidspoint://app/login?...` 인텐트를 받아도
/// GoRouter가 갱신되지 않는 문제를 보완하고, 초대 파라미터를 pending에 저장합니다.
class InviteLinkListener extends ConsumerStatefulWidget {
  const InviteLinkListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<InviteLinkListener> createState() => _InviteLinkListenerState();
}

class _InviteLinkListenerState extends ConsumerState<InviteLinkListener> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _init();
  }

  Future<void> _init() async {
    final initial = await _appLinks.getInitialLink();
    if (mounted) {
      _handleUri(initial);
    }
    _sub = _appLinks.uriLinkStream.listen(_handleUri, onError: (_) {});
  }

  void _handleUri(Uri? uri) {
    if (uri == null || !mounted) return;
    if (uri.scheme != 'kidspoint' || uri.host != 'app') return;
    if (uri.path != '/login' && !uri.path.endsWith('/login')) return;

    final inviteCode = uri.queryParameters['inviteCode'];
    if (inviteCode == null || inviteCode.isEmpty) return;

    final memberId = uri.queryParameters['memberId'];
    final target = Uri(path: '/login', queryParameters: uri.queryParameters).toString();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      storePendingInvite(ref, inviteCode, memberId);
      GoRouter.of(context).go(target);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
