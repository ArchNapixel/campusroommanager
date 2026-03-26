import 'package:flutter/material.dart';
import '../../core/builders/interactive_map_builder.dart';
import '../../core/models/room_model.dart';
import '../../core/theme/app_theme.dart';
import 'room_tile_widget.dart';
import 'heatmap_overlay.dart';

/// Interactive map view with floor-plan visualization
class InteractiveMapView extends StatefulWidget {
  final InteractiveMapSpecification spec;
  final List<Room> rooms;
  final Function(Room)? onRoomSelected;

  const InteractiveMapView({
    Key? key,
    required this.spec,
    required this.rooms,
    this.onRoomSelected,
  }) : super(key: key);

  @override
  State<InteractiveMapView> createState() => _InteractiveMapViewState();
}

class _InteractiveMapViewState extends State<InteractiveMapView> {
  late double _currentZoom;
  Offset _panOffset = Offset.zero;
  Room? _selectedRoom;

  @override
  void initState() {
    super.initState();
    _currentZoom = widget.spec.zoomLevel;
  }

  void _handleZoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 0.2).clamp(0.5, 3.0);
    });
  }

  void _handleZoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 0.2).clamp(0.5, 3.0);
    });
  }

  void _handleRoomTap(Room room) {
    setState(() => _selectedRoom = room);
    widget.onRoomSelected?.call(room);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Stack(
      children: [
        // Floor plan canvas
        GestureDetector(
          onPanUpdate: (details) {
            if (widget.spec.showFloorPlan) {
              setState(() {
                _panOffset += details.delta;
              });
            }
          },
          child: Container(
            color: AppColors.primaryBackground,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Transform.translate(
                  offset: _panOffset,
                  child: Transform.scale(
                    scale: _currentZoom,
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: 1200,
                      height: 800,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBackground,
                        border: Border.all(
                          color: AppColors.borderColor,
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Floor plan grid
                          if (widget.spec.showFloorPlan)
                            _buildFloorPlanGrid(),

                          // Room tiles
                          if (widget.spec.showClickableTiles)
                            ...widget.rooms.map((room) {
                              final coords =
                                  widget.spec.roomCoordinates[room.id];
                              if (coords == null) return SizedBox.shrink();

                              return Positioned(
                                left: coords,
                                top: widget.spec.roomCoordinates[room.id]
                                        ?.toDouble() ??
                                    0,
                                child: RoomTile(
                                  room: room,
                                  isSelected: _selectedRoom?.id == room.id,
                                  onTap: () => _handleRoomTap(room),
                                  showDetails: widget.spec.showBookingDetails,
                                ),
                              );
                            }).toList(),

                          // Heatmap overlay
                          if (widget.spec.showHeatmapOverlay)
                            HeatmapOverlay(
                              rooms: widget.rooms,
                              roomCoordinates:
                                  widget.spec.roomCoordinates,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Controls
        Positioned(
          right: 16,
          bottom: 16,
          child: _buildControls(isMobile),
        ),

        // Legend
        if (widget.spec.showBirdEyeView)
          Positioned(
            left: 16,
            bottom: 16,
            child: _buildLegend(),
          ),

        // Selected room details panel
        if (_selectedRoom != null && !isMobile)
          Positioned(
            right: 16,
            top: 16,
            child: _buildRoomDetailsPanel(),
          ),
      ],
    );
  }

  Widget _buildFloorPlanGrid() {
    return CustomPaint(
      painter: FloorPlanGridPainter(),
      size: Size(1200, 800),
    );
  }

  Widget _buildControls(bool isMobile) {
    return Column(
      children: [
        FloatingActionButton(
          mini: isMobile,
          onPressed: _handleZoomIn,
          heroTag: 'zoom_in',
          child: Icon(Icons.add),
        ),
        SizedBox(height: 8),
        FloatingActionButton(
          mini: isMobile,
          onPressed: () => setState(() {
            _currentZoom = 1.0;
            _panOffset = Offset.zero;
          }),
          heroTag: 'reset',
          child: Icon(Icons.close),
        ),
        SizedBox(height: 8),
        FloatingActionButton(
          mini: isMobile,
          onPressed: _handleZoomOut,
          heroTag: 'zoom_out',
          child: Icon(Icons.remove),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Legend',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 8),
            _legendItem('Available', AppColors.available),
            _legendItem('Occupied', AppColors.occupied),
            _legendItem('Pending', AppColors.pending),
            _legendItem('Maintenance', AppColors.maintenance),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildRoomDetailsPanel() {
    if (_selectedRoom == null) return SizedBox.shrink();

    return Card(
      child: Container(
        width: 280,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedRoom!.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _selectedRoom = null),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Capacity: ${_selectedRoom!.capacity}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Building: ${_selectedRoom!.building}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to booking
                },
                child: Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FloorPlanGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderColor.withOpacity(0.3)
      ..strokeWidth = 0.5;

    const gridSize = 50.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(FloorPlanGridPainter oldDelegate) => false;
}
