import 'package:flutter/material.dart';
import '../../core/models/room_model.dart';
import '../../core/theme/app_theme.dart';

/// Heatmap overlay showing room usage frequency
class HeatmapOverlay extends StatelessWidget {
  final List<Room> rooms;
  final Map<String, double> roomCoordinates;

  const HeatmapOverlay({
    Key? key,
    required this.rooms,
    required this.roomCoordinates,
  }) : super(key: key);

  Color _getHeatmapColor(double frequency) {
    // Color gradient: blue (low usage) -> green -> yellow -> red (high usage)
    if (frequency < 0.25) {
      return AppColors.buttonPrimary; // Blue
    } else if (frequency < 0.5) {
      return AppColors.available; // Cyan
    } else if (frequency < 0.75) {
      return AppColors.pending; // Amber
    } else {
      return AppColors.occupied; // Red
    }
  }

  double _getUsageFrequency(Room room) {
    return (room.amenities['usageFrequency'] as double?) ?? 0.5;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1200,
      height: 800,
      child: Stack(
        children: rooms
            .where((room) => roomCoordinates.containsKey(room.id))
            .map((room) {
              final coords = roomCoordinates[room.id]!;
              final frequency = _getUsageFrequency(room);
              final color = _getHeatmapColor(frequency);

              return Positioned(
                left: coords,
                top: coords,
                child: Opacity(
                  opacity: 0.2,
                  child: Container(
                    width: 140,
                    height: 100,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              );
            })
            .toList(),
      ),
    );
  }
}
