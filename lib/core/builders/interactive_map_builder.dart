/// Builder for constructing Interactive Map specifications
class InteractiveMapBuilder {
  bool _showFloorPlan = true;
  bool _showClickableTiles = true;
  bool _showBookingDetails = true;
  bool _showHeatmapOverlay = false;
  bool _showBirdEyeView = false;
  String? _selectedFloor;
  String? _selectedBuilding;
  double _zoomLevel = 1.0;
  Map<String, double> _roomCoordinates = {};
  Map<String, dynamic> _customConfig = {};
  int _heatmapRefreshRate = 5000; // milliseconds

  InteractiveMapBuilder();

  InteractiveMapBuilder showFloorPlan(bool show) {
    _showFloorPlan = show;
    return this;
  }

  InteractiveMapBuilder showClickableTiles(bool show) {
    _showClickableTiles = show;
    return this;
  }

  InteractiveMapBuilder showBookingDetails(bool show) {
    _showBookingDetails = show;
    return this;
  }

  InteractiveMapBuilder showHeatmapOverlay(bool show) {
    _showHeatmapOverlay = show;
    return this;
  }

  InteractiveMapBuilder showBirdEyeView(bool show) {
    _showBirdEyeView = show;
    return this;
  }

  InteractiveMapBuilder withFloor(String floor) {
    _selectedFloor = floor;
    return this;
  }

  InteractiveMapBuilder withBuilding(String building) {
    _selectedBuilding = building;
    return this;
  }

  InteractiveMapBuilder withZoomLevel(double zoom) {
    _zoomLevel = zoom.clamp(0.5, 3.0);
    return this;
  }

  InteractiveMapBuilder withRoomCoordinates(Map<String, double> coordinates) {
    _roomCoordinates = coordinates;
    return this;
  }

  InteractiveMapBuilder withHeatmapRefreshRate(int millis) {
    _heatmapRefreshRate = millis;
    return this;
  }

  InteractiveMapBuilder withCustomConfig(Map<String, dynamic> config) {
    _customConfig = config;
    return this;
  }

  /// Build the interactive map specification
  InteractiveMapSpecification build() {
    return InteractiveMapSpecification(
      showFloorPlan: _showFloorPlan,
      showClickableTiles: _showClickableTiles,
      showBookingDetails: _showBookingDetails,
      showHeatmapOverlay: _showHeatmapOverlay,
      showBirdEyeView: _showBirdEyeView,
      selectedFloor: _selectedFloor,
      selectedBuilding: _selectedBuilding,
      zoomLevel: _zoomLevel,
      roomCoordinates: _roomCoordinates,
      heatmapRefreshRate: _heatmapRefreshRate,
      customConfig: _customConfig,
    );
  }
}

/// Specification object for interactive map
class InteractiveMapSpecification {
  final bool showFloorPlan;
  final bool showClickableTiles;
  final bool showBookingDetails;
  final bool showHeatmapOverlay;
  final bool showBirdEyeView;
  final String? selectedFloor;
  final String? selectedBuilding;
  final double zoomLevel;
  final Map<String, double> roomCoordinates;
  final int heatmapRefreshRate;
  final Map<String, dynamic> customConfig;

  InteractiveMapSpecification({
    required this.showFloorPlan,
    required this.showClickableTiles,
    required this.showBookingDetails,
    required this.showHeatmapOverlay,
    required this.showBirdEyeView,
    this.selectedFloor,
    this.selectedBuilding,
    required this.zoomLevel,
    required this.roomCoordinates,
    required this.heatmapRefreshRate,
    required this.customConfig,
  });
}
