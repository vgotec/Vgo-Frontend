// lib/presentation/widgets/dynamic_form/wrappers/time_wrapper.dart

import 'package:flutter/material.dart';
import 'package:dynamic_form_kit/src/manager/form_state_manager.dart';
import 'package:dynamic_form_kit/src/utils/style_parser.dart';
import 'package:dynamic_form_kit/src/widget_collection/vgotec_time_picker.dart';

class TimeWrapper extends StatefulWidget {
  final Map<String, dynamic> field;
  final FormStateManager manager;

  const TimeWrapper({
    Key? key,
    required this.field,
    required this.manager,
  }) : super(key: key);

  @override
  State<TimeWrapper> createState() => _TimeWrapperState();
}

class _TimeWrapperState extends State<TimeWrapper> {
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    final key = widget.field['key'] as String;

    // Get initial value from manager if available
    final value = widget.manager.getValue(key);
    if (value is TimeOfDay) {
      _selectedTime = value;
    } else if (value is String && value.isNotEmpty) {
      // Optional: parse string like "14:30"
      final parts = value.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String key = widget.field['key'] ?? '';
    final String label = widget.field['label'] ?? '';
    final config = widget.field['config'] as Map<String, dynamic>? ?? {};
    final style = config['style'] as Map<String, dynamic>? ?? {};
    final behavior = config['behavior'] as Map<String, dynamic>? ?? {};

    final Color labelColor =
        StyleParser.parseColor(style['labelColor'], Colors.grey.shade700);
    final Color borderColor =
        StyleParser.parseColor(style['borderColor'], Colors.grey.shade400);
    final bool use24HourFormat = behavior['use24HourFormat'] ?? true;

    return VgotecTimePicker(
      label: label,
      value: _selectedTime,
      use24HourFormat: use24HourFormat,
      labelColor: labelColor,
      borderColor: borderColor,
      onChanged: (newTime) {
        setState(() => _selectedTime = newTime);
        widget.manager.setFieldValue(key, newTime);
      },
    );
  }
}
