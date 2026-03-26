# Technical Implementation Guide

## 🏗️ Modular Architecture Deep Dive

### Principle: Single Responsibility + Modularity

Each module is **completely independent** and can be:
- ✅ Tested in isolation
- ✅ Replaced without affecting others
- ✅ Reused in different contexts
- ✅ Developed by different team members

### Module Structure Pattern

Every module follows this structure:

```
modules/my_module/
├── my_module_provider.dart       # State management (ChangeNotifier)
├── my_module_screen.dart         # Main UI component
├── components/                   # Sub-components (optional)
│   ├── my_component.dart
│   └── another_component.dart
└── my_module_barrel.dart         # Barrel export (imports all)
```

### Barrel Exports

Used for clean imports:

```dart
// BAD: Multiple imports
import 'modules/rooms/room_list_screen.dart';
import 'modules/rooms/room_card.dart';
import 'modules/rooms/rooms_provider.dart';

// GOOD: Single barrel import
import 'modules/rooms/rooms_barrel.dart';
```

## 💎 Design Patterns Applied

### 1. Factory Pattern

**Purpose**: Encapsulate object creation logic

**Example - RoomFactory**:
```dart
abstract class RoomFactory {
  // Creates room with defaults for labs
  static Room createLab({
    required String id,
    required String name,
    required int capacity,
    // ... other params
  }) {
    return Room(
      // Pre-populated amenities for labs
      amenities: {
        'hasEquipment': true,
        'hasProjector': true,
        'hasWhiteboard': true,
        'hasComputers': true,
      },
      // ... other defaults
    );
  }

  // Creates classroom with classroom defaults
  static Room createClassroom({...}) {...}

  // Custom room with all parameters
  static Room createCustom({...}) {...}
}
```

**Benefits**:
- Eliminates massive constructors
- Type-specific defaults
- Easy to add new types
- Testable creation logic

### 2. Builder Pattern

**Purpose**: Construct complex objects step by step

**Example - RoomCardBuilder**:
```dart
class RoomCardBuilder {
  bool _showCapacity = true;
  bool _showAmenities = false;
  bool _showHeatmap = false;

  // Fluent interface (method chaining)
  RoomCardBuilder withCapacity(bool show) {
    _showCapacity = show;
    return this;               // ← Returns self for chaining
  }

  RoomCardBuilder withAmenities(bool show) {
    _showAmenities = show;
    return this;
  }

  // Final build method
  RoomCardSpecification build() {
    return RoomCardSpecification(
      showCapacity: _showCapacity,
      showAmenities: _showAmenities,
      showHeatmap: _showHeatmap,
      // ... other fields
    );
  }
}

// Usage:
final spec = RoomCardBuilder(room)
  .withCapacity(true)
  .withAmenities(true)
  .withHeatmap(true)
  .build();
```

**Benefits**:
- Readable, fluent API
- Optional parameters as methods
- Step-by-step configuration
- Immutable final objects

### 3. Provider Pattern

**Purpose**: Manage state across widgets

**Example - RoomsProvider**:
```dart
class RoomsProvider with ChangeNotifier {
  List<Room> _rooms = [];

  List<Room> get rooms => _rooms;

  // Async data loading
  Future<void> loadRooms() async {
    _rooms = await fetchFromAPI();
    notifyListeners();  // ← Rebuilds consumers
  }

  // Business logic
  List<Room> getAvailableRooms() {
    return _rooms.where(
      (r) => r.occupancyStatus == OccupancyStatus.available
    ).toList();
  }

  void updateRoomStatus(String roomId, OccupancyStatus status) {
    final index = _rooms.indexWhere((r) => r.id == roomId);
    if (index != -1) {
      _rooms[index] = _rooms[index].copyWith(
        occupancyStatus: status,
        lastUpdated: DateTime.now(),
      );
      notifyListeners();
    }
  }
}

// Usage in Widget:
final roomsProvider = context.watch<RoomsProvider>();
final rooms = roomsProvider.rooms;
```

**Benefits**:
- Centralized state
- Reactive rebuilds
- Easy to test
- Decoupled from UI

## 🔄 Data Flow Architecture

```
┌─────────────┐
│  Widget/UI  │
└──────┬──────┘
       │ watches
       ↓
┌──────────────────┐
│    Provider      │ ← ChangeNotifier
│  (State Manager) │   notifyListeners()
└──────┬───────────┘
       │ calls methods
       ↓
┌──────────────────┐
│  Data Models     │  ← Room, Booking, User
│                  │
│  Factories      │   ← RoomFactory, etc.
└──────┬───────────┘
       │
       ↓
┌──────────────────┐
│   Backend API    │  ← (To be implemented)
│   Mock Data      │
└──────────────────┘
```

## 📦 Creating a New Module

### Step 1: Create Directory Structure
```bash
mkdir lib/modules/my_new_module
cd lib/modules/my_new_module
```

### Step 2: Create Data Models (if needed)
```dart
// core/models/my_model.dart
class MyModel {
  final String id;
  final String name;

  MyModel({
    required this.id,
    required this.name,
  });

  MyModel copyWith({String? id, String? name}) {
    return MyModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
```

### Step 3: Create Provider
```dart
// modules/my_new_module/my_new_module_provider.dart
class MyNewModuleProvider with ChangeNotifier {
  List<MyModel> _items = [];
  bool _isLoading = false;

  // Getters
  List<MyModel> get items => _items;
  bool get isLoading => _isLoading;

  // Load data
  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    // Fetch data
    _items = await fetchItems();

    _isLoading = false;
    notifyListeners();
  }

  // Business logic
  void addItem(MyModel item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
```

### Step 4: Create Screen
```dart
// modules/my_new_module/my_new_module_screen.dart
class MyNewModuleScreen extends StatefulWidget {
  const MyNewModuleScreen({Key? key}) : super(key: key);

  @override
  State<MyNewModuleScreen> createState() => _MyNewModuleScreenState();
}

class _MyNewModuleScreenState extends State<MyNewModuleScreen> {
  late MyNewModuleProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = MyNewModuleProvider();
    _provider.loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My New Module')),
      body: ListView.builder(
        itemCount: _provider.items.length,
        itemBuilder: (context, index) {
          final item = _provider.items[index];
          return ListTile(title: Text(item.name));
        },
      ),
    );
  }
}
```

### Step 5: Create Barrel Export
```dart
// modules/my_new_module/my_new_module_barrel.dart
export 'my_new_module_provider.dart';
export 'my_new_module_screen.dart';
// Export components if any
```

### Step 6: Integrate into App Shell
```dart
// modules/app_shell/app_shell.dart
import '../my_new_module/my_new_module_barrel.dart';

// In _initializeNavigation():
_navigationItems = [
  // ... existing items
  NavigationItem(
    icon: Icons.new_label,
    label: 'My New Module',
  ),
];

// In _screens mapping:
_screens = {
  // ... existing screens
  3: MyNewModuleScreen(),
};
```

## 🎯 State Management Best Practices

### Do's ✅

```dart
// ✅ Use copyWith for immutability
room = room.copyWith(
  occupancyStatus: OccupancyStatus.occupied,
  lastUpdated: DateTime.now(),
);

// ✅ Call notifyListeners after changes
void updateStatus(String id, OccupancyStatus status) {
  _rooms[index] = _rooms[index].copyWith(
    occupancyStatus: status,
  );
  notifyListeners();  // ← Always notify!
}

// ✅ Use specific getters
List<Room> getAvailableRooms() {
  return _rooms.where((r) => 
    r.occupancyStatus == OccupancyStatus.available
  ).toList();
}

// ✅ Make fields private
class RoomsProvider with ChangeNotifier {
  List<Room> _rooms = [];  // ← Private
  List<Room> get rooms => _rooms;  // ← Public getter
}
```

### Don'ts ❌

```dart
// ❌ Don't mutate directly
_rooms[0].occupancyStatus = OccupancyStatus.occupied;  // ← BAD!

// ❌ Don't forget notifyListeners
void updateStatus(String id, OccupancyStatus status) {
  _rooms[index] = _rooms[index].copyWith(status);
  // ← MISSING notifyListeners()!
}

// ❌ Don't expose mutable lists
List<Room> get rooms => _rooms;  // ← Can be modified externally!

// Should be:
List<Room> get rooms => UnmodifiableListView(_rooms);

// ❌ Don't do heavy work in build
@override
Widget build(BuildContext context) {
  // ❌ Don't do expensive calculations here!
  final sorted = items.sort();  // ← Runs every rebuild!
  return ListView(...);
}
```

## 🧪 Testing the Architecture

### Unit Test Example
```dart
test('RoomFactory creates lab with correct amenities', () {
  final room = RoomFactory.createLab(
    id: 'lab1',
    name: 'Physics Lab',
    capacity: 30,
    building: 'Science',
    floor: '2',
    roomNumber: '201',
  );

  expect(room.type, RoomType.lab);
  expect(room.amenities['hasEquipment'], true);
  expect(room.amenities['hasProjector'], true);
  expect(room.capacity, 30);
});
```

### Provider Test Example
```dart
test('RoomsProvider filters available rooms', () async {
  final provider = RoomsProvider();
  await provider.loadRooms();

  final available = provider.getAvailableRooms();

  expect(available, isNotEmpty);
  for (var room in available) {
    expect(room.occupancyStatus, OccupancyStatus.available);
  }
});
```

### Widget Test Example
```dart
testWidgets('RoomCard shows room name', (WidgetTester tester) async {
  final room = RoomFactory.createLab(...);
  final spec = RoomCardBuilder(room).build();

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: RoomCard(spec: spec),
      ),
    ),
  );

  expect(find.text('Physics Lab'), findsOneWidget);
});
```

## 🚀 Performance Optimization

### 1. Lazy Loading
```dart
// Load data only when needed
class RoomsProvider with ChangeNotifier {
  List<Room>? _rooms;

  Future<void> ensureLoaded() async {
    if (_rooms == null) {
      _rooms = await fetchRooms();
      notifyListeners();
    }
  }
}
```

### 2. Pagination
```dart
class RoomsProvider with ChangeNotifier {
  static const pageSize = 20;
  int _currentPage = 0;

  Future<void> loadNextPage() async {
    final next = await fetchRooms(
      page: _currentPage,
      limit: pageSize,
    );
    _rooms.addAll(next);
    _currentPage++;
    notifyListeners();
  }
}
```

### 3. Caching
```dart
class RoomsProvider with ChangeNotifier {
  final Map<String, Room> _cache = {};

  Room getRoomById(String id) {
    return _cache.putIfAbsent(id, () => fetchRoom(id));
  }
}
```

## 🔗 Backend Integration

### Replace Mock Data with API Calls

```dart
// Before (mock data)
Future<void> loadRooms() async {
  _rooms = [
    RoomFactory.createLab(...),
    RoomFactory.createClassroom(...),
  ];
  notifyListeners();
}

// After (API calls)
Future<void> loadRooms() async {
  try {
    final response = await http.get('/api/rooms');
    _rooms = (response.json() as List)
      .map((r) => Room.fromJson(r))
      .toList();
    notifyListeners();
  } catch (e) {
    // Handle error
  }
}
```

## 📊 Debugging Tools

```dart
// Debug provider state
provider.addListener(() {
  print('Provider changed: ${provider.rooms.length} rooms');
});

// Debug widgets
debugPrintBuildableObjectsInOrder();
debugPrintBeginFrameBanner = true;
debugPrintEndFrameBanner = true;

// Dev tools
void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (_) => CampusRoomManagerApp(),
    ),
  );
}
```

---

**This architecture ensures:**
- ✅ Zero coupling between modules
- ✅ Easy testing and debugging
- ✅ Scalable to 100+ features
- ✅ Team-friendly development
- ✅ Production-ready code
