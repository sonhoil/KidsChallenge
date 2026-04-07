-- Add in_use_by_user_id and in_use_at columns to items table
ALTER TABLE boxsage.items 
ADD COLUMN IF NOT EXISTS in_use_by_user_id UUID REFERENCES boxsage.users(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS in_use_at TIMESTAMP WITH TIME ZONE;

-- Add index for better query performance
CREATE INDEX IF NOT EXISTS idx_items_in_use_by_user_id ON boxsage.items(in_use_by_user_id);
