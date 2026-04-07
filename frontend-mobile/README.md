# Kids Challenge - Flutter Mobile App

아이들에게 미션을 부여하고 리워드를 주는 Flutter 네이티브 앱입니다.

## 프로젝트 구조

```
lib/
├── main.dart                    # 앱 진입점
├── core/                        # 핵심 설정 및 유틸리티
│   ├── config/                  # 앱 설정 (API URL 등)
│   ├── theme/                   # 테마 및 색상 정의
│   └── utils/                   # 유틸리티 함수
├── data/                        # 데이터 레이어
│   ├── models/                  # 모델 클래스
│   ├── repositories/            # 리포지토리 (API 호출)
│   └── datasources/            # 데이터 소스 (API 클라이언트)
└── presentation/               # UI 레이어
    ├── screens/                 # 화면
    │   ├── child/              # 아이 모드 화면
    │   │   ├── home/           # 홈 (미션 목록)
    │   │   ├── store/          # 상점 (리워드 구매)
    │   │   ├── coupon/         # 쿠폰함
    │   │   └── profile/        # 프로필
    │   ├── parent/             # 부모 모드 화면
    │   │   ├── parent_dashboard_screen.dart
    │   │   ├── parent_missions_screen.dart
    │   │   ├── parent_members_screen.dart
    │   │   ├── parent_store_screen.dart
    │   │   ├── create_mission_screen.dart
    │   │   ├── create_reward_screen.dart
    │   │   ├── create_member_screen.dart
    │   │   ├── child_stats_screen.dart
    │   │   └── point_adjustment_screen.dart
    │   └── login/               # 로그인 화면
    └── widgets/                 # 공통 위젯
        ├── mission_card.dart
        ├── reward_card.dart
        ├── pending_card.dart
        └── ticket_card.dart
```

## 주요 기능

### 아이 모드
- **홈**: 오늘 할 일 미션 목록 및 완료 처리
- **상점**: 포인트로 리워드 구매
- **쿠폰함**: 구매한 쿠폰/티켓 확인 및 사용
- **프로필**: 내 정보 및 통계 확인

### 부모 모드
- **대시보드**: 승인 대기 중인 미션 관리
- **미션 관리**: 미션 생성, 수정, 삭제
- **멤버 관리**: 아이 계정 추가 및 관리
- **리워드 관리**: 리워드 생성 및 관리
- **포인트 조정**: 수동 포인트 지급/차감

## 설정

1. **백엔드 URL 설정**
   - `lib/core/config/app_config.dart`에서 `baseUrl` 수정

2. **의존성 설치**
   ```bash
   flutter pub get
   ```

3. **실행**
   ```bash
   flutter run
   ```

## 백엔드 API 연동

모든 API 호출은 `data/repositories/` 폴더의 리포지토리 클래스들을 통해 이루어집니다.

- `MissionRepository`: 미션 관련 API
- `RewardRepository`: 리워드 관련 API
- `PointRepository`: 포인트 관련 API
- `FamilyRepository`: 가족/멤버 관련 API

## 상태 관리

현재는 기본적인 StatefulWidget을 사용하고 있으며, 향후 Riverpod 또는 Provider로 전환 가능합니다.

## 다음 단계

1. 실제 백엔드 API 연동
2. 상태 관리 라이브러리 적용 (Riverpod)
3. 로컬 저장소 연동 (SharedPreferences)
4. 에러 처리 및 로딩 상태 관리
5. 애니메이션 및 UX 개선
