-- subscription_status ENUM 타입 생성
DO $$ BEGIN
    CREATE TYPE subscription_status AS ENUM ('active', 'canceled', 'trial', 'past_due');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- subscriptions 테이블 생성
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

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_subscriptions_organization_id ON subscriptions(organization_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);
