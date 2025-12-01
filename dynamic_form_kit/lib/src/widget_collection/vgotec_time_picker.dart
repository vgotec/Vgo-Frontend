import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VgotecTimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay? value;
  final bool use24HourFormat;
  final ValueChanged<TimeOfDay?> onChanged;
  final Color labelColor;
  final Color borderColor;

  const VgotecTimePicker({
    Key? key,
    required this.label,
    this.value,
    this.use24HourFormat = true,
    required this.onChanged,
    this.labelColor = Colors.black,
    this.borderColor = Colors.grey,
  }) : super(key: key);

  String _formatTime(TimeOfDay? time) {
    if (time == null) return "Select Time";

    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = use24HourFormat ? DateFormat.Hm() : DateFormat.jm();
    return format.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: value ?? TimeOfDay.now(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: use24HourFormat),
              child: child!,
            );
          },
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: labelColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: borderColor),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(
          _formatTime(value),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
