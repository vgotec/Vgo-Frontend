import 'package:dynamic_form_kit/dynamic_form_kit.dart';
import 'package:flutter/material.dart';
// ⭐️ ADD StyleParser import (you must have this in your package)
import '../utils/style_parser.dart'; 
import '../widget_collection/vgotec_calendar.dart';

class CalendarWrapper extends StatelessWidget {
  final Map<String, dynamic> field;
  final FormStateManager manager;
  final Map<String, dynamic>? dataContext; // Accept dataContext

  const CalendarWrapper({
    super.key,
    required this.field,
    required this.manager,
    this.dataContext, // Add to constructor
  });

  @override
  Widget build(BuildContext context) {
    final fieldKey = field['key'] ?? 'calendar_field';
    final config = field['config'] as Map<String, dynamic>? ?? {};
    final style = config['style'] as Map<String, dynamic>? ?? {};

    // ⭐️ FIX 2: Correctly read dataKey from the 'field' map, not config
    final String dataKey = field['dataKey'] ?? 'dateStatuses';

    // ... (Your style parsing code) ...
    final double width = StyleParser.parseDouble(style['width'], 400);
    final double cellHeight = StyleParser.parseDouble(style['cellHeight'], 40);
    final Color selectedColor =
        StyleParser.parseColor(style['selectedColor'], Colors.blue);
    final Color todayColor =
        StyleParser.parseColor(style['todayColor'], Colors.orange);
    final Alignment headerAlignment =
        StyleParser.parseAlignment(style['headerAlignment']);
    final Alignment calendarAlignment =
        StyleParser.parseAlignment(style['calendarAlignment']);
    final bool startWeekOnMonday =
        (style['startWeekOnMonday']?.toString().toLowerCase() == 'true');
    final TextStyle headerTextStyle = TextStyle(
      fontSize: StyleParser.parseDouble(style['headerFontSize'], 20),
      fontWeight: style['headerFontWeight'] == 'bold'
          ? FontWeight.bold
          : FontWeight.normal,
      color: StyleParser.parseColor(style['headerTextColor'], Colors.black),
    );

    // Wrap in ListenableBuilder to read live data from the context
    return ListenableBuilder(
      listenable: manager,
      builder: (context, _) {
        // Read the color map from the dataContext
        final effectiveContext = dataContext ?? manager.dataContext;
        final colorMap = (effectiveContext[dataKey] as Map?)
                ?.cast<DateTime, String>() ??
            <DateTime, String>{};
            print("WRAPPER: Reading dataKey '$dataKey'. Found color map with ${colorMap.length} items.");

        return VgotecCalendar(
          // Pass all style props
          width: width,
          cellHeight: cellHeight,
          selectedColor: selectedColor,
          todayColor: todayColor,
          headerAlignment: headerAlignment,
          calendarAlignment: calendarAlignment,
          headerTextStyle: headerTextStyle,
          startWeekOnMonday: startWeekOnMonday,
          
          // Pass the color map
          colorMap: colorMap,

          onDateSelected: (date) {
            // 1. Set the field value (this is good)
            manager.setFieldValue(fieldKey, date.toIso8601String());

            // 2. Read the action config from the top-level 'field'
            final Map<String, dynamic>? actionConfig =
                field['action'] as Map<String, dynamic>?;

            // 3. Get the action type and endpoint from the JSON
            final String actionType =
                actionConfig?['type'] ?? 'print_date'; // Default to 'print_date'
            final String? actionEndpoint =
                actionConfig?['endpoint'] as String?;
                final String? target = actionConfig?['navigationTarget'] as String?;

            // 4. Trigger the action with the *correct* payload
            manager.triggerAction({
              'type': actionType, // This will now be 'navigateTo'
              'payload': {
                'selectedDate': date.toIso8601String(),
                'endpoint': actionEndpoint ,// This now passes the endpoint
                'navigationTarget': target
              },
            });
          },

          onMonthChanged: (date) { // ⭐️ FIX 1: The parameter is 'date'
            // Dispatch action for parent (CalendarFormScreen) to hear
            manager.triggerAction({
              'type': 'monthChanged',
              // Use the 'date' variable from the callback
              'payload': {'newMonth': date.toIso8601String()}, 
            });
          },
        );
      },
    );
  }
}