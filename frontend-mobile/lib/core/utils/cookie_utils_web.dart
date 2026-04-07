// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// 웹 환경 전용 쿠키 유틸리티
class CookieUtils {
  static String? getSessionCookie() {
    try {
      final cookies = html.document.cookie ?? '';
      final sessionMatch = RegExp(r'SESSION=([^;]+)').firstMatch(cookies);
      final sessionId = sessionMatch?.group(1);
      return sessionId;
    } catch (e) {
      return null;
    }
  }
}
