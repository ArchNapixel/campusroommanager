-- ============================================================
-- DATABASE MIGRATION: ADD UNIQUE CONSTRAINT ON USERNAME
-- ============================================================
-- Execute these SQL statements in your Supabase SQL Editor
-- Location: SQL Editor → Run queries below

-- Add unique constraint on username column to prevent duplicates
ALTER TABLE users ADD CONSTRAINT unique_username UNIQUE (username);

-- Create index for faster username lookups
CREATE INDEX IF NOT EXISTS idx_users_username ON public.users USING btree (username) TABLESPACE pg_default;

-- Note: If you have existing duplicate usernames, you'll need to handle them first:
-- SELECT username, COUNT(*) FROM users GROUP BY username HAVING COUNT(*) > 1;
-- Then manually delete or rename duplicates before running the constraint
