# Flutter 웹 지원 설정 완료

## 수정 사항

### 1. 웹 디렉토리 생성
- `web/index.html` 생성
- `web/manifest.json` 생성

### 2. KakaoSdk.init() 오류 수정
- `KakaoSdk.init()`은 `void`를 반환하므로 `await` 제거

## 실행 방법

### 웹에서 실행
```bash
cd frontend-mobile
flutter run -d chrome
```

### 웹 빌드
```bash
flutter build web
```

## 주의사항

### 카카오 로그인 (웹 환경)
웹 환경에서는 카카오 로그인이 다르게 동작할 수 있습니다:
- 카카오 JavaScript SDK가 필요할 수 있음
- `loginWithKakaoWeb()` 메서드가 아직 구현되지 않음
- 현재는 `loginWithKakaoAccount()`를 사용하거나 웹 전용 구현 필요

### 구글 로그인 (웹 환경)
구글 로그인은 웹에서도 동작하지만, OAuth 2.0 클라이언트 ID 설정이 필요합니다.

## 다음 단계

1. 웹에서 앱 실행 테스트
2. 카카오 로그인 웹 구현 (필요시)
3. 구글 로그인 웹 설정 확인
