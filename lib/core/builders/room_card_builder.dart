import '../models/room_model.dart';

/// Builder for constructing Room Card UI specifications incrementally
class RoomCardBuilder {
  final Room room;
  bool _showCapacity = true;
  bool _showAmenities = false;
  bool _showStatusIndicator = true;
  bool _showHeatmapOverlay = false;
  bool _isClickable = true;
  bool _showFilters = false;
  Map<String, dynamic> _customStyle = {};

  RoomCardBuilder(this.room);

  RoomCardBuilder withCapacity(bool show) {
    _showCapacity = show;
    return this;
  }

  RoomCardBuilder withAmenities(bool show) {
    _showAmenities = show;
    return this;
  }

  RoomCardBuilder withStatusIndicator(bool show) {
    _showStatusIndicator = show;
    return this;
  }

  RoomCardBuilder withHeatmapOverlay(bool show) {
    _showHeatmapOverlay = show;
    return this;
  }

  RoomCardBuilder makeClickable(bool clickable) {
    _isClickable = clickable;
    return this;
  }

  RoomCardBuilder withFilters(bool show) {
    _showFilters = show;
    return this;
  }

  RoomCardBuilder withCustomStyle(Map<String, dynamic> style) {
    _customStyle = style;
    return this;
  }

  /// Build specifications for room card UI
  RoomCardSpecification build() {
    return RoomCardSpecification(
      room: room,
      showCapacity: _showCapacity,
      showAmenities: _showAmenities,
      showStatusIndicator: _showStatusIndicator,
      showHeatmapOverlay: _showHeatmapOverlay,
      isClickable: _isClickable,
      showFilters: _showFilters,
      customStyle: _customStyle,
    );
  }
}

/// Specification object built by RoomCardBuilder
class RoomCardSpecification {
  final Room room;
  final bool showCapacity;
  final bool showAmenities;
  final bool showStatusIndicator;
  final bool showHeatmapOverlay;
  final bool isClickable;
  final bool showFilters;
  final Map<String, dynamic> customStyle;

  RoomCardSpecification({
    required this.room,
    required this.showCapacity,
    required this.showAmenities,
    required this.showStatusIndicator,
    required this.showHeatmapOverlay,
    required this.isClickable,
    required this.showFilters,
    required this.customStyle,
  });
}
