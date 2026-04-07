-- ============================================================
-- DATABASE MIGRATION: ADD PROVIDER COLUMN TO USERS TABLE
-- ============================================================
-- Execute these SQL statements in your Supabase SQL Editor
-- Location: SQL Editor → Run queries below

-- Add provider column to track authentication method (email, google, etc.)
ALTER TABLE users ADD COLUMN provider TEXT DEFAULT 'email';

-- Add constraint to ensure only valid providers
ALTER TABLE users ADD CONSTRAINT provider_check CHECK (provider IN ('email', 'google'));

-- Add index for faster filtering by provider if needed
CREATE INDEX IF NOT EXISTS idx_users_provider ON public.users USING btree (provider) TABLESPACE pg_default;

-- Update existing users to have 'email' as provider (if they don't already)
UPDATE users SET provider = 'email' WHERE provider IS NULL;
