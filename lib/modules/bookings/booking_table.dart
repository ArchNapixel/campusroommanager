import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/booking_model.dart';
import '../../core/models/room_model.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/status_indicator.dart';
import 'booking_action_buttons.dart';
import 'booking_detail_modal.dart';

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
        return booking.purpose.toLowerCase().contains(query) ||
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
      return Center(
        child: Text(
          'No bookings found',
          style: TextStyle(color: AppColors.bodyText),
        ),
      );
    }

    // Responsive: show table on desktop, list on mobile
    if (MediaQuery.of(context).size.width > 900) {
      return _buildTable(context);
    } else {
      return _buildListView(context);
    }
  }

  Widget _buildTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('Room')),
            DataColumn(label: Text('Purpose')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Time')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: _displayedBookings
              .map((booking) {
                final room = widget.roomsMap[booking.roomId];
                final timeFormat = DateFormat('hh:mm a');

                return DataRow(
                  cells: [
                    DataCell(Text(room?.name ?? 'Unknown')),
                    DataCell(Text(booking.purpose)),
                    DataCell(Text(DateFormat('MMM dd').format(booking.startTime))),
                    DataCell(
                      Text(
                        '${timeFormat.format(booking.startTime)} - ${timeFormat.format(booking.endTime)}',
                      ),
                    ),
                    DataCell(
                      StatusIndicator(
                        status: _bookingStatusToOccupancy(booking.status),
                      ),
                    ),
                    DataCell(
                      BookingActionButtons(
                        booking: booking,
                        onEdit: () {},
                        onCancel: () {},
                        onDetails: () => _showDetails(context, booking, room),
                      ),
                    ),
                  ],
                );
              })
              .toList(),
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return ListView.builder(
      itemCount: _displayedBookings.length,
      itemBuilder: (context, index) {
        final booking = _displayedBookings[index];
        final room = widget.roomsMap[booking.roomId];
        final timeFormat = DateFormat('hh:mm a');

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: EdgeInsets.all(16),
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
                            room?.name ?? 'Unknown Room',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: 4),
                          Text(
                            booking.purpose,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: StatusIndicator(
                        status: _bookingStatusToOccupancy(booking.status),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '${DateFormat('MMM dd, yyyy').format(booking.startTime)} - ${timeFormat.format(booking.startTime)} to ${timeFormat.format(booking.endTime)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: 12),
                BookingActionButtons(
                  booking: booking,
                  onEdit: () {},
                  onCancel: () {},
                  onDetails: () => _showDetails(context, booking, room),
                ),
              ],
            ),
          ),
        );
      },
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

  OccupancyStatus _bookingStatusToOccupancy(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return OccupancyStatus.pending;
      case BookingStatus.confirmed:
      case BookingStatus.inProgress:
        return OccupancyStatus.occupied;
      case BookingStatus.completed:
      case BookingStatus.cancelled:
        return OccupancyStatus.available;
    }
  }
}
