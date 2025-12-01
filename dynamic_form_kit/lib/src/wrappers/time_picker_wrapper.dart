import 'package:flutter/material.dart';
import 'package:dynamic_form_kit/src/manager/form_state_manager.dart';
import 'package:dynamic_form_kit/src/utils/style_parser.dart';
import 'package:dynamic_form_kit/src/widget_collection/vgotec_time_picker.dart';

class TimePickerWrapper extends StatefulWidget {
  final Map<String, dynamic> field;
  final FormStateManager manager;

  const TimePickerWrapper({
    Key? key,
    required this.field,
    required this.manager,
  }) : super(key: key);

  @override
  State<TimePickerWrapper> createState() => _TimePickerWrapperState();
}

class _TimePickerWrapperState extends State<TimePickerWrapper> {
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    final fieldKey = widget.field['key'] ?? 'time_field';
    final label = widget.field['label'] ?? 'Time';
    final config = widget.field['config'] as Map<String, dynamic>? ?? {};
    final style = config['style'] as Map<String, dynamic>? ?? {};

    final bool use24HourFormat =
        (style['use24HourFormat']?.toString().toLowerCase() == 'true');

    final Color labelColor = StyleParser.parseColor(style['labelColor'], Colors.black);
    final Color borderColor = StyleParser.parseColor(style['borderColor'], Colors.grey);

    // Load saved value (if any)
    final saved = widget.manager.getValue(fieldKey);
    if (saved != null && _selectedTime == null) {
      final parts = saved.split(":");
      if (parts.length >= 2) {
        _selectedTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    return VgotecTimePicker(
      label: label,
      value: _selectedTime,
      use24HourFormat: use24HourFormat,
      labelColor: labelColor,
      borderColor: borderColor,
      onChanged: (picked) {
        if (picked == null) return;
        setState(() => _selectedTime = picked);
        final formatted = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
        widget.manager.setFieldValue(fieldKey, formatted);
      },
    );
  }
}
