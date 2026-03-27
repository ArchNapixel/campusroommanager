import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../core/models/room_model.dart';
import '../core/models/booking_model.dart';
import '../core/theme/app_theme.dart';
import '../modules/bookings/bookings_provider.dart';
import '../modules/rooms/rooms_provider.dart';

/// Room booking screen with calendar and time slot selection
class RoomBookingScreen extends StatefulWidget {
  final Room room;

  const RoomBookingScreen({
    Key? key,
    required this.room,
  }) : super(key: key);

  @override
  State<RoomBookingScreen> createState() => _RoomBookingScreenState();
}

class _RoomBookingScreenState extends State<RoomBookingScreen> {
  late DateTime _selectedDate;
  DateTime? _focusedDate;
  late RoomsProvider _roomsProvider;
  late BookingsProvider _bookingsProvider;
  final _purposeController = TextEditingController();
  final _occupantsController = TextEditingController();

  // Time slots: 8 AM to 8 PM in 2-hour intervals
  static const List<String> timeSlots = [
    '08:00 - 10:00',
    '10:00 - 12:00',
    '12:00 - 14:00',
    '14:00 - 16:00',
    '16:00 - 18:00',
    '18:00 - 20:00',
  ];

  String? _selectedTimeSlot;
  Map<String, bool> _slotAvailability = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _focusedDate = DateTime.now();
    _roomsProvider = RoomsProvider();
    _bookingsProvider = BookingsProvider();
    _checkSlotAvailability();
  }

  Future<void> _checkSlotAvailability() async {
    await _bookingsProvider.loadBookings();
    final availability = <String, bool>{};

    for (int i = 0; i < timeSlots.length; i++) {
      final startHour = 8 + (i * 2);
      final endHour = startHour + 2;

      final startTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        startHour,
      );
      final endTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        endHour,
      );

      // Check if room is available for this time slot
      final isAvailable = _bookingsProvider.isRoomAvailable(
        widget.room.id,
        startTime,
        endTime,
      );

      availability[timeSlots[i]] = isAvailable;
    }

    setState(() {
      _slotAvailability = availability;
      _selectedTimeSlot = null;
    });
  }

  void _onDateSelected(DateTime selectedDate, DateTime focusedDate) {
    setState(() {
      _selectedDate = selectedDate;
      _focusedDate = focusedDate;
    });
    _checkSlotAvailability();
  }

  void _showBookingConfirmation() {
    if (_selectedTimeSlot == null ||
        _purposeController.text.isEmpty ||
        _occupantsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a time slot and fill all details'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final timeSlotIndex = timeSlots.indexOf(_selectedTimeSlot!);
    final startHour = 8 + (timeSlotIndex * 2);
    final endHour = startHour + 2;

    final startTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      startHour,
    );
    final endTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      endHour,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room: ${widget.room.name}'),
            SizedBox(height: 8),
            Text(
              'Date: ${_selectedDate.toString().split(' ')[0]}',
            ),
            SizedBox(height: 8),
            Text('Time: $_selectedTimeSlot'),
            SizedBox(height: 8),
            Text('Purpose: ${_purposeController.text}'),
            SizedBox(height: 8),
            Text('Expected Occupants: ${_occupantsController.text}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _createBooking(startTime, endTime);
              Navigator.pop(context);
            },
            child: Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  Future<void> _createBooking(DateTime startTime, DateTime endTime) async {
    final booking = Booking(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      roomId: widget.room.id,
      userId: 'current_user', // TODO: Get from auth
      startTime: startTime,
      endTime: endTime,
      purpose: _purposeController.text,
      status: BookingStatus.pending,
      expectedOccupants: int.tryParse(_occupantsController.text) ?? 1,
      createdAt: DateTime.now(),
      notes: '',
    );

    await _bookingsProvider.createBooking(booking);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room booked successfully!'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _occupantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.room.name}'),
        backgroundColor: AppColors.secondaryBackground,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room info card
              Card(
                color: AppColors.secondaryBackground,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.room.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${widget.room.building} - Room ${widget.room.roomNumber}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Capacity: ${widget.room.capacity} people',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Calendar
              Text(
                'Select Date',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 12),
              Card(
                color: AppColors.secondaryBackground,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(Duration(days: 90)),
                    focusedDay: _focusedDate ?? DateTime.now(),
                    selectedDayPredicate: (day) =>
                        isSameDay(day, _selectedDate),
                    onDaySelected: _onDateSelected,
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: AppColors.buttonPrimary.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: AppColors.buttonPrimary,
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: TextStyle(
                        color: AppColors.bodyText,
                      ),
                      weekendTextStyle: TextStyle(
                        color: AppColors.bodyText,
                      ),
                      outsideTextStyle: TextStyle(
                        color: AppColors.mutedText,
                      ),
                      disabledTextStyle: TextStyle(
                        color: AppColors.mutedText,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        color: AppColors.headerText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: AppColors.buttonPrimary,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: AppColors.buttonPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Time slots
              Text(
                'Select Time Slot',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  final slot = timeSlots[index];
                  final isAvailable = _slotAvailability[slot] ?? false;
                  final isSelected = _selectedTimeSlot == slot;

                  return GestureDetector(
                    onTap: isAvailable
                        ? () {
                            setState(() {
                              _selectedTimeSlot = slot;
                            });
                          }
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.buttonPrimary
                            : isAvailable
                                ? AppColors.available.withOpacity(0.2)
                                : AppColors.occupied.withOpacity(0.2),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.buttonPrimary
                              : isAvailable
                                  ? AppColors.available
                                  : AppColors.occupied,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              slot,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.headerText
                                    : isAvailable
                                        ? AppColors.available
                                        : AppColors.occupied,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              isAvailable ? 'Available' : 'Booked',
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.headerText
                                    : isAvailable
                                        ? AppColors.available
                                        : AppColors.occupied,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 24),

              // Booking details form
              Text(
                'Booking Details',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 12),
              TextField(
                controller: _purposeController,
                decoration: InputDecoration(
                  labelText: 'Purpose of Booking',
                  hintText: 'e.g., Lab Session, Lecture, Meeting',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _occupantsController,
                decoration: InputDecoration(
                  labelText: 'Expected Occupants',
                  hintText: 'Number of people',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24),

              // Book button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _showBookingConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                  ),
                  child: Text(
                    'Book Room',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
