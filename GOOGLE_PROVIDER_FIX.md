# Google Provider Bug Fix - Implementation Guide

## Problem Summary

When users signed up via Google OAuth, Supabase was showing the auth provider as **"email"** instead of **"google"**, even though they authenticated with Google. This happened because:

1. The OAuth flow was using email/password account creation instead of native OAuth
2. The custom `users` table had no `provider` column to track the authentication method

## Solution Implemented

### 1. Database Migration (NEW FILE)
**File**: [DATABASE_MIGRATIONS_AUTH_PROVIDER.sql](DATABASE_MIGRATIONS_AUTH_PROVIDER.sql)

This migration adds a `provider` column to track authentication method:
```sql
ALTER TABLE users ADD COLUMN provider TEXT DEFAULT 'email';
ALTER TABLE users ADD CONSTRAINT provider_check CHECK (provider IN ('email', 'google'));
CREATE INDEX idx_users_provider ON users USING btree (provider);
```

**Action Required**: Run this SQL in your Supabase SQL Editor to add the provider column.

### 2. Code Changes

#### File: [lib/core/services/supabase_oauth_service.dart](lib/core/services/supabase_oauth_service.dart#L119)

**Change**: Added `'provider': 'google'` when inserting user from Google signup:
```dart
await SupabaseService.client.from('users').insert({
  'id': response.user!.id,
  'email': email,
  'username': username,
  'full_name': displayName ?? username,
  'role': role,
  'profile_picture_url': photoUrl,
  'provider': 'google',  // ← NEW: Track Google signup
});
```

#### File: [lib/modules/login/login_provider.dart](lib/modules/login/login_provider.dart#L185)

**Two methods updated**:

1. **`signUp()` method** (line 185):
   - Added `'provider': 'email'` for regular email signups

2. **`signUpWithEmailDirect()` method** (line 397):
   - Added `'provider': 'email'` for direct email signups

```dart
await SupabaseService.client.from('users').insert({
  'id': response.user!.id,
  'email': email,
  'username': username,
  'full_name': username,
  'role': role.toString().split('.').last,
  'provider': 'email',  // ← NEW: Track email signup
});
```

## Testing the Fix

### Step 1: Run the Database Migration
1. Go to your Supabase Dashboard → SQL Editor
2. Open [DATABASE_MIGRATIONS_AUTH_PROVIDER.sql](DATABASE_MIGRATIONS_AUTH_PROVIDER.sql)
3. Copy and paste the migration SQL
4. Execute the query

### Step 2: Test Google Signup
1. Start your app: `flutter run -d chrome --web-port 3000`
2. Select "Google Sign-Up"
3. Complete the signup process
4. Check your Supabase database:
   - Go to Tables → users
   - Find your new user
   - Verify the `provider` column shows **"google"** ✓

### Step 3: Test Email Signup
1. Test regular email signup
2. Verify the `provider` column shows **"email"** ✓

## What Changed in Behavior

| Signup Method | Before | After |
|---|---|---|
| Google OAuth | provider = "email" ❌ | provider = "google" ✓ |
| Email/Password | provider = (not set) ❌ | provider = "email" ✓ |
| Direct Email | provider = (not set) ❌ | provider = "email" ✓ |

## Why This Matters

- **User Analytics**: Track how users signed up (Google vs email)
- **Account Recovery**: Different recovery flows for different providers
- **Security**: Monitor if users switch providers
- **Future OAuth**: Easy to add more providers (Microsoft, Apple, etc.)

## Future Enhancements

If you add more OAuth providers, simply:
1. Add them to the `provider_check` constraint in the migration
2. Set `'provider': 'provider_name'` in the respective signup methods

Example for Microsoft OAuth:
```dart
'provider': 'microsoft'
```

## Verification Checklist

- [x] SQL migration file created
- [x] OAuth service updated (Google provider)
- [x] Login provider updated (email providers)
- [x] All three signup methods include provider field

## Questions?

Check the provider value in Supabase:
```sql
SELECT id, email, provider, role, created_at FROM users ORDER BY created_at DESC LIMIT 5;
```

This shows the last 5 users with their authentication provider.
