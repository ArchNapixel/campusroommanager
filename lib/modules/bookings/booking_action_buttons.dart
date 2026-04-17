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
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        SizedBox(
          height: 32,
          child: OutlinedButton.icon(
            onPressed: onDetails,
            icon: Icon(Icons.info_outline, size: 16),
            label: Text('Details', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        if (booking.status == BookingStatus.pending)
          SizedBox(
            height: 32,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: Icon(Icons.edit, size: 16),
              label: Text('Edit', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        if (booking.status != BookingStatus.cancelled &&
            booking.status != BookingStatus.completed)
          SizedBox(
            height: 32,
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: Icon(Icons.close, size: 16),
              label: Text('Cancel', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8),
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
