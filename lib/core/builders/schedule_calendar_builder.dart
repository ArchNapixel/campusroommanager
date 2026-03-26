/// Builder for constructing Schedule Calendar View specifications
class ScheduleCalendarBuilder {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _enableDragAndDrop = false;
  bool _showEventRenderer = true;
  bool _showMonthView = true;
  bool _showWeekView = false;
  bool _showDayView = false;
  bool _highlightTodaysEvents = true;
  List<String> _eventFilters = [];
  Map<String, dynamic> _customConfig = {};

  ScheduleCalendarBuilder();

  ScheduleCalendarBuilder withFocusedDay(DateTime day) {
    _focusedDay = day;
    return this;
  }

  ScheduleCalendarBuilder withSelectedDay(DateTime? day) {
    _selectedDay = day;
    return this;
  }

  ScheduleCalendarBuilder enableDragAndDrop(bool enable) {
    _enableDragAndDrop = enable;
    return this;
  }

  ScheduleCalendarBuilder withEventRenderer(bool show) {
    _showEventRenderer = show;
    return this;
  }

  ScheduleCalendarBuilder showMonthView(bool show) {
    _showMonthView = show;
    return this;
  }

  ScheduleCalendarBuilder showWeekView(bool show) {
    _showWeekView = show;
    return this;
  }

  ScheduleCalendarBuilder showDayView(bool show) {
    _showDayView = show;
    return this;
  }

  ScheduleCalendarBuilder highlightTodaysEvents(bool highlight) {
    _highlightTodaysEvents = highlight;
    return this;
  }

  ScheduleCalendarBuilder withEventFilters(List<String> filters) {
    _eventFilters = filters;
    return this;
  }

  ScheduleCalendarBuilder withCustomConfig(Map<String, dynamic> config) {
    _customConfig = config;
    return this;
  }

  /// Build the calendar specification
  ScheduleCalendarSpecification build() {
    return ScheduleCalendarSpecification(
      focusedDay: _focusedDay,
      selectedDay: _selectedDay,
      enableDragAndDrop: _enableDragAndDrop,
      showEventRenderer: _showEventRenderer,
      showMonthView: _showMonthView,
      showWeekView: _showWeekView,
      showDayView: _showDayView,
      highlightTodaysEvents: _highlightTodaysEvents,
      eventFilters: _eventFilters,
      customConfig: _customConfig,
    );
  }
}

/// Specification object for calendar view
class ScheduleCalendarSpecification {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final bool enableDragAndDrop;
  final bool showEventRenderer;
  final bool showMonthView;
  final bool showWeekView;
  final bool showDayView;
  final bool highlightTodaysEvents;
  final List<String> eventFilters;
  final Map<String, dynamic> customConfig;

  ScheduleCalendarSpecification({
    required this.focusedDay,
    this.selectedDay,
    required this.enableDragAndDrop,
    required this.showEventRenderer,
    required this.showMonthView,
    required this.showWeekView,
    required this.showDayView,
    required this.highlightTodaysEvents,
    required this.eventFilters,
    required this.customConfig,
  });
}
