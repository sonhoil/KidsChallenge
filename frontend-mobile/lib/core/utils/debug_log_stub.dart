/// 모바일 환경용 스텁 파일
/// 웹 환경에서는 debug_log_web.dart가 사용됩니다.

class DebugLogWeb {
  static void sendLog(String location, String message, Map<String, dynamic> data, String hypothesisId) {
    // 모바일 환경에서는 로그를 전송하지 않음
  }
}
