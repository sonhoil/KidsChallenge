# 모바일 환경 테스트 가이드

## 개요

Kids Challenge 앱은 네이티브 모바일 앱이므로, 실제 모바일 기기(Android/iOS)에서 테스트하는 것이 권장됩니다.

## 웹 환경 제한사항

웹 환경에서는 다음 기능이 제한됩니다:
- ❌ 카카오톡 앱 로그인 (웹에서는 카카오계정 로그인만 가능)
- ⚠️ 일부 네이티브 기능 제한

## 모바일 환경 테스트 방법

### Android 기기 테스트

#### 1. USB 디버깅 활성화
1. Android 기기의 **설정** > **휴대전화 정보** > **빌드 번호**를 7번 연속 탭
2. **설정** > **개발자 옵션** > **USB 디버깅** 활성화

#### 2. 기기 연결 및 확인
```bash
cd frontend-mobile

# 연결된 기기 확인
flutter devices

# Android 기기에서 실행
flutter run
```

#### 3. 네트워크 설정
모바일 기기와 백엔드 서버가 같은 네트워크에 있어야 합니다.

**옵션 1: 로컬 IP 사용 (권장)**
```dart
// lib/core/config/app_config.dart
static const String baseUrl = 'http://192.168.200.138:8080/api'; // 실제 로컬 IP
```

**옵션 2: ngrok 사용 (외부 접근 필요 시)**
```bash
# 백엔드 서버를 ngrok으로 터널링
ngrok http 8080
# 생성된 URL을 app_config.dart에 설정
```

### iOS 기기 테스트 (macOS만 가능)

#### 1. Xcode 설정
1. Xcode 설치
2. **Xcode** > **Preferences** > **Accounts**에서 Apple ID 로그인
3. **Signing & Capabilities**에서 개발 팀 선택

#### 2. 기기 연결 및 실행
```bash
cd frontend-mobile

# 연결된 기기 확인
flutter devices

# iOS 기기에서 실행
flutter run -d <device-id>
```

## 카카오 로그인 테스트

### Android에서 카카오 로그인 테스트

1. **카카오 개발자 콘솔 설정 확인**
   - Android 플랫폼 등록 확인
   - 패키지명: `com.kidspoint.kids_challenge`
   - 키 해시 등록 확인

2. **앱 실행 및 로그인**
   ```bash
   flutter run
   ```
   - 로그인 화면에서 "카카오로 시작하기" 버튼 클릭
   - 카카오톡 앱 또는 카카오계정으로 로그인

### iOS에서 카카오 로그인 테스트

1. **카카오 개발자 콘솔 설정**
   - iOS 플랫폼 등록
   - Bundle ID 등록
   - URL Scheme 등록

2. **앱 실행 및 로그인**
   - 로그인 화면에서 "카카오로 시작하기" 버튼 클릭

## 네트워크 연결 문제 해결

### 문제: 백엔드에 연결되지 않음

**해결 방법:**
1. 백엔드 서버가 실행 중인지 확인
2. 모바일 기기와 개발 머신이 같은 Wi-Fi 네트워크에 연결되어 있는지 확인
3. 방화벽 설정 확인
4. `app_config.dart`의 `baseUrl`이 올바른지 확인

**로컬 IP 확인 (macOS/Linux):**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**로컬 IP 확인 (Windows):**
```cmd
ipconfig
```

### 문제: CORS 오류

모바일 앱에서는 CORS 문제가 발생하지 않습니다. 웹 환경에서만 발생합니다.

## 테스트 체크리스트

### 기본 기능
- [ ] 앱 실행 확인
- [ ] 로그인 화면 표시 확인
- [ ] 일반 로그인 (테스트 계정) 확인

### 카카오 로그인
- [ ] 카카오 로그인 버튼 클릭
- [ ] 카카오톡 앱 로그인 또는 카카오계정 로그인
- [ ] 로그인 후 홈 화면 이동 확인
- [ ] 세션 유지 확인 (앱 재시작 후)

### 구글 로그인
- [ ] 구글 로그인 버튼 클릭
- [ ] 구글 계정 선택 및 로그인
- [ ] 로그인 후 홈 화면 이동 확인

### 가족 기능
- [ ] 가족 생성
- [ ] 가족 가입 (초대코드)
- [ ] 가족 멤버 목록 확인

### 미션 기능
- [ ] 미션 생성
- [ ] 미션 할당
- [ ] 미션 완료 및 승인

### 포인트 기능
- [ ] 포인트 잔액 확인
- [ ] 포인트 적립 (미션 완료)
- [ ] 포인트 사용 (리워드 구매)

## 디버깅 팁

### Flutter 로그 확인
```bash
flutter run --verbose
```

### Android 로그 확인
```bash
adb logcat | grep -i "kids_challenge\|flutter"
```

### iOS 로그 확인
Xcode의 Console에서 확인하거나:
```bash
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "kids_challenge"'
```

## 성능 최적화

### 릴리즈 빌드 테스트
```bash
# Android
flutter build apk --release
flutter install --release

# iOS
flutter build ios --release
```

## 주의사항

1. **개발 환경 vs 프로덕션 환경**
   - 개발: `http://localhost` 또는 로컬 IP 사용
   - 프로덕션: 실제 도메인 사용

2. **보안**
   - 프로덕션에서는 HTTPS 사용 필수
   - API 키는 환경 변수로 관리

3. **카카오 로그인**
   - 디버그 키 해시와 릴리즈 키 해시 모두 등록 필요
   - 실제 배포 전에 릴리즈 키 해시 등록 확인

## 다음 단계

1. ✅ 모바일 기기에서 앱 실행
2. ✅ 카카오 로그인 테스트
3. ✅ 구글 로그인 테스트 (설정 완료 후)
4. ✅ 모든 기능 테스트
5. ✅ 릴리즈 빌드 테스트
