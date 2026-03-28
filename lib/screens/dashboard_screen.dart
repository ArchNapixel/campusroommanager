import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/builders/room_card_builder.dart';
import '../core/models/room_model.dart';
import '../core/models/user_model.dart';
import '../core/theme/app_theme.dart';
import '../shared/widgets/room_filter_component.dart';
import '../shared/widgets/custom_app_bar.dart';
import '../shared/widgets/loading_widget.dart';
import '../modules/rooms/room_card.dart';
import '../modules/rooms/rooms_provider.dart';
import '../modules/login/login_provider.dart';
import '../modules/app_shell/settings_screen.dart';
import 'room_booking_screen.dart';

/// Dashboard screen showing all available rooms with admin CRUD capabilities
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late RoomsProvider _roomsProvider;
  final _searchController = TextEditingController();
  List<RoomType> _selectedFilters = [];
  List<Room> _filteredRooms = [];

  @override
  void initState() {
    super.initState();
    _roomsProvider = RoomsProvider();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    await _roomsProvider.loadRooms();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredRooms = _roomsProvider.roomsAsModels.where((room) {
        final matchesSearch = room.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            room.building
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            room.roomNumber
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        final matchesFilter = _selectedFilters.isEmpty ||
            _selectedFilters.contains(room.type);

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _showEditRoomDialog(Room room) {
    final nameController = TextEditingController(text: room.name);
    final buildingController = TextEditingController(text: room.building);
    final roomNumberController = TextEditingController(text: room.roomNumber);
    final capacityController = TextEditingController(text: room.capacity.toString());
    RoomType selectedType = room.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Room'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Room Name',
                    hintText: 'e.g., Lab 101',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: buildingController,
                  decoration: InputDecoration(
                    labelText: 'Building',
                    hintText: 'e.g., Science Building',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: roomNumberController,
                  decoration: InputDecoration(
                    labelText: 'Room Number',
                    hintText: 'e.g., 101',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: capacityController,
                  decoration: InputDecoration(
                    labelText: 'Capacity',
                    hintText: 'e.g., 30',
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<RoomType>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Room Type',
                  ),
                  items: [
                    DropdownMenuItem(
                      value: RoomType.classroom,
                      child: Text('Classroom'),
                    ),
                    DropdownMenuItem(
                      value: RoomType.lab,
                      child: Text('Laboratory'),
                    ),
                    DropdownMenuItem(
                      value: RoomType.audioVisual,
                      child: Text('Audio/Visual'),
                    ),
                    DropdownMenuItem(
                      value: RoomType.other,
                      child: Text('Other'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedType = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameController.dispose();
                buildingController.dispose();
                roomNumberController.dispose();
                capacityController.dispose();
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    buildingController.text.isNotEmpty &&
                    roomNumberController.text.isNotEmpty &&
                    capacityController.text.isNotEmpty) {
                  await _roomsProvider.updateRoom(
                    room.id,
                    {
                      'description': nameController.text,
                      'building': buildingController.text,
                      'room_number': roomNumberController.text,
                      'capacity': int.tryParse(capacityController.text) ?? 0,
                      'room_type': selectedType.toString().split('.').last,
                    },
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Room updated successfully!')),
                    );
                  }
                  nameController.dispose();
                  buildingController.dispose();
                  roomNumberController.dispose();
                  capacityController.dispose();
                  if (context.mounted) {
                    Navigator.pop(context);
                    _applyFilters();
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteRoomDialog(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Room'),
        content: Text('Are you sure you want to delete ${room.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _roomsProvider.deleteRoom(room.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Room deleted successfully!')),
              );
              Navigator.pop(context);
              _applyFilters();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateRoomDialog() {
    final nameController = TextEditingController();
    final buildingController = TextEditingController();
    final roomNumberController = TextEditingController();
    final capacityController = TextEditingController();
    RoomType selectedType = RoomType.classroom;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Create New Room'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Room Name',
                    hintText: 'e.g., Lab 101',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: buildingController,
                  decoration: InputDecoration(
                    labelText: 'Building',
                    hintText: 'e.g., Science Building',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: roomNumberController,
                  decoration: InputDecoration(
                    labelText: 'Room Number',
                    hintText: 'e.g., 101',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: capacityController,
                  decoration: InputDecoration(
                    labelText: 'Capacity',
                    hintText: 'e.g., 30',
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<RoomType>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Room Type',
                  ),
                  items: [
                    DropdownMenuItem(
                      value: RoomType.classroom,
                      child: Text('Classroom'),
                    ),
                    DropdownMenuItem(
                      value: RoomType.lab,
                      child: Text('Laboratory'),
                    ),
                    DropdownMenuItem(
                      value: RoomType.audioVisual,
                      child: Text('Audio/Visual'),
                    ),
                    DropdownMenuItem(
                      value: RoomType.other,
                      child: Text('Other'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedType = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameController.dispose();
                buildingController.dispose();
                roomNumberController.dispose();
                capacityController.dispose();
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    buildingController.text.isNotEmpty &&
                    roomNumberController.text.isNotEmpty &&
                    capacityController.text.isNotEmpty) {
                  await _roomsProvider.createRoom(
                    {
                      'description': nameController.text,
                      'building': buildingController.text,
                      'room_number': roomNumberController.text,
                      'capacity': int.tryParse(capacityController.text) ?? 0,
                      'room_type': selectedType.toString().split('.').last,
                    },
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Room created successfully!')),
                    );
                  }
                  nameController.dispose();
                  buildingController.dispose();
                  roomNumberController.dispose();
                  capacityController.dispose();
                  if (context.mounted) {
                    Navigator.pop(context);
                    _applyFilters();
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')),
                  );
              }
            },
            child: Text('Create'),
          ),
        ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard',
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadRooms,
          ),
          // Profile Settings Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Consumer<LoginProvider>(
              builder: (context, loginProvider, _) {
                final profileUrl =
                    loginProvider.currentUser?.profilePictureUrl;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.buttonPrimary,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: profileUrl != null && profileUrl.isNotEmpty
                          ? Image.network(
                              profileUrl,
                              fit: BoxFit.cover,
                              width: 36,
                              height: 36,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 36,
                                  height: 36,
                                  color: AppColors.deepNavy,
                                  child: Icon(
                                    Icons.person,
                                    size: 18,
                                    color: AppColors.bodyText,
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 36,
                              height: 36,
                              color: AppColors.deepNavy,
                              child: Icon(
                                Icons.person,
                                size: 18,
                                color: AppColors.bodyText,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (loginProvider.currentUserRole == UserRole.admin)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _showCreateRoomDialog,
                  icon: Icon(Icons.add),
                  label: Text('CREATE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.headerText,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search rooms...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
              ),
              onChanged: (_) => _applyFilters(),
            ),
          ),

          // Filter section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Type',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(height: 8),
                RoomFilterComponent(
                  selectedFilters: _selectedFilters,
                  onFilterChanged: (filters) {
                    _selectedFilters = filters;
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 8),

          // Room count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Showing ${_filteredRooms.length} rooms',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedText,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),

          // Room grid or list
          Expanded(
            child: _roomsProvider.isLoading
                ? LoadingWidget(message: 'Loading rooms...')
                : _filteredRooms.isEmpty
                    ? Center(
                        child: Text(
                          'No rooms found',
                          style: TextStyle(color: AppColors.bodyText),
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.95,
                        ),
                        padding: EdgeInsets.all(16),
                        itemCount: _filteredRooms.length,
                        itemBuilder: (context, index) {
                          final room = _filteredRooms[index];
                          final spec = RoomCardBuilder(room)
                              .withCapacity(true)
                              .withAmenities(true)
                              .withStatusIndicator(true)
                              .withHeatmapOverlay(true)
                              .makeClickable(true)
                              .build();

                          return RoomCard(
                            spec: spec,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RoomBookingScreen(
                                    room: room,
                                  ),
                                ),
                              );
                            },
                            onEdit: () => _showEditRoomDialog(room),
                            onDelete: () => _showDeleteRoomDialog(room),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
