import 'package:flutter/material.dart';
import '../../core/builders/room_card_builder.dart';
import '../../core/models/room_model.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/room_filter_component.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/loading_widget.dart';
import 'room_card.dart';
import 'rooms_provider.dart';

/// Room list screen showing all available rooms
class RoomListScreen extends StatefulWidget {
  const RoomListScreen({Key? key}) : super(key: key);

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Available Rooms',
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadRooms,
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
