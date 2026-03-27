import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/booking_model.dart';
import '../../core/theme/app_theme.dart';

/// Event renderer module for displaying individual events
class EventRenderer extends StatelessWidget {
  final Booking booking;
  final int? usageCount;

  const EventRenderer({
    Key? key,
    required this.booking,
    this.usageCount,
  }) : super(key: key);

  Color _getEventColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.pending;
      case BookingStatus.confirmed:
        return AppColors.buttonPrimary;
      case BookingStatus.inProgress:
        return AppColors.available;
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
        return AppColors.error;
    }
  }

  String _getStatusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');
    final eventColor = _getEventColor(booking.status);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        border: Border(left: BorderSide(color: eventColor, width: 4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.purpose,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${timeFormat.format(booking.startTime)} - ${timeFormat.format(booking.endTime)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.mutedText,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: eventColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusLabel(booking.status),
                    style: TextStyle(
                      color: eventColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (usageCount != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people, size: 14, color: AppColors.mutedText),
                  SizedBox(width: 4),
                  Text(
                    '${booking.expectedOccupants} people',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
