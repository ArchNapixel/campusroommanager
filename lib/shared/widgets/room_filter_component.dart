import 'package:flutter/material.dart';
import '../../core/models/room_model.dart';
import '../../core/theme/app_theme.dart';

/// Filter component for filtering rooms by type
class RoomFilterComponent extends StatefulWidget {
  final Function(List<RoomType>) onFilterChanged;
  final List<RoomType> selectedFilters;

  const RoomFilterComponent({
    Key? key,
    required this.onFilterChanged,
    this.selectedFilters = const [],
  }) : super(key: key);

  @override
  State<RoomFilterComponent> createState() => _RoomFilterComponentState();
}

class _RoomFilterComponentState extends State<RoomFilterComponent> {
  late List<RoomType> _selectedFilters;

  @override
  void initState() {
    super.initState();
    _selectedFilters = List.from(widget.selectedFilters);
  }

  void _toggleFilter(RoomType type) {
    setState(() {
      if (_selectedFilters.contains(type)) {
        _selectedFilters.remove(type);
      } else {
        _selectedFilters.add(type);
      }
    });
    widget.onFilterChanged(_selectedFilters);
  }

  String _getRoomTypeLabel(RoomType type) {
    switch (type) {
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: RoomType.values
          .map((type) => FilterChip(
                label: Text(_getRoomTypeLabel(type)),
                selected: _selectedFilters.contains(type),
                onSelected: (_) => _toggleFilter(type),
                backgroundColor: AppColors.secondaryBackground,
                selectedColor: AppColors.buttonPrimary.withOpacity(0.3),
                side: BorderSide(
                  color: _selectedFilters.contains(type)
                      ? AppColors.buttonPrimary
                      : AppColors.borderColor,
                ),
              ))
          .toList(),
    );
  }
}
