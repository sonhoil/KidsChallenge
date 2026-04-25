-- FCM 토큰 (사용자당 1기기, 마지막 등록 토큰으로 갱신)
CREATE TABLE IF NOT EXISTS user_push_tokens (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    fcm_token TEXT NOT NULL,
    platform TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_push_tokens_updated_at ON user_push_tokens(updated_at);
