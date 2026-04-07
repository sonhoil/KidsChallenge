-- 테스트 계정 비밀번호 업데이트
-- 비밀번호: Test1234!
-- 이 스크립트는 백엔드 서버의 /api/auth/test/generate-hash?password=Test1234! 엔드포인트를 통해
-- 생성한 해시로 업데이트해야 합니다.

-- 1. 먼저 백엔드 서버에서 해시 생성:
--    GET http://localhost:8080/api/auth/test/generate-hash?password=Test1234!
--    응답에서 해시 값을 복사

-- 2. 아래 UPDATE 문의 해시 값을 위에서 생성한 해시로 교체
UPDATE users 
SET password = '$2a$12$YOUR_GENERATED_HASH_HERE',  -- 여기에 생성한 해시를 넣으세요
    updated_at = NOW()
WHERE username = 'testuser';

-- 또는 테스트 계정이 없으면 생성
INSERT INTO users (
    id,
    username,
    password,
    email,
    nickname,
    created_at,
    updated_at
) 
SELECT 
    gen_random_uuid(),
    'testuser',
    '$2a$12$YOUR_GENERATED_HASH_HERE',  -- 여기에 생성한 해시를 넣으세요
    'test@kidspoint.app',
    '테스트 사용자',
    NOW(),
    NOW()
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'testuser');
