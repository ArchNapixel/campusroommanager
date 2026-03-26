import 'package:flutter/material.dart';
import '../../core/builders/interactive_map_builder.dart';
import '../../core/models/room_model.dart';

/// State provider for interactive map
class InteractiveMapProvider with ChangeNotifier {
  InteractiveMapSpecification _spec;
  List<Room> _rooms = [];
  Map<String, double> _roomCoordinates = {};
  bool _isLoading = false;

  InteractiveMapProvider({
    InteractiveMapSpecification? spec,
  }) : _spec = spec ?? InteractiveMapBuilder().build();

  InteractiveMapSpecification get spec => _spec;
  List<Room> get rooms => _rooms;
  Map<String, double> get roomCoordinates => _roomCoordinates;
  bool get isLoading => _isLoading;

  /// Initialize map with rooms
  Future<void> initializeMap(List<Room> rooms) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: 300));

    _rooms = rooms;

    // Generate mock coordinates for rooms
    _generateRoomCoordinates();

    _isLoading = false;
    notifyListeners();
  }

  /// Generate mock room coordinates
  void _generateRoomCoordinates() {
    _roomCoordinates.clear();
    double x = 50;

    for (final room in _rooms) {
      _roomCoordinates[room.id] = x;
      x += 160;
    }
  }

  /// Update map specification
  void updateMapSpec(InteractiveMapSpecification spec) {
    _spec = spec;
    notifyListeners();
  }

  /// Get builder for updating spec
  InteractiveMapBuilder getBuilder() {
    return InteractiveMapBuilder()
        .showFloorPlan(_spec.showFloorPlan)
        .showClickableTiles(_spec.showClickableTiles)
        .showBookingDetails(_spec.showBookingDetails)
        .showHeatmapOverlay(_spec.showHeatmapOverlay)
        .showBirdEyeView(_spec.showBirdEyeView)
        .withZoomLevel(_spec.zoomLevel);
  }

  /// Toggle heatmap overlay
  void toggleHeatmap() {
    _spec = getBuilder()
        .showHeatmapOverlay(!_spec.showHeatmapOverlay)
        .build();
    notifyListeners();
  }

  /// Set zoom level
  void setZoomLevel(double zoom) {
    _spec = getBuilder().withZoomLevel(zoom).build();
    notifyListeners();
  }

  /// Select floor
  void selectFloor(String floor) {
    _spec = InteractiveMapBuilder()
        .showFloorPlan(_spec.showFloorPlan)
        .withFloor(floor)
        .build();
    notifyListeners();
  }

  /// Get rooms for selected floor
  List<Room> getRoomsForFloor(String floor) {
    return _rooms.where((room) => room.floor == floor).toList();
  }
}
