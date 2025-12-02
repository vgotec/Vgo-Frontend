import 'package:flutter/material.dart';
import 'package:dynamic_form_kit/src/manager/form_state_manager.dart';
import 'package:dynamic_form_kit/src/utils/style_parser.dart';
import 'package:dynamic_form_kit/src/widget_collection/vgotec_hours_display.dart';

class HoursLabelWrapper extends StatefulWidget {
  final Map<String, dynamic> field;
  final FormStateManager manager;

  const HoursLabelWrapper({
    Key? key,
    required this.field,
    required this.manager,
  }) : super(key: key);

  @override
  State<HoursLabelWrapper> createState() => _HoursLabelWrapperState();
}

class _HoursLabelWrapperState extends State<HoursLabelWrapper> {
  String _hoursValue = "0.00";

  @override
  void initState() {
    super.initState();
    widget.manager.addListener(_updateHours);
    // Call initial calculation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHours());
  }

  @override
  void dispose() {
    widget.manager.removeListener(_updateHours);
    super.dispose();
  }

  void _updateHours() {
    // 1. Get the key (e.g., "workHours" from your JSON)
    final String durationKey = widget.field['key'] ?? 'workHours';

    double calculatedHours = 0.0;
    
    try {
      // 2. Get dependent values
      final startTimeStr = widget.manager.getValue('startTime');
      final endTimeStr = widget.manager.getValue('endTime');

      if (startTimeStr != null && endTimeStr != null) {
        // 3. Parse time strings
        final partsS = startTimeStr.toString().split(':');
        final partsE = endTimeStr.toString().split(':');
        
        final todS = TimeOfDay(hour: int.parse(partsS[0]), minute: int.parse(partsS[1]));
        final todE = TimeOfDay(hour: int.parse(partsE[0]), minute: int.parse(partsE[1]));

        // 4. Calculate duration
        final double startMinutes = todS.hour * 60.0 + todS.minute;
        final double endMinutes = todE.hour * 60.0 + todE.minute;
        
        double durationInMinutes = endMinutes - startMinutes;
        
        if (durationInMinutes < 0) { // Handle overnight
           durationInMinutes += 24 * 60;
        }
        
        calculatedHours = durationInMinutes / 60.0; // This is the long double
      }
    } catch (e) {
      debugPrint("HoursLabelWrapper: Error parsing time ($e)");
      calculatedHours = 0.0;
    }

    // ----------------------------------------------------
    // ⬇️ ⬇️  NEW FIX: ROUND THE VALUE  ⬇️ ⬇️
    // ----------------------------------------------------
    // 5. Round the value to 2 decimal places
    // (e.g., 23.1333... -> 2313.33... -> 2313 -> 23.13)
    final double roundedHours = (calculatedHours * 100).round() / 100.0;
    
    // 6. Update the UI state using the rounded value
    final String hoursString = roundedHours.toStringAsFixed(2);
    if (mounted && _hoursValue != hoursString) {
      setState(() {
        _hoursValue = hoursString;
      });
    }

    // 7. Get the *currently saved* value from the manager
    final dynamic currentlySavedValue = widget.manager.getValue(durationKey);

    // Only call setFieldValue if the new *rounded* value is different
    if (currentlySavedValue != roundedHours) {
      // Save the *rounded* numeric value (double)
      widget.manager.setFieldValue(durationKey, roundedHours);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.field['label'] ?? 'Total Hours';
    final config = widget.field['config'] as Map<String, dynamic>? ?? {};
    final style = config['style'] as Map<String, dynamic>? ?? {};

    final Color labelColor =
        StyleParser.parseColor(style['labelColor'], Colors.grey.shade700);
    final Color valueColor =
        StyleParser.parseColor(style['valueColor'], Colors.black87);
    final double fontSize = StyleParser.parseDouble(style['fontSize'], 16.0);

    return VgotecHoursLabel(
      label: label,
      value: _hoursValue, // This will now update correctly
      labelColor: labelColor,
      valueColor: valueColor,
      fontSize: fontSize,
    );
  }
}