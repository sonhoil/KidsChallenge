-- Add deleted_at column to items table for soft delete functionality
ALTER TABLE boxsage.items 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE;

-- Add index for better query performance when filtering non-deleted items
CREATE INDEX IF NOT EXISTS idx_items_deleted_at ON boxsage.items(deleted_at) WHERE deleted_at IS NULL;
