# BoxServer 백엔드 구조

## 패키지 구조 (대기능별 분리)

```
com.boxsage.api/
├── auth/                    # 인증/인가 모듈
│   ├── controller/
│   │   └── AuthController.java
│   ├── domain/
│   │   └── User.java
│   ├── dto/
│   │   ├── LoginRequest.java
│   │   ├── RegisterRequest.java
│   │   └── UserResponse.java
│   ├── mapper/
│   │   └── UserMapper.java
│   └── service/
│       ├── AuthService.java
│       └── UserDetailsServiceImpl.java
│
├── organization/            # 조직 관리 모듈
│   ├── config/
│   │   └── OrganizationGuard.java
│   ├── controller/
│   │   └── OrganizationController.java
│   ├── domain/
│   │   ├── Organization.java
│   │   └── OrganizationMember.java
│   ├── dto/
│   │   ├── CreateOrganizationRequest.java
│   │   ├── OrganizationResponse.java
│   │   └── SelectOrganizationRequest.java
│   ├── mapper/
│   │   ├── OrganizationMapper.java
│   │   └── OrganizationMemberMapper.java
│   ├── service/
│   │   └── OrganizationService.java
│   └── util/
│       └── OrganizationContext.java
│
├── box/                     # 박스 관리 모듈
│   ├── controller/
│   │   └── BoxController.java (QR 엔드포인트 포함)
│   ├── domain/
│   │   └── Box.java
│   ├── dto/
│   │   ├── BoxResponse.java
│   │   ├── CreateBoxRequest.java
│   │   └── UpdateBoxRequest.java
│   ├── mapper/
│   │   └── BoxMapper.java
│   ├── service/
│   │   └── BoxService.java
│   └── util/
│       └── QrCodeUtil.java
│
├── item/                    # 아이템 관리 모듈
│   ├── controller/
│   │   └── ItemController.java (QR 엔드포인트 포함)
│   ├── domain/
│   │   └── Item.java
│   ├── dto/
│   │   ├── CreateItemRequest.java
│   │   ├── ItemResponse.java
│   │   └── UpdateItemRequest.java
│   ├── mapper/
│   │   └── ItemMapper.java
│   ├── service/
│   │   └── ItemService.java
│   └── util/
│       └── QrCodeUtil.java
│
├── config/                  # 공통 설정
│   ├── GlobalExceptionHandler.java
│   ├── MyBatisConfig.java
│   ├── SecurityConfig.java
│   ├── UUIDTypeHandler.java
│   └── WebConfig.java
│
├── controller/
│   ├── base/
│   │   └── ApiControllerBase.java
│   └── HealthController.java
│
└── dto/                     # 공통 DTO
    ├── ApiResponse.java
    ├── ErrorResponse.java
    └── PageResponse.java
```

## 리소스 구조

```
src/main/resources/
├── mapper/
│   ├── auth/
│   │   └── UserMapper.xml
│   ├── organization/
│   │   ├── OrganizationMapper.xml
│   │   └── OrganizationMemberMapper.xml
│   ├── box/
│   │   └── BoxMapper.xml
│   └── item/
│       └── ItemMapper.xml
└── application.yml
```

## API 엔드포인트

### 인증 (Auth)
- `POST /api/auth/register` - 회원가입
- `POST /api/auth/login` - 로그인
- `POST /api/auth/logout` - 로그아웃
- `GET /api/auth/me` - 현재 사용자 정보

### 조직 (Organization)
- `POST /api/organizations` - 조직 생성
- `GET /api/organizations` - 내 조직 목록
- `GET /api/organizations/{id}` - 조직 상세
- `POST /api/organizations/select` - 조직 선택 (세션에 저장)

### 박스 (Box)
- `GET /api/boxes` - 박스 목록 (페이지네이션)
- `POST /api/boxes` - 박스 생성
- `GET /api/boxes/{id}` - 박스 상세
- `PUT /api/boxes/{id}` - 박스 수정
- `DELETE /api/boxes/{id}` - 박스 삭제
- `GET /api/boxes/{id}/qr` - 박스 QR 코드 (PNG/SVG)

### 아이템 (Item)
- `GET /api/items?boxId=...` - 아이템 목록 (페이지네이션)
- `POST /api/items` - 아이템 생성
- `GET /api/items/{id}` - 아이템 상세 (UUID 또는 qr_uuid)
- `PUT /api/items/{id}` - 아이템 수정
- `DELETE /api/items/{id}` - 아이템 삭제
- `GET /api/items/{id}/qr` - 아이템 QR 코드 (PNG)

## 주요 기능

### 1. 인증/인가
- Spring Security + Spring Session JDBC
- BCrypt 비밀번호 해시 (강도 12)
- CSRF 보호 (Cookie 기반)
- 세션 기반 인증

### 2. 조직 관리
- 조직 생성/조회
- 멤버십 관리 (admin/member 역할)
- 세션 기반 조직 컨텍스트
- OrganizationGuard 인터셉터로 박스/아이템 접근 시 조직 컨텍스트 필수

### 3. 박스 관리
- CRUD 작업
- 박스 한도 검사 (organizations.box_limit)
- 아이템 수 및 최근 업데이트 통계
- QR 코드 생성 (PNG/SVG)

### 4. 아이템 관리
- CRUD 작업
- 박스 소속 검증
- 생성자 메타데이터 추적
- QR 코드 생성 (PNG)
- 박스 정보 JOIN으로 N+1 회피

## 다음 단계

1. 데이터베이스 마이그레이션 (Flyway) 설정
2. Spring Session JDBC 테이블 생성
3. 테스트 작성
4. 세부 로직 보완 및 최적화
