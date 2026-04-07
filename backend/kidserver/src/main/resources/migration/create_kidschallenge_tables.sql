-- KidsChallenge 도메인용 테이블 및 ENUM 타입 정의
-- 기존 프로젝트 스타일을 따라 PostgreSQL ENUM + UUID PK + TIMESTAMPTZ 사용

-- 미션 상태 ENUM
DO $$ BEGIN
    CREATE TYPE mission_status AS ENUM ('todo', 'pending', 'approved', 'rejected', 'cancelled');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 가족 내 역할 ENUM
DO $$ BEGIN
    CREATE TYPE family_role AS ENUM ('parent', 'child');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 리워드 구매 상태 ENUM
DO $$ BEGIN
    CREATE TYPE reward_purchase_status AS ENUM ('pending', 'confirmed', 'used', 'cancelled');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 가족 테이블
CREATE TABLE IF NOT EXISTS families (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    invite_code TEXT UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 가족 구성원 (부모/아이 매핑)
CREATE TABLE IF NOT EXISTS family_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role family_role NOT NULL,
    nickname TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (family_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_family_members_family_id ON family_members(family_id);
CREATE INDEX IF NOT EXISTS idx_family_members_user_id ON family_members(user_id);

-- 아이별 포인트 계좌
CREATE TABLE IF NOT EXISTS point_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    balance INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (family_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_point_accounts_family_user ON point_accounts(family_id, user_id);

-- 포인트 트랜잭션 (입출금 내역)
CREATE TABLE IF NOT EXISTS point_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    point_account_id UUID NOT NULL REFERENCES point_accounts(id) ON DELETE CASCADE,
    amount INT NOT NULL,
    type TEXT NOT NULL,              -- 예: MISSION_REWARD, REWARD_PURCHASE, MANUAL_ADJUSTMENT
    reference_type TEXT,             -- 예: MISSION_ASSIGNMENT, REWARD_PURCHASE
    reference_id UUID,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_point_transactions_account ON point_transactions(point_account_id, created_at);

-- 미션 정의
CREATE TABLE IF NOT EXISTS missions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    default_points INT NOT NULL,
    icon_type TEXT,                  -- 프론트에서 사용하는 아이콘 키 (예: BED, DOG 등)
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_missions_family_id ON missions(family_id);

-- 미션 할당 (아이별 오늘 할 일, 진행 상태)
CREATE TABLE IF NOT EXISTS mission_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mission_id UUID NOT NULL REFERENCES missions(id) ON DELETE CASCADE,
    assignee_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- CHILD
    assigned_by UUID NOT NULL REFERENCES users(id),                   -- PARENT
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    due_date DATE,
    status mission_status NOT NULL DEFAULT 'todo',
    points INT NOT NULL,            -- 이 미션에 대해 실제 지급될 포인트 (기본값은 missions.default_points)
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_mission_assignments_assignee ON mission_assignments(assignee_id, status);
CREATE INDEX IF NOT EXISTS idx_mission_assignments_family ON mission_assignments(family_id);

-- 미션 상태 변경 로그
CREATE TABLE IF NOT EXISTS mission_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mission_assignment_id UUID NOT NULL REFERENCES mission_assignments(id) ON DELETE CASCADE,
    from_status mission_status,
    to_status mission_status NOT NULL,
    changed_by UUID NOT NULL REFERENCES users(id),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_mission_logs_assignment ON mission_logs(mission_assignment_id);

-- 리워드(보상) 정의
CREATE TABLE IF NOT EXISTS rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    price_points INT NOT NULL,
    category TEXT,                   -- 예: COUPON, TICKET, TOY 등
    icon_type TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rewards_family_id ON rewards(family_id);

-- 리워드 구매/보유 내역 (쿠폰/티켓)
CREATE TABLE IF NOT EXISTS reward_purchases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reward_id UUID NOT NULL REFERENCES rewards(id) ON DELETE CASCADE,
    buyer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,   -- CHILD
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    point_transaction_id UUID REFERENCES point_transactions(id) ON DELETE SET NULL,
    status reward_purchase_status NOT NULL DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reward_purchases_buyer ON reward_purchases(buyer_id, status);
CREATE INDEX IF NOT EXISTS idx_reward_purchases_family ON reward_purchases(family_id);

