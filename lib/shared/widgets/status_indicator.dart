import 'package:flutter/material.dart';
import '../../core/models/room_model.dart';
import '../../core/theme/app_theme.dart';

/// Status indicator widget showing room occupancy status
class StatusIndicator extends StatelessWidget {
  final OccupancyStatus status;
  final double size;
  final bool showLabel;

  const StatusIndicator({
    Key? key,
    required this.status,
    this.size = 12,
    this.showLabel = true,
  }) : super(key: key);

  Color get _statusColor {
    switch (status) {
      case OccupancyStatus.available:
        return AppColors.available;
      case OccupancyStatus.occupied:
        return AppColors.occupied;
      case OccupancyStatus.pending:
        return AppColors.pending;
      case OccupancyStatus.maintenance:
        return AppColors.maintenance;
    }
  }

  String get _statusLabel {
    switch (status) {
      case OccupancyStatus.available:
        return 'Available';
      case OccupancyStatus.occupied:
        return 'Occupied';
      case OccupancyStatus.pending:
        return 'Pending';
      case OccupancyStatus.maintenance:
        return 'Maintenance';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _statusColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _statusColor.withOpacity(0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          SizedBox(width: 8),
          Text(
            _statusLabel,
            style: TextStyle(
              color: _statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
