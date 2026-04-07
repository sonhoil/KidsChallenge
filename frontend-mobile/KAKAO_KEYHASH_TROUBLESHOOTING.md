# 카카오 키 해시 검증 실패 문제 해결 가이드

## 현재 상황
키 해시 검증 실패 오류가 계속 발생하고 있습니다:
```
{error: invalid_request, error_description: Android keyHash validation failed.}
```

## 확인된 키 해시
- **SHA1**: `91:50:AD:CA:BE:C0:FF:1F:BD:35:34:A4:95:3A:2A:FF:25:36:32:CD:3E:DB:E9:16:8E:E6:E8:9B:5F:C8:09:6F`
- **Base64 키 해시**: `kVCtyr7A/x+9NTSklToq/yU2Ms0+2+kWjubom1/ICW8=`

## 해결 방법

### 1. 카카오 개발자 콘솔 확인
- [ ] 패키지명이 정확한지 확인: `com.kidspoint.kids_challenge`
- [ ] 키 해시가 정확히 등록되었는지 확인: `kVCtyr7A/x+9NTSklToq/yU2Ms0+2+kWjubom1/ICW8=`
- [ ] 잘린 키 해시가 없는지 확인 (예: `kVCtyr7A/x+9NTSklToq/yU2Ms0=` 같은 잘린 값 제거)
- [ ] 저장 버튼을 클릭했는지 확인

### 2. 변경사항 반영 대기
카카오 개발자 콘솔에 변경사항이 반영되는 데 **5-10분** 정도 소요될 수 있습니다.
- 변경 후 즉시 테스트하지 말고 몇 분 기다린 후 다시 시도하세요.

### 3. 앱 완전 제거 및 재설치
기존 앱이 다른 키스토어로 서명되었을 수 있으므로 완전히 제거하고 재설치하세요:

```bash
# 앱 완전 제거
adb uninstall com.kidspoint.kids_challenge

# 앱 재설치
cd frontend-mobile
flutter clean
flutter pub get
flutter run
```

또는 Android Studio에서:
1. 기기에서 앱 완전 제거
2. `flutter clean` 실행
3. `flutter run` 실행

### 4. 실제 사용 중인 키 해시 확인
앱이 실제로 사용하는 키 해시를 확인하려면:

#### 방법 1: Android 로그 확인
카카오 SDK가 로그에 키 해시를 출력할 수 있습니다. 앱 실행 후 로그를 확인하세요:
```bash
adb logcat | grep -i "keyhash\|key hash\|SHA1"
```

#### 방법 2: 카카오 SDK 로그 확인
카카오 SDK 초기화 시 로그에 키 해시가 출력될 수 있습니다:
```bash
adb logcat | grep -i "kakao"
```

### 5. 키스토어 확인
현재 사용 중인 키스토어가 올바른지 확인:

```bash
# 디버그 키스토어 확인
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

출력된 SHA1 값이 위의 값과 일치하는지 확인하세요.

### 6. 빌드 타입 확인
`android/app/build.gradle`에서 릴리즈 빌드가 디버그 키스토어를 사용하는지 확인:

```gradle
buildTypes {
    release {
        signingConfig signingConfigs.debug  // 디버그 키스토어 사용
    }
}
```

릴리즈 빌드를 사용하는 경우 릴리즈 키 해시도 등록해야 합니다.

### 7. 카카오 개발자 콘솔 재확인
1. 카카오 개발자 콘솔 접속
2. 내 애플리케이션 선택
3. **앱 설정** > **플랫폼** > **Android** 선택
4. 키 해시 섹션 확인:
   - 올바른 키 해시만 등록되어 있는지 확인
   - 잘린 키 해시가 있으면 제거
   - 저장 버튼 클릭

### 8. 네트워크 및 캐시 확인
- 카카오 서버의 캐시 문제일 수 있으므로 몇 분 후 다시 시도
- 다른 네트워크에서 테스트 (Wi-Fi vs 모바일 데이터)

## 체크리스트
- [ ] 카카오 개발자 콘솔에 키 해시 정확히 등록됨
- [ ] 잘린 키 해시 제거됨
- [ ] 저장 버튼 클릭함
- [ ] 5-10분 대기 (변경사항 반영 시간)
- [ ] 앱 완전 제거 및 재설치
- [ ] 올바른 키스토어 사용 확인
- [ ] AndroidManifest.xml의 스킴이 올바른지 확인: `kakao01d96aed07dfdb284de6448247a0b8ae`
- [ ] 패키지명이 정확한지 확인: `com.kidspoint.kids_challenge`

## 추가 디버깅
여전히 문제가 발생하면:

1. **카카오 SDK 버전 확인**:
   ```yaml
   # pubspec.yaml
   kakao_flutter_sdk: ^1.3.0
   ```

2. **AndroidManifest.xml 확인**:
   - Intent Filter가 올바르게 설정되었는지 확인
   - 스킴이 네이티브 앱 키와 일치하는지 확인

3. **카카오 개발자 콘솔 문의**:
   - 문제가 계속되면 카카오 개발자 센터에 문의

## 참고
- 키 해시는 앱 서명에 따라 달라집니다
- 디버그 빌드와 릴리즈 빌드는 다른 키 해시를 사용합니다
- 키스토어를 변경하면 키 해시도 변경됩니다
