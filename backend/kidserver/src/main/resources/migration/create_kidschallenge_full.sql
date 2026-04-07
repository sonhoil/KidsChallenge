-- KidsChallenge 앱 전체 스키마 DDL (Kids 도메인 전용)
-- 기존 boxsage(organization/box/item 등) 도메인은 이 파일에 포함하지 않았습니다.
-- 이 파일은 KidsChallenge에서 사용하는 새로운 테이블/ENUM을 한 번에 볼 수 있도록 정리한 것입니다.
-- 모든 테이블과 ENUM은 kidspoint 스키마에 명시적으로 생성됩니다.

-- 스키마 생성
CREATE SCHEMA IF NOT EXISTS kidspoint;

-- 미션 상태 ENUM
DO $$ BEGIN
    CREATE TYPE kidspoint.mission_status AS ENUM ('todo', 'pending', 'approved', 'rejected', 'cancelled');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 가족 내 역할 ENUM
DO $$ BEGIN
    CREATE TYPE kidspoint.family_role AS ENUM ('parent', 'child');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 리워드 구매 상태 ENUM
DO $$ BEGIN
    CREATE TYPE kidspoint.reward_purchase_status AS ENUM ('pending', 'confirmed', 'used', 'cancelled');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 가족 테이블
CREATE TABLE IF NOT EXISTS kidspoint.families (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    invite_code TEXT UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 가족 구성원 (부모/아이 매핑)
CREATE TABLE IF NOT EXISTS kidspoint.family_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES kidspoint.families(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES kidspoint.users(id) ON DELETE CASCADE,
    role kidspoint.family_role NOT NULL,
    nickname TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (family_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_family_members_family_id ON kidspoint.family_members(family_id);
CREATE INDEX IF NOT EXISTS idx_family_members_user_id ON kidspoint.family_members(user_id);

-- 아이별 포인트 계좌
CREATE TABLE IF NOT EXISTS kidspoint.point_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES kidspoint.families(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES kidspoint.users(id) ON DELETE CASCADE,
    balance INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (family_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_point_accounts_family_user ON kidspoint.point_accounts(family_id, user_id);

-- 포인트 트랜잭션 (입출금 내역)
CREATE TABLE IF NOT EXISTS kidspoint.point_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    point_account_id UUID NOT NULL REFERENCES kidspoint.point_accounts(id) ON DELETE CASCADE,
    amount INT NOT NULL,
    type TEXT NOT NULL,              -- 예: MISSION_REWARD, REWARD_PURCHASE, MANUAL_ADJUSTMENT
    reference_type TEXT,             -- 예: MISSION_ASSIGNMENT, REWARD_PURCHASE
    reference_id UUID,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_point_transactions_account ON kidspoint.point_transactions(point_account_id, created_at);

-- 미션 정의
CREATE TABLE IF NOT EXISTS kidspoint.missions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES kidspoint.families(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    default_points INT NOT NULL,
    icon_type TEXT,                  -- 프론트에서 사용하는 아이콘 키 (예: BED, DOG 등)
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by UUID NOT NULL REFERENCES kidspoint.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_missions_family_id ON kidspoint.missions(family_id);

-- 미션 할당 (아이별 오늘 할 일, 진행 상태)
CREATE TABLE IF NOT EXISTS kidspoint.mission_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mission_id UUID NOT NULL REFERENCES kidspoint.missions(id) ON DELETE CASCADE,
    assignee_id UUID NOT NULL REFERENCES kidspoint.users(id) ON DELETE CASCADE, -- CHILD
    assigned_by UUID NOT NULL REFERENCES kidspoint.users(id),                   -- PARENT
    family_id UUID NOT NULL REFERENCES kidspoint.families(id) ON DELETE CASCADE,
    due_date DATE,
    status kidspoint.mission_status NOT NULL DEFAULT 'todo',
    points INT NOT NULL,            -- 이 미션에 대해 실제 지급될 포인트 (기본값은 missions.default_points)
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_mission_assignments_assignee ON kidspoint.mission_assignments(assignee_id, status);
CREATE INDEX IF NOT EXISTS idx_mission_assignments_family ON kidspoint.mission_assignments(family_id);

-- 미션 상태 변경 로그
CREATE TABLE IF NOT EXISTS kidspoint.mission_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mission_assignment_id UUID NOT NULL REFERENCES kidspoint.mission_assignments(id) ON DELETE CASCADE,
    from_status kidspoint.mission_status,
    to_status kidspoint.mission_status NOT NULL,
    changed_by UUID NOT NULL REFERENCES kidspoint.users(id),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_mission_logs_assignment ON kidspoint.mission_logs(mission_assignment_id);

-- 리워드(보상) 정의
CREATE TABLE IF NOT EXISTS kidspoint.rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES kidspoint.families(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    price_points INT NOT NULL,
    category TEXT,                   -- 예: COUPON, TICKET, TOY 등
    icon_type TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by UUID NOT NULL REFERENCES kidspoint.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rewards_family_id ON kidspoint.rewards(family_id);

-- 리워드 구매/보유 내역 (쿠폰/티켓)
CREATE TABLE IF NOT EXISTS kidspoint.reward_purchases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reward_id UUID NOT NULL REFERENCES kidspoint.rewards(id) ON DELETE CASCADE,
    buyer_id UUID NOT NULL REFERENCES kidspoint.users(id) ON DELETE CASCADE,   -- CHILD
    family_id UUID NOT NULL REFERENCES kidspoint.families(id) ON DELETE CASCADE,
    point_transaction_id UUID REFERENCES kidspoint.point_transactions(id) ON DELETE SET NULL,
    status kidspoint.reward_purchase_status NOT NULL DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reward_purchases_buyer ON kidspoint.reward_purchases(buyer_id, status);
CREATE INDEX IF NOT EXISTS idx_reward_purchases_family ON kidspoint.reward_purchases(family_id);

