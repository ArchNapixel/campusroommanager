import 'package:flutter/material.dart';
import '../../core/builders/room_card_builder.dart';
import '../../core/models/room_model.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/status_indicator.dart';

/// Room card widget built with RoomCardBuilder
class RoomCard extends StatelessWidget {
  final RoomCardSpecification spec;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RoomCard({
    Key? key,
    required this.spec,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  String get _roomTypeLabel {
    switch (spec.room.type) {
      case RoomType.lab:
        return 'Laboratory';
      case RoomType.audioVisual:
        return 'A/V Room';
      case RoomType.classroom:
        return 'Classroom';
      case RoomType.other:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: spec.isClickable ? onTap : null,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: spec.room.occupancyStatus == OccupancyStatus.occupied
                  ? AppColors.occupied.withOpacity(0.3)
                  : AppColors.available.withOpacity(0.3),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spec.room.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${spec.room.building} - Floor ${spec.room.floor}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                            onTap: onEdit,
                          ),
                        if (onDelete != null)
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: AppColors.error),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                            onTap: onDelete,
                          ),
                      ],
                    ),
                    if (spec.showStatusIndicator)
                      StatusIndicator(
                        status: spec.room.occupancyStatus,
                        showLabel: false,
                      ),
                  ],
                ),
                SizedBox(height: 12),

                // Room type and room number
                Row(
                  children: [
                    Chip(
                      label: Text(_roomTypeLabel),
                      backgroundColor: AppColors.buttonPrimary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: AppColors.buttonPrimary,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Room ${spec.room.roomNumber}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Capacity
                if (spec.showCapacity)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: AppColors.bodyText,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Capacity: ${spec.room.capacity} people',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                // Amenities
                if (spec.showAmenities && spec.room.amenities.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Wrap(
                      spacing: 8,
                      children: spec.room.amenities.entries
                          .where((e) => e.value == true)
                          .map((e) => Chip(
                                label: Text(_amenityLabel(e.key)),
                                backgroundColor:
                                    AppColors.available.withOpacity(0.1),
                                labelStyle: TextStyle(
                                  color: AppColors.available,
                                  fontSize: 11,
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 8),
                              ))
                          .toList(),
                    ),
                  ),

                // Heatmap indicator (usage frequency)
                if (spec.showHeatmapOverlay)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: AppColors.borderColor,
                      ),
                      child: Stack(
                        children: [
                          Container(
                            height: 4,
                            width: (spec.room.amenities['usageFrequency'] ??
                                    0.5) *
                                double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: AppColors.hover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Action button for clickable cards
                if (spec.isClickable)
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: TextButton(
                        onPressed: onTap,
                        child: Text('View & Book'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _amenityLabel(String key) {
    const amenityLabels = {
      'hasProjector': 'Projector',
      'hasWhiteboard': 'Whiteboard',
      'hasComputers': 'Computers',
      'hasEquipment': 'Equipment',
      'hasAudioSystem': 'Audio System',
      'hasSoundboard': 'Sound Board',
      'hasScreenShare': 'Screen Share',
      'hasRecording': 'Recording',
      'hasSeating': 'Seating',
      'hasClimateControl': 'A/C',
    };
    return amenityLabels[key] ?? key;
  }
}
