import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ⭐️ ADD StyleParser import (or your utility for parsing hex colors)
import '../utils/style_parser.dart';

class VgotecCalendar extends StatefulWidget {
  final double width;
  final double cellHeight;
  final Color selectedColor;
  final Color todayColor;
  final Alignment headerAlignment;
  final Alignment calendarAlignment;
  final TextStyle headerTextStyle;
  final bool startWeekOnMonday;
  final Function(DateTime)? onDateSelected;

  // ⭐️ 1. ADD these new parameters
  final Map<DateTime, String> colorMap;
  final Function(DateTime)? onMonthChanged;

  const VgotecCalendar({
    super.key,
    this.width = 400,
    this.cellHeight = 40,
    this.selectedColor = Colors.blue,
    this.todayColor = Colors.orange,
    this.headerAlignment = Alignment.center,
    this.calendarAlignment = Alignment.center,
    this.headerTextStyle =
        const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    this.startWeekOnMonday = false,
    this.onDateSelected,
    
    // ⭐️ 2. ADD them to the constructor
    this.colorMap = const {}, // Default to an empty map
    this.onMonthChanged,
  });

  @override
  State<VgotecCalendar> createState() => _VgotecCalendarState();
}

class _VgotecCalendarState extends State<VgotecCalendar> {
  DateTime _focusedDate = DateTime.now();
  DateTime? _selectedDate;
  DateTime _lastReportedMonth = DateTime.now(); // Prevents duplicate API calls

  void _changeMonth(int offset) {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + offset);

      // ⭐️ 3. CALL the new callback if the month *actually* changed
      if (_focusedDate.month != _lastReportedMonth.month ||
          _focusedDate.year != _lastReportedMonth.year) {
            
        widget.onMonthChanged?.call(_focusedDate);
        _lastReportedMonth = _focusedDate;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.width,
        // The Card and Padding widgets have been removed.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(), // You can also remove this if you don't want the line
            _buildWeekdays(),
            _buildMonthGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final monthName = DateFormat.yMMMM().format(_focusedDate);
    return Align(
      alignment: widget.headerAlignment,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _changeMonth(-1)),
          Text(monthName, style: widget.headerTextStyle),
          IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _changeMonth(1)),
        ],
      ),
    );
  }

  Widget _buildWeekdays() {
    final days = widget.startWeekOnMonday
        ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map((d) => Expanded(
                child: Center(
                  child: Text(d,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildMonthGrid() {
    final firstDay = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final daysInMonth =
        DateUtils.getDaysInMonth(_focusedDate.year, _focusedDate.month);

    // Calculate how many empty cells to show before the 1st day
    final startOffset = widget.startWeekOnMonday
        ? (firstDay.weekday == 7 ? 0 : firstDay.weekday - 1)
        : firstDay.weekday % 7;

    final totalCells = daysInMonth + startOffset;
    final rows = (totalCells / 7).ceil();

    // 🔹 Each day box width (divide total calendar width by 7)
    final horizontalPadding = 7 * 4; // each cell has 2px margin left + 2px right
    final dayWidth = (widget.width - horizontalPadding) / 7;

    return Column(
      children: List.generate(rows, (rowIndex) {
        final days = List.generate(7, (dayIndex) {
          final dayNum = rowIndex * 7 + dayIndex - startOffset + 1;
          if (dayNum < 1 || dayNum > daysInMonth)
            return const Expanded(child: SizedBox());

          final date = DateTime(_focusedDate.year, _focusedDate.month, dayNum);
          
          // ⭐️ 4. Use DateUtils.dateOnly for all date comparisons
          final dateOnly = DateUtils.dateOnly(date);
          final isToday = DateUtils.isSameDay(dateOnly, DateUtils.dateOnly(DateTime.now()));
          final isSelected = _selectedDate != null &&
              DateUtils.isSameDay(dateOnly, DateUtils.dateOnly(_selectedDate!));

          // ⭐️ 5. Find the custom color from the map
          final String? customColorCode = widget.colorMap[dateOnly];
          if (customColorCode != null) {
            // print("CALENDAR: Found color for $dateOnly: $customColorCode");
          }

          // ⭐️ 6. Determine colors based on priority
          Color cellColor = Colors.transparent;
          Color borderColor = Colors.grey.shade300;
          Color textColor = Colors.black87;

          if (isSelected) {
            cellColor = widget.selectedColor.withOpacity(0.8);
            textColor = Colors.white;
          } else if (customColorCode != null) {
            // Use StyleParser to handle the hex string
            cellColor = StyleParser.parseColor(customColorCode, Colors.transparent);
          }

          if (isToday && !isSelected) {
            // Don't outline today if it's selected
            borderColor = widget.todayColor;
          }

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedDate = date);
                widget.onDateSelected?.call(date);
              },
              // ⭐️ 7. Apply the new colors
              child: Container(
                height: widget.cellHeight,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: borderColor,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$dayNum',
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        });

        return Row(children: days);
      }),
    );
  }
}