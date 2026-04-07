-- organization_plan enum에 'premium' 값 추가
-- 이미 존재하는 경우 무시

DO $$ 
BEGIN
    -- 'premium' 값이 이미 있는지 확인
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_enum 
        WHERE enumlabel = 'premium' 
        AND enumtypid = (
            SELECT oid 
            FROM pg_type 
            WHERE typname = 'organization_plan'
            AND typnamespace = (
                SELECT oid 
                FROM pg_namespace 
                WHERE nspname = 'boxsage'
            )
        )
    ) THEN
        -- boxsage 스키마의 organization_plan enum에 'premium' 값 추가
        ALTER TYPE boxsage.organization_plan ADD VALUE IF NOT EXISTS 'premium';
    END IF;
END $$;
