// lib/presentation/widgets/widget_collection/vgotec_date_picker.dart

import 'package:flutter/material.dart';

class VgotecDatePicker extends StatelessWidget {
  final String label;
  final String placeholder;
  final String? value;
  final bool isRequired;
  final Color labelColor;
  final Color iconColor;
  final VoidCallback? onTap;   // ← now nullable
  final bool readOnly;         // ← NEW

  const VgotecDatePicker({
    Key? key,
    required this.label,
    required this.placeholder,
    this.value,
    this.isRequired = false,
    this.labelColor = Colors.black,
    this.iconColor = Colors.blue,
    required this.onTap,
    this.readOnly = false,     // ← NEW
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = readOnly;

    return InkWell(
      onTap: isDisabled ? null : onTap,    // ← No tap when readOnly
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label + (isRequired ? ' *' : ''),
          labelStyle: TextStyle(
            color: isDisabled ? Colors.grey : labelColor,
          ),
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? placeholder,
              style: TextStyle(
                color: isDisabled
                    ? Colors.grey
                    : (value == null ? Colors.grey.shade600 : Colors.black),
                fontSize: 16,
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: isDisabled ? Colors.grey : iconColor,
            ),
          ],
        ),
      ),
    );
  }
}
