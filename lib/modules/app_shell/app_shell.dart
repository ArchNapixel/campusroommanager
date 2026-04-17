import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/builders/schedule_calendar_builder.dart';
import '../bookings/bookings_barrel.dart';
import '../rooms/rooms_barrel.dart';
import '../schedules/schedules_barrel.dart';
import '../users/users_barrel.dart';
import 'navigation_drawer.dart';
import 'settings_screen.dart';

/// Main app shell with navigation
class AppShell extends StatefulWidget {
  final UserRole userRole;
  final VoidCallback onLogout;

  const AppShell({
    Key? key,
    required this.userRole,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<NavigationItem> _navigationItems;
  late final Map<int, Widget> _screens;

  @override
  void initState() {
    super.initState();
    _initializeNavigation();
  }

  void _initializeNavigation() {
    _navigationItems = _buildNavigationItems();
    _screens = {
      0: const DashboardScreen(),
      1: _buildBookingsScreen(),
      2: _buildSchedulesScreen(),
      if (widget.userRole == UserRole.admin) 3: const UserListScreen(),
      4: const SettingsScreen(),
    };
  }

  List<NavigationItem> _buildNavigationItems() {
    final items = [
      NavigationItem(
        icon: Icons.meeting_room,
        label: 'Rooms',
        isActive: _selectedIndex == 0,
      ),
      NavigationItem(
        icon: Icons.calendar_today,
        label: 'Bookings',
        isActive: _selectedIndex == 1,
      ),
      NavigationItem(
        icon: Icons.schedule,
        label: 'Schedule',
        isActive: _selectedIndex == 2,
      ),
    ];

    if (widget.userRole == UserRole.admin) {
      items.add(
        NavigationItem(
          icon: Icons.people,
          label: 'Users',
          isActive: _selectedIndex == 3,
        ),
      );
    }

    items.add(
      NavigationItem(
        icon: Icons.settings,
        label: 'Settings',
        isActive: _selectedIndex == 4,
      ),
    );

    return items;
  }

  Widget _buildBookingsScreen() {
    return _BookingsScreenWithRefresh();
  }

  Widget _buildSchedulesScreen() {
    return _SchedulesScreenWithRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Campus Room Manager'),
        elevation: 2,
        backgroundColor: AppColors.secondaryBackground,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // TODO: Show user profile menu
            },
          ),
        ],
        leading: isMobile
            ? IconButton(
                icon: Icon(Icons.menu),
                onPressed: () =>
                    _scaffoldKey.currentState?.openDrawer(),
              )
            : null,
      ),
      drawer: isMobile
          ? NavigationDrawerWidget(
              items: _navigationItems,
              onItemSelected: (index) {
                setState(() => _selectedIndex = index);
                Navigator.pop(context);
              },
              userRole: widget.userRole,
              onLogout: widget.onLogout,
            )
          : null,
      body: Row(
        children: [
          // Sidebar navigation (desktop only)
          if (!isMobile)
            NavigationDrawerWidget(
              items: _navigationItems,
              onItemSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              userRole: widget.userRole,
              onLogout: widget.onLogout,
              expanded: true,
            ),

          // Main content
          Expanded(
            child: _screens[_selectedIndex] ??
                Center(
                  child: Text('Screen not found'),
                ),
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final bool isActive;

  NavigationItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });
}

/// Bookings screen with refresh button
class _BookingsScreenWithRefresh extends StatefulWidget {
  const _BookingsScreenWithRefresh();

  @override
  State<_BookingsScreenWithRefresh> createState() =>
      _BookingsScreenWithRefreshState();
}

class _BookingsScreenWithRefreshState extends State<_BookingsScreenWithRefresh> {
  late Future<List<dynamic>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _refreshBookings();
  }

  Future<void> _refreshBookings() {
    final bookingsProvider = context.read<BookingsProvider>();
    final roomsProvider = context.read<RoomsProvider>();

    setState(() {
      _bookingsFuture = Future.wait<dynamic>([
        bookingsProvider.loadAllBookings(),
        roomsProvider.loadRooms(),
      ]);
    });
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookingsProvider, RoomsProvider>(
      builder: (context, bookingsProvider, roomsProvider, _) {
        return Column(
          children: [
            // Refresh button header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.dividerColor.withOpacity(0.3),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.borderColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Bookings',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: _refreshBookings,
                    tooltip: 'Refresh bookings',
                    color: AppColors.buttonPrimary,
                    splashRadius: 24,
                  ),
                ],
              ),
            ),
            // Bookings table
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _bookingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.error,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error loading bookings',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _refreshBookings,
                            icon: Icon(Icons.refresh),
                            label: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  final roomsMap = roomsProvider.roomsMapAsModels;
                  return Consumer<BookingsProvider>(
                    builder: (context, bookingsProvider, _) {
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: BookingTable(
                          bookings: bookingsProvider.allBookingsAsModels,
                          roomsMap: roomsMap,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Schedules screen with refresh button
class _SchedulesScreenWithRefresh extends StatefulWidget {
  const _SchedulesScreenWithRefresh();

  @override
  State<_SchedulesScreenWithRefresh> createState() =>
      _SchedulesScreenWithRefreshState();
}

class _SchedulesScreenWithRefreshState extends State<_SchedulesScreenWithRefresh> {
  late Future<List<dynamic>> _schedulesFuture;

  @override
  void initState() {
    super.initState();
    _refreshSchedules();
  }

  Future<void> _refreshSchedules() {
    final bookingsProvider = context.read<BookingsProvider>();
    final schedulesProvider = context.read<SchedulesProvider>();

    setState(() {
      _schedulesFuture = Future.wait<dynamic>([
        bookingsProvider.loadAllBookings(),
        schedulesProvider.loadSchedules(bookingsProvider.allBookingsAsModels),
      ]);
    });
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookingsProvider, SchedulesProvider>(
      builder: (context, bookingsProvider, schedulesProvider, _) {
        return Column(
          children: [
            // Refresh button header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.dividerColor.withOpacity(0.3),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.borderColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Schedule',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: _refreshSchedules,
                    tooltip: 'Refresh schedule',
                    color: AppColors.buttonPrimary,
                    splashRadius: 24,
                  ),
                ],
              ),
            ),
            // Calendar
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _schedulesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.error,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error loading schedule',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _refreshSchedules,
                            icon: Icon(Icons.refresh),
                            label: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  final spec = ScheduleCalendarBuilder()
                      .showMonthView(true)
                      .highlightTodaysEvents(true)
                      .build();
                  return Consumer<SchedulesProvider>(
                    builder: (context, schedulesProvider, _) {
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: ScheduleCalendarView(
                          spec: spec,
                          schedules: schedulesProvider.schedules,
                          bookings: schedulesProvider.bookings,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
