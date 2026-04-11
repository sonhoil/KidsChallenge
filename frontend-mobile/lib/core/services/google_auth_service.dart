import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config/app_config.dart';

class GoogleAuthService {
  static GoogleSignIn? _googleSignIn;

  /// iOS는 `GIDClientID`/초기화용 클라이언트 ID가 필요하다. Android는 [clientId] 미지정.
  static GoogleSignIn get _instance {
    _googleSignIn ??= GoogleSignIn(
      scopes: const ['email', 'profile'],
      clientId: _iosClientIdIfConfigured,
    );
    return _googleSignIn!;
  }

  static String? get _iosClientIdIfConfigured {
    if (kIsWeb) return null;
    if (defaultTargetPlatform != TargetPlatform.iOS) return null;
    final id = AppConfig.googleIosClientId;
    return id.isEmpty ? null : id;
  }

  /// 구글 로그인
  static Future<String?> signIn() async {
    try {
      final GoogleSignInAccount? account = await _instance.signIn();
      if (account == null) {
        // 사용자가 로그인 취소
        return null;
      }

      // 인증 정보 가져오기
      final GoogleSignInAuthentication auth = await account.authentication;
      return auth.accessToken;
    } on PlatformException catch (e) {
      final raw = '${e.message ?? e.details ?? e}';
      if (raw.contains('ApiException: 10')) {
        throw Exception(
          '구글 로그인 설정 오류입니다(ApiException:10).\n'
          'Google Cloud Console에서 Android OAuth 클라이언트의 패키지명/SHA-1을 확인해주세요.',
        );
      }
      if (raw.contains('GIDClientID') || raw.contains('No active configuration')) {
        throw Exception(
          'iOS 구글 로그인 설정이 필요합니다.\n'
          '1) Google Cloud Console에서 iOS용 OAuth 클라이언트(번들 ID: com.kidspoint.kidsChallenge)를 만든 뒤\n'
          '2) `lib/core/config/app_config.dart`의 googleIosClientId를 채우고\n'
          '3) `ios/Runner/Info.plist`의 Google URL 스킴을 REVERSED_CLIENT_ID와 동일하게 맞춰주세요.',
        );
      }
      print('[GoogleAuthService] Platform sign in error: $e');
      rethrow;
    } catch (e) {
      final raw = '$e';
      if (raw.contains('GIDClientID') || raw.contains('No active configuration')) {
        throw Exception(
          'iOS 구글 로그인 설정이 필요합니다.\n'
          '1) Google Cloud Console에서 iOS용 OAuth 클라이언트(번들 ID: com.kidspoint.kidsChallenge)를 만든 뒤\n'
          '2) `lib/core/config/app_config.dart`의 googleIosClientId를 채우고\n'
          '3) `ios/Runner/Info.plist`의 Google URL 스킴을 REVERSED_CLIENT_ID와 동일하게 맞춰주세요.',
        );
      }
      print('[GoogleAuthService] Sign in error: $e');
      rethrow;
    }
  }

  /// 로그아웃
  static Future<void> signOut() async {
    try {
      await _instance.signOut();
    } catch (e) {
      print('[GoogleAuthService] Sign out error: $e');
    }
  }

  /// 현재 로그인 상태 확인
  static Future<bool> isSignedIn() async {
    try {
      return await _instance.isSignedIn();
    } catch (e) {
      return false;
    }
  }

  /// 현재 사용자 정보 가져오기
  static Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      return _instance.currentUser;
    } catch (e) {
      return null;
    }
  }
}
