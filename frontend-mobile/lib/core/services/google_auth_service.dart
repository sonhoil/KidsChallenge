import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// 구글 로그인
  static Future<String?> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
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
      print('[GoogleAuthService] Platform sign in error: $e');
      rethrow;
    } catch (e) {
      print('[GoogleAuthService] Sign in error: $e');
      rethrow;
    }
  }

  /// 로그아웃
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('[GoogleAuthService] Sign out error: $e');
    }
  }

  /// 현재 로그인 상태 확인
  static Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      return false;
    }
  }

  /// 현재 사용자 정보 가져오기
  static Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      return _googleSignIn.currentUser;
    } catch (e) {
      return null;
    }
  }
}
