-- ============================================================
-- DATABASE MIGRATIONS FOR PROFILE PICTURE UPLOAD FEATURE
-- ============================================================
-- Execute these SQL statements in your Supabase SQL Editor
-- Location: SQL Editor → Run queries below

-- 1. Add profile_picture_url column to users table
ALTER TABLE users ADD COLUMN profile_picture_url TEXT;

-- 2. Add profile_picture_url column to admin_accounts table (optional)
ALTER TABLE admin_accounts ADD COLUMN profile_picture_url TEXT;

-- 3. Add image_url column to rooms table (for future room image uploads)
ALTER TABLE rooms ADD COLUMN image_url TEXT;

-- ============================================================
-- SUPABASE STORAGE SETUP
-- ============================================================
-- 1. Go to Supabase Dashboard → Storage
-- 2. Click "Create a new bucket"
-- 3. Create bucket named: "profiles"
-- 4. Set Access Level to: "Public"
-- 5. Click "Create bucket"

-- ============================================================
-- RLS POLICIES FOR STORAGE (Optional but Recommended)
-- ============================================================

-- Allow users to upload to their own profile folder
CREATE POLICY "Users can upload own profile pictures"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profiles' 
  AND (auth.uid())::text = (string_to_array(name, '/'))[1]
);

-- Allow users to read all profile pictures
CREATE POLICY "Users can view profile pictures"
ON storage.objects
FOR SELECT
USING (bucket_id = 'profiles');

-- Allow users to delete their own profile pictures
CREATE POLICY "Users can delete own profile pictures"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'profiles'
  AND (auth.uid())::text = (string_to_array(name, '/'))[1]
);

-- ============================================================
-- DATABASE MIGRATIONS FOR SCHEDULES TABLE
-- ============================================================

-- Drop existing schedules table if it exists
DROP TABLE IF EXISTS public.schedules CASCADE;

CREATE TABLE public.schedules (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL,
  day_of_week text NOT NULL,
  start_time time without time zone NOT NULL,
  end_time time without time zone NOT NULL,
  class_name text NULL,
  instructor_name text NULL,
  created_at timestamp without time zone NULL DEFAULT now(),
  updated_at timestamp without time zone NULL DEFAULT now(),
  CONSTRAINT schedules_pkey PRIMARY KEY (id),
  CONSTRAINT schedules_room_id_fkey FOREIGN KEY (room_id) REFERENCES rooms (id) ON DELETE CASCADE,
  CONSTRAINT schedules_day_of_week_check CHECK (
    (
      day_of_week = ANY (
        ARRAY[
          'monday'::text,
          'tuesday'::text,
          'wednesday'::text,
          'thursday'::text,
          'friday'::text,
          'saturday'::text,
          'sunday'::text
        ]
      )
    )
  )
) TABLESPACE pg_default;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_schedules_room_id ON public.schedules USING btree (room_id) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_schedules_day ON public.schedules USING btree (day_of_week) TABLESPACE pg_default;
