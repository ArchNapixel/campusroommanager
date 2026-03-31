import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/booking_model.dart';
import '../../core/models/room_model.dart';
import '../../core/theme/app_theme.dart';
import 'bookings_provider.dart';

/// Dialog for cancelling a booking with reason input
class BookingCancellationDialog extends StatefulWidget {
  final Booking booking;
  final Room roomInfo;
  final VoidCallback onCancelled;

  const BookingCancellationDialog({
    Key? key,
    required this.booking,
    required this.roomInfo,
    required this.onCancelled,
  }) : super(key: key);

  @override
  State<BookingCancellationDialog> createState() =>
      _BookingCancellationDialogState();
}

class _BookingCancellationDialogState extends State<BookingCancellationDialog> {
  late TextEditingController _reasonController;
  bool _isLoading = false;

  // Predefined reasons
  static const List<String> _commonReasons = [
    'Schedule conflict',
    'No longer needed',
    'Found alternative room',
    'Event cancelled',
    'Personal reasons',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleCancel() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a cancellation reason')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get BookingsProvider from context
      final provider =
          Provider.of<BookingsProvider>(context, listen: false);

      // Call cancel with reason
      final success = await provider.cancelBooking(
        widget.booking.id,
        reason: _reasonController.text.trim(),
      );

      if (success) {
        widget.onCancelled();
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to cancel booking'),
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
    final formatter = DateFormat('MMM dd, yyyy - hh:mm a');

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
                      Icons.warning_outlined,
                      color: AppColors.warning,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Cancel Booking',
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

                // ============ BOOKING DETAILS ============
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
                      _DetailRow(
                        label: 'Room',
                        value: widget.roomInfo.name,
                      ),
                      SizedBox(height: 8),
                      _DetailRow(
                        label: 'Purpose',
                        value: widget.booking.title,
                      ),
                      SizedBox(height: 8),
                      _DetailRow(
                        label: 'Date & Time',
                        value: formatter.format(widget.booking.startTime),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // ============ WARNING MESSAGE ============
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This action cannot be undone. Provide a reason for cancellation.',
                          style: TextStyle(color: AppColors.bodyText, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // ============ REASON SELECTION ============
                Text(
                  'Select or enter a reason',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(height: 12),

                // Quick select chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _commonReasons
                      .map((reason) => FilterChip(
                            label: Text(reason),
                            selected: _reasonController.text == reason,
                            onSelected: (selected) {
                              setState(() {
                                _reasonController.text =
                                    selected ? reason : '';
                              });
                            },
                          ))
                      .toList(),
                ),
                SizedBox(height: 16),

                // Custom reason text field
                TextField(
                  controller: _reasonController,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: 'Or enter a custom reason...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: AppColors.primaryBackground,
                    counterText: '',
                  ),
                ),
                SizedBox(height: 24),

                // ============ ACTION BUTTONS ============
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isLoading ? null : Navigator.of(context).pop,
                      child: Text('Keep Booking'),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
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
                          : Text('Cancel Booking'),
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

/// Simple detail row widget
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.mutedText,
            fontSize: 13,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
