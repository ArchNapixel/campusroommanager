import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/builders/schedule_calendar_builder.dart';
import '../bookings/bookings_barrel.dart';
import '../rooms/rooms_barrel.dart';
import '../schedules/schedules_barrel.dart';
import '../users/users_barrel.dart';
import '../interactive_map/interactive_map_barrel.dart';
import 'navigation_drawer.dart';

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
      if (widget.userRole == UserRole.admin)
        4: _buildInteractiveMapScreen(),
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
      items.addAll([
        NavigationItem(
          icon: Icons.people,
          label: 'Users',
          isActive: _selectedIndex == 3,
        ),
        NavigationItem(
          icon: Icons.map,
          label: 'Map',
          isActive: _selectedIndex == 4,
        ),
      ]);
    }

    return items;
  }

  Widget _buildBookingsScreen() {
    final bookingsProvider = BookingsProvider();
    return FutureBuilder(
      future: bookingsProvider.loadBookings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final roomsProvider = RoomsProvider();
        return FutureBuilder(
          future: roomsProvider.loadRooms(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            final roomsMap =
                {for (var room in roomsProvider.rooms) room.id: room};
            return BookingTable(
              bookings: bookingsProvider.bookings,
              roomsMap: roomsMap,
            );
          },
        );
      },
    );
  }

  Widget _buildSchedulesScreen() {
    return FutureBuilder(
      future: _loadSchedules(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          final data = snapshot.data as Map;
          final spec = data['spec'];
          final schedules = data['schedules'];
          final bookings = data['bookings'];
          return ScheduleCalendarView(
            spec: spec,
            schedules: schedules,
            bookings: bookings,
          );
        }
        return Center(
            child: Text('Error loading schedules',
            style: TextStyle(color: AppColors.error)));
      },
    );
  }

  Future<Map> _loadSchedules() async {
    final bookingsProvider = BookingsProvider();
    await bookingsProvider.loadBookings();
    final schedulesProvider = SchedulesProvider();
    await schedulesProvider.loadSchedules(bookingsProvider.bookings);
    final spec = ScheduleCalendarBuilder()
        .showMonthView(true)
        .highlightTodaysEvents(true)
        .build();
    return {
      'spec': spec,
      'schedules': schedulesProvider.schedules,
      'bookings': schedulesProvider.bookings,
    };
  }

  Widget _buildInteractiveMapScreen() {
    return FutureBuilder(
      future: _loadMapData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          final data = snapshot.data as Map;
          final spec = data['spec'];
          final rooms = data['rooms'];
          return InteractiveMapView(
            spec: spec,
            rooms: rooms,
          );
        }
        return Center(
            child: Text('Error loading map',
            style: TextStyle(color: AppColors.error)));
      },
    );
  }

  Future<Map> _loadMapData() async {
    final roomsProvider = RoomsProvider();
    await roomsProvider.loadRooms();
    final mapProvider = InteractiveMapProvider();
    await mapProvider.initializeMap(roomsProvider.rooms);
    return {
      'spec': mapProvider.spec,
      'rooms': roomsProvider.rooms,
    };
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
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: widget.onLogout,
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
