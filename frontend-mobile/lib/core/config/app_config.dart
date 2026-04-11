class AppConfig {
  // 네트워크 설정
  // 모바일 기기에서 테스트할 때는 로컬 IP 사용 (예: 192.168.200.129)
  // Android 에뮬레이터에서는 10.0.2.2 사용
  // 웹 브라우저에서는 localhost 사용
  static const String apiOrigin = 'https://kidschallenge-production.up.railway.app';
  static const String baseUrl = '$apiOrigin/api'; // 실제 기기용 (로컬 IP로 변경 필요)
  // static const String baseUrl = 'http://localhost:8080/api'; // 웹 브라우저용
  // static const String baseUrl = 'http://10.0.2.2:8080/api'; // Android 에뮬레이터용
  
  // API Endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authMe = '/auth/me';
  static const String authKakaoToken = '/auth/kakao/token';
  static const String authGoogleToken = '/auth/google/token';
  
  // Kids API Endpoints
  static const String families = '/kids/families';
  static const String familyMembers = '/kids/families';
  static const String missions = '/kids/missions';
  static const String rewards = '/kids/rewards';
  static const String points = '/kids/points';
  static const String inviteLinkBaseUrl = 'kidspoint://app/login';
  static const String inviteShareBaseUrl = '$apiOrigin/invite/link';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
