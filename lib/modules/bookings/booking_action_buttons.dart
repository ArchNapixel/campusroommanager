import 'package:flutter/material.dart';
import '../../core/models/booking_model.dart';
import '../../core/theme/app_theme.dart';

/// Modular action buttons for bookings
class BookingActionButtons extends StatelessWidget {
  final Booking booking;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onDetails;

  const BookingActionButtons({
    Key? key,
    required this.booking,
    required this.onEdit,
    required this.onCancel,
    required this.onDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        TextButton.icon(
          onPressed: onDetails,
          icon: Icon(Icons.info_outline),
          label: Text('Details'),
        ),
        if (booking.status == BookingStatus.pending)
          TextButton.icon(
            onPressed: onEdit,
            icon: Icon(Icons.edit),
            label: Text('Edit'),
          ),
        if (booking.status != BookingStatus.cancelled &&
            booking.status != BookingStatus.completed)
          TextButton.icon(
            onPressed: onCancel,
            icon: Icon(Icons.close),
            label: Text('Cancel'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
          ),
      ],
    );
  }
}
