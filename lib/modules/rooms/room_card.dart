import 'package:flutter/material.dart';
import '../../core/builders/room_card_builder.dart';
import '../../core/models/room_model.dart';
import '../../core/theme/app_theme.dart';

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
      child: MouseRegion(
        cursor: spec.isClickable ? SystemMouseCursors.click : MouseCursor.defer,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          transform: Matrix4.identity()..translate(0, 0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: AppColors.secondaryBackground,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: spec.room.occupancyStatus == OccupancyStatus.occupied
                      ? AppColors.occupied.withOpacity(0.4)
                      : AppColors.available.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  if (spec.room.occupancyStatus == OccupancyStatus.available)
                    BoxShadow(
                      color: AppColors.available.withOpacity(0.1),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  else
                    BoxShadow(
                      color: AppColors.occupied.withOpacity(0.08),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title, floor badge, and status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Room name with larger font
                              Text(
                                spec.room.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.headerText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              // Building name
                              Text(
                                spec.room.building,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.mutedText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        // Floor badge
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.buttonPrimary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.buttonPrimary.withOpacity(0.3),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(
                            'Floor ${spec.room.floor}',
                            style: TextStyle(
                              color: AppColors.buttonPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Room number and type
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            _roomTypeLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: AppColors.buttonPrimary.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: AppColors.buttonPrimary,
                          ),
                          side: BorderSide(
                            color: AppColors.buttonPrimary.withOpacity(0.3),
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.dividerColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Room ${spec.room.roomNumber}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Capacity - Professional display
                    if (spec.showCapacity)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.available.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.available.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 20,
                              color: AppColors.available,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Capacity: ${spec.room.capacity} people',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.available,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (spec.showCapacity && spec.showAmenities && spec.room.amenities.isNotEmpty)
                      SizedBox(height: 12),

                    // Amenities
                    if (spec.showAmenities && spec.room.amenities.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amenities',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.mutedText,
                            ),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: spec.room.amenities.entries
                                .where((e) => e.value == true)
                                .map((e) => Chip(
                                  label: Text(
                                    _amenityLabel(e.key),
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor: AppColors.available.withOpacity(0.12),
                                  labelStyle: TextStyle(
                                    color: AppColors.available,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  side: BorderSide(
                                    color: AppColors.available.withOpacity(0.2),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                ))
                                .toList(),
                          ),
                        ],
                      ),

                    if (spec.showHeatmapOverlay)
                      SizedBox(height: 12),

                    // Heatmap indicator with label
                    if (spec.showHeatmapOverlay)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Usage Frequency',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.mutedText,
                                ),
                              ),
                              Text(
                                '${((spec.room.amenities['usageFrequency'] ?? 0.5) * 100).toStringAsFixed(0)}%',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.hover,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: spec.room.amenities['usageFrequency'] ?? 0.5,
                              minHeight: 6,
                              backgroundColor: AppColors.borderColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.hover,
                              ),
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 16),

                    // Footer with status and actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (spec.showStatusIndicator)
                          _buildStatusBadge(spec.room.occupancyStatus),
                        Spacer(),
                        // Action buttons
                        if (onEdit != null || onDelete != null)
                          PopupMenuButton(
                            icon: Icon(
                              Icons.more_vert,
                              color: AppColors.mutedText,
                              size: 20,
                            ),
                            itemBuilder: (context) => [
                              if (onEdit != null)
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18, color: AppColors.buttonPrimary),
                                      SizedBox(width: 12),
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
                                      SizedBox(width: 12),
                                      Text('Delete', style: TextStyle(color: AppColors.error)),
                                    ],
                                  ),
                                  onTap: onDelete,
                                ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OccupancyStatus status) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    String label;

    switch (status) {
      case OccupancyStatus.available:
        backgroundColor = AppColors.available.withOpacity(0.15);
        borderColor = AppColors.available.withOpacity(0.4);
        textColor = AppColors.available;
        label = 'Available';
      case OccupancyStatus.occupied:
        backgroundColor = AppColors.occupied.withOpacity(0.15);
        borderColor = AppColors.occupied.withOpacity(0.4);
        textColor = AppColors.occupied;
        label = 'Occupied';
      case OccupancyStatus.pending:
        backgroundColor = AppColors.pending.withOpacity(0.15);
        borderColor = AppColors.pending.withOpacity(0.4);
        textColor = AppColors.pending;
        label = 'Pending';
      case OccupancyStatus.maintenance:
        backgroundColor = AppColors.maintenance.withOpacity(0.15);
        borderColor = AppColors.maintenance.withOpacity(0.4);
        textColor = AppColors.maintenance;
        label = 'Maintenance';
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.15),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
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
