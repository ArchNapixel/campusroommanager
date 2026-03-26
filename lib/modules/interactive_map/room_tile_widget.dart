import 'package:flutter/material.dart';
import '../../core/models/room_model.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/status_indicator.dart';

/// Clickable room tile widget
class RoomTile extends StatefulWidget {
  final Room room;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showDetails;

  const RoomTile({
    Key? key,
    required this.room,
    required this.isSelected,
    required this.onTap,
    this.showDetails = true,
  }) : super(key: key);

  @override
  State<RoomTile> createState() => _RoomTileState();
}

class _RoomTileState extends State<RoomTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: 140,
          height: 100,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.buttonPrimary.withOpacity(0.3)
                : AppColors.secondaryBackground.withOpacity(0.8),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.buttonPrimary
                  : (_isHovered
                      ? AppColors.hover
                      : AppColors.borderColor),
              width: widget.isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovered || widget.isSelected
                ? [
                    BoxShadow(
                      color:
                          (widget.isSelected
                              ? AppColors.buttonPrimary
                              : AppColors.hover)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room name and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.room.name,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: 4),
                    StatusIndicator(
                      status: widget.room.occupancyStatus,
                      size: 8,
                      showLabel: false,
                    ),
                  ],
                ),
                SizedBox(height: 4),

                // Room number
                Text(
                  'Room ${widget.room.roomNumber}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.mutedText,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),

                // Capacity
                Text(
                  '${widget.room.capacity} people',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.mutedText,
                    fontSize: 10,
                  ),
                ),

                if (widget.showDetails && (_isHovered || widget.isSelected))
                  ...[
                SizedBox(height: 4),
                Text(
                  widget.room.building,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.bodyText,
                    fontSize: 9,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
