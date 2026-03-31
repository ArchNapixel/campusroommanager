# Comprehensive Booking Error Handling Documentation

## Overview

A comprehensive error handling system has been added to the room booking feature to provide detailed, actionable error messages and diagnostic information for both users and developers.

## Key Improvements

### 1. **Custom BookingException Class** (`booking_exception.dart`)
- Standardized error handling for all booking operations
- Automatic error type detection and categorization
- User-friendly messages paired with technical details
- Supports 12 different error categories

**Error Categories Detected:**
- Network/Connection errors
- Authentication errors  
- Permission/Authorization errors
- Room not found errors
- User not found errors
- Duplicate booking errors
- Foreign key constraint errors
- Check constraint errors
- Database errors
- Server errors (5xx)
- Unknown errors

### 2. **Enhanced BookingsProvider** (`bookings_provider.dart`)

#### Improved `createBooking()` Method:
- **Comprehensive validation** before database operations
- **Detailed error context** with specific validation steps
- **Categorized error messages** that explain exactly what went wrong
- **User ID validation** with helpful guidance

**Validation checks include:**
1. Room ID validation
2. User ID validation (detects "current_user" placeholder)
3. Time range validation
4. Booking duration validation (30 min - 8 hours)
5. Past booking prevention
6. Purpose validation
7. Occupants count validation
8. Room availability checking
9. Daily booking limit enforcement
10. Time conflict detection

**Error Messages Now Include:**
- What went wrong
- Why it happened
- Suggested actions to fix it

### 3. **Enhanced RoomBookingScreen** (`room_booking_screen.dart`)

#### Critical Fixes:
- **Fixed hardcoded userId bug**: Now retrieves actual user ID from LoginProvider
- **Fixed occupants input**: Validates and passes occupants count to booking creation
- **Added comprehensive error dialogs** with:
  - Clear error description
  - Technical details (hidden by default, expandable)
  - Suggested troubleshooting steps
  - Visual error icons
  - Multiple action recommendations

#### Error Dialog Features:
- **Main Error Message**: Plain language explanation of what failed
- **Technical Details Section**: Shows specific error codes and details
- **Suggested Actions**: Context-aware suggestions based on error type
- **Diagnostic Logging**: Full booking details logged to console for developer review

### 4. **BookingDiagnostics Utility** (`booking_diagnostics.dart`)

**Features:**
- Generates detailed diagnostic reports
- Validates all booking parameters
- Provides troubleshooting steps
- Creates formatted console output
- Includes user-friendly error summaries

**Diagnostic Report Includes:**
```
User Information:
- Role and ID (warns if missing)

Booking Details:
- Room, times, duration, purpose

Validation Results:
- ✅ or ❌ for each check

Error Message:
- Full error context

Troubleshooting Steps:
- Specific action items based on error type
```

### 5. **Enhanced DatabaseService** (`database_service.dart`)

#### `createBooking()` Method:
- Pre-flight validation of all booking data
- Detailed logging of booking parameters
- Exception parsing for Supabase errors
- Comprehensive error messages

**Validation Before DB Operation:**
- Room ID present and not empty
- User ID present and not placeholder
- Start/end times present
- Purpose not empty

### 6. **LoginProvider Enhancement** (`login_provider.dart`)

Added new getter:
```dart
String? get currentUserId => _currentUser?.id;
```

This enables the room booking screen to properly retrieve the authenticated user's ID instead of using the placeholder "current_user".

## Common Errors and Solutions

### Error: "User ID is missing. Please log in again."
**Cause**: User is not properly authenticated or session expired
**Solution**: 
1. Log out completely
2. Log in again with correct credentials
3. Check internet connection
4. Restart the application if problem persists

### Error: "You do not have permission to book this room."
**Cause**: Room has Room-Level Security (RLS) policies restricting bookings
**Solution**:
1. Contact your administrator
2. Try booking a different room
3. Verify your account is active and in the correct role

### Error: "Room is already booked from HH:MM to HH:MM."
**Cause**: Another user or yourself already has a booking for that time
**Solution**:
1. Select a different time slot
2. Check the room's availability calendar
3. Try booking on a different date
4. Select a different room

### Error: "Network error. Please check your internet connection."
**Cause**: Connection issue between app and server
**Solution**:
1. Check WiFi/mobile connection is active
2. Try moving to better signal area
3. Wait 30 seconds and try again
4. Restart the app

### Error: "Booking must be at least 30 minutes long."
**Cause**: Duration too short
**Solution**: 
1. Select a longer time slot (minimum 30 minutes)
2. Choose different start/end times
3. Most available slots are 1-2 hours

### Error: "You have reached the maximum of 5 bookings per day."
**Cause**: Daily booking limit enforced
**Solution**:
1. Book on a different day
2. Cancel an existing booking for today
3. Combine bookings into fewer, longer sessions

## Debugging Information

### For End Users

When a booking fails:
1. **Read the error message carefully** - it explains exactly what went wrong
2. **Check the suggested actions** - they're tailored to your specific error
3. **Verify your details** - room, date, time, purpose
4. **Report persistent issues** with:
   - Error message
   - What you were trying to do
   - When it happened
   - Your role (student/instructor/admin)

### For Administrators/Developers

When investigating booking failures:

1. **Check browser console** - BookingDiagnostics logs full diagnostic reports
2. **Review Supabase logs** - Check server-side RLS policies and permissions
3. **Verify user account** - Ensure user role is correct in database
4. **Test with different users** - Isolate if issue is user-specific or room-specific
5. **Check room configuration** - Verify room record exists and is active

**Diagnostic Output Example:**
```
═══════════════════════════════════════════════
BOOKING ERROR DIAGNOSTIC REPORT
═══════════════════════════════════════════════

USER INFORMATION:
  Role: student
  User ID: abc-123-def
  
BOOKING DETAILS:
  Room ID: room-456
  Start Time: 2026-03-31 14:00:00.000
  End Time: 2026-03-31 16:00:00.000
  Duration: 120 minutes
  Purpose: "Study Session"

VALIDATION CHECKS:
  ✅ Start time is before end time
  ✅ Start time is in the future
  ✅ Duration is valid (120 minutes)
  ✅ Purpose is valid (13 chars)
  ❌ Room is booked 10:00-16:00

ERROR MESSAGE:
  Room is already booked from 10:00 to 16:00

TROUBLESHOOTING STEPS:
  1. Select a different time slot
  2. Try booking on a different date
  3. Contact the room administrator
```

## Validation Flow

```
createBooking()
    ↓
[Validate IDs]
    ↓ (fail) → Throw INVALID_USER/INVALID_ROOM
    ↓ (ok)
[Validate Time Range]
    ↓ (fail) → Throw INVALID_TIME_RANGE
    ↓ (ok)
[Validate Duration]
    ↓ (fail) → Throw DURATION_TOO_SHORT/DURATION_TOO_LONG
    ↓ (ok)
[Check Past Booking]
    ↓ (fail) → Throw BOOKING_IN_PAST
    ↓ (ok)
[Validate Purpose]
    ↓ (fail) → Throw INVALID_PURPOSE/PURPOSE_TOO_LONG
    ↓ (ok)
[Check Room Availability]
    ↓ (fail) → Throw ROOM_NOT_AVAILABLE
    ↓ (ok)
[Check Daily Limit]
    ↓ (fail) → Throw DAILY_LIMIT_EXCEEDED
    ↓ (ok)
[Create in Database]
    ↓ (fail) → Throw DATABASE_ERROR/PERMISSION_ERROR
    ↓ (ok)
✅ SUCCESS
```

## Files Modified/Created

### Created:
- `lib/core/services/booking_exception.dart` - Custom exception class
- `lib/core/utilities/booking_diagnostics.dart` - Diagnostic helper

### Modified:
- `lib/core/services/database_service.dart` - Enhanced createBooking()
- `lib/modules/bookings/bookings_provider.dart` - Major improvements
- `lib/modules/login/login_provider.dart` - Added currentUserId getter
- `lib/screens/room_booking_screen.dart` - Enhanced error handling and fixed userId bug

## Testing the Error Handling

### Test Case 1: User Not Logged In
1. Don't log in
2. Try to book a room
3. Expected: "User ID is missing. Please log in again."

### Test Case 2: Invalid Time Range
1. Select end time before start time (if possible)
2. Expected: "Start time must be before end time."

### Test Case 3: Booking in Past
1. Try to book a time that has already passed (if possible)
2. Expected: "Cannot create bookings in the past."

### Test Case 4: Room Not Available
1. Book a room for a specific time
2. Try to book the same room for overlapping time with different account
3. Expected: "Room is already booked from HH:MM to HH:MM."

### Test Case 5: Daily Limit
1. Make 5 bookings for today (as a regular user)
2. Try to make a 6th booking for today
3. Expected: "You have reached the maximum of 5 bookings per day."

## Future Improvements

- [ ] Email notifications on booking failures
- [ ] Booking retry logic for network failures
- [ ] Admin override capabilities for permission errors
- [ ] Integration with calendar export (iCal)
- [ ] Automated error reporting to admin dashboard
- [ ] Machine learning to predict availability conflicts
- [ ] SMS notifications for booking confirmations
