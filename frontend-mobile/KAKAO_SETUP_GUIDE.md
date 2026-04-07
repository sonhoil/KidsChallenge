# 카카오 로그인 설정 가이드

## 1. Android 앱 정보 확인

### 패키지명 (Package Name) 확인

Flutter 앱의 패키지명은 `android/app/build.gradle` 파일에서 확인할 수 있습니다.

```bash
# 패키지명 확인
cd frontend-mobile
cat android/app/build.gradle | grep applicationId
```

일반적으로 `com.kidspoint.kids_challenge` 형식입니다.

### 키 해시 (Key Hash) 생성

카카오 SDK는 키 해시가 등록된 앱만 사용할 수 있습니다. 디버그 키와 릴리즈 키 각각의 해시를 생성해야 합니다.

#### 디버그 키 해시 생성 (개발용)

**macOS/Linux:**
```bash
cd frontend-mobile/android
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

**Windows:**
```cmd
cd frontend-mobile\android
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

출력된 SHA1 값을 Base64로 인코딩하면 키 해시가 됩니다.

**또는 간단한 방법 (OpenSSL 사용):**
```bash
# SHA1 값을 복사한 후
echo "SHA1_VALUE" | xxd -r -p | openssl base64
```

#### 릴리즈 키 해시 생성 (배포용)

릴리즈 키스토어가 있는 경우:
```bash
keytool -list -v -keystore your-release-key.keystore -alias your-key-alias
```

#### Flutter로 자동 생성 (권장)

더 간단한 방법으로, Flutter 앱에서 직접 키 해시를 확인할 수 있습니다:

```dart
// 임시로 앱에 추가하여 키 해시 확인
import 'package:flutter/services.dart';

Future<void> getKeyHash() async {
  try {
    const platform = MethodChannel('samples.flutter.dev/keyhash');
    final String keyHash = await platform.invokeMethod('getKeyHash');
    print('Key Hash: $keyHash');
  } on PlatformException catch (e) {
    print("Failed to get key hash: '${e.message}'.");
  }
}
```

또는 **카카오 SDK의 키 해시 확인 기능 사용**:
- 카카오 SDK를 초기화하면 로그에 키 해시가 출력됩니다
- 앱 실행 후 로그를 확인하세요

## 2. 카카오 개발자 콘솔 설정

### 2.1 Android 앱 정보 등록

1. [카카오 개발자 콘솔](https://developers.kakao.com/) 접속
2. 내 애플리케이션 선택
3. **앱 설정** > **플랫폼** > **Android 플랫폼 추가**
4. 다음 정보 입력:

   **패키지명:**
   ```
   com.kidspoint.kids_challenge
   ```
   (실제 패키지명으로 확인 필요)

   **키 해시:**
   - 디버그 키 해시 (개발용)
   - 릴리즈 키 해시 (배포용)
   - 여러 개 추가 가능 (각각 + 버튼으로 추가)

   **스토어 URL (선택사항):**
   ```
   market://details?id=com.kidspoint.kids_challenge
   ```
   또는
   ```
   https://play.google.com/store/apps/details?id=com.kidspoint.kids_challenge
   ```

### 2.2 카카오 로그인 활성화

1. **제품 설정** > **카카오 로그인** 활성화
2. **Redirect URI** 등록:
   ```
   kakao{YOUR_APP_KEY}://oauth
   ```
   예: `kakao1234567890abcdef://oauth`

### 2.3 네이티브 앱 키 확인

1. **앱 설정** > **앱 키**에서 확인:
   - **REST API 키**: 백엔드에서 사용
   - **네이티브 앱 키**: Flutter 앱에서 사용

## 3. Flutter 앱 설정

### 3.1 KakaoAuthService에 네이티브 앱 키 설정

`lib/core/services/kakao_auth_service.dart` 파일 수정:

```dart
await KakaoSdk.init(
  nativeAppKey: 'YOUR_NATIVE_APP_KEY', // 카카오 개발자 콘솔에서 확인한 네이티브 앱 키
  javaScriptAppKey: 'YOUR_JAVASCRIPT_APP_KEY', // 웹용 (선택사항)
);
```

### 3.2 AndroidManifest.xml 설정

`android/app/src/main/AndroidManifest.xml`에 카카오 로그인을 위한 Intent Filter 추가:

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

예: `kakao1234567890abcdef://oauth`인 경우
```xml
<data android:scheme="kakao1234567890abcdef" />
```

### 3.3 build.gradle 확인

`android/app/build.gradle`에 최소 SDK 버전 확인:
```gradle
android {
    defaultConfig {
        minSdkVersion 21  // 카카오 SDK 최소 요구사항
    }
}
```

## 4. 백엔드 설정

`backend/kidserver/src/main/resources/application.properties` 확인:

```properties
kakao.client-id=${KAKAO_CLIENT_ID:YOUR_REST_API_KEY}
kakao.client-secret=${KAKAO_CLIENT_SECRET:YOUR_CLIENT_SECRET}
kakao.redirect-uri=${KAKAO_REDIRECT_URI:http://localhost:8080/api/auth/kakao/callback}
kakao.frontend-redirect-uri=${KAKAO_FRONTEND_REDIRECT_URI:http://localhost:5173}
```

- **REST API 키**: 카카오 개발자 콘솔 > 앱 키에서 확인
- **Client Secret**: 카카오 개발자 콘솔 > 제품 설정 > 카카오 로그인 > 보안에서 확인

## 5. 키 해시 생성 스크립트

편의를 위해 키 해시 생성 스크립트를 제공합니다:

### macOS/Linux 스크립트

`frontend-mobile/scripts/get_keyhash.sh`:
```bash
#!/bin/bash

echo "=== 디버그 키 해시 생성 ==="
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep -A 1 "SHA1:" | tail -1 | sed 's/.*SHA1: //' | xxd -r -p | openssl base64

echo ""
echo "=== 릴리즈 키 해시 생성 (키스토어 경로 입력 필요) ==="
read -p "릴리즈 키스토어 경로: " keystore_path
read -p "키스토어 비밀번호: " -s keystore_pass
read -p "키 별칭: " key_alias

keytool -list -v -keystore "$keystore_path" -alias "$key_alias" -storepass "$keystore_pass" 2>/dev/null | grep -A 1 "SHA1:" | tail -1 | sed 's/.*SHA1: //' | xxd -r -p | openssl base64
```

실행:
```bash
chmod +x frontend-mobile/scripts/get_keyhash.sh
./frontend-mobile/scripts/get_keyhash.sh
```

## 6. 확인 사항 체크리스트

- [ ] 카카오 개발자 콘솔에서 Android 플랫폼 추가
- [ ] 패키지명 등록 (`com.kidspoint.kids_challenge`)
- [ ] 디버그 키 해시 등록
- [ ] 릴리즈 키 해시 등록 (배포 시)
- [ ] 카카오 로그인 활성화
- [ ] Redirect URI 등록 (`kakao{YOUR_APP_KEY}://oauth`)
- [ ] Flutter 앱에 네이티브 앱 키 설정
- [ ] AndroidManifest.xml에 Intent Filter 추가
- [ ] 백엔드에 REST API 키 및 Client Secret 설정

## 7. 테스트

설정 완료 후:

1. Flutter 앱 실행
2. 로그인 화면에서 "카카오로 시작하기" 버튼 클릭
3. 카카오톡 앱 또는 카카오계정으로 로그인
4. 로그인 성공 확인

## 문제 해결

### "키 해시가 등록되지 않았습니다" 오류
- 키 해시가 정확히 등록되었는지 확인
- 디버그/릴리즈 키 해시를 모두 등록했는지 확인
- 앱을 완전히 종료하고 다시 실행

### "앱이 등록되지 않았습니다" 오류
- 패키지명이 정확한지 확인
- 카카오 개발자 콘솔에서 Android 플랫폼이 추가되었는지 확인

### 로그인 후 앱으로 돌아오지 않음
- AndroidManifest.xml의 Intent Filter 확인
- Redirect URI가 정확한지 확인
