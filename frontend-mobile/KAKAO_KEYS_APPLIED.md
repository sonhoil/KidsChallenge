# 카카오 키 적용 완료

## 적용된 키 정보

### 네이티브 앱 키 (Flutter 앱용)
```
01d96aed07dfdb284de6448247a0b8ae
```

**적용 위치:**
- `lib/core/services/kakao_auth_service.dart`: KakaoSdk.init()에 설정
- `android/app/src/main/AndroidManifest.xml`: Intent Filter의 scheme에 설정

### REST API 키 (백엔드용)
```
ec0330129144c677f684395b1907ca19
```

**적용 위치:**
- `backend/kidserver/src/main/resources/application.properties`: kakao.client-id에 설정

## 적용된 파일

### 1. Flutter - KakaoAuthService
```dart
await KakaoSdk.init(
  nativeAppKey: '01d96aed07dfdb284de6448247a0b8ae',
  javaScriptAppKey: '01d96aed07dfdb284de6448247a0b8ae',
);
```

### 2. Flutter - AndroidManifest.xml
```xml
<data android:scheme="kakao01d96aed07dfdb284de6448247a0b8ae" />
```

### 3. 백엔드 - application.properties
```properties
kakao.client-id=${KAKAO_CLIENT_ID:ec0330129144c677f684395b1907ca19}
```

## 카카오 개발자 콘솔 확인 사항

### Redirect URI 확인
카카오 개발자 콘솔에서 다음 Redirect URI가 자동 생성되었는지 확인:
```
kakao01d96aed07dfdb284de6448247a0b8ae://oauth
```

이 URI는 AndroidManifest.xml의 scheme과 일치해야 합니다.

### Client Secret 확인
백엔드에서 사용할 Client Secret도 확인이 필요합니다:
1. 카카오 개발자 콘솔 > 제품 설정 > 카카오 로그인
2. 보안 탭에서 Client Secret 확인
3. `application.properties`의 `kakao.client-secret`에 설정

## 테스트

### 1. Flutter 앱 실행
```bash
cd frontend-mobile
flutter run
```

### 2. 카카오 로그인 테스트
1. 로그인 화면에서 "카카오로 시작하기" 버튼 클릭
2. 카카오톡 앱 또는 카카오계정으로 로그인
3. 로그인 성공 확인

### 3. 백엔드 로그 확인
백엔드 콘솔에서 카카오 로그인 요청이 정상적으로 처리되는지 확인

## 문제 해결

### "앱이 등록되지 않았습니다" 오류
- 카카오 개발자 콘솔에서 Android 플랫폼이 추가되었는지 확인
- 패키지명이 `com.kidspoint.kids_challenge`로 정확히 등록되었는지 확인
- 키 해시가 등록되었는지 확인 (`kVCtyr7A/x+9NTSklToq/yU2Ms0=`)

### "키 해시가 등록되지 않았습니다" 오류
- 카카오 개발자 콘솔 > Android 앱 정보 > 키 해시에 등록 확인
- 디버그 키 해시: `kVCtyr7A/x+9NTSklToq/yU2Ms0=`

### 로그인 후 앱으로 돌아오지 않음
- AndroidManifest.xml의 scheme이 정확한지 확인
- 카카오 개발자 콘솔의 Redirect URI와 일치하는지 확인

## 다음 단계

1. ✅ 네이티브 앱 키 적용 완료
2. ✅ REST API 키 적용 완료
3. ⏳ Client Secret 확인 및 설정 (필요시)
4. ⏳ 카카오 개발자 콘솔에서 Android 플랫폼 등록 확인
5. ⏳ 키 해시 등록 확인
6. ⏳ 실제 카카오 로그인 테스트
