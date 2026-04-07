-- Add allow_public_join column to organizations table
ALTER TABLE organizations 
ADD COLUMN IF NOT EXISTS allow_public_join BOOLEAN DEFAULT FALSE;

-- Update existing organizations to have allow_public_join = false
UPDATE organizations 
SET allow_public_join = FALSE 
WHERE allow_public_join IS NULL;
