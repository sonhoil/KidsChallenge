# 소셜 로그인 구분 컬럼 추가 가이드

## 변경 사항

`users` 테이블에 소셜 로그인 사용자를 구분하기 위한 컬럼을 추가했습니다.

### 추가된 컬럼

1. **`auth_type`** (TEXT, NOT NULL, DEFAULT 'local')
   - 인증 타입: `'local'`, `'kakao'`, `'google'`
   - 제약 조건: `CHECK (auth_type IN ('local', 'kakao', 'google'))`

2. **`social_id`** (TEXT, NULL)
   - 소셜 로그인 ID (카카오 ID, 구글 ID 등)
   - 일반 로그인 사용자는 `NULL`

### 인덱스

- `idx_users_auth_type`: `auth_type` 컬럼 인덱스
- `idx_users_social_id`: `social_id` 컬럼 인덱스 (NULL 제외)
- `idx_users_auth_social`: 복합 인덱스 (`auth_type`, `social_id`) (NULL 제외)

## 마이그레이션 방법

### 옵션 1: 기존 데이터베이스에 컬럼 추가 (권장)

```bash
psql -U postgres -d postgres -f backend/kidserver/src/main/resources/migration/add_auth_type_to_users.sql
```

이 스크립트는:
- `auth_type`과 `social_id` 컬럼 추가
- 기존 카카오 사용자 자동 업데이트 (username이 "kakao_"로 시작하는 경우)
- 인덱스 및 제약 조건 추가

### 옵션 2: 전체 스키마 재생성

기존 데이터베이스를 삭제하고 새로 시작하는 경우:

```bash
# 1. users 테이블 생성 (auth_type 포함)
psql -U postgres -d postgres -f backend/kidserver/src/main/resources/migration/create_users_table.sql

# 2. 전체 스키마 생성
psql -U postgres -d postgres -f backend/kidserver/src/main/resources/migration/create_kidschallenge_full_v2.sql

# 3. Spring Session 테이블 생성
psql -U postgres -d postgres -f backend/kidserver/src/main/resources/migration/create_spring_session_tables.sql
```

## 코드 변경 사항

### 1. Domain (`User.java`)
- `authType` 필드 추가
- `socialId` 필드 추가

### 2. Mapper (`UserMapper.java`, `UserMapper.xml`)
- `selectByAuthTypeAndSocialId()` 메서드 추가
- 모든 SELECT, INSERT, UPDATE 쿼리에 `auth_type`, `social_id` 포함

### 3. Service (`AuthService.java`, `KakaoAuthService.java`)
- 일반 회원가입: `authType = "local"`, `socialId = null`
- 카카오 로그인: `authType = "kakao"`, `socialId = 카카오ID`
- 카카오 사용자 조회: `selectByAuthTypeAndSocialId("kakao", 카카오ID)` 사용

### 4. DTO (`UserResponse.java`)
- `authType` 필드 추가

## 사용 예시

### 카카오 로그인 사용자 조회

```java
// 기존 방식 (username으로 조회)
User user = userMapper.selectByUsername("kakao_123456");

// 새로운 방식 (auth_type + social_id로 조회) - 권장
User user = userMapper.selectByAuthTypeAndSocialId("kakao", "123456");
```

### 구글 로그인 사용자 조회 (향후 구현)

```java
User user = userMapper.selectByAuthTypeAndSocialId("google", "google_user_id");
```

## 검증 쿼리

```sql
-- 모든 사용자의 인증 타입 확인
SELECT id, username, auth_type, social_id, email, nickname
FROM kidspoint.users
ORDER BY created_at DESC;

-- 카카오 로그인 사용자만 조회
SELECT id, username, auth_type, social_id, email, nickname
FROM kidspoint.users
WHERE auth_type = 'kakao';

-- 일반 로그인 사용자만 조회
SELECT id, username, auth_type, social_id, email, nickname
FROM kidspoint.users
WHERE auth_type = 'local';
```

## 향후 구글 로그인 구현 시

1. `GoogleAuthService.java` 생성 (KakaoAuthService와 유사)
2. `AuthController`에 `/api/auth/google/login` 엔드포인트 추가
3. 구글 사용자 조회 시 `selectByAuthTypeAndSocialId("google", 구글ID)` 사용
