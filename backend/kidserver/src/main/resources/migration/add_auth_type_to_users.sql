-- users 테이블에 소셜 로그인 구분 컬럼 추가
-- auth_type: 'local', 'kakao', 'google' 등
-- social_id: 소셜 로그인 ID (카카오 ID, 구글 ID 등)

-- auth_type 컬럼 추가 (기본값: 'local')
ALTER TABLE kidspoint.users 
ADD COLUMN IF NOT EXISTS auth_type TEXT NOT NULL DEFAULT 'local';

-- social_id 컬럼 추가 (소셜 로그인 ID 저장)
ALTER TABLE kidspoint.users 
ADD COLUMN IF NOT EXISTS social_id TEXT;

-- 기존 카카오 사용자 업데이트 (username이 "kakao_"로 시작하는 경우)
UPDATE kidspoint.users 
SET auth_type = 'kakao',
    social_id = SUBSTRING(username FROM 7)  -- "kakao_" 제거하여 카카오 ID 추출
WHERE username LIKE 'kakao_%' 
  AND auth_type = 'local';

-- 인덱스 추가 (소셜 로그인 조회 성능 향상)
CREATE INDEX IF NOT EXISTS idx_users_auth_type ON kidspoint.users(auth_type);
CREATE INDEX IF NOT EXISTS idx_users_social_id ON kidspoint.users(social_id) WHERE social_id IS NOT NULL;

-- 복합 인덱스 (auth_type + social_id로 소셜 사용자 조회)
CREATE INDEX IF NOT EXISTS idx_users_auth_social ON kidspoint.users(auth_type, social_id) WHERE social_id IS NOT NULL;

-- 제약 조건: auth_type은 'local', 'kakao', 'google' 중 하나만 허용
ALTER TABLE kidspoint.users 
ADD CONSTRAINT check_auth_type 
CHECK (auth_type IN ('local', 'kakao', 'google'));

-- 제약 조건: 소셜 로그인 사용자는 social_id가 필수
-- 주의: 이 제약 조건은 기존 데이터에 영향을 줄 수 있으므로 주의해서 사용
-- ALTER TABLE kidspoint.users 
-- ADD CONSTRAINT check_social_id 
-- CHECK ((auth_type = 'local' AND social_id IS NULL) OR (auth_type != 'local' AND social_id IS NOT NULL));
