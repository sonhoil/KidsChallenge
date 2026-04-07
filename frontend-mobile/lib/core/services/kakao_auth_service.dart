import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class KakaoAuthService {
  static const MethodChannel _channel = MethodChannel('com.kidspoint.kids_challenge/keyhash');
  
  /// 디버그 로그 전송
  static void _sendDebugLog(String location, String message, Map<String, dynamic> data, String hypothesisId, String runId) {
    try {
      final payload = {
        'location': location,
        'message': message,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'hypothesisId': hypothesisId,
        'runId': runId,
      };
      // Fire-and-forget; 에러는 굳이 catchError로 처리하지 않는다
      http.post(
        Uri.parse('http://127.0.0.1:7242/ingest/2af590f9-e426-4bb7-87c6-e327b08f5d9b'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
    } catch (e) {
      // 로그 전송 실패 무시
    }
  }
  
  /// 실제 앱이 사용하는 키 해시 가져오기
  static Future<String?> _getActualKeyHash() async {
    if (kIsWeb) {
      print('[KakaoAuthService] Web environment, skipping key hash');
      return null;
    }
    try {
      print('[KakaoAuthService] Calling native method to get key hash...');
      final String? keyHash = await _channel.invokeMethod('getKeyHash');
      if (keyHash != null && keyHash.isNotEmpty) {
        print('[KakaoAuthService] ✅ Successfully got key hash from native: $keyHash');
      } else {
        print('[KakaoAuthService] ⚠️ Key hash is null or empty from native');
      }
      return keyHash;
    } catch (e, stackTrace) {
      print('[KakaoAuthService] ❌ Failed to get key hash: $e');
      print('[KakaoAuthService] Stack trace: $stackTrace');
      // #region agent log
      _sendDebugLog('kakao_auth_service.dart:42', 'Failed to get key hash from native', {
        'error': e.toString(),
        'stackTrace': stackTrace.toString()
      }, 'A', 'init');
      // #endregion
      return null;
    }
  }
  
  /// 카카오 로그인 초기화
  static Future<void> init() async {
    // 카카오 SDK 초기화
    // 실제 앱에서는 native app key를 사용해야 합니다
    // 개발 환경에서는 REST API key를 사용할 수 있습니다
    try {
      // 실제 키 해시 확인
      print('[KakaoAuthService] Getting actual key hash...');
      final actualKeyHash = await _getActualKeyHash();
      if (actualKeyHash != null && actualKeyHash.isNotEmpty) {
        print('[KakaoAuthService] ✅ Actual Key Hash: $actualKeyHash');
        // #region agent log
        _sendDebugLog('kakao_auth_service.dart:35', 'Actual key hash from app', {'keyHash': actualKeyHash}, 'A', 'init');
        // #endregion
      } else {
        print('[KakaoAuthService] ⚠️ Failed to get key hash or key hash is empty');
        // #region agent log
        _sendDebugLog('kakao_auth_service.dart:38', 'Failed to get key hash', {'keyHash': actualKeyHash}, 'A', 'init');
        // #endregion
      }
      
      // KakaoSdk.init()은 void를 반환하므로 await 불필요
      print('[KakaoAuthService] Initializing Kakao SDK...');
      KakaoSdk.init(
        nativeAppKey: '01d96aed07dfdb284de6448247a0b8ae',
        javaScriptAppKey: '01d96aed07dfdb284de6448247a0b8ae', // 웹용 (동일한 키 사용)
      );
      print('[KakaoAuthService] ✅ Kakao SDK initialized');
      // #region agent log
      _sendDebugLog('kakao_auth_service.dart:42', 'Kakao SDK initialized', {'nativeAppKey': '01d96aed07dfdb284de6448247a0b8ae'}, 'B', 'init');
      // #endregion
    } catch (e) {
      print('[KakaoAuthService] ❌ Init error: $e');
      // #region agent log
      _sendDebugLog('kakao_auth_service.dart:46', 'Kakao SDK init error', {'error': e.toString()}, 'B', 'init');
      // #endregion
      // 이미 초기화된 경우 무시
    }
  }

  /// 카카오톡 앱으로 로그인 시도
  static Future<String?> loginWithKakaoTalk() async {
    try {
      // 웹 환경에서는 카카오톡 로그인이 지원되지 않으므로 카카오계정으로 로그인
      if (kIsWeb) {
        print('[KakaoAuthService] Web environment detected, using KakaoAccount login');
        return await loginWithKakaoAccount();
      }
      
      // 실제 키 해시 확인
      print('[KakaoAuthService] Getting key hash before login...');
      final actualKeyHash = await _getActualKeyHash();
      if (actualKeyHash != null && actualKeyHash.isNotEmpty) {
        print('[KakaoAuthService] ✅ Key Hash before login: $actualKeyHash');
        // #region agent log
        _sendDebugLog('kakao_auth_service.dart:60', 'Key hash before KakaoTalk login', {'keyHash': actualKeyHash}, 'A', 'login');
        // #endregion
      } else {
        print('[KakaoAuthService] ⚠️ Key hash is null or empty before login');
        // #region agent log
        _sendDebugLog('kakao_auth_service.dart:65', 'Key hash is null or empty', {'keyHash': actualKeyHash}, 'A', 'login');
        // #endregion
      }
      
      // 모바일 환경: 카카오톡 앱으로 로그인 시도
      // 카카오톡이 설치되어 있으면 앱으로, 없으면 카카오계정으로 자동 전환됨
      print('[KakaoAuthService] Attempting KakaoTalk login...');
      // #region agent log
      _sendDebugLog('kakao_auth_service.dart:68', 'Calling loginWithKakaoTalk', {}, 'B', 'login');
      // #endregion
      OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
      print('[KakaoAuthService] KakaoTalk login successful');
      // #region agent log
      _sendDebugLog('kakao_auth_service.dart:71', 'KakaoTalk login successful', {'hasAccessToken': token.accessToken.isNotEmpty}, 'B', 'login');
      // #endregion
      return token.accessToken;
    } catch (e) {
      print('[KakaoAuthService] Login with KakaoTalk error: $e');
      final errorStr = e.toString();
      // #region agent log
      _sendDebugLog('kakao_auth_service.dart:76', 'KakaoTalk login error details', {
        'error': errorStr,
        'containsKeyHash': errorStr.contains('keyHash') || errorStr.contains('key hash'),
        'containsInvalidRequest': errorStr.contains('invalid_request')
      }, 'A,C,D', 'login');
      // #endregion
      // 카카오톡 로그인 실패 시에만 카카오계정으로 시도
      // PlatformException이 발생하면 카카오톡이 설치되지 않은 것이므로 카카오계정으로 전환
      if (e.toString().contains('PlatformException') || 
          e.toString().contains('NotImplemented') ||
          e.toString().contains('카카오톡')) {
        print('[KakaoAuthService] KakaoTalk not available, trying KakaoAccount login');
        try {
          return await loginWithKakaoAccount();
        } catch (e2) {
          print('[KakaoAuthService] Login with KakaoAccount error: $e2');
          rethrow;
        }
      }
      rethrow;
    }
  }

  /// 카카오계정으로 로그인
  static Future<String?> loginWithKakaoAccount() async {
    try {
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      return token.accessToken;
    } catch (e) {
      print('[KakaoAuthService] Login with KakaoAccount error: $e');
      rethrow;
    }
  }

  /// 카카오톡 설치 여부 확인
  static Future<bool> isKakaoTalkInstalled() async {
    try {
      // kakao_flutter_sdk의 실제 메서드 사용
      // 주의: 실제 SDK 버전에 따라 메서드명이 다를 수 있음
      // UserApi.instance.isKakaoTalkInstalled() 또는 다른 방법 사용
      // 임시로 false 반환 (loginWithKakaoTalk이 자동으로 처리)
      return false;
    } catch (e) {
      print('[KakaoAuthService] isKakaoTalkInstalled error: $e');
      return false;
    }
  }

  /// 웹 환경에서 카카오 로그인 (카카오 JavaScript SDK 사용)
  static Future<String?> loginWithKakaoWeb() async {
    // 웹 환경에서는 카카오 JavaScript SDK를 사용해야 합니다
    // 이는 별도로 구현해야 합니다
    throw UnimplementedError('Web Kakao login not implemented yet');
  }

  /// 로그아웃
  static Future<void> logout() async {
    try {
      await UserApi.instance.logout();
    } catch (e) {
      print('[KakaoAuthService] Logout error: $e');
    }
  }

  /// 현재 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    try {
      return await AuthApi.instance.hasToken();
    } catch (e) {
      return false;
    }
  }
}
