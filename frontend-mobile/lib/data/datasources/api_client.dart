import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:kids_challenge/core/config/app_config.dart';

class ApiClient {
  late final Dio _dio;
  static const String _sessionKey = 'session_id';
  static const String _authTokenKey = 'auth_token';

  /// [main]에서 prefs 로드 직후·로그인 직후 설정. 첫 요청 인터셉터 타이밍 이슈로 Bearer가 빠지는 것을 방지합니다.
  static String? cachedBearerToken;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
        },
        // 웹 브라우저에서 쿠키를 자동으로 전송하도록 설정
        followRedirects: true,
        validateStatus: (status) => status! < 500,
      ),
    );
    
    // 웹 환경에서는 Dio가 자동으로 브라우저의 fetch API를 사용하므로
    // 별도의 BrowserHttpClientAdapter 설정이 필요 없습니다.
    // Android 빌드 시 web 패키지 타입 오류를 방지하기 위해
    // dio/browser.dart import를 제거했습니다.

    // 웹 환경에서는 브라우저가 쿠키를 자동으로 관리하므로
    // 수동 쿠키 처리는 모바일 환경에서만 필요
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print('[API] Request: ${options.method} ${options.baseUrl}${options.path}');
          print('[API] Request headers: ${options.headers}');
          
          // 쿠키 / Bearer 토큰 처리
          if (!kIsWeb) {
            // 모바일 환경: SharedPreferences에서 쿠키 읽기
            try {
              final prefs = await SharedPreferences.getInstance();
              final sessionId = prefs.getString(_sessionKey);
              if (sessionId != null) {
                options.headers['Cookie'] = 'SESSION=$sessionId';
                print('[API] Added Cookie header for mobile: SESSION=$sessionId');
              }
              
              // Bearer: 메모리 캐시 우선(콜드 스타트 첫 요청 대비), 이후 SharedPreferences
              final authToken = (cachedBearerToken != null && cachedBearerToken!.isNotEmpty)
                  ? cachedBearerToken
                  : prefs.getString(_authTokenKey);
              if (authToken != null && authToken.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $authToken';
                print('[API] Added Authorization header for mobile: Bearer $authToken');
              }
            } catch (e) {
              // SharedPreferences 오류 무시
            }
          } else {
            // 웹 환경: 브라우저가 자동으로 쿠키를 전송하므로 수동 설정 불필요
            // Dio는 웹 환경에서 브라우저의 fetch API를 사용하므로 쿠키가 자동으로 포함됨
            print('[API] Web environment: cookies are handled automatically by browser');
          }
          
          handler.next(options);
        },
        onResponse: (response, handler) async {
          print('[API] Response: ${response.statusCode}');
          print('[API] Response headers: ${response.headers}');
          
          // 세션 쿠키 저장 (모바일 환경용)
          // 웹에서는 브라우저가 자동으로 쿠키를 저장함
          if (!kIsWeb) {
            try {
              // Dio는 여러 Set-Cookie 를 map['set-cookie'] 리스트로 줄 수 있다. 첫 줄만 보다 보면 SESSION 을 놓칠 수 있음.
              final cookieHeaderList = response.headers.map['set-cookie'];
              print('[API] Set-Cookie headers: $cookieHeaderList');
              if (cookieHeaderList != null) {
                String? sid;
                for (final cookieLine in cookieHeaderList) {
                  final m =
                      RegExp(r'SESSION=([^;]+)').firstMatch(cookieLine);
                  if (m != null) {
                    sid = m.group(1);
                    break;
                  }
                }
                if (sid != null && sid.isNotEmpty) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(_sessionKey, sid);
                  print('[API] Saved session ID for mobile: $sid');
                }
              }
            } catch (e) {
              print('[API] Error saving session cookie: $e');
            }
          } else {
            // 웹 환경: 쿠키 확인
            // Dio는 헤더 이름을 소문자로 변환하므로 'set-cookie'로 확인
            final setCookieHeaders = response.headers.map['set-cookie'];
            print('[API] Set-Cookie headers (web): $setCookieHeaders');
            print('[API] All response headers: ${response.headers.map}');
            
            if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
              final cookieString = setCookieHeaders.join('; ');
              print('[API] Set-Cookie header string (web): $cookieString');
              if (cookieString.contains('SESSION=')) {
                print('[API] Session cookie received in web environment');
              }
            } else {
              // 대소문자 구분 없이 확인
              final allHeaders = response.headers.map;
              for (var key in allHeaders.keys) {
                if (key.toLowerCase() == 'set-cookie') {
                  print('[API] Found Set-Cookie header with key: $key, value: ${allHeaders[key]}');
                }
              }
            }
          }
          
          handler.next(response);
        },
        onError: (error, handler) async {
          print('[API] Interceptor Error: ${error.requestOptions.path}');
          print('[API] Status Code: ${error.response?.statusCode}');
          print('[API] Response Data: ${error.response?.data}');
          print('[API] Error Message: ${error.message}');
          
          // CSRF 오류인 경우 토큰을 가져와서 재시도
          if (kIsWeb && error.response?.statusCode == 403) {
            try {
              // CSRF 토큰을 가져오기 위해 GET 요청
              final csrfResponse = await _dio.get('/api/auth/me');
              final xsrfToken = csrfResponse.headers.value('X-XSRF-TOKEN');
              if (xsrfToken != null && error.requestOptions.method != 'GET') {
                // 원래 요청에 CSRF 토큰 추가하여 재시도
                error.requestOptions.headers['X-XSRF-TOKEN'] = xsrfToken;
                // 재시도는 여기서 하지 않고, 상위에서 처리하도록 함
              }
            } catch (e) {
              print('[API] Failed to get CSRF token: $e');
            }
          }
          
          handler.next(error);
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      print('[API] GET ${AppConfig.baseUrl}$path');
      // 웹에서는 브라우저가 자동으로 쿠키를 전송함
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      print('[API] GET Response: ${response.statusCode}');
      if (response.statusCode == 403 || response.statusCode == 401) {
        print('[API] Authentication error - status: ${response.statusCode}, data: ${response.data}');
      }
      return response;
    } on DioException catch (e) {
      print('[API] GET DioException: ${e.response?.statusCode}');
      print('[API] GET DioException data: ${e.response?.data}');
      print('[API] GET DioException headers: ${e.response?.headers}');
      rethrow;
    } catch (e) {
      print('[API] GET Error: $e');
      rethrow;
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      print('[API] POST ${AppConfig.baseUrl}$path');
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      print('[API] POST Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('[API] POST Error: $e');
      rethrow;
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
}
