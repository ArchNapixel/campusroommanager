import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/booking_model.dart';
import '../../core/models/room_model.dart';
import '../../core/theme/app_theme.dart';
import 'booking_action_buttons.dart';
import 'booking_detail_modal.dart';
import 'booking_cancellation_dialog.dart';
import 'booking_modification_dialog.dart';

/// Table widget for displaying bookings with search/filter
class BookingTable extends StatefulWidget {
  final List<Booking> bookings;
  final Map<String, Room> roomsMap;
  final String? searchQuery;
  final BookingStatus? filterStatus;

  const BookingTable({
    Key? key,
    required this.bookings,
    required this.roomsMap,
    this.searchQuery,
    this.filterStatus,
  }) : super(key: key);

  @override
  State<BookingTable> createState() => _BookingTableState();
}

class _BookingTableState extends State<BookingTable> {
  late List<Booking> _displayedBookings;

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  @override
  void didUpdateWidget(BookingTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applyFilters();
  }

  void _applyFilters() {
    _displayedBookings = widget.bookings.where((booking) {
      // Status filter
      if (widget.filterStatus != null && booking.status != widget.filterStatus) {
        return false;
      }

      // Search filter
      if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
        final query = widget.searchQuery!.toLowerCase();
        final room = widget.roomsMap[booking.roomId];
        return booking.title.toLowerCase().contains(query) ||
            (room?.name.toLowerCase().contains(query) ?? false) ||
            booking.id.toLowerCase().contains(query);
      }

      return true;
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_displayedBookings.isEmpty) {
      return _buildEmptyState(context);
    }

    // Always use card grid view for consistent design
    return _buildCardGrid(context);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.mutedText,
            ),
            SizedBox(height: 24),
            Text(
              'No bookings found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.headerText,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search query',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardGrid(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _displayedBookings.length,
      itemBuilder: (context, index) {
        final booking = _displayedBookings[index];
        final room = widget.roomsMap[booking.roomId];
        final timeFormat = DateFormat('hh:mm a');

        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: AppColors.secondaryBackground,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.buttonPrimary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Room and title section
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            room?.name ?? 'Unknown Room',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.headerText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            booking.title,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.mutedText,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 16),

                    // Date section
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 13,
                                color: AppColors.buttonPrimary,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  DateFormat('MMM dd, yyyy').format(booking.startTime),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 12),

                    // Time section
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 13,
                                color: AppColors.buttonPrimary,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${timeFormat.format(booking.startTime)} - ${timeFormat.format(booking.endTime)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 12),

                    // Status badge
                    _buildStatusBadge(booking.status),

                    SizedBox(width: 12),

                    // Action buttons
                    Expanded(
                      flex: 1,
                      child: BookingActionButtons(
                        booking: booking,
                        onEdit: () => _showModificationDialog(context, booking, room),
                        onCancel: () => _showCancellationDialog(context, booking, room),
                        onDetails: () => _showDetails(context, booking, room),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  Widget _buildStatusBadge(BookingStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String label;

    switch (status) {
      case BookingStatus.pending:
        backgroundColor = AppColors.pending.withOpacity(0.15);
        textColor = AppColors.pending;
        icon = Icons.schedule;
        label = 'Pending';
      case BookingStatus.confirmed:
        backgroundColor = AppColors.available.withOpacity(0.15);
        textColor = AppColors.available;
        icon = Icons.check_circle;
        label = 'Confirmed';
      case BookingStatus.inProgress:
        backgroundColor = AppColors.available.withOpacity(0.15);
        textColor = AppColors.available;
        icon = Icons.play_circle;
        label = 'In Progress';
      case BookingStatus.completed:
        backgroundColor = AppColors.success.withOpacity(0.15);
        textColor = AppColors.success;
        icon = Icons.check_circle_outline;
        label = 'Completed';
      case BookingStatus.cancelled:
        backgroundColor = AppColors.error.withOpacity(0.15);
        textColor = AppColors.error;
        icon = Icons.cancel_outlined;
        label = 'Cancelled';
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textColor.withOpacity(0.3),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }



  void _showDetails(BuildContext context, Booking booking, Room? room) {
    if (room == null) return;
    showDialog(
      context: context,
      builder: (context) => BookingDetailModal(
        booking: booking,
        roomInfo: room,
      ),
    );
  }

  void _showModificationDialog(
    BuildContext context,
    Booking booking,
    Room? room,
  ) {
    if (room == null) return;
    showDialog(
      context: context,
      builder: (context) => BookingModificationDialog(
        booking: booking,
        roomInfo: room,
        onModified: () {
          // Trigger refresh by calling parent callback or refreshing list
          _applyFilters();
        },
      ),
    );
  }

  void _showCancellationDialog(
    BuildContext context,
    Booking booking,
    Room? room,
  ) {
    if (room == null) return;
    showDialog(
      context: context,
      builder: (context) => BookingCancellationDialog(
        booking: booking,
        roomInfo: room,
        onCancelled: () {
          // Trigger refresh by calling parent callback or refreshing list
          _applyFilters();
        },
      ),
    );
  }


}
