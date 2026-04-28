-- Apple Sign in: users.auth_type 체크 제약에 'apple' 추가
ALTER TABLE kidspoint.users DROP CONSTRAINT IF EXISTS check_auth_type;
ALTER TABLE kidspoint.users ADD CONSTRAINT check_auth_type
  CHECK (auth_type IN ('local', 'kakao', 'google', 'apple'));
