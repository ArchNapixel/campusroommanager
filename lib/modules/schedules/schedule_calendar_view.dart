import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/builders/schedule_calendar_builder.dart';
import '../../core/models/booking_model.dart';
import '../../core/models/schedule_model.dart';
import '../../core/theme/app_theme.dart';
import 'event_renderer.dart';


/// Calendar view for schedules using Builder pattern
class ScheduleCalendarView extends StatefulWidget {
  final ScheduleCalendarSpecification spec;
  final List<Schedule> schedules;
  final List<Booking> bookings;

  const ScheduleCalendarView({
    Key? key,
    required this.spec,
    required this.schedules,
    required this.bookings,
  }) : super(key: key);

  @override
  State<ScheduleCalendarView> createState() => _ScheduleCalendarViewState();
}

class _ScheduleCalendarViewState extends State<ScheduleCalendarView> {
  late DateTime _focusedDay;
  late DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.spec.focusedDay;
    _selectedDay = widget.spec.selectedDay;
  }

  List<Booking> _getBookingsForDay(DateTime day) {
    return widget.bookings.where((booking) {
      return booking.startTime.year == day.year &&
          booking.startTime.month == day.month &&
          booking.startTime.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Calendar
          if (widget.spec.showMonthView)
            Card(
              margin: EdgeInsets.all(16),
              color: AppColors.secondaryBackground,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime.now().subtract(Duration(days: 365)),
                  lastDay: DateTime.now().add(Duration(days: 365)),
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    defaultDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: TextStyle(color: AppColors.bodyText),
                    selectedDecoration: BoxDecoration(
                      color: AppColors.buttonPrimary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(
                      color: AppColors.headerText,
                      fontWeight: FontWeight.bold,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppColors.available.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.available),
                    ),
                    todayTextStyle: TextStyle(
                      color: AppColors.available,
                      fontWeight: FontWeight.bold,
                    ),
                    weekendTextStyle: TextStyle(color: AppColors.bodyText),
                    outsideTextStyle: TextStyle(
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

          // Selected day events
          if (_selectedDay != null && widget.spec.highlightTodaysEvents)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Events for ${_selectedDay!.toString().split(' ')[0]}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 12),
                  ..._buildEventsList(_getBookingsForDay(_selectedDay!)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildEventsList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return [
        Center(
          child: Text(
            'No events scheduled',
            style: TextStyle(color: AppColors.mutedText),
          ),
        ),
      ];
    }

    return bookings
        .map((booking) => EventRenderer(booking: booking))
        .toList();
  }
}
