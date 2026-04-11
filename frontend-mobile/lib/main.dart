import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_challenge/core/config/app_config.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/presentation/screens/login/login_screen.dart';
import 'package:kids_challenge/presentation/screens/child/home/home_screen.dart';
import 'package:kids_challenge/presentation/screens/child/store/store_screen.dart';
import 'package:kids_challenge/presentation/screens/child/coupon/coupon_screen.dart';
import 'package:kids_challenge/presentation/screens/child/profile/profile_screen.dart';
import 'package:kids_challenge/presentation/screens/parent/parent_dashboard_screen.dart';
import 'package:kids_challenge/presentation/screens/parent/parent_missions_screen.dart';
import 'package:kids_challenge/presentation/screens/parent/parent_mission_requests_screen.dart';
import 'package:kids_challenge/presentation/screens/parent/parent_members_screen.dart';
import 'package:kids_challenge/presentation/screens/parent/parent_store_screen.dart';
import 'package:kids_challenge/presentation/screens/parent/parent_settings_screen.dart';
import 'package:kids_challenge/presentation/screens/parent/create_mission_screen.dart';
import 'package:kids_challenge/presentation/screens/parent/create_reward_screen.dart';
import 'package:kids_challenge/presentation/screens/parent/create_member_screen.dart';
import 'package:kids_challenge/presentation/screens/parent/child_stats_screen.dart';
import 'package:kids_challenge/presentation/screens/parent/point_adjustment_screen.dart';
import 'package:kids_challenge/presentation/screens/parent/child_point_edit_screen.dart';
import 'package:kids_challenge/data/models/family_model.dart';
import 'package:kids_challenge/data/models/reward_model.dart';
import 'package:kids_challenge/data/models/mission_model.dart';
import 'package:kids_challenge/presentation/screens/create_family_screen.dart';
import 'package:kids_challenge/presentation/state/auth_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: KidsChallengeApp(),
    ),
  );
}

class KidsChallengeApp extends StatelessWidget {
  const KidsChallengeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final router = ref.watch(_routerProvider);
        return MaterialApp.router(
          title: '칭찬통장',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: router,
        );
      },
    );
  }
}

final _routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final currentFamily = ref.watch(currentFamilyProvider);
  final myFamiliesAsync = ref.watch(myFamiliesProvider);
  
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      if (authState.bootstrapping) {
        return null;
      }
      final isLoggedIn = authState.isAuthenticated;
      final isLoginPage = state.uri.path == '/login';
      final isCreateFamilyPage = state.uri.path == '/create-family';
      
      // 로그인되지 않은 경우
      if (!isLoggedIn) {
        if (!isLoginPage) {
          return '/login';
        }
        return null;
      }
      
      // 로그인된 경우
      if (isLoggedIn) {
        // 가족 목록 로딩 중이면 대기
        if (myFamiliesAsync.isLoading) {
          return null;
        }
        
        // 가족 목록 조회 완료
        final families = myFamiliesAsync.value ?? [];
        // currentFamily 가 이미 설정되어 있다면 가족이 있는 것으로 간주
        final hasFamily = currentFamily != null || families.isNotEmpty;
        
        // 로그인 페이지에 있으면 적절한 화면으로 리다이렉트
        if (isLoginPage) {
          if (hasFamily) {
            // 가족이 있으면 역할에 따라 이동
            final family = currentFamily ?? families.first;
            return family.role == 'parent' ? '/parent' : '/child';
          } else {
            // 가족이 없으면 가족 생성 화면으로 이동
            return '/create-family';
          }
        }
        
        // 가족 생성 페이지가 아닌 다른 페이지에 있는데 가족이 없으면 가족 생성 화면으로 이동
        if (!isCreateFamilyPage && !hasFamily) {
          return '/create-family';
        }
        
        // 가족 생성 페이지에 있는데 가족이 있으면 적절한 화면으로 이동
        if (isCreateFamilyPage && hasFamily) {
          final family = currentFamily ?? families.first;
          return family.role == 'parent' ? '/parent' : '/child';
        }
      }
      
      return null; // 리다이렉트 없음
    },
    routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(
        inviteCode: state.uri.queryParameters['inviteCode'],
        memberId: state.uri.queryParameters['memberId'],
      ),
    ),
    GoRoute(
      path: '/create-family',
      builder: (context, state) => const CreateFamilyScreen(),
    ),
    GoRoute(
      path: '/child',
      builder: (context, state) => const ChildMainScreen(),
    ),
    GoRoute(
      path: '/parent',
      builder: (context, state) => const ParentDashboardScreen(),
    ),
    GoRoute(
      path: '/parent/missions',
      builder: (context, state) => const ParentMissionsScreen(),
    ),
    GoRoute(
      path: '/parent/members',
      builder: (context, state) => const ParentMembersScreen(),
    ),
    GoRoute(
      path: '/parent/store',
      builder: (context, state) => const ParentStoreScreen(),
    ),
    GoRoute(
      path: '/parent/settings',
      builder: (context, state) => const ParentSettingsScreen(),
    ),
    GoRoute(
      path: '/parent/create-mission',
      builder: (context, state) {
        final mission = state.extra as MissionModel?;
        return CreateMissionScreen(mission: mission);
      },
    ),
    GoRoute(
      path: '/parent/mission-requests',
      builder: (context, state) => const ParentMissionRequestsScreen(),
    ),
    GoRoute(
      path: '/parent/create-reward',
      builder: (context, state) {
        final reward = state.extra as RewardModel?;
        return CreateRewardScreen(reward: reward);
      },
    ),
    GoRoute(
      path: '/parent/create-member',
      builder: (context, state) => const CreateMemberScreen(),
    ),
    GoRoute(
      path: '/parent/child-stats',
      builder: (context, state) {
        final member = state.extra as FamilyMemberModel?;
        return ChildStatsScreen(member: member);
      },
    ),
    GoRoute(
      path: '/parent/point-adjustment',
      builder: (context, state) {
        final member = state.extra as FamilyMemberModel?;
        return PointAdjustmentScreen(member: member);
      },
    ),
  ],
  );
});

class ChildMainScreen extends StatefulWidget {
  const ChildMainScreen({super.key});

  @override
  State<ChildMainScreen> createState() => _ChildMainScreenState();
}

class _ChildMainScreenState extends State<ChildMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          StoreScreen(),
          CouponScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, '홈', 0),
              _buildNavItem(Icons.store, '상점', 1),
              _buildNavItem(Icons.confirmation_number, '쿠폰', 2),
              _buildNavItem(Icons.person, '프로필', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
