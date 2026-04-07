# KidsChallenge DDL 설계 검토 및 수정사항

## 발견된 문제점

### 1. 스키마 명시 부족
- **문제**: DDL 파일들이 스키마를 명시하지 않아 기본 스키마(public)에 테이블이 생성될 수 있음
- **영향**: `application.properties`에서 `currentSchema=kidspoint`로 설정했지만, 테이블이 다른 스키마에 생성되면 외래 키 제약 조건이 실패함
- **해결**: 모든 DDL에 `kidspoint.` 스키마를 명시적으로 지정

### 2. 외래 키 제약 조건 스키마 불일치
- **문제**: `family_members.user_id`가 `users.id`를 참조하지만, `users` 테이블이 다른 스키마에 있으면 제약 조건 실패
- **영향**: 가족 생성 시 외래 키 제약 조건 위반 오류 발생
- **해결**: 모든 외래 키 제약 조건이 `kidspoint.users`를 참조하도록 수정

### 3. 소셜 로그인 지원 설계
- **현재 상태**: 
  - `users.username`: 일반 사용자는 사용자명, 소셜 사용자는 `"kakao_123456"` 형식
  - `users.password`: 일반 사용자는 BCrypt 해시, 소셜 사용자는 랜덤 UUID 해시
  - `users.email`: 소셜 로그인 사용자의 이메일 저장 가능
  - `users.nickname`: 소셜 로그인 사용자의 닉네임 저장 가능
- **설계 검토 결과**: ✅ 적절함
  - 소셜 로그인 사용자도 일반 사용자와 동일한 구조로 저장됨
  - `password` 컬럼이 NOT NULL이지만, 소셜 로그인 사용자는 랜덤 해시를 저장하므로 문제 없음
  - 카카오 로그인 시 자동으로 사용자 생성/업데이트 로직이 구현되어 있음

## 수정된 DDL 파일

### 1. `create_users_table.sql`
- ✅ `kidspoint` 스키마 명시 추가
- ✅ 소셜 로그인 지원 주석 추가

### 2. `create_kidschallenge_full_v2.sql` (새 파일)
- ✅ 모든 테이블에 `kidspoint.` 스키마 명시
- ✅ 모든 ENUM 타입에 `kidspoint.` 스키마 명시
- ✅ 모든 외래 키 제약 조건이 `kidspoint.users` 참조
- ✅ 소셜 로그인 지원 주석 추가

### 3. `fix_schema_and_constraints.sql` (새 파일)
- ✅ 기존 데이터베이스 수정용 스크립트
- ✅ 스키마 생성
- ✅ 기존 제약 조건 삭제 및 재생성
- ✅ 데이터 마이그레이션 (필요한 경우)

## DB 수정사항

### 즉시 실행해야 할 SQL 스크립트

1. **`fix_schema_and_constraints.sql` 실행**
   ```sql
   -- 이 스크립트는 기존 데이터베이스를 수정합니다.
   -- 기존 제약 조건을 삭제하고 올바른 스키마를 참조하도록 재생성합니다.
   ```

2. **또는 새로 시작하는 경우 `create_kidschallenge_full_v2.sql` 실행**
   ```sql
   -- 이 스크립트는 모든 테이블을 kidspoint 스키마에 생성합니다.
   -- 기존 테이블이 있다면 먼저 삭제하거나 fix_schema_and_constraints.sql을 사용하세요.
   ```

### 스키마 확인 쿼리

```sql
-- kidspoint 스키마에 users 테이블이 있는지 확인
SELECT table_schema, table_name 
FROM information_schema.tables 
WHERE table_schema = 'kidspoint' AND table_name = 'users';

-- 현재 사용자가 users 테이블에 있는지 확인
SELECT * FROM kidspoint.users WHERE id = '75ccade8-4328-4966-8847-3df53d11a1f4';

-- family_members의 외래 키 제약 조건 확인
SELECT 
    tc.constraint_name, 
    tc.table_schema, 
    tc.table_name,
    kcu.column_name,
    ccu.table_schema AS foreign_table_schema,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'kidspoint'
    AND tc.table_name = 'family_members'
    AND kcu.column_name = 'user_id';
```

## 소셜 로그인 설계 검토

### ✅ 잘 설계된 부분
1. **사용자 식별**: `username`에 `"kakao_"` 접두사 사용으로 일반 사용자와 구분
2. **비밀번호 처리**: 소셜 로그인 사용자도 랜덤 해시 저장으로 NOT NULL 제약 조건 만족
3. **자동 회원가입**: 카카오 로그인 시 자동으로 사용자 생성/업데이트
4. **이메일/닉네임**: 소셜 로그인 사용자의 이메일과 닉네임 저장 가능

### 개선 제안 (선택사항)
1. **소셜 로그인 타입 컬럼 추가** (향후 확장성)
   ```sql
   ALTER TABLE kidspoint.users ADD COLUMN IF NOT EXISTS auth_type TEXT DEFAULT 'local';
   -- 'local', 'kakao', 'google' 등
   ```
2. **소셜 로그인 ID 별도 저장** (선택사항)
   ```sql
   ALTER TABLE kidspoint.users ADD COLUMN IF NOT EXISTS social_id TEXT;
   -- 카카오 ID, 구글 ID 등을 별도로 저장
   ```

## 권장 사항

1. **즉시 실행**: `fix_schema_and_constraints.sql` 실행하여 기존 데이터베이스 수정
2. **향후**: 새로운 환경에서는 `create_kidschallenge_full_v2.sql` 사용
3. **검증**: 위의 확인 쿼리로 스키마와 제약 조건이 올바르게 설정되었는지 확인

## 실행 순서

### 기존 데이터베이스 수정 (권장)

```bash
# PostgreSQL에 접속하여 다음 스크립트 실행
psql -U postgres -d postgres -f backend/kidserver/src/main/resources/migration/fix_schema_and_constraints.sql
```

### 새로 시작하는 경우

```bash
# 1. users 테이블 생성
psql -U postgres -d postgres -f backend/kidserver/src/main/resources/migration/create_users_table.sql

# 2. 전체 스키마 생성
psql -U postgres -d postgres -f backend/kidserver/src/main/resources/migration/create_kidschallenge_full_v2.sql

# 3. Spring Session 테이블 생성
psql -U postgres -d postgres -f backend/kidserver/src/main/resources/migration/create_spring_session_tables.sql
```

## 수정된 파일 목록

1. ✅ `create_users_table.sql` - 스키마 명시 추가
2. ✅ `create_kidschallenge_full.sql` - 모든 테이블에 스키마 명시 추가
3. ✅ `create_kidschallenge_full_v2.sql` - 새 파일 (권장)
4. ✅ `fix_schema_and_constraints.sql` - 기존 DB 수정용 스크립트
5. ✅ `DDL_REVIEW.md` - 이 문서
