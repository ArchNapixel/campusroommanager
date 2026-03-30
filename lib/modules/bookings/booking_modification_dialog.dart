import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/booking_model.dart';
import '../../core/models/room_model.dart';
import '../../core/theme/app_theme.dart';
import 'bookings_provider.dart';

/// Dialog for modifying an existing booking (time, purpose)
class BookingModificationDialog extends StatefulWidget {
  final Booking booking;
  final Room roomInfo;
  final VoidCallback onModified;

  const BookingModificationDialog({
    Key? key,
    required this.booking,
    required this.roomInfo,
    required this.onModified,
  }) : super(key: key);

  @override
  State<BookingModificationDialog> createState() =>
      _BookingModificationDialogState();
}

class _BookingModificationDialogState
    extends State<BookingModificationDialog> {
  late DateTime _startTime;
  late DateTime _endTime;
  late TextEditingController _purposeController;
  bool _isLoading = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _startTime = widget.booking.startTime;
    _endTime = widget.booking.endTime;
    _purposeController = TextEditingController(text: widget.booking.purpose);
  }

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  /// Validate the modification form
  bool _validateForm() {
    _validationError = null;

    // Check start before end
    if (_startTime.isAfter(_endTime)) {
      _validationError = 'Start time must be before end time';
      return false;
    }

    // Check duration (30min-8hr)
    final duration = _endTime.difference(_startTime);
    if (duration.inMinutes < 30) {
      _validationError = 'Booking must be at least 30 minutes long';
      return false;
    }

    if (duration.inHours > 8) {
      _validationError = 'Booking cannot exceed 8 hours';
      return false;
    }

    // Check purpose
    if (_purposeController.text.trim().isEmpty) {
      _validationError = 'Purpose is required';
      return false;
    }

    if (_purposeController.text.trim().length > 500) {
      _validationError = 'Purpose cannot exceed 500 characters';
      return false;
    }

    return true;
  }

  /// Handle time change
  Future<void> _selectTime(
    BuildContext context,
    bool isStart,
  ) async {
    final currentTime = isStart ? _startTime : _endTime;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate == null) return;

    if (!mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentTime),
    );

    if (pickedTime == null) return;

    final newDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isStart) {
        _startTime = newDateTime;
        // Auto-adjust end time if needed
        if (_endTime.isBefore(_startTime)) {
          _endTime = _startTime.add(Duration(hours: 1));
        }
      } else {
        _endTime = newDateTime;
      }
      _validationError = null;
    });
  }

  Future<void> _handleModify() async {
    if (!_validateForm()) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider =
          Provider.of<BookingsProvider>(context, listen: false);

      // Check what changed
      final timeChanged =
          _startTime != widget.booking.startTime ||
          _endTime != widget.booking.endTime;
      final purposeChanged =
          _purposeController.text.trim() != widget.booking.purpose;

      if (!timeChanged && !purposeChanged) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No changes made')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Call modify
      final success = await provider.modifyBooking(
        bookingId: widget.booking.id,
        newStartTime: timeChanged ? _startTime : null,
        newEndTime: timeChanged ? _endTime : null,
        newPurpose: purposeChanged ? _purposeController.text.trim() : null,
      );

      if (success) {
        widget.onModified();
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to update booking'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final timeFormatter = DateFormat('hh:mm a');

    return Dialog(
      backgroundColor: AppColors.secondaryBackground,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ============ HEADER ============
                Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: AppColors.buttonPrimary,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Modify Booking',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      onPressed: Navigator.of(context).pop,
                      icon: Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // ============ CURRENT BOOKING INFO ============
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Booking',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedText,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${widget.roomInfo.name}',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${dateFormatter.format(widget.booking.startTime)} • '
                        '${timeFormatter.format(widget.booking.startTime)} - '
                        '${timeFormatter.format(widget.booking.endTime)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.bodyText,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // ============ MODIFICATION FIELDS ============

                // Start Time
                Text(
                  'Start Date & Time',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : () => _selectTime(context, true),
                  icon: Icon(Icons.calendar_today),
                  label: Text(
                    '${dateFormatter.format(_startTime)} '
                    '${timeFormatter.format(_startTime)}',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                  ),
                ),
                SizedBox(height: 16),

                // End Time
                Text(
                  'End Date & Time',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : () => _selectTime(context, false),
                  icon: Icon(Icons.calendar_today),
                  label: Text(
                    '${dateFormatter.format(_endTime)} '
                    '${timeFormatter.format(_endTime)}',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                  ),
                ),
                SizedBox(height: 16),

                // Duration info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        color: AppColors.buttonPrimary,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Duration: ${_endTime.difference(_startTime).inHours}h '
                          '${_endTime.difference(_startTime).inMinutes % 60}m',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Purpose
                Text(
                  'Purpose',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _purposeController,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Enter booking purpose or details...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: AppColors.primaryBackground,
                    counterText: '',
                  ),
                ),
                SizedBox(height: 16),

                // ============ VALIDATION ERROR ============
                if (_validationError != null)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 18,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _validationError!,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_validationError != null) SizedBox(height: 16),

                // ============ ACTION BUTTONS ============
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isLoading ? null : Navigator.of(context).pop,
                      child: Text('Cancel'),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleModify,
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
