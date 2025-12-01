// lib/presentation/widgets/widget_collection/vgotec_dropdown.dart

import 'package:flutter/material.dart';

class VgotecDropdown extends StatelessWidget {
  final String label;
  final String placeholder;
  final String? value;
  final List<Map<String, String>> items;
  final Function(String?)? onChanged; // ← now nullable
  final Color labelColor;
  final bool readOnly;                // ← NEW

  const VgotecDropdown({
    Key? key,
    required this.label,
    required this.placeholder,
    this.value,
    required this.items,
    required this.onChanged,
    this.labelColor = Colors.black,
    this.readOnly = false,            // ← NEW
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = readOnly;

    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(
        placeholder,
        style: TextStyle(color: isDisabled ? Colors.grey : Colors.black54),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDisabled ? Colors.grey : labelColor,
        ),
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          enabled: !isDisabled,
          child: Text(
            item['label']!,
            style: TextStyle(
              color: isDisabled ? Colors.grey : Colors.black,
            ),
          ),
        );
      }).toList(),
      onChanged: isDisabled ? null : onChanged,     // ← disable interaction
      disabledHint: Text(
        value ?? placeholder,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
