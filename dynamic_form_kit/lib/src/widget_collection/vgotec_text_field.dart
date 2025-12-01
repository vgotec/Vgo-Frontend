import 'package:flutter/material.dart';

class VgotecTextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final bool isRequired;
  final int maxLines;
  final Color labelColor;
  final Color borderColor;
  final Color backgroundColor;
  final double fontSize;
  final FontWeight fontWeight;
  final double borderRadius;
  final double contentPadding;

  final List<Map<String, String>>? options;
  final bool hidden;

  /// ⭐ NEW: readOnly support
  final bool readOnly;

  const VgotecTextField({
    Key? key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.isRequired = false,
    this.maxLines = 1,
    this.labelColor = Colors.black,
    this.borderColor = Colors.grey,
    this.backgroundColor = Colors.transparent,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.normal,
    this.borderRadius = 8.0,
    this.contentPadding = 16.0,
    this.options,
    this.hidden = false,
    this.readOnly = false, // ⭐ default
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hidden) return const SizedBox.shrink();

    // -------------------------------------------------------------------
    // ⭐ CASE 1: Dropdown mode
    // -------------------------------------------------------------------
    if (options != null && options!.isNotEmpty) {
      return AbsorbPointer(
        absorbing: readOnly,
        child: Opacity(
          opacity: readOnly ? 0.6 : 1.0,
          child: DropdownButtonFormField<String>(
            value: controller.text.isEmpty ? null : controller.text,
            decoration: InputDecoration(
              labelText: label + (isRequired ? ' *' : ''),
              labelStyle: TextStyle(color: labelColor),
              filled: true,
              fillColor: readOnly ? Colors.grey.shade200 : backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: borderColor),
              ),
            ),
            items: options!.map((opt) {
              return DropdownMenuItem<String>(
                value: opt['value'] ?? '',
                child: Text(opt['label'] ?? ''),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) controller.text = val;
            },
          ),
        ),
      );
    }

    // -------------------------------------------------------------------
    // ⭐ CASE 2: Normal TextField mode with read-only support
    // -------------------------------------------------------------------
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly, // ⭐ IMPORTANT
        maxLines: maxLines,
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
        decoration: InputDecoration(
          labelText: label + (isRequired ? ' *' : ''),
          labelStyle: TextStyle(color: labelColor),
          hintText: placeholder,
          filled: true,
          fillColor: readOnly ? Colors.grey.shade200 : backgroundColor,
          contentPadding: EdgeInsets.all(contentPadding),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: readOnly
                  ? borderColor
                  : Theme.of(context).primaryColor,
              width: readOnly ? 1.0 : 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
