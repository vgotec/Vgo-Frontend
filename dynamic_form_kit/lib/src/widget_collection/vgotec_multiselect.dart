// lib/presentation/widgets/widget_collection/vgotec_multiselect.dart

import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class VgotecMultiSelect extends StatelessWidget {
  final String label;
  final String placeholder;
  final String dialogTitle;
  final String searchHint;
  final List<MultiSelectItem<String>> items;
  final List<String> initialValue;
  final bool searchable;
  final Color chipBackgroundColor;
  final Color chipTextColor;
  final Color borderColor;
  final Function(List<String>) onConfirm;

  const VgotecMultiSelect({
    Key? key,
    required this.label,
    required this.placeholder,
    required this.dialogTitle,
    required this.searchHint,
    required this.items,
    required this.initialValue,
    this.searchable = false,
    required this.chipBackgroundColor,
    required this.chipTextColor,
    required this.borderColor,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiSelectDialogField<String>(
      buttonText: Text(label),
      // buttonHint: Text(placeholder),
      title: Text(dialogTitle),
      searchHint: searchHint,
      items: items,
      initialValue: initialValue,
      searchable: searchable,
      chipDisplay: MultiSelectChipDisplay(
        chipColor: chipBackgroundColor,
        textStyle: TextStyle(color: chipTextColor),
      ),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1.0),
        borderRadius: BorderRadius.circular(4.0),
      ),
      onConfirm: onConfirm,
    );
  }
}