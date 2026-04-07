# 소셜 로그인 설정 가이드

## 개요

카카오와 구글 로그인을 Flutter 앱에 구현했습니다. 실제 사용을 위해서는 각 플랫폼의 설정이 필요합니다.

## 구현된 기능

### 백엔드
- ✅ 카카오 로그인 API (`/api/auth/kakao/token`)
- ✅ 구글 로그인 API (`/api/auth/google/token`)
- ✅ 소셜 로그인 사용자 자동 회원가입
- ✅ `auth_type` 및 `social_id` 컬럼으로 소셜 로그인 구분

### Flutter
- ✅ 카카오 로그인 서비스 (`KakaoAuthService`)
- ✅ 구글 로그인 서비스 (`GoogleAuthService`)
- ✅ 로그인 화면에 소셜 로그인 버튼 연결
- ✅ AuthRepository에 소셜 로그인 메서드 추가
- ✅ AuthProvider에 소셜 로그인 메서드 추가

## 설정 필요 사항

### 1. 카카오 로그인 설정

#### 1.1 카카오 개발자 콘솔 설정
1. [카카오 개발자 콘솔](https://developers.kakao.com/) 접속
2. 애플리케이션 등록
3. 플랫폼 설정:
   - **Android**: 패키지명 등록 (예: `com.kidspoint.kids_challenge`)
   - **iOS**: Bundle ID 등록
   - **Web**: 사이트 도메인 등록
4. 카카오 로그인 활성화
5. Redirect URI 등록:
   - Android: `kakao{YOUR_APP_KEY}://oauth`
   - iOS: `kakao{YOUR_APP_KEY}://oauth`
   - Web: `http://localhost:8080/api/auth/kakao/callback`

#### 1.2 Flutter 설정

**`lib/core/services/kakao_auth_service.dart` 수정:**
```dart
await KakaoSdk.init(
  nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY', // 실제 키로 교체
  javaScriptAppKey: 'YOUR_KAKAO_JAVASCRIPT_APP_KEY', // 웹용 (선택사항)
);
```

**Android 설정 (`android/app/src/main/AndroidManifest.xml`):**
```xml
<activity
    android:name="com.kakao.sdk.auth.AuthCodeHandlerActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="kakao{YOUR_APP_KEY}" />
    </intent-filter>
</activity>
```

**iOS 설정 (`ios/Runner/Info.plist`):**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>kakao{YOUR_APP_KEY}</string>
        </array>
    </dict>
</array>
```

#### 1.3 백엔드 설정

**`application.properties` 확인:**
```properties
kakao.client-id=${KAKAO_CLIENT_ID:YOUR_CLIENT_ID}
kakao.client-secret=${KAKAO_CLIENT_SECRET:YOUR_CLIENT_SECRET}
kakao.redirect-uri=${KAKAO_REDIRECT_URI:http://localhost:8080/api/auth/kakao/callback}
```

### 2. 구글 로그인 설정

#### 2.1 Google Cloud Console 설정
1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. 프로젝트 생성 또는 선택
3. **API 및 서비스** > **사용자 인증 정보** 이동
4. **OAuth 2.0 클라이언트 ID** 생성:
   - 애플리케이션 유형: **Android**, **iOS**, **웹 애플리케이션** 각각 생성
   - Android: 패키지명 및 SHA-1 인증서 지문 등록
   - iOS: Bundle ID 등록
   - Web: 승인된 리디렉션 URI 등록

#### 2.2 Flutter 설정

**Android 설정 (`android/app/build.gradle`):**
```gradle
defaultConfig {
    // ...
    minSdkVersion 21
}
```

**Android 설정 (`android/app/src/main/AndroidManifest.xml`):**
```xml
<meta-data
    android:name="com.google.android.gms.version"
    android:value="@integer/google_play_services_version" />
```

**iOS 설정 (`ios/Runner/Info.plist`):**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

**`lib/core/services/google_auth_service.dart` 수정:**
```dart
static final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  // Android/iOS에서 자동으로 설정 파일을 읽습니다
  // 웹에서는 별도 설정 필요
);
```

## 테스트

### 로컬 테스트
1. 백엔드 실행: `./mvnw spring-boot:run`
2. Flutter 앱 실행: `flutter run`
3. 로그인 화면에서 카카오/구글 버튼 클릭

### 주의사항
- **웹 환경**: 카카오/구글 로그인은 웹에서 다르게 동작할 수 있습니다
- **디버그 모드**: 개발 중에는 테스트 계정으로 로그인 가능
- **프로덕션**: 실제 배포 전에 모든 설정을 완료해야 합니다

## 문제 해결

### 카카오 로그인 오류
- 카카오 SDK 초기화 확인
- Native App Key 확인
- Redirect URI 설정 확인
- Android/iOS 플랫폼 등록 확인

### 구글 로그인 오류
- Google Cloud Console 설정 확인
- OAuth 2.0 클라이언트 ID 확인
- SHA-1 인증서 지문 확인 (Android)
- Bundle ID 확인 (iOS)

## 참고 자료
- [카카오 로그인 가이드](https://developers.kakao.com/docs/latest/ko/kakaologin/flutter)
- [구글 로그인 가이드](https://pub.dev/packages/google_sign_in)
