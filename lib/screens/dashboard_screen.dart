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
      _filteredRooms = _roomsProvider.rooms.where((room) {
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

  void _showCreateRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Room'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Room Name',
                  hintText: 'e.g., Lab 101',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Building',
                  hintText: 'e.g., Science Building',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Room Number',
                  hintText: 'e.g., 101',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Capacity',
                  hintText: 'e.g., 30',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement room creation logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Room created successfully!')),
              );
              Navigator.pop(context);
              _loadRooms();
            },
            child: Text('Create'),
          ),
        ],
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
    final isAdmin = loginProvider.currentUserRole == UserRole.admin;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard',
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadRooms,
          ),
          if (isAdmin)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _showCreateRoomDialog,
                  icon: Icon(Icons.add),
                  label: Text('CREATE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
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
                          childAspectRatio: 1.1,
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
                              // TODO: Navigate to room details
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Booking ${room.name}...'),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
