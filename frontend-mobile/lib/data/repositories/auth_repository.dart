import 'package:dio/dio.dart';
import 'package:kids_challenge/data/datasources/api_client.dart';
import 'package:kids_challenge/data/models/user_model.dart';
import 'package:kids_challenge/core/config/app_config.dart';

/// /auth/me 가 401·403일 때 — 저장된 세션이 서버에서 무효함
class SessionExpiredException implements Exception {
  @override
  String toString() => 'Session expired';
}

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<UserModel> login(String username, String password) async {
    try {
      print('[AuthRepository] Attempting login for: $username');
      final response = await _apiClient.post(
        AppConfig.authLogin,
        data: {
          'username': username,
          'password': password,
        },
      );
      
      print('[AuthRepository] Login response status: ${response.statusCode}');
      print('[AuthRepository] Login response data: ${response.data}');
      
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          print('[AuthRepository] Login successful');
          return UserModel.fromJson(data['data']);
        }
      }
      throw Exception(response.data['message'] ?? 'Login failed');
    } on DioException catch (e) {
      print('[AuthRepository] Login DioException: ${e.response?.statusCode}');
      print('[AuthRepository] Login DioException data: ${e.response?.data}');
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('아이디 또는 비밀번호가 올바르지 않습니다.');
      }
      rethrow;
    } catch (e) {
      print('[AuthRepository] Login Error: $e');
      rethrow;
    }
  }

  Future<UserModel> register(String username, String password, String email, String nickname) async {
    final response = await _apiClient.post(
      AppConfig.authRegister,
      data: {
        'username': username,
        'password': password,
        'email': email,
        'nickname': nickname,
      },
    );
    
    if (response.data['success'] == true && response.data['data'] != null) {
      return UserModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Registration failed');
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(AppConfig.authMe);
    final code = response.statusCode ?? 0;
    if (code == 401 || code == 403) {
      throw SessionExpiredException();
    }
    if (response.data is Map &&
        response.data['success'] == true &&
        response.data['data'] != null) {
      return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to get current user');
  }

  Future<void> logout() async {
    await _apiClient.post(AppConfig.authLogin.replaceAll('/login', '/logout'));
  }

  Future<UserModel> updateNickname(String nickname) async {
    final response = await _apiClient.put(
      AppConfig.authMe.replaceAll('/me', '/me/nickname'),
      data: {'nickname': nickname},
    );
    if (response.data['success'] == true && response.data['data'] != null) {
      return UserModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to update nickname');
  }
  /// 카카오 로그인 (액세스 토큰으로 로그인)
  Future<UserModel> loginWithKakao(String accessToken) async {
    try {
      print('[AuthRepository] Attempting Kakao login');
      final response = await _apiClient.post(
        AppConfig.authKakaoToken,
        data: {
          'accessToken': accessToken,
        },
      );
      
      print('[AuthRepository] Kakao login response status: ${response.statusCode}');
      print('[AuthRepository] Kakao login response data: ${response.data}');
      
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          print('[AuthRepository] Kakao login successful');
          return UserModel.fromJson(data['data']);
        }
      }
      throw Exception(response.data['message'] ?? 'Kakao login failed');
    } on DioException catch (e) {
      print('[AuthRepository] Kakao login DioException: ${e.response?.statusCode}');
      print('[AuthRepository] Kakao login DioException data: ${e.response?.data}');
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('카카오 로그인에 실패했습니다.');
      }
      rethrow;
    } catch (e) {
      print('[AuthRepository] Kakao login Error: $e');
      rethrow;
    }
  }

  /// 구글 로그인 (액세스 토큰으로 로그인)
  Future<UserModel> loginWithGoogle(String accessToken) async {
    try {
      print('[AuthRepository] Attempting Google login');
      final response = await _apiClient.post(
        AppConfig.authGoogleToken,
        data: {
          'accessToken': accessToken,
        },
      );
      
      print('[AuthRepository] Google login response status: ${response.statusCode}');
      print('[AuthRepository] Google login response data: ${response.data}');
      
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          print('[AuthRepository] Google login successful');
          return UserModel.fromJson(data['data']);
        }
      }
      throw Exception(response.data['message'] ?? 'Google login failed');
    } on DioException catch (e) {
      print('[AuthRepository] Google login DioException: ${e.response?.statusCode}');
      print('[AuthRepository] Google login DioException data: ${e.response?.data}');
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('구글 로그인에 실패했습니다.');
      }
      rethrow;
    } catch (e) {
      print('[AuthRepository] Google login Error: $e');
      rethrow;
    }
  }
}
