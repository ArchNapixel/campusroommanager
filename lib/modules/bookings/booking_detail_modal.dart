import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/booking_model.dart';
import '../../core/models/room_model.dart';
import '../../core/theme/app_theme.dart';

/// Detailed modal for booking information
class BookingDetailModal extends StatelessWidget {
  final Booking booking;
  final Room roomInfo;

  const BookingDetailModal({
    Key? key,
    required this.booking,
    required this.roomInfo,
  }) : super(key: key);

  String _statusLabel(BookingStatus status) {
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
    final formatter = DateFormat('MMM dd, yyyy - hh:mm a');

    return Dialog(
      backgroundColor: AppColors.secondaryBackground,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booking Details',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Room information
              _buildSection(
                context,
                'Room Information',
                [
                  _buildDetailRow('Room Name', roomInfo.name),
                  _buildDetailRow('Building', roomInfo.building),
                  _buildDetailRow('Room Number', roomInfo.roomNumber),
                  _buildDetailRow('Capacity', '${roomInfo.capacity} people'),
                ],
              ),
              SizedBox(height: 16),

              // Booking details
              _buildSection(
                context,
                'Booking Details',
                [
                  _buildDetailRow('Booking ID', booking.id),
                  _buildDetailRow(
                    'Status',
                    _statusLabel(booking.status),
                    valueColor: _getStatusColor(booking.status),
                  ),
                  _buildDetailRow('Purpose', booking.purpose),
                  _buildDetailRow('Expected Occupants', '${booking.expectedOccupants}'),
                ],
              ),
              SizedBox(height: 16),

              // Time information
              _buildSection(
                context,
                'Time',
                [
                  _buildDetailRow('Start', formatter.format(booking.startTime)),
                  _buildDetailRow('End', formatter.format(booking.endTime)),
                  _buildDetailRow(
                    'Duration',
                    '${booking.durationMinutes} minutes',
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Additional notes
              if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Text(
                    booking.notes!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                SizedBox(height: 16),
              ],

              // Cancellation info
              if (booking.status == BookingStatus.cancelled &&
                  booking.cancellationReason != null) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cancellation Reason',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        booking.cancellationReason!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.headerText,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.pending;
      case BookingStatus.confirmed:
        return AppColors.available;
      case BookingStatus.inProgress:
        return AppColors.buttonPrimary;
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
        return AppColors.error;
    }
  }
}
