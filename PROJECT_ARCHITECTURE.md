# Campus Room Manager - Highly Modular Flutter Web App

A professional, production-ready Flutter web application for managing university lab and audio-visual room bookings with real-time occupancy indicators, built with **maximum modularity** using Factory and Builder design patterns.

## 🎯 Problem Statement

Universities face "phantom bookings"—rooms reserved but unused—leaving professors unable to find available labs for sudden exams. This app provides instant, real-time room availability with intuitive booking and visual room management.

## ✨ Key Features

- ✅ **Real-Time Occupancy Status** - Live indicators for room availability
- ✅ **Multi-Role Access** - Student, Teacher, and Admin dashboards
- ✅ **Interactive Floor Plans** - Zoomable map with heatmap overlays
- ✅ **Calendar Scheduling** - Month/week/day views with drag-and-drop
- ✅ **Responsive Design** - Desktop sidebar, mobile drawer navigation
- ✅ **Dark Mode Theme** - Professional dark UI with vibrant accents
- ✅ **Modular Architecture** - Self-contained, reusable modules
- ✅ **Factory & Builder Patterns** - Clean object creation and UI composition

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point with Provider setup
├── core/
│   ├── models/                        # Data models (Room, Booking, User, Schedule)
│   ├── factories/                     # Factory pattern: RoomFactory, BookingFactory, etc.
│   ├── builders/                      # Builder pattern: RoomCardBuilder, etc.
│   └── theme/                         # App theming & colors
├── modules/
│   ├── app_shell/                    # Navigation shell (sidebar/drawer)
│   ├── login/                        # Authentication module
│   ├── rooms/                        # Room listing & search
│   ├── bookings/                     # Booking management & history
│   ├── schedules/                    # Calendar view & scheduling
│   ├── users/                        # User management (admin only)
│   └── interactive_map/              # Floor-plan map with heatmap
├── shared/
│   └── widgets/                      # Reusable UI components
└── utilities/                        # Helper functions
```

## 🏗️ Architecture Pattern

### Factory Pattern
Clean object creation with type-specific factories:
```dart
// Create a lab room with automatic amenities
final labRoom = RoomFactory.createLab(
  id: 'lab1',
  name: 'Physics Lab A',
  capacity: 30,
  building: 'Science',
  floor: '2',
  roomNumber: '201',
);

// Create a user with role presets
final student = UserFactory.createStudent(
  name: 'Alice',
  email: 'alice@uni.edu',
  studentId: 'STU001',
);
```

### Builder Pattern
Flexible UI composition without massive constructors:
```dart
// Build a room card with customizable components
final cardSpec = RoomCardBuilder(room)
  .withCapacity(true)
  .withAmenities(true)
  .withStatusIndicator(true)
  .withHeatmapOverlay(true)
  .makeClickable(true)
  .build();

// Build a calendar with optional features
final calendarSpec = ScheduleCalendarBuilder()
  .showMonthView(true)
  .enableDragAndDrop(true)
  .highlightTodaysEvents(true)
  .build();
```

### Provider Pattern
State management with ChangeNotifier:
```dart
// Access rooms provider
final roomsProvider = RoomsProvider();
final availableRooms = roomsProvider.getAvailableRooms();

// Update occupancy
roomsProvider.updateRoomStatus(roomId, OccupancyStatus.occupied);
```

## 🎨 Theme & Colors

All colors are centralized in `core/theme/app_theme.dart`:

| Element | Color | Hex |
|---------|-------|-----|
| Primary Background | Charcoal | #121212 |
| Secondary Background | Dark Gray | #1E1E1E |
| Available | Bright Cyan | #00FFFF |
| Occupied | Crimson | #DC143C |
| Pending | Amber | #FFBF00 |
| Button Primary | Electric Blue | #3B82F6 |
| Button Hover | Neon Green | #39FF14 |

## 📱 Responsive Design

- **Desktop** (> 900px): Expanded sidebar + full content
- **Tablet** (600-900px): Optimized spacing
- **Mobile** (< 600px): Drawer navigation + stacked layouts

## 🔐 Role-Based Access

### Student
- View available rooms
- Create bookings
- View own booking history
- Access calendar

### Teacher
- All student features
- Admin group bookings
- View class schedules
- Booking analytics

### Admin
- All teacher features
- User management
- Interactive floor maps
- Heatmap analytics
- System settings

## 🚀 Getting Started

### Prerequisites
- Flutter 3.10.7+
- Dart 3.0+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/campusroommanager.git
cd campusroommanager
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run -d chrome  # For web
flutter run            # For mobile
```

## 📦 Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  go_router: ^13.0.0           # Routing
  provider: ^6.4.0             # State management
  intl: ^0.19.0                # Internationalization
  table_calendar: ^3.1.0       # Calendar widget
  uuid: ^4.0.0                 # Unique IDs
```

## 🔄 Data Models

### Room
```dart
Room(
  id, name, capacity, type, building, floor, roomNumber,
  occupancyStatus, lastUpdated, amenities, latitude, longitude
)
```

### Booking
```dart
Booking(
  id, roomId, userId, startTime, endTime, purpose,
  status, expectedOccupants, notes, createdAt, etc.
)
```

### User
```dart
User(
  id, name, email, role, department, studentId, createdAt, isActive
)
```

### Schedule
```dart
Schedule(
  id, roomId, bookingId, date, createdAt, notes
)
```

## 🔌 Module Integration

### Creating a New Module

1. Create module folder: `modules/my_module/`
2. Create components:
   - `my_module_screen.dart` - Main UI
   - `my_module_provider.dart` - State management
   - `my_module_barrel.dart` - Barrel export
3. Export in `app_shell.dart`
4. Add navigation item in `AppShell`

### Using a Module

```dart
import 'modules/rooms/rooms_barrel.dart';

// In widget
final roomsProvider = RoomsProvider();
await roomsProvider.loadRooms();
```

## 🧪 Mock Data

All modules include mock data generators:
- 5 sample rooms with different types
- 5 sample users with different roles
- 3 sample bookings with different statuses
- Auto-generated schedules

**To use real backend data**, replace provider implementations with API calls.

## 📝 TODO / Backend Integration

Marked with `// TODO:` comments:

1. **Authentication**
   - Real user authentication
   - JWT token management
   - Role permission validation

2. **Real-Time Updates**
   - WebSocket listeners for occupancy
   - Auto-refresh on room status changes
   - Real-time collaboration

3. **Database**
   - Firebase Firestore integration
   - Conflict resolution
   - Data persistence

4. **Navigation**
   - Go Router implementation
   - Named route navigation
   - Deep linking

## 🎯 Code Examples

### Create a Booking with Builder
```dart
final booking = BookingBuilder()
  .withRoomId('room1')
  .withUserId('user1')
  .withTimeRange(
    DateTime.now().add(Duration(hours: 2)),
    DateTime.now().add(Duration(hours: 4)),
  )
  .withPurpose('Physics Lab Session')
  .withExpectedOccupants(15)
  .withNotes('Bring safety equipment')
  .build();
```

### Build a Room Card UI
```dart
RoomCard(
  spec: RoomCardBuilder(room)
    .withCapacity(true)
    .withAmenities(true)
    .withStatusIndicator(true)
    .withHeatmapOverlay(true)
    .build(),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => BookingScreen(room: room)),
  ),
)
```

### Search & Filter
```dart
final roomsProvider = RoomsProvider();

// Search
final results = roomsProvider.searchRooms('Physics');

// Filter by type
final labs = roomsProvider.getRoomsByType(RoomType.lab);

// Check availability
final available = roomsProvider.getAvailableRooms();
```

## 🐛 Debugging

Enable debug logs:
```dart
// In main.dart
runApp(
  DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => const CampusRoomManagerApp(),
  ),
);
```

## 📊 Performance Tips

1. Use `ChangeNotifier.select()` to listen to specific fields
2. Implement `FutureBuilder` for loading states
3. Use `ListView.builder()` for large lists
4. Lazy-load images with `CachedNetworkImage`

## 🤝 Contributing

1. Create a feature branch
2. Follow the modular structure
3. Add barrel exports
4. Update documentation
5. Submit PR

## 📄 License

MIT License - See LICENSE file

## 💡 Future Enhancements

- [ ] Mobile app (iOS/Android)
- [ ] Video conferencing integration
- [ ] Email/SMS notifications
- [ ] API documentation generator
- [ ] Performance monitoring
- [ ] Accessibility improvements
- [ ] Dark/light theme toggle
- [ ] Multi-language support
- [ ] Advanced analytics dashboard
- [ ] Room maintenance scheduling

## 📞 Support

For issues or questions:
- Open an issue on GitHub
- Contact: support@campusroommanager.dev
- Documentation: [Project Wiki](https://github.com/yourusername/campusroommanager/wiki)

---

**Built with ❤️ using Flutter & Dart**

*Solving the phantom booking problem, one room at a time.*
