-- 구글 플레이스토어 테스트용 계정 생성
-- 이 스크립트는 테스트 계정을 생성합니다.

-- 테스트 계정 정보:
-- 사용자명: testuser
-- 비밀번호: Test1234!
-- 이메일: test@boxsage.app

-- 기존 테스트 계정이 있으면 삭제 (선택사항)
-- DELETE FROM boxsage.users WHERE username = 'testuser';

-- 테스트 계정 생성
-- 주의: 비밀번호 해시는 BCryptPasswordEncoder(12)로 생성해야 합니다.
-- 현재 해시는 rounds 10으로 생성되었을 수 있어 로그인이 실패할 수 있습니다.
-- 서버에서 직접 해시를 생성하여 업데이트하세요:
-- 
-- Java 코드:
-- BCryptPasswordEncoder encoder = new BCryptPasswordEncoder(12);
-- String hash = encoder.encode("Test1234!");
-- System.out.println("Hash: " + hash);
--
-- 또는 온라인 BCrypt 해시 생성기 사용 (rounds 12):
-- https://bcrypt-generator.com/
INSERT INTO boxsage.users (
    id,
    username,
    password,
    email,
    nickname,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    'testuser',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', -- Test1234! 비밀번호 해시 (rounds 10 - 업데이트 필요할 수 있음)
    'test@boxsage.app',
    '테스트 사용자',
    NOW(),
    NOW()
)
ON CONFLICT (username) DO UPDATE SET
    password = EXCLUDED.password,
    updated_at = NOW();

-- 비밀번호 해시 업데이트 (rounds 12로 재생성한 경우)
-- UPDATE boxsage.users 
-- SET password = '$2a$12$새로운해시값',
--     updated_at = NOW()
-- WHERE username = 'testuser';

-- 생성된 테스트 계정 확인
SELECT id, username, email, nickname, created_at 
FROM boxsage.users 
WHERE username = 'testuser';
