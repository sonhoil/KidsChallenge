# 카카오 개발자 콘솔 - Android 앱 정보 등록 가이드

## 확인된 정보

### 패키지명 (Package Name)
```
com.kidspoint.kids_challenge
```

이 값은 `android/app/build.gradle` 파일의 `applicationId`에서 확인되었습니다.

## 키 해시 생성 방법

### 방법 1: 스크립트 사용 (권장)

터미널에서 다음 명령어 실행:

```bash
cd frontend-mobile
./scripts/get_keyhash.sh
```

스크립트가 자동으로 디버그 키 해시를 생성하고 Base64로 인코딩된 값을 출력합니다.

### 방법 2: 수동 생성

#### 디버그 키 해시 (개발용)

**macOS/Linux:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

출력 예시:
```
SHA1: AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12
```

이 SHA1 값을 Base64로 인코딩:
```bash
echo "AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12" | tr -d ':' | xxd -r -p | openssl base64
```

**Windows:**
```cmd
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

SHA1 값을 복사한 후, 온라인 Base64 인코더 사용하거나 PowerShell로 변환:
```powershell
$sha1 = "AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12"
$bytes = ($sha1 -replace ':', '') -split '(..)' | Where-Object { $_ } | ForEach-Object { [Convert]::ToByte($_, 16) }
[Convert]::ToBase64String($bytes)
```

#### 릴리즈 키 해시 (배포용)

릴리즈 키스토어가 있는 경우:
```bash
keytool -list -v -keystore path/to/your-release-key.keystore -alias your-key-alias
```

## 카카오 개발자 콘솔 등록 절차

### 1. Android 플랫폼 추가

1. [카카오 개발자 콘솔](https://developers.kakao.com/) 접속
2. 내 애플리케이션 선택
3. **앱 설정** > **플랫폼** 메뉴
4. **Android 플랫폼 추가** 클릭

### 2. Android 앱 정보 입력

#### 패키지명
```
com.kidspoint.kids_challenge
```

#### 키 해시
- 위에서 생성한 디버그 키 해시 입력
- **+ 버튼**을 클릭하여 여러 개 추가 가능
- 릴리즈 키 해시도 별도로 추가 (배포 시 필요)

#### 스토어 URL (선택사항)
개발 단계에서는 "없음" 선택 가능

배포 시:
```
market://details?id=com.kidspoint.kids_challenge
```
또는
```
https://play.google.com/store/apps/details?id=com.kidspoint.kids_challenge
```

### 3. 네이티브 앱 키 확인

등록 완료 후:
1. **앱 설정** > **앱 키** 메뉴
2. **네이티브 앱 키** 복사
3. `lib/core/services/kakao_auth_service.dart` 파일에 설정:
   ```dart
   await KakaoSdk.init(
     nativeAppKey: '복사한_네이티브_앱_키',
   );
   ```

### 4. Redirect URI 확인

1. **제품 설정** > **카카오 로그인** 메뉴
2. **Redirect URI** 확인:
   ```
   kakao{네이티브_앱_키}://oauth
   ```
   예: `kakao1234567890abcdef://oauth`

3. `android/app/src/main/AndroidManifest.xml`의 Intent Filter에 반영:
   ```xml
   <data android:scheme="kakao1234567890abcdef" />
   ```

## 체크리스트

- [ ] 패키지명 확인: `com.kidspoint.kids_challenge`
- [ ] 디버그 키 해시 생성 및 등록
- [ ] 릴리즈 키 해시 생성 및 등록 (배포 시)
- [ ] 카카오 개발자 콘솔에 Android 플랫폼 추가
- [ ] 네이티브 앱 키 확인 및 Flutter 앱에 설정
- [ ] Redirect URI 확인 및 AndroidManifest.xml에 반영

## 참고

- 키 해시는 앱 서명에 사용되는 인증서의 고유 식별자입니다
- 디버그 빌드와 릴리즈 빌드는 서로 다른 키스토어를 사용하므로 각각의 키 해시를 등록해야 합니다
- 키 해시가 정확하지 않으면 카카오 로그인이 작동하지 않습니다
