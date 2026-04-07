// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert' show jsonEncode;

/// 웹 환경에서 디버그 로그를 전송하는 유틸리티
class DebugLogWeb {
  static void sendLog(String location, String message, Map<String, dynamic> data, String hypothesisId) {
    try {
      final payload = jsonEncode({
        'location': location,
        'message': message,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'hypothesisId': hypothesisId,
      });
      html.HttpRequest.request(
        'http://127.0.0.1:7242/ingest/2af590f9-e426-4bb7-87c6-e327b08f5d9b',
        method: 'POST',
        requestHeaders: {'Content-Type': 'application/json'},
        sendData: payload,
      ).catchError((_) {});
    } catch (_) {}
  }
}
