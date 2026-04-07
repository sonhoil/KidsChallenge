# 카카오 개발자 콘솔 등록 정보

## Android 앱 정보

### 1. 패키지명 (Package Name)
```
com.kidspoint.kids_challenge
```

### 2. 키 해시 (Key Hash)

#### 디버그 키 해시 (개발용)
**SHA1:**
```
91:50:AD:CA:BE:C0:FF:1F:BD:35:34:A4:95:3A:2A:FF:25:36:32:CD:3E:DB:E9:16:8E:E6:E8:9B:5F:C8:09:6F
```

**Base64 인코딩된 키 해시 (카카오 등록용):**
아래 명령어로 생성:
```bash
echo "91:50:AD:CA:BE:C0:FF:1F:BD:35:34:A4:95:3A:2A:FF:25:36:32:CD" | tr -d ':' | xxd -r -p | openssl base64
```

또는 온라인 도구 사용:
1. SHA1 값에서 콜론(`:`) 제거: `9150ADCABEC0FF1FBD3534A4953A2AFF253632CD`
2. [Base64 인코더](https://www.base64encode.org/)에 입력
3. 결과를 카카오 개발자 콘솔에 등록

**참고:** 전체 SHA1 값이 길어서 앞 20바이트만 사용하거나, 전체 값을 사용할 수 있습니다. 
카카오 SDK는 보통 앞 20바이트의 SHA1을 Base64로 인코딩한 값을 사용합니다.

#### 전체 SHA1을 사용하는 경우
```bash
echo "91:50:AD:CA:BE:C0:FF:1F:BD:35:34:A4:95:3A:2A:FF:25:36:32:CD:3E:DB:E9:16:8E:E6:E8:9B:5F:C8:09:6F" | tr -d ':' | xxd -r -p | openssl base64
```

### 3. 스토어 URL (선택사항)
개발 단계에서는 "없음" 선택

배포 시:
```
market://details?id=com.kidspoint.kids_challenge
```

## 카카오 개발자 콘솔 등록 절차

### Step 1: Android 플랫폼 추가
1. [카카오 개발자 콘솔](https://developers.kakao.com/) 접속
2. 내 애플리케이션 선택
3. **앱 설정** > **플랫폼** 메뉴
4. **Android 플랫폼 추가** 클릭

### Step 2: Android 앱 정보 입력

**패키지명 입력:**
```
com.kidspoint.kids_challenge
```

**키 해시 입력:**
- 위에서 생성한 Base64 인코딩된 키 해시 입력
- **+ 버튼**을 클릭하여 여러 개 추가 가능
- 디버그 키 해시와 릴리즈 키 해시를 모두 등록 권장

**스토어 URL:**
- 개발 단계: "없음" 선택
- 배포 단계: `market://details?id=com.kidspoint.kids_challenge` 입력

### Step 3: 네이티브 앱 키 확인

등록 완료 후:
1. **앱 설정** > **앱 키** 메뉴
2. **네이티브 앱 키** 복사
3. `lib/core/services/kakao_auth_service.dart` 파일 수정:
   ```dart
   await KakaoSdk.init(
     nativeAppKey: '복사한_네이티브_앱_키',
   );
   ```

### Step 4: Redirect URI 확인 및 AndroidManifest.xml 설정

1. **제품 설정** > **카카오 로그인** 메뉴
2. **Redirect URI** 확인 (자동 생성됨):
   ```
   kakao{네이티브_앱_키}://oauth
   ```
   예: `kakao1234567890abcdef://oauth`

3. `android/app/src/main/AndroidManifest.xml` 파일 수정:
   ```xml
   <activity
       android:name="com.kakao.sdk.auth.AuthCodeHandlerActivity"
       android:exported="true">
       <intent-filter>
           <action android:name="android.intent.action.VIEW" />
           <category android:name="android.intent.category.DEFAULT" />
           <category android:name="android.intent.category.BROWSABLE" />
           <!-- 네이티브 앱 키로 교체 -->
           <data android:scheme="kakao1234567890abcdef" />
       </intent-filter>
   </activity>
   ```

## 키 해시 생성 명령어 (참고)

### 디버그 키 해시 (현재 확인된 값)
```bash
# SHA1 확인
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1

# Base64 인코딩 (앞 20바이트)
echo "91:50:AD:CA:BE:C0:FF:1F:BD:35:34:A4:95:3A:2A:FF:25:36:32:CD" | tr -d ':' | xxd -r -p | openssl base64

# Base64 인코딩 (전체)
echo "91:50:AD:CA:BE:C0:FF:1F:BD:35:34:A4:95:3A:2A:FF:25:36:32:CD:3E:DB:E9:16:8E:E6:E8:9B:5F:C8:09:6F" | tr -d ':' | xxd -r -p | openssl base64
```

### 릴리즈 키 해시 (배포용)
```bash
keytool -list -v -keystore path/to/your-release-key.keystore -alias your-key-alias
```

## 중요 사항

1. **키 해시는 정확해야 합니다**: 잘못된 키 해시를 등록하면 카카오 로그인이 작동하지 않습니다.

2. **디버그와 릴리즈 키 해시 모두 등록**: 개발 중에는 디버그 키 해시로 충분하지만, 배포 시에는 릴리즈 키 해시도 필요합니다.

3. **네이티브 앱 키는 보안에 주의**: 네이티브 앱 키는 클라이언트에 노출되므로, 앱 키 노출 자체는 문제가 되지 않지만, Client Secret은 절대 노출되면 안 됩니다.

4. **Redirect URI 확인**: AndroidManifest.xml의 scheme 값이 카카오 개발자 콘솔의 Redirect URI와 정확히 일치해야 합니다.

## 문제 해결

### "키 해시가 등록되지 않았습니다" 오류
- 키 해시가 정확한지 다시 확인
- Base64 인코딩이 올바른지 확인
- 앱을 완전히 종료하고 다시 실행

### "앱이 등록되지 않았습니다" 오류
- 패키지명이 정확한지 확인 (`com.kidspoint.kids_challenge`)
- 카카오 개발자 콘솔에서 Android 플랫폼이 추가되었는지 확인
