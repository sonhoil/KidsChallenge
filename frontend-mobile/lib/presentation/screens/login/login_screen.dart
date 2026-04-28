import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_challenge/core/config/app_config.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/presentation/legal/app_terms_text.dart';
import 'package:kids_challenge/presentation/state/auth_provider.dart';
import 'package:kids_challenge/presentation/state/pending_invite_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? inviteCode;
  final String? memberId;

  const LoginScreen({
    super.key,
    this.inviteCode,
    this.memberId,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _persistInviteFromRoute();
    });
  }

  @override
  void didUpdateWidget(covariant LoginScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.inviteCode != oldWidget.inviteCode ||
        widget.memberId != oldWidget.memberId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _persistInviteFromRoute();
      });
    }
  }

  /// 라우트에 초대 파라미터가 있으면 pending에 복사해 GoRouter 재생성 시에도 유지합니다.
  void _persistInviteFromRoute() {
    if (widget.inviteCode != null && widget.inviteCode!.isNotEmpty) {
      storePendingInvite(ref, widget.inviteCode!, widget.memberId);
      print(
        '[LoginScreen] Invite from route → pending: ${widget.inviteCode}, memberId: ${widget.memberId}',
      );
    }
  }

  String? _effectiveInviteCode() =>
      widget.inviteCode ?? ref.read(pendingInviteCodeProvider);

  String? _effectiveMemberId() =>
      widget.memberId ?? ref.read(pendingMemberIdProvider);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('아이디와 비밀번호를 입력해주세요'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final success = await ref.read(authStateProvider.notifier).login(
      _usernameController.text,
      _passwordController.text,
      inviteCode: _effectiveInviteCode(),
      memberId: _effectiveMemberId(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _navigateAfterLogin();
    } else {
      final error = ref.read(authStateProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? '로그인에 실패했습니다'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _handleKakaoLogin() async {
    setState(() => _isLoading = true);
    
    final success = await ref.read(authStateProvider.notifier).loginWithKakao(
      inviteCode: _effectiveInviteCode(),
      memberId: _effectiveMemberId(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _navigateAfterLogin();
    } else {
      final error = ref.read(authStateProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? '카카오 로그인에 실패했습니다'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _handleAppleLogin() async {
    setState(() => _isLoading = true);
    final success = await ref.read(authStateProvider.notifier).loginWithApple(
          inviteCode: _effectiveInviteCode(),
          memberId: _effectiveMemberId(),
        );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      _navigateAfterLogin();
    } else {
      final error = ref.read(authStateProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Apple 로그인에 실패했습니다'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _showTermsDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight: MediaQuery.sizeOf(context).height * 0.88,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          AppTermsText.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppTermsText.fullText,
                            style: TextStyle(fontSize: 13, height: 1.5, color: AppTheme.slate800),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            AppTermsText.privacyNotice(AppConfig.apiOrigin),
                            style: const TextStyle(fontSize: 12, color: AppTheme.slate500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    
    final success = await ref.read(authStateProvider.notifier).loginWithGoogle(
      inviteCode: _effectiveInviteCode(),
      memberId: _effectiveMemberId(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _navigateAfterLogin();
    } else {
      final error = ref.read(authStateProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? '구글 로그인에 실패했습니다'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _navigateAfterLogin() {
    final family = ref.read(currentFamilyProvider);
    if (family == null) {
      return;
    }
    final role = family.role;
    if (role == 'parent') {
      context.go('/parent');
    } else {
      context.go('/child');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final pendingCode = ref.watch(pendingInviteCodeProvider);
    final pendingMember = ref.watch(pendingMemberIdProvider);
    final inviteCode = widget.inviteCode ?? pendingCode;
    final memberId = widget.memberId ?? pendingMember;

    if (authState.bootstrapping) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).vertical -
                    32,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '칭찬통장',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.slate800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                '집안일을 하고 포인트를 모아\n원하는 보상을 받아보세요!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.slate500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (inviteCode != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryLight),
                  ),
                  child: Text(
                    memberId != null
                        ? '초대 링크로 들어왔어요. 로그인하면 지정된 아이 프로필에 바로 연결됩니다.'
                        : '가족 초대 링크로 들어왔어요. 로그인하면 가족에 참여합니다.',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slate700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: '아이디',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                obscureText: true,
                onSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 16),
              // 테스트 로그인 버튼
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading || authState.isLoading ? null : () {
                    _usernameController.text = 'testuser';
                    _passwordController.text = 'Test1234!';
                    _handleLogin();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.slate600,
                    side: const BorderSide(color: AppTheme.slate300, width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '🧪 테스트 계정으로 로그인',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!kIsWeb && Theme.of(context).platform == TargetPlatform.iOS) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed:
                        _isLoading || authState.isLoading ? null : _handleAppleLogin,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading || authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.apple, size: 26, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Apple로 시작하기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || authState.isLoading ? null : _handleKakaoLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE500),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading || authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat_bubble_outline, size: 24),
                            const SizedBox(width: 8),
                            const Text(
                              '카카오로 시작하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading || authState.isLoading ? null : _handleGoogleLogin,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.slate700,
                    side: const BorderSide(color: AppTheme.slate200, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.g_mobiledata, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Google로 시작하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              TextButton.icon(
                onPressed: _showTermsDialog,
                icon: const Icon(Icons.article_outlined, size: 18, color: AppTheme.primary),
                label: const Text(
                  '서비스 이용약관 및 개인정보 안내 보기',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '가입·로그인 시 위 내용에 동의한 것으로 봅니다.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.slate400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
