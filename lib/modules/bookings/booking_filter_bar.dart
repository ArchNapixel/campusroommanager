import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

/// Filter configuration for bookings
class BookingFilterConfig {
  final String? searchQuery;
  final String? status; // pending, confirmed, completed, cancelled
  final DateTime? startDate;
  final DateTime? endDate;
  final String? roomId;

  BookingFilterConfig({
    this.searchQuery,
    this.status,
    this.startDate,
    this.endDate,
    this.roomId,
  });

  BookingFilterConfig copyWith({
    String? searchQuery,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? roomId,
  }) {
    return BookingFilterConfig(
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      roomId: roomId ?? this.roomId,
    );
  }

  void clear() {
    // This method can be used to clear filters in the future
  }

  bool get isEmpty =>
      searchQuery == null &&
      status == null &&
      startDate == null &&
      endDate == null &&
      roomId == null;
}

/// Filter bar widget for booking lists
class BookingFilterBar extends StatefulWidget {
  final BookingFilterConfig initialConfig;
  final ValueChanged<BookingFilterConfig> onFilterChanged;
  final List<String>? availableRooms;

  const BookingFilterBar({
    Key? key,
    required this.initialConfig,
    required this.onFilterChanged,
    this.availableRooms,
  }) : super(key: key);

  @override
  State<BookingFilterBar> createState() => _BookingFilterBarState();
}

class _BookingFilterBarState extends State<BookingFilterBar> {
  late TextEditingController _searchController;
  late BookingFilterConfig _currentConfig;
  bool _showFilters = false;

  static const List<String> _statusOptions = [
    'pending',
    'confirmed',
    'completed',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _currentConfig = widget.initialConfig;
    _searchController =
        TextEditingController(text: _currentConfig.searchQuery ?? '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilter(BookingFilterConfig newConfig) {
    setState(() => _currentConfig = newConfig);
    widget.onFilterChanged(newConfig);
  }

  void _clearFilters() {
    _searchController.clear();
    _updateFilter(BookingFilterConfig());
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: _currentConfig.startDate != null &&
              _currentConfig.endDate != null
          ? DateTimeRange(
              start: _currentConfig.startDate!,
              end: _currentConfig.endDate!,
            )
          : null,
    );

    if (picked != null) {
      _updateFilter(_currentConfig.copyWith(
        startDate: picked.start,
        endDate: picked.end,
      ));
    }
  }

  String _formatDateRange() {
    if (_currentConfig.startDate == null || _currentConfig.endDate == null) {
      return 'Select dates';
    }
    final formatter = DateFormat('MMM dd');
    return '${formatter.format(_currentConfig.startDate!)} - ${formatter.format(_currentConfig.endDate!)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ============ SEARCH BAR ============
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            border: Border.all(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: AppColors.mutedText),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by purpose...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    _updateFilter(_currentConfig.copyWith(
                      searchQuery: value.isEmpty ? null : value,
                    ));
                  },
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _updateFilter(_currentConfig.copyWith(searchQuery: null));
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 32),
                ),
              SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.tune,
                  color: _currentConfig.isEmpty
                      ? AppColors.mutedText
                      : AppColors.buttonPrimary,
                ),
                onPressed: () =>
                    setState(() => _showFilters = !_showFilters),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),

        // ============ FILTERS (EXPANDABLE) ============
        if (_showFilters)
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              border: Border.all(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status filter
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _statusOptions
                      .map((status) => FilterChip(
                            label: Text(
                              status[0].toUpperCase() + status.substring(1),
                            ),
                            selected: _currentConfig.status == status,
                            onSelected: (selected) {
                              _updateFilter(_currentConfig.copyWith(
                                status: selected ? status : null,
                              ));
                            },
                          ))
                      .toList(),
                ),
                SizedBox(height: 16),

                // Date range filter
                Text(
                  'Date Range',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
                SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _selectDateRange,
                  icon: Icon(Icons.calendar_today, size: 18),
                  label: Text(_formatDateRange()),
                ),
                SizedBox(height: 16),

                // Room filter (if available rooms provided)
                if (widget.availableRooms != null &&
                    widget.availableRooms!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Room',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedText,
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButton<String?>(
                        value: _currentConfig.roomId,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text('All Rooms'),
                          ),
                          ...widget.availableRooms!
                              .map((room) => DropdownMenuItem(
                                    value: room,
                                    child: Text(room),
                                  ))
                              .toList(),
                        ],
                        onChanged: (value) {
                          _updateFilter(_currentConfig.copyWith(roomId: value));
                        },
                      ),
                      SizedBox(height: 16),
                    ],
                  ),

                // Clear filters button
                if (!_currentConfig.isEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      child: Text('Clear All Filters'),
                    ),
                  ),
              ],
            ),
          ),
        SizedBox(height: 12),

        // ============ ACTIVE FILTERS DISPLAY ============
        if (!_currentConfig.isEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_currentConfig.status != null)
                  Chip(
                    label: Text(
                      'Status: ${_currentConfig.status![0].toUpperCase()}${_currentConfig.status!.substring(1)}',
                      style: TextStyle(fontSize: 12),
                    ),
                    onDeleted: () => _updateFilter(
                      _currentConfig.copyWith(status: null),
                    ),
                  ),
                if (_currentConfig.startDate != null &&
                    _currentConfig.endDate != null)
                  Chip(
                    label: Text(
                      _formatDateRange(),
                      style: TextStyle(fontSize: 12),
                    ),
                    onDeleted: () => _updateFilter(
                      _currentConfig.copyWith(
                        startDate: null,
                        endDate: null,
                      ),
                    ),
                  ),
                if (_currentConfig.roomId != null)
                  Chip(
                    label: Text(
                      'Room: ${_currentConfig.roomId}',
                      style: TextStyle(fontSize: 12),
                    ),
                    onDeleted: () =>
                        _updateFilter(_currentConfig.copyWith(roomId: null)),
                  ),
                if (_currentConfig.searchQuery != null &&
                    _currentConfig.searchQuery!.isNotEmpty)
                  Chip(
                    label: Text(
                      'Search: ${_currentConfig.searchQuery}',
                      style: TextStyle(fontSize: 12),
                    ),
                    onDeleted: () =>
                        _updateFilter(_currentConfig.copyWith(searchQuery: null)),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
