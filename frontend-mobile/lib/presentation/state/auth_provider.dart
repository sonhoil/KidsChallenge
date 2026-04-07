import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/api_client.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/family_repository.dart';
import '../../data/repositories/point_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/family_model.dart';
import '../../core/services/kakao_auth_service.dart';
import '../../core/services/google_auth_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});

final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return FamilyRepository(ref.read(apiClientProvider));
});

final pointRepositoryProvider = Provider<PointRepository>((ref) {
  return PointRepository(ref.read(apiClientProvider));
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider), ref);
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;
  
  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final Ref _ref;
  static const bool _autoTestLogin = false; // 테스트용 자동 로그인 비활성화

  AuthNotifier(this._authRepository, this._ref) : super(AuthState()) {
    if (_autoTestLogin) {
      _testLogin();
    } else {
      _loadUser();
    }
  }

  Future<void> _testLogin() async {
    try {
      print('[Auth] Auto test login starting...');
      final success = await login('testuser', 'Test1234!');
      if (success) {
        print('[Auth] Auto test login successful');
        // 가족 정보는 별도 Provider에서 자동으로 로드됨
      } else {
        print('[Auth] Auto test login failed');
        _loadUser(); // 실패 시 일반 로드 시도
      }
    } catch (e) {
      print('[Auth] Auto test login error: $e');
      _loadUser(); // 실패 시 일반 로드 시도
    }
  }

  Future<void> _loadUser() async {
    try {
      print('[Auth] Loading current user...');
      final user = await _authRepository.getCurrentUser();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);
      await prefs.setString('auth_token', user.id);
      print('[Auth] Current user loaded: ${user.nickname}');
      state = state.copyWith(user: user);
      _ref.invalidate(myFamiliesProvider);
      await _initializeFamily(null);
    } catch (e) {
      print('[Auth] Failed to load user: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('auth_token');
      await prefs.remove('session_id');
      // 로그인 안 된 상태
      state = AuthState();
    }
  }

  Future<bool> login(String username, String password, {String? inviteCode, String? memberId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('session_id');
      await prefs.remove('auth_token');
      _ref.read(currentFamilyProvider.notifier).state = null;
      _ref.invalidate(myFamiliesProvider);
      final user = await _authRepository.login(username, password);
      await prefs.setString('user_id', user.id);
      await prefs.setString('auth_token', user.id);
      state = state.copyWith(user: user, isLoading: false);
      
      // 로그인 후 초기화: 가족 설정
      await _initializeFamily(inviteCode, memberId: memberId);
      
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> _initializeFamily(String? inviteCode, {String? memberId}) async {
    try {
      print('[AuthNotifier] Initializing family setup...');
      _ref.invalidate(myFamiliesProvider);

      if (inviteCode != null && inviteCode.isNotEmpty) {
        print('[AuthNotifier] Joining family with invite code: $inviteCode, memberId: $memberId');
        final familyRepo = _ref.read(familyRepositoryProvider);
        final joinedFamily = await familyRepo.joinFamily(
          inviteCode,
          memberId: memberId,
        );
        _ref.read(currentFamilyProvider.notifier).state = joinedFamily;
        _ref.invalidate(myFamiliesProvider);
        print('[AuthNotifier] Successfully joined family: ${joinedFamily.id}');
        return;
      }

      final families = await _ref.read(myFamiliesProvider.future);
      print('[AuthNotifier] Current families count: ${families.length}');

      if (families.isNotEmpty) {
        print('[AuthNotifier] Family already exists, selecting first family');
        _ref.read(currentFamilyProvider.notifier).state = families.first;
        return;
      }
    } catch (e) {
      print('[AuthNotifier] Error initializing family: $e');
      // 에러가 발생해도 로그인은 성공으로 처리
    }
  }

  Future<bool> loginWithKakao({String? inviteCode, String? memberId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('session_id');
      await prefs.remove('auth_token');
      _ref.read(currentFamilyProvider.notifier).state = null;
      _ref.invalidate(myFamiliesProvider);
      // 카카오 로그인 서비스 초기화
      await _initKakaoService();
      
      // 카카오 로그인 수행
      final accessToken = await _performKakaoLogin();
      if (accessToken == null) {
        state = state.copyWith(isLoading: false, error: '카카오 로그인이 취소되었습니다.');
        return false;
      }

      // 백엔드에 카카오 액세스 토큰 전달하여 로그인
      final user = await _authRepository.loginWithKakao(accessToken);
      await prefs.setString('user_id', user.id);
      // Bearer 토큰으로도 사용할 수 있도록 auth_token 저장 (UUID 문자열)
      await prefs.setString('auth_token', user.id);
      state = state.copyWith(user: user, isLoading: false);
      
      // 로그인 후 초기화: 가족 설정
      await _initializeFamily(inviteCode, memberId: memberId);
      
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> loginWithGoogle({String? inviteCode, String? memberId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('session_id');
      await prefs.remove('auth_token');
      _ref.read(currentFamilyProvider.notifier).state = null;
      _ref.invalidate(myFamiliesProvider);
      // 구글 로그인 수행
      final accessToken = await _performGoogleLogin();
      if (accessToken == null) {
        state = state.copyWith(isLoading: false, error: '구글 로그인이 취소되었습니다.');
        return false;
      }

      // 백엔드에 구글 액세스 토큰 전달하여 로그인
      final user = await _authRepository.loginWithGoogle(accessToken);
      await prefs.setString('user_id', user.id);
      // Bearer 토큰으로도 사용할 수 있도록 auth_token 저장 (UUID 문자열)
      await prefs.setString('auth_token', user.id);
      state = state.copyWith(user: user, isLoading: false);
      
      // 로그인 후 초기화: 가족 설정
      await _initializeFamily(inviteCode, memberId: memberId);
      
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> _initKakaoService() async {
    try {
      print('[AuthNotifier] Initializing Kakao service...');
      await KakaoAuthService.init();
      print('[AuthNotifier] ✅ Kakao service initialized');
    } catch (e, stackTrace) {
      print('[AuthNotifier] ❌ Kakao service init error: $e');
      print('[AuthNotifier] Stack trace: $stackTrace');
      // 웹 환경에서는 무시할 수 있음
    }
  }

  Future<String?> _performKakaoLogin() async {
    try {
      return await KakaoAuthService.loginWithKakaoTalk();
    } catch (e) {
      print('[AuthNotifier] Kakao login error: $e');
      rethrow;
    }
  }

  Future<String?> _performGoogleLogin() async {
    try {
      return await GoogleAuthService.signIn();
    } catch (e) {
      print('[AuthNotifier] Google login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('auth_token');
      await prefs.remove('session_id');
      
      // 소셜 로그인 로그아웃도 수행
      try {
        await KakaoAuthService.logout();
      } catch (e) {
        // 카카오 로그아웃 실패는 무시
      }
      
      try {
        await GoogleAuthService.signOut();
      } catch (e) {
        // 구글 로그아웃 실패는 무시
      }

      _ref.read(currentFamilyProvider.notifier).state = null;
      _ref.invalidate(myFamiliesProvider);
      state = AuthState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> updateNickname(String newNickname) async {
    try {
      final updated = await _authRepository.updateNickname(newNickname);
      state = state.copyWith(user: updated);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final currentFamilyProvider = StateProvider<FamilyModel?>((ref) => null);

final myFamiliesProvider = FutureProvider<List<FamilyModel>>((ref) async {
  final repo = ref.read(familyRepositoryProvider);
  try {
    return await repo.getMyFamilies();
  } catch (e) {
    final message = e.toString();
    if (message.contains('인증이 필요합니다')) {
      return [];
    }
    rethrow;
  }
});

final pointBalanceProvider = FutureProvider.family<int, String>((ref, familyId) async {
  final pointRepo = ref.read(pointRepositoryProvider);
  final balance = await pointRepo.getBalance(familyId);
  return balance.balance;
});
