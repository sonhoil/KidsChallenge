-- users 테이블 생성 (kidspoint 스키마용)
-- 기존 boxsage 스키마의 users 테이블과 동일한 구조
-- 소셜 로그인 지원: password는 NOT NULL이지만 소셜 로그인 사용자는 랜덤 해시 저장

-- 스키마 생성
CREATE SCHEMA IF NOT EXISTS kidspoint;

CREATE TABLE IF NOT EXISTS kidspoint.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT NOT NULL UNIQUE,  -- 일반: 사용자명, 소셜: 고유한 사용자명 (예: "kakao_123456", "google_123456")
    password TEXT NOT NULL,         -- 일반: BCrypt 해시, 소셜: 랜덤 UUID 해시
    email TEXT,
    nickname TEXT,
    auth_type TEXT NOT NULL DEFAULT 'local',  -- 인증 타입: 'local', 'kakao', 'google'
    social_id TEXT,                 -- 소셜 로그인 ID (카카오 ID, 구글 ID 등)
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT check_auth_type CHECK (auth_type IN ('local', 'kakao', 'google'))
);

CREATE INDEX IF NOT EXISTS idx_users_username ON kidspoint.users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON kidspoint.users(email);
CREATE INDEX IF NOT EXISTS idx_users_auth_type ON kidspoint.users(auth_type);
CREATE INDEX IF NOT EXISTS idx_users_social_id ON kidspoint.users(social_id) WHERE social_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_users_auth_social ON kidspoint.users(auth_type, social_id) WHERE social_id IS NOT NULL;

-- 테스트 계정 생성
-- 비밀번호: Test1234!
-- 비밀번호 해시는 BCryptPasswordEncoder(12)로 생성해야 합니다.
-- Java 코드로 생성:
-- BCryptPasswordEncoder encoder = new BCryptPasswordEncoder(12);
-- String hash = encoder.encode("Test1234!");
-- 
-- 또는 온라인 도구 사용: https://bcrypt-generator.com/ (rounds: 12)
-- 
-- 아래 해시는 예시입니다. 실제로는 서버에서 생성한 해시를 사용하세요.
INSERT INTO kidspoint.users (
    id,
    username,
    password,
    email,
    nickname,
    auth_type,
    social_id,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    'testuser',
    '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyY5x5x5x5x5', -- Test1234! 비밀번호 해시 (rounds 12) - 실제 해시로 교체 필요
    'test@kidspoint.app',
    '테스트 사용자',
    'local',  -- 일반 로그인 사용자
    NULL,     -- 소셜 로그인 ID 없음
    NOW(),
    NOW()
)
ON CONFLICT (username) DO NOTHING;
