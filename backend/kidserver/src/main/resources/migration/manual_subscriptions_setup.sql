-- subscriptions 테이블 수동 생성 스크립트
-- 데이터베이스에 직접 실행하거나, Flyway 마이그레이션이 실행되지 않은 경우 사용

-- 1. subscription_status ENUM 타입 생성
DO $$ BEGIN
    CREATE TYPE subscription_status AS ENUM ('active', 'canceled', 'trial', 'past_due');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. subscriptions 테이블 생성 (이미 존재하면 무시)
CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL UNIQUE REFERENCES organizations(id) ON DELETE CASCADE,
    payment_provider TEXT,
    payment_id TEXT,
    customer_id TEXT,
    status subscription_status DEFAULT 'trial',
    current_period_start TIMESTAMP WITH TIME ZONE,
    current_period_end TIMESTAMP WITH TIME ZONE,
    trial_end TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. 누락된 컬럼 추가 (이미 존재하면 무시)
DO $$ BEGIN
    ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS payment_provider TEXT;
    ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS payment_id TEXT;
    ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS customer_id TEXT;
    ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS status subscription_status DEFAULT 'trial';
    ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS current_period_start TIMESTAMP WITH TIME ZONE;
    ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS current_period_end TIMESTAMP WITH TIME ZONE;
    ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS trial_end TIMESTAMP WITH TIME ZONE;
    ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
EXCEPTION
    WHEN duplicate_column THEN null;
END $$;

-- 4. 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_subscriptions_organization_id ON subscriptions(organization_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);
