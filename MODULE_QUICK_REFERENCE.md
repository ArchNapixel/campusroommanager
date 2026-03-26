# Module Quick Reference Guide

## 🔍 Quick Module Lookup

### 📋 Login Module (`modules/login/`)

**Purpose**: User authentication with role selection

**Key Files**:
- `login_screen.dart` - Main login UI using LoginScreenBuilder
- `role_selector_widget.dart` - Visual role card selector
- `login_provider.dart` - Auth state management

**Usage**:
```dart
import 'modules/login/login_barrel.dart';

// In main widget
LoginScreen(
  onRoleSelected: (role) {
    loginProvider.login(role, email, password);
  },
)
```

**Provider Methods**:
- `login(UserRole, String, String)` - Authenticate user
- `logout()` - Clear auth state
- `hasRole(UserRole)` - Check user role
- `get isAdmin` - Is admin shortcut

**State**:
- `currentUserRole` - Active role
- `isAuthenticated` - Auth status
- `currentUser` - User object

---

### 🏥 Rooms Module (`modules/rooms/`)

**Purpose**: Display available rooms with search & filter

**Key Files**:
- `room_list_screen.dart` - Grid/list of rooms
- `room_card.dart` - Individual room card using RoomCardBuilder
- `rooms_provider.dart` - Room data management

**Usage**:
```dart
import 'modules/rooms/rooms_barrel.dart';

// Build room card UI
final spec = RoomCardBuilder(room)
  .withCapacity(true)
  .withAmenities(true)
  .withStatusIndicator(true)
  .withHeatmapOverlay(true)
  .build();

// Display card
RoomCard(spec: spec, onTap: () => bookRoom())
```

**Provider Methods**:
- `loadRooms()` - Fetch/load rooms
- `getRoomById(String)` - Find room
- `getRoomsByType(RoomType)` - Filter by type
- `getAvailableRooms()` - Get free rooms
- `searchRooms(String)` - Search by name
- `updateRoomStatus(String, OccupancyStatus)` - Update status

**Features**:
- Real-time occupancy status
- Room amenities display
- Usage frequency heatmap
- Type-based filtering

---

### 📅 Bookings Module (`modules/bookings/`)

**Purpose**: View, create, and manage room bookings

**Key Files**:
- `booking_table.dart` - Responsive table/list of bookings
- `booking_detail_modal.dart` - Full booking information modal
- `booking_action_buttons.dart` - Modular action buttons
- `bookings_provider.dart` - Booking state management

**Usage**:
```dart
import 'modules/bookings/bookings_barrel.dart';

// Create booking with builder
final booking = BookingBuilder()
  .withRoomId('room1')
  .withUserId('user1')
  .withTimeRange(start, end)
  .withPurpose('Lab Session')
  .withExpectedOccupants(15)
  .withNotes('Bring equipment')
  .build();

// Display bookings
BookingTable(
  bookings: bookingsProvider.bookings,
  roomsMap: roomsMap,
  searchQuery: query,
  filterStatus: status,
)
```

**Provider Methods**:
- `loadBookings()` - Load all bookings
- `createBooking(Booking)` - Create new
- `updateBooking(String, Booking)` - Modify
- `cancelBooking(String, String)` - Cancel with reason
- `getBookingsForUser(String)` - User's bookings
- `getBookingsForRoom(String)` - Room's bookings
- `hasConflict(String, DateTime, DateTime)` - Check overlaps

**Status Types**:
- `pending` - Awaiting approval (Amber)
- `confirmed` - Approved (Cyan)
- `inProgress` - Currently using (Blue)
- `completed` - Finished (Green)
- `cancelled` - Cancelled (Red)

---

### 📆 Schedules Module (`modules/schedules/`)

**Purpose**: Calendar view with scheduled events

**Key Files**:
- `schedule_calendar_view.dart` - Calendar using table_calendar
- `event_renderer.dart` - Individual event UI
- `schedules_provider.dart` - Event data management

**Usage**:
```dart
import 'modules/schedules/schedules_barrel.dart';

// Build calendar
final spec = ScheduleCalendarBuilder()
  .showMonthView(true)
  .enableDragAndDrop(true)
  .highlightTodaysEvents(true)
  .build();

// Display calendar
ScheduleCalendarView(
  spec: spec,
  schedules: schedules,
  bookings: bookings,
)
```

**Provider Methods**:
- `loadSchedules(List<Booking>)` - Load events
- `addSchedule(Schedule)` - Add event
- `updateSchedule(String, Schedule)` - Modify event
- `deleteSchedule(String)` - Remove event
- `getBookingsForDate(DateTime)` - Get day's events
- `getSchedulesForRoom(String)` - Room's schedule
- `getBookingsForDateRange(DateTime, DateTime)` - Date range
- `isRoomAvailable(String, DateTime, DateTime)` - Check slot

**Builder Options**:
- `showMonthView()` - Month calendar
- `showWeekView()` - Week view
- `showDayView()` - Day view
- `enableDragAndDrop()` - Move events
- `highlightTodaysEvents()` - Today highlight
- `withEventFilters()` - Filter events

---

### 👥 Users Module (`modules/users/`)

**Purpose**: User management (admin only)

**Key Files**:
- `user_list_screen.dart` - List of users with role badges
- `user_crud_form.dart` - Create/edit user form
- `users_provider.dart` - User data management

**Usage**:
```dart
import 'modules/users/users_barrel.dart';

// Display users
UserListScreen()

// Create/edit user
UserCrudForm(
  initialUser: user,  // null for create
  onSave: (user) => usersProvider.createUser(user),
  onCancel: () => Navigator.pop(context),
)
```

**Provider Methods**:
- `loadUsers()` - Load all users
- `createUser(User)` - Add user
- `updateUser(String, User)` - Modify user
- `deleteUser(String)` - Remove user
- `getUserById(String)` - Find user
- `getUsersByRole(UserRole)` - Filter by role
- `searchUsers(String)` - Search by name/email
- `getActiveUsers()` - Active only

**User Types**:
```dart
// Student
UserFactory.createStudent(
  name, email, studentId, department
)

// Teacher
UserFactory.createTeacher(
  name, email, department
)

// Admin
UserFactory.createAdmin(
  name, email, department
)
```

---

### 🗺️ Interactive Map Module (`modules/interactive_map/`)

**Purpose**: Floor-plan visualization with room heatmap

**Key Files**:
- `interactive_map_view.dart` - Main map with zoom/pan
- `room_tile_widget.dart` - Clickable room tiles
- `heatmap_overlay.dart` - Usage frequency heatmap
- `interactive_map_provider.dart` - Map state

**Usage**:
```dart
import 'modules/interactive_map/interactive_map_barrel.dart';

// Build map
final spec = InteractiveMapBuilder()
  .showFloorPlan(true)
  .showClickableTiles(true)
  .showHeatmapOverlay(true)
  .showBirdEyeView(true)
  .withFloor('2')
  .build();

// Display map
InteractiveMapView(
  spec: spec,
  rooms: rooms,
  onRoomSelected: (room) => showDetails(room),
)
```

**Builder Options**:
- `showFloorPlan()` - Grid background
- `showClickableTiles()` - Room tiles
- `showBookingDetails()` - Show details on hover
- `showHeatmapOverlay()` - Usage heatmap
- `showBirdEyeView()` - Legend view
- `withFloor()` - Filter by floor
- `withBuilding()` - Filter by building
- `withZoomLevel()` - Initial zoom (0.5-3.0)

**Provider Methods**:
- `initializeMap(List<Room>)` - Setup map
- `updateMapSpec(InteractiveMapSpecification)` - Update
- `toggleHeatmap()` - Toggle overlay
- `setZoomLevel(double)` - Zoom
- `selectFloor(String)` - Change floor
- `getRoomsForFloor(String)` - Floor rooms

**Features**:
- Pan & zoom controls
- Floor/building filtering
- Heatmap color gradient:
  - Blue: Low usage
  - Cyan: Medium-low usage
  - Amber: Medium-high usage
  - Red: High usage

---

### 🎯 App Shell Module (`modules/app_shell/`)

**Purpose**: Main navigation and layout

**Key Files**:
- `app_shell.dart` - Main shell with responsive nav
- `navigation_drawer.dart` - Sidebar/drawer nav

**Usage**:
```dart
import 'modules/app_shell/app_shell_barrel.dart';

AppShell(
  userRole: UserRole.teacher,
  onLogout: () => loginProvider.logout(),
)
```

**Features**:
- Desktop: Expanded sidebar
- Mobile: Drawer navigation
- Role-based menu (Admin sees extra tabs)
- Responsive layout

**Navigation Structure**:
```
Base (All roles):
- Rooms
- Bookings
- Schedule

Admin Only:
- Users
- Map
```

---

## 🎨 Shared Widgets (`shared/widgets/`)

### StatusIndicator
```dart
StatusIndicator(
  status: OccupancyStatus.available,
  size: 12,      // Icon size
  showLabel: true,  // Show "Available" text
)
```
Colors: Available (Cyan), Occupied (Red), Pending (Amber), Maintenance (Orange)

### RoomFilterComponent
```dart
RoomFilterComponent(
  selectedFilters: [RoomType.lab],
  onFilterChanged: (filters) {
    // React to filter changes
  },
)
```

### LoadingWidget
```dart
LoadingWidget(
  message: 'Loading rooms...',
)
```

### ErrorWidget
```dart
ErrorWidget(
  message: 'Failed to load rooms',
  onRetry: () => reload(),
  retryLabel: 'Try Again',
)
```

### CustomAppBar
```dart
CustomAppBar(
  title: 'My Screen',
  actions: [IconButton(icon: Icon(Icons.settings), onPressed: {})],
  showBackButton: true,
  onBackPressed: () => Navigator.pop(context),
)
```

---

## 🔑 Core Models Quick Reference

### Room
```dart
Room(
  id: 'room1',
  name: 'Physics Lab A',
  capacity: 30,
  type: RoomType.lab,
  building: 'Science Building',
  floor: '2',
  roomNumber: '201',
  occupancyStatus: OccupancyStatus.available,
  lastUpdated: DateTime.now(),
  amenities: {
    'hasProjector': true,
    'hasWhiteboard': true,
  },
)
```

### Booking
```dart
Booking(
  id: 'booking1',
  roomId: 'room1',
  userId: 'user1',
  purpose: 'Physics Lab Session',
  startTime: DateTime.now().add(Duration(hours: 2)),
  endTime: DateTime.now().add(Duration(hours: 4)),
  status: BookingStatus.pending,
  expectedOccupants: 15,
  notes: 'Bring safety gear',
)
```

### User
```dart
User(
  id: 'user1',
  name: 'Alice Johnson',
  email: 'alice@uni.edu',
  role: UserRole.student,
  studentId: 'STU001',
  department: 'Computer Science',
  isActive: true,
)
```

### Schedule
```dart
Schedule(
  id: 'schedule1',
  roomId: 'room1',
  bookingId: 'booking1',
  date: DateTime.now(),
  notes: 'Physics lab scheduled',
)
```

---

## 🚀 Common Tasks

### Task: Display Available Rooms
```dart
final provider = RoomsProvider();
await provider.loadRooms();
final available = provider.getAvailableRooms();
// Use in widget...
```

### Task: Create a Booking
```dart
final booking = BookingFactory.createStandardBooking(
  roomId: 'room1',
  userId: 'user1',
  startTime: startTime,
  endTime: endTime,
  purpose: 'Lab Session',
);
bookingsProvider.createBooking(booking);
```

### Task: Filter Users by Role
```dart
final students = usersProvider.getUsersByRole(UserRole.student);
final teachers = usersProvider.getUsersByRole(UserRole.teacher);
```

### Task: Check Room Availability
```dart
final isAvailable = schedulesProvider.isRoomAvailable(
  'room1',
  startTime,
  endTime,
);
```

### Task: Get Events for Date
```dart
final events = schedulesProvider.getBookingsForDate(
  DateTime(2024, 3, 26),
);
```

---

## 📱 Responsive Breakpoints

- **Desktop**: width > 900px → Sidebar nav
- **Mobile**: width < 600px → Drawer nav
- **Tables**: Responsive (table on desktop, list on mobile)

---

## 🎯 Provider Pattern Template

Use this when creating new providers:

```dart
class MyModuleProvider with ChangeNotifier {
  List<MyModel> _items = [];
  bool _isLoading = false;

  // Getters
  List<MyModel> get items => _items;
  bool get isLoading => _isLoading;

  // Load data
  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await fetchItems();
    } catch (e) {
      print('Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // CRUD
  void addItem(MyModel item) {
    _items.add(item);
    notifyListeners();
  }

  void updateItem(String id, MyModel updated) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index] = updated;
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  // Business logic
  List<MyModel> search(String query) {
    return _items.where((item) => 
      item.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
```

---

**🎯 Need Help?**
- Check `TECHNICAL_GUIDE.md` for deep dives
- Review `PROJECT_ARCHITECTURE.md` for overview
- Look at module examples for patterns
- Check providers for business logic
