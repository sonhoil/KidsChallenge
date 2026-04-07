-- 스키마 및 외래 키 제약 조건 수정 스크립트
-- 이 스크립트는 kidspoint 스키마에 모든 테이블이 올바르게 생성되도록 보장합니다.

-- 1. kidspoint 스키마가 없으면 생성
CREATE SCHEMA IF NOT EXISTS kidspoint;

-- 2. users 테이블이 kidspoint 스키마에 있는지 확인하고, 없으면 생성
CREATE TABLE IF NOT EXISTS kidspoint.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,  -- 소셜 로그인 사용자도 랜덤 해시 저장
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

-- 3. 기존 users 테이블의 데이터를 kidspoint.users로 마이그레이션 (있는 경우)
-- 주의: 이 작업은 기존 데이터를 보존합니다.
DO $$
BEGIN
    -- public 스키마에 users 테이블이 있고, kidspoint.users에 데이터가 없는 경우에만 마이그레이션
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users')
       AND NOT EXISTS (SELECT 1 FROM kidspoint.users LIMIT 1)
    THEN
        INSERT INTO kidspoint.users (id, username, password, email, nickname, auth_type, social_id, created_at, updated_at)
        SELECT 
            id, 
            username, 
            password, 
            email, 
            nickname,
            CASE 
                WHEN username LIKE 'kakao_%' THEN 'kakao'
                WHEN username LIKE 'google_%' THEN 'google'
                ELSE 'local'
            END AS auth_type,
            CASE 
                WHEN username LIKE 'kakao_%' THEN SUBSTRING(username FROM 7)
                WHEN username LIKE 'google_%' THEN SUBSTRING(username FROM 8)
                ELSE NULL
            END AS social_id,
            created_at, 
            updated_at
        FROM public.users
        ON CONFLICT (username) DO NOTHING;
    END IF;
END $$;

-- 4. family_members 테이블의 외래 키 제약 조건 확인 및 수정
-- 기존 제약 조건이 있다면 삭제하고 재생성
DO $$
BEGIN
    -- 기존 외래 키 제약 조건 삭제 (있는 경우)
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_schema = 'kidspoint' 
        AND table_name = 'family_members' 
        AND constraint_name = 'family_members_user_id_fkey'
    ) THEN
        ALTER TABLE kidspoint.family_members DROP CONSTRAINT family_members_user_id_fkey;
    END IF;
    
    -- 올바른 스키마를 참조하는 외래 키 제약 조건 재생성
    ALTER TABLE kidspoint.family_members 
    ADD CONSTRAINT family_members_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES kidspoint.users(id) ON DELETE CASCADE;
END $$;

-- 5. 다른 테이블들의 외래 키 제약 조건도 확인 및 수정
-- point_accounts
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_schema = 'kidspoint' 
        AND table_name = 'point_accounts' 
        AND constraint_name = 'point_accounts_user_id_fkey'
    ) THEN
        ALTER TABLE kidspoint.point_accounts DROP CONSTRAINT point_accounts_user_id_fkey;
    END IF;
    
    ALTER TABLE kidspoint.point_accounts 
    ADD CONSTRAINT point_accounts_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES kidspoint.users(id) ON DELETE CASCADE;
END $$;

-- missions
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_schema = 'kidspoint' 
        AND table_name = 'missions' 
        AND constraint_name = 'missions_created_by_fkey'
    ) THEN
        ALTER TABLE kidspoint.missions DROP CONSTRAINT missions_created_by_fkey;
    END IF;
    
    ALTER TABLE kidspoint.missions 
    ADD CONSTRAINT missions_created_by_fkey 
    FOREIGN KEY (created_by) REFERENCES kidspoint.users(id);
END $$;

-- mission_assignments
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_schema = 'kidspoint' 
        AND table_name = 'mission_assignments' 
        AND constraint_name = 'mission_assignments_assignee_id_fkey'
    ) THEN
        ALTER TABLE kidspoint.mission_assignments DROP CONSTRAINT mission_assignments_assignee_id_fkey;
    END IF;
    
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_schema = 'kidspoint' 
        AND table_name = 'mission_assignments' 
        AND constraint_name = 'mission_assignments_assigned_by_fkey'
    ) THEN
        ALTER TABLE kidspoint.mission_assignments DROP CONSTRAINT mission_assignments_assigned_by_fkey;
    END IF;
    
    ALTER TABLE kidspoint.mission_assignments 
    ADD CONSTRAINT mission_assignments_assignee_id_fkey 
    FOREIGN KEY (assignee_id) REFERENCES kidspoint.users(id) ON DELETE CASCADE;
    
    ALTER TABLE kidspoint.mission_assignments 
    ADD CONSTRAINT mission_assignments_assigned_by_fkey 
    FOREIGN KEY (assigned_by) REFERENCES kidspoint.users(id);
END $$;

-- mission_logs
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_schema = 'kidspoint' 
        AND table_name = 'mission_logs' 
        AND constraint_name = 'mission_logs_changed_by_fkey'
    ) THEN
        ALTER TABLE kidspoint.mission_logs DROP CONSTRAINT mission_logs_changed_by_fkey;
    END IF;
    
    ALTER TABLE kidspoint.mission_logs 
    ADD CONSTRAINT mission_logs_changed_by_fkey 
    FOREIGN KEY (changed_by) REFERENCES kidspoint.users(id);
END $$;

-- rewards
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_schema = 'kidspoint' 
        AND table_name = 'rewards' 
        AND constraint_name = 'rewards_created_by_fkey'
    ) THEN
        ALTER TABLE kidspoint.rewards DROP CONSTRAINT rewards_created_by_fkey;
    END IF;
    
    ALTER TABLE kidspoint.rewards 
    ADD CONSTRAINT rewards_created_by_fkey 
    FOREIGN KEY (created_by) REFERENCES kidspoint.users(id);
END $$;

-- reward_purchases
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_schema = 'kidspoint' 
        AND table_name = 'reward_purchases' 
        AND constraint_name = 'reward_purchases_buyer_id_fkey'
    ) THEN
        ALTER TABLE kidspoint.reward_purchases DROP CONSTRAINT reward_purchases_buyer_id_fkey;
    END IF;
    
    ALTER TABLE kidspoint.reward_purchases 
    ADD CONSTRAINT reward_purchases_buyer_id_fkey 
    FOREIGN KEY (buyer_id) REFERENCES kidspoint.users(id) ON DELETE CASCADE;
END $$;

-- 6. auth_type과 social_id 컬럼 추가 (기존 테이블에 없는 경우)
DO $$
BEGIN
    -- auth_type 컬럼 추가
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'kidspoint' 
        AND table_name = 'users' 
        AND column_name = 'auth_type'
    ) THEN
        ALTER TABLE kidspoint.users ADD COLUMN auth_type TEXT NOT NULL DEFAULT 'local';
        -- 기존 카카오 사용자 업데이트
        UPDATE kidspoint.users 
        SET auth_type = 'kakao',
            social_id = SUBSTRING(username FROM 7)
        WHERE username LIKE 'kakao_%' AND auth_type = 'local';
    END IF;
    
    -- social_id 컬럼 추가
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'kidspoint' 
        AND table_name = 'users' 
        AND column_name = 'social_id'
    ) THEN
        ALTER TABLE kidspoint.users ADD COLUMN social_id TEXT;
    END IF;
    
    -- 제약 조건 추가
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_schema = 'kidspoint' 
        AND table_name = 'users' 
        AND constraint_name = 'check_auth_type'
    ) THEN
        ALTER TABLE kidspoint.users 
        ADD CONSTRAINT check_auth_type 
        CHECK (auth_type IN ('local', 'kakao', 'google'));
    END IF;
END $$;

-- 7. 인덱스 추가
CREATE INDEX IF NOT EXISTS idx_users_auth_type ON kidspoint.users(auth_type);
CREATE INDEX IF NOT EXISTS idx_users_social_id ON kidspoint.users(social_id) WHERE social_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_users_auth_social ON kidspoint.users(auth_type, social_id) WHERE social_id IS NOT NULL;
